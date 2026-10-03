using ErpGovernance.Application.DTOs;
using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Entities;
using ErpGovernance.Infrastructure.Data;
using ErpGovernance.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Web.Controllers;

[Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Activities.View)]
public class ActivitiesController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IProgressRollupService _progress;
    private readonly IAuditService _audit;
    private readonly ICurrentUserService _currentUser;
    private readonly INotificationService _notifications;

    public ActivitiesController(ApplicationDbContext db, IProgressRollupService progress, IAuditService audit, ICurrentUserService currentUser, INotificationService notifications)
    {
        _db = db;
        _progress = progress;
        _audit = audit;
        _currentUser = currentUser;
        _notifications = notifications;
    }

    public async Task<IActionResult> Index(int checklistId)
    {
        var activities = await _db.Activities
            .Include(a => a.AssignedUser)
            .Where(a => a.ChecklistId == checklistId)
            .Select(a => new ActivityListDto
            {
                Id = a.Id,
                ChecklistId = a.ChecklistId,
                Title = a.Title,
                ActivityType = a.ActivityType,
                AssignedUserName = a.AssignedUser != null ? a.AssignedUser.FullName : null,
                Status = a.Status,
                Priority = a.Priority,
                ActualStartDateTime = a.ActualStartDateTime,
                ActualEndDateTime = a.ActualEndDateTime,
                ProgressPercentage = a.ProgressPercentage,
                CreatedAt = a.CreatedAt
            }).ToListAsync();

        var legacyLogs = await _db.CommunicationLogs
            .Include(c => c.LoggedBy)
            .Where(c => c.ChecklistId == checklistId && c.ActivityId == null)
            .OrderByDescending(c => c.CommunicationDate)
            .ToListAsync();

        ViewBag.ChecklistId = checklistId;
        ViewBag.LegacyLogs = legacyLogs;
        return View(activities);
    }

    public async Task<IActionResult> Create(int checklistId, int? migrateCommunicationId)
    {
        await PopulateDropdowns();
        var dto = new ActivityFormDto { ChecklistId = checklistId };
        if (migrateCommunicationId.HasValue && migrateCommunicationId.Value > 0)
        {
            var comm = await _db.CommunicationLogs.FindAsync(migrateCommunicationId.Value);
            if (comm != null)
            {
                dto.Title = comm.Subject ?? comm.Summary ?? "Migrated Communication";
                dto.Description = comm.Summary + (string.IsNullOrEmpty(comm.MomContent) ? "" : $"\n\nMOM Content:\n{comm.MomContent}");
                
                dto.ActivityType = comm.CommunicationType?.ToLower() switch
                {
                    "email" => ErpGovernance.Domain.Enums.ActivityType.Email,
                    "call" or "phone call" => ErpGovernance.Domain.Enums.ActivityType.Call,
                    "meeting" or "online meeting" or "physical meeting" or "discussion" => ErpGovernance.Domain.Enums.ActivityType.Meeting,
                    _ => ErpGovernance.Domain.Enums.ActivityType.Task
                };
                dto.Participants = comm.Participants;
                dto.ActualStartDateTime = comm.ActualStartDateTime ?? comm.CommunicationDate;
                dto.ActualEndDateTime = comm.ActualEndDateTime;
                dto.MigrateCommunicationId = comm.Id;
            }
        }
        return View("Form", dto);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(ActivityFormDto dto)
    {
        if (!ModelState.IsValid)
        {
            await PopulateDropdowns();
            return View("Form", dto);
        }

        var activity = new Activity
        {
            ChecklistId = dto.ChecklistId,
            Title = dto.Title,
            Description = dto.Description,
            ActivityType = dto.ActivityType,
            ResponsibleTeam = dto.ResponsibleTeam,
            AssignedUserId = dto.AssignedUserId,
            Participants = dto.Participants,
            MeetingNotes = dto.MeetingNotes,
            NextFollowupDate = dto.NextFollowupDate,
            EscalationStatus = dto.EscalationStatus,
            Outcome = dto.Outcome,
            ActualStartDateTime = dto.ActualStartDateTime,
            ActualEndDateTime = dto.ActualEndDateTime,
            Status = dto.Status,
            Priority = dto.Priority,
            ProgressPercentage = dto.ProgressPercentage,
            Remarks = dto.Remarks,
            CreatedById = _currentUser.UserId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            MigrateCommunicationId = dto.MigrateCommunicationId
        };

        _db.Activities.Add(activity);
        await _db.SaveChangesAsync();

        if (dto.MigrateCommunicationId.HasValue && dto.MigrateCommunicationId.Value > 0)
        {
            var comm = await _db.CommunicationLogs.FindAsync(dto.MigrateCommunicationId.Value);
            if (comm != null)
            {
                _db.CommunicationLogs.Remove(comm);
                await _db.SaveChangesAsync();
            }
        }

        await _progress.RecalcFromChecklistAsync(activity.ChecklistId, _db);
        await _audit.LogAsync("create", "Activity", activity.Id, $"Created activity: {activity.Title}");

        // Notify assigned user if different from current user
        if (activity.AssignedUserId.HasValue && activity.AssignedUserId != _currentUser.UserId)
            await _notifications.SendAsync(activity.AssignedUserId.Value, "New Activity Assigned",
                $"You have been assigned to: {activity.Title}", "info", "Activity", activity.Id);

        TempData["Success"] = "Activity created successfully.";
        return RedirectToAction(nameof(Index), new { checklistId = activity.ChecklistId });
    }
    public async Task<IActionResult> Detail(int id)
    {
        var activity = await _db.Activities
            .Include(a => a.AssignedUser)
            .Include(a => a.CreatedBy)
            .Include(a => a.CommunicationLogs).ThenInclude(c => c.LoggedBy)
            .Include(a => a.Checklist).ThenInclude(c => c.SubModule).ThenInclude(sm => sm.SubModuleGroup).ThenInclude(g => g.Module).ThenInclude(m => m.Project)
            .FirstOrDefaultAsync(a => a.Id == id);
            
        if (activity == null) return NotFound();
        return View(activity);
    }

    public async Task<IActionResult> Edit(int id)
    {
        var activity = await _db.Activities.FindAsync(id);
        if (activity == null) return NotFound();

        if (!CanEditActivity(activity)) return Forbid();

        await PopulateDropdowns();
        return View("Form", new ActivityFormDto
        {
            Id = activity.Id,
            ChecklistId = activity.ChecklistId,
            Title = activity.Title,
            Description = activity.Description,
            ActivityType = activity.ActivityType,
            ResponsibleTeam = activity.ResponsibleTeam,
            AssignedUserId = activity.AssignedUserId,
            Participants = activity.Participants,
            MeetingNotes = activity.MeetingNotes,
            NextFollowupDate = activity.NextFollowupDate,
            EscalationStatus = activity.EscalationStatus,
            Outcome = activity.Outcome,
            ActualStartDateTime = activity.ActualStartDateTime,
            ActualEndDateTime = activity.ActualEndDateTime,
            Status = activity.Status,
            Priority = activity.Priority,
            ProgressPercentage = activity.ProgressPercentage,
            Remarks = activity.Remarks
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, ActivityFormDto dto)
    {
        if (id != dto.Id) return BadRequest();

        if (!ModelState.IsValid)
        {
            await PopulateDropdowns();
            return View("Form", dto);
        }

        var activity = await _db.Activities.FindAsync(id);
        if (activity == null) return NotFound();

        if (!CanEditActivity(activity)) return Forbid();

        var oldStatus = activity.Status.ToString();

        activity.Title = dto.Title;
        activity.Description = dto.Description;
        activity.ActivityType = dto.ActivityType;
        activity.ResponsibleTeam = dto.ResponsibleTeam;
        activity.AssignedUserId = dto.AssignedUserId;
        activity.Participants = dto.Participants;
        activity.MeetingNotes = dto.MeetingNotes;
        activity.NextFollowupDate = dto.NextFollowupDate;
        activity.EscalationStatus = dto.EscalationStatus;
        activity.Outcome = dto.Outcome;
        activity.ActualStartDateTime = dto.ActualStartDateTime;
        activity.ActualEndDateTime = dto.ActualEndDateTime;
        activity.Status = dto.Status;
        activity.Priority = dto.Priority;
        activity.ProgressPercentage = dto.ProgressPercentage;
        activity.Remarks = dto.Remarks;
        activity.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
        await _progress.RecalcFromChecklistAsync(activity.ChecklistId, _db);

        if (oldStatus != dto.Status.ToString())
        {
            await _audit.LogStatusChangeAsync("Activity", activity.Id, oldStatus, dto.Status.ToString(), "Status changed via edit");
            // Notify assigning PM/Admin of status change
            if (activity.AssignedUserId.HasValue && activity.AssignedUserId != _currentUser.UserId)
                await _notifications.SendAsync(activity.AssignedUserId.Value, "Activity Status Changed",
                    $"{activity.Title} changed from {oldStatus} to {dto.Status}", "info", "Activity", activity.Id);
        }
            
        await _audit.LogAsync("update", "Activity", activity.Id, $"Updated activity: {activity.Title}");
        
        TempData["Success"] = "Activity updated successfully.";
        return RedirectToAction(nameof(Index), new { checklistId = activity.ChecklistId });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id)
    {
        var activity = await _db.Activities.FindAsync(id);
        if (activity == null) return NotFound();

        if (!CanEditActivity(activity)) return Forbid();

        var checklistId = activity.ChecklistId;
        _db.Activities.Remove(activity);
        await _db.SaveChangesAsync();

        await _progress.RecalcFromChecklistAsync(checklistId, _db);
        await _audit.LogAsync("delete", "Activity", id, $"Deleted activity: {activity.Title}");

        TempData["Success"] = "Activity deleted successfully.";
        return RedirectToAction(nameof(Index), new { checklistId = checklistId });
    }

    [HttpGet]
    public async Task<IActionResult> Form(int? id, int? checklistId, int? migrateCommunicationId)
    {
        await PopulateDropdowns();
        if (id.HasValue && id.Value > 0)
        {
            var activity = await _db.Activities.FindAsync(id.Value);
            if (activity == null) return NotFound();
            if (!CanEditActivity(activity)) return Forbid();

            return PartialView("_ActivityModalForm", new ActivityFormDto
            {
                Id = activity.Id,
                ChecklistId = activity.ChecklistId,
                Title = activity.Title,
                Description = activity.Description,
                ActivityType = activity.ActivityType,
                ResponsibleTeam = activity.ResponsibleTeam,
                AssignedUserId = activity.AssignedUserId,
                Participants = activity.Participants,
                MeetingNotes = activity.MeetingNotes,
                NextFollowupDate = activity.NextFollowupDate,
                EscalationStatus = activity.EscalationStatus,
                Outcome = activity.Outcome,
                ActualStartDateTime = activity.ActualStartDateTime,
                ActualEndDateTime = activity.ActualEndDateTime,
                Status = activity.Status,
                Priority = activity.Priority,
                ProgressPercentage = activity.ProgressPercentage,
                Remarks = activity.Remarks
            });
        }
        else
        {
            var dto = new ActivityFormDto { ChecklistId = checklistId ?? 0 };
            if (migrateCommunicationId.HasValue && migrateCommunicationId.Value > 0)
            {
                var comm = await _db.CommunicationLogs.FindAsync(migrateCommunicationId.Value);
                if (comm != null)
                {
                    dto.Title = comm.Subject ?? comm.Summary ?? "Migrated Communication";
                    dto.Description = comm.Summary + (string.IsNullOrEmpty(comm.MomContent) ? "" : $"\n\nMOM Content:\n{comm.MomContent}");
                    
                    dto.ActivityType = comm.CommunicationType?.ToLower() switch
                    {
                        "email" => ErpGovernance.Domain.Enums.ActivityType.Email,
                        "call" or "phone call" => ErpGovernance.Domain.Enums.ActivityType.Call,
                        "meeting" or "online meeting" or "physical meeting" or "discussion" => ErpGovernance.Domain.Enums.ActivityType.Meeting,
                        _ => ErpGovernance.Domain.Enums.ActivityType.Task
                    };
                    dto.Participants = comm.Participants;
                    dto.ActualStartDateTime = comm.ActualStartDateTime ?? comm.CommunicationDate;
                    dto.ActualEndDateTime = comm.ActualEndDateTime;
                    dto.MigrateCommunicationId = comm.Id;
                }
            }
            return PartialView("_ActivityModalForm", dto);
        }
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Save(ActivityFormDto dto)
    {
        if (!ModelState.IsValid)
        {
            await PopulateDropdowns();
            return PartialView("_ActivityModalForm", dto);
        }

        if (dto.Id > 0)
        {
            var activity = await _db.Activities.FindAsync(dto.Id);
            if (activity == null) return NotFound();
            if (!CanEditActivity(activity)) return Forbid();

            var oldStatus = activity.Status.ToString();

            activity.Title = dto.Title;
            activity.Description = dto.Description;
            activity.ActivityType = dto.ActivityType;
            activity.ResponsibleTeam = dto.ResponsibleTeam;
            activity.AssignedUserId = dto.AssignedUserId;
            activity.Participants = dto.Participants;
            activity.MeetingNotes = dto.MeetingNotes;
            activity.NextFollowupDate = dto.NextFollowupDate;
            activity.EscalationStatus = dto.EscalationStatus;
            activity.Outcome = dto.Outcome;
            activity.ActualStartDateTime = dto.ActualStartDateTime;
            activity.ActualEndDateTime = dto.ActualEndDateTime;
            activity.Status = dto.Status;
            activity.Priority = dto.Priority;
            activity.ProgressPercentage = dto.ProgressPercentage;
            activity.Remarks = dto.Remarks;
            activity.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync();
            await _progress.RecalcFromChecklistAsync(activity.ChecklistId, _db);

            if (oldStatus != dto.Status.ToString())
            {
                await _audit.LogStatusChangeAsync("Activity", activity.Id, oldStatus, dto.Status.ToString(), "Status changed via AJAX edit");
                if (activity.AssignedUserId.HasValue && activity.AssignedUserId != _currentUser.UserId)
                    await _notifications.SendAsync(activity.AssignedUserId.Value, "Activity Status Changed",
                        $"{activity.Title} changed from {oldStatus} to {dto.Status}", "info", "Activity", activity.Id);
            }
            await _audit.LogAsync("update", "Activity", activity.Id, $"Updated activity (AJAX): {activity.Title}");
        }
        else
        {
            // Verify create permissions for the current user (e.g. deny if viewer)
            if (_currentUser.Role == "viewer") return Forbid();

            var activity = new Activity
            {
                ChecklistId = dto.ChecklistId,
                Title = dto.Title,
                Description = dto.Description,
                ActivityType = dto.ActivityType,
                ResponsibleTeam = dto.ResponsibleTeam,
                AssignedUserId = dto.AssignedUserId,
                Participants = dto.Participants,
                MeetingNotes = dto.MeetingNotes,
                NextFollowupDate = dto.NextFollowupDate,
                EscalationStatus = dto.EscalationStatus,
                Outcome = dto.Outcome,
                ActualStartDateTime = dto.ActualStartDateTime,
                ActualEndDateTime = dto.ActualEndDateTime,
                Status = dto.Status,
                Priority = dto.Priority,
                ProgressPercentage = dto.ProgressPercentage,
                Remarks = dto.Remarks,
                CreatedById = _currentUser.UserId,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                MigrateCommunicationId = dto.MigrateCommunicationId
            };

            _db.Activities.Add(activity);
            await _db.SaveChangesAsync();

            if (dto.MigrateCommunicationId.HasValue && dto.MigrateCommunicationId.Value > 0)
            {
                var comm = await _db.CommunicationLogs.FindAsync(dto.MigrateCommunicationId.Value);
                if (comm != null)
                {
                    _db.CommunicationLogs.Remove(comm);
                    await _db.SaveChangesAsync();
                }
            }

            await _progress.RecalcFromChecklistAsync(activity.ChecklistId, _db);
            await _audit.LogAsync("create", "Activity", activity.Id, $"Created activity (AJAX): {activity.Title}");

            if (activity.AssignedUserId.HasValue && activity.AssignedUserId != _currentUser.UserId)
                await _notifications.SendAsync(activity.AssignedUserId.Value, "New Activity Assigned",
                    $"You have been assigned to: {activity.Title}", "info", "Activity", activity.Id);
        }

        return Ok();
    }

    private bool CanEditActivity(Activity activity)
    {
        var role = _currentUser.Role;
        if (role == "super_admin" || role == "project_hod" || role == "project_manager")
        {
            return true;
        }
        if (role == "viewer")
        {
            return false;
        }
        if (role == "erp_team" || role == "university_user")
        {
            return activity.AssignedUserId == _currentUser.UserId;
        }
        if (role == "reviewer")
        {
            return activity.ActivityType == ErpGovernance.Domain.Enums.ActivityType.Approval;
        }
        return false;
    }

    private async Task PopulateDropdowns()
    {
        var users = await _db.Users.Where(u => u.IsActive).ToListAsync();
        ViewBag.Users = users.Select(u => new SelectListItem { Value = u.Id.ToString(), Text = $"{u.FullName} ({u.Email})" }).ToList();
    }
}
