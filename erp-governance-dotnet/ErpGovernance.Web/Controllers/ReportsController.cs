using ErpGovernance.Application.DTOs;
using ErpGovernance.Application.Interfaces;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Web.Controllers;

[Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Reports.View)]
public class ReportsController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IProjectScopeService _scope;

    public ReportsController(ApplicationDbContext db, IProjectScopeService scope)
    {
        _db = db;
        _scope = scope;
    }

    public IActionResult Index()
    {
        return View();
    }

    public async Task<IActionResult> Progress(int? orgId, int? projectId)
    {
        var accessibleIds = await _scope.GetAccessibleProjectIdsAsync();
        
        var query = _db.Checklists
            .Include(c => c.SubModule).ThenInclude(sm => sm.SubModuleGroup).ThenInclude(smg => smg.Module).ThenInclude(m => m.Project)
            .AsQueryable();

        if (accessibleIds != null)
            query = query.Where(c => accessibleIds.Contains(c.SubModule.SubModuleGroup.Module.ProjectId));

        if (orgId.HasValue)
            query = query.Where(c => c.SubModule.SubModuleGroup.Module.OrganizationId == orgId.Value);

        if (projectId.HasValue)
            query = query.Where(c => c.SubModule.SubModuleGroup.Module.ProjectId == projectId.Value);

        var data = await query.Select(c => new ProgressReportDto
        {
            ProjectName = c.SubModule.SubModuleGroup.Module.Project.Name,
            ModuleName = c.SubModule.SubModuleGroup.Module.Name,
            SubModuleGroupName = c.SubModule.SubModuleGroup.Name,
            SubModuleName = c.SubModule.Name,
            ChecklistName = c.Name,
            Status = c.Status,
            Priority = c.Priority,
            ProgressPercentage = c.ProgressPercentage,
            ExpectedStartDate = c.ExpectedStartDate,
            ExpectedEndDate = c.ExpectedEndDate
        }).ToListAsync();

        await PopulateFilters();
        return View(data);
    }

    public async Task<IActionResult> Delayed(int? orgId, int? projectId)
    {
        var accessibleIds = await _scope.GetAccessibleProjectIdsAsync();
        
        // 1. Query Checklists
        var checklistQuery = _db.Checklists
            .Include(c => c.SubModule).ThenInclude(sm => sm.SubModuleGroup).ThenInclude(g => g.Module).ThenInclude(m => m.Project)
            .Where(c => c.Status == Domain.Enums.ItemStatus.Delayed || (c.Status != Domain.Enums.ItemStatus.Completed && c.ExpectedEndDate.HasValue && c.ExpectedEndDate.Value < DateOnly.FromDateTime(DateTime.Today)))
            .AsQueryable();

        if (accessibleIds != null)
            checklistQuery = checklistQuery.Where(c => accessibleIds.Contains(c.SubModule.SubModuleGroup.Module.ProjectId));

        if (orgId.HasValue)
            checklistQuery = checklistQuery.Where(c => c.SubModule.SubModuleGroup.Module.OrganizationId == orgId.Value);

        if (projectId.HasValue)
            checklistQuery = checklistQuery.Where(c => c.SubModule.SubModuleGroup.Module.ProjectId == projectId.Value);

        var delayedChecklists = await checklistQuery.Select(c => new DelayedItemDto
        {
            EntityType = "Checklist",
            EntityName = c.Name,
            HierarchyPath = $"{c.SubModule.SubModuleGroup.Module.Project.Name} > {c.SubModule.SubModuleGroup.Name} > {c.SubModule.Name}",
            Status = c.Status,
            ExpectedEndDate = c.ExpectedEndDate,
            DaysDelayed = c.ExpectedEndDate.HasValue ? (DateOnly.FromDateTime(DateTime.Today).DayNumber - c.ExpectedEndDate.Value.DayNumber) : 0
        }).ToListAsync();

        // 2. Query Activities
        var activityQuery = _db.Activities
            .Include(a => a.Checklist).ThenInclude(c => c.SubModule).ThenInclude(sm => sm.SubModuleGroup).ThenInclude(g => g.Module).ThenInclude(m => m.Project)
            .Where(a => a.Status == Domain.Enums.ItemStatus.Delayed || (a.Status != Domain.Enums.ItemStatus.Completed && a.ExpectedEndDate.HasValue && a.ExpectedEndDate.Value < DateOnly.FromDateTime(DateTime.Today)))
            .AsQueryable();

        if (accessibleIds != null)
            activityQuery = activityQuery.Where(a => accessibleIds.Contains(a.Checklist.SubModule.SubModuleGroup.Module.ProjectId));

        if (orgId.HasValue)
            activityQuery = activityQuery.Where(a => a.Checklist.SubModule.SubModuleGroup.Module.OrganizationId == orgId.Value);

        if (projectId.HasValue)
            activityQuery = activityQuery.Where(a => a.Checklist.SubModule.SubModuleGroup.Module.ProjectId == projectId.Value);

        var delayedActivities = await activityQuery.Select(a => new DelayedItemDto
        {
            EntityType = "Activity",
            EntityName = a.Title,
            HierarchyPath = $"{a.Checklist.SubModule.SubModuleGroup.Module.Project.Name} > {a.Checklist.Name}",
            Status = a.Status,
            ExpectedEndDate = a.ExpectedEndDate,
            DaysDelayed = a.ExpectedEndDate.HasValue ? (DateOnly.FromDateTime(DateTime.Today).DayNumber - a.ExpectedEndDate.Value.DayNumber) : 0
        }).ToListAsync();

        // 3. Combine and order
        var data = delayedChecklists.Concat(delayedActivities)
            .OrderByDescending(d => d.DaysDelayed)
            .ToList();

        await PopulateFilters();
        return View(data);
    }

    public async Task<IActionResult> Pending(int? orgId, int? projectId)
    {
        var accessibleIds = await _scope.GetAccessibleProjectIdsAsync();
        var query = _db.Activities
            .Include(a => a.Checklist).ThenInclude(c => c.SubModule).ThenInclude(sm => sm.SubModuleGroup).ThenInclude(g => g.Module).ThenInclude(m => m.Project)
            .Include(a => a.AssignedUser)
            .Where(a => a.Status == Domain.Enums.ItemStatus.PendingErp || a.Status == Domain.Enums.ItemStatus.PendingUniversity)
            .AsQueryable();

        if (accessibleIds != null)
            query = query.Where(a => accessibleIds.Contains(a.Checklist.SubModule.SubModuleGroup.Module.ProjectId));

        if (orgId.HasValue)
            query = query.Where(a => a.Checklist.SubModule.SubModuleGroup.Module.OrganizationId == orgId.Value);

        if (projectId.HasValue)
            query = query.Where(a => a.Checklist.SubModule.SubModuleGroup.Module.ProjectId == projectId.Value);

        var data = await query.Select(a => new PendingItemDto
        {
            EntityType = "Activity",
            EntityName = a.Title,
            HierarchyPath = $"{a.Checklist.SubModule.SubModuleGroup.Module.Project.Name} > {a.Checklist.Name}",
            Status = a.Status,
            ExpectedEndDate = a.ExpectedEndDate,
            AssignedTo = a.AssignedUser != null ? a.AssignedUser.FullName : (a.ResponsibleTeam ?? "Unassigned")
        }).ToListAsync();

        await PopulateFilters();
        return View(data);
    }

    public async Task<IActionResult> Responsibility(int? orgId, int? projectId)
    {
        var accessibleIds = await _scope.GetAccessibleProjectIdsAsync();
        var query = _db.Activities
            .Include(a => a.Checklist).ThenInclude(c => c.SubModule).ThenInclude(sm => sm.SubModuleGroup).ThenInclude(g => g.Module).ThenInclude(m => m.Project)
            .Include(a => a.AssignedUser)
            .Where(a => a.Status != Domain.Enums.ItemStatus.Completed)
            .AsQueryable();

        if (accessibleIds != null)
            query = query.Where(a => accessibleIds.Contains(a.Checklist.SubModule.SubModuleGroup.Module.ProjectId));

        if (orgId.HasValue)
            query = query.Where(a => a.Checklist.SubModule.SubModuleGroup.Module.OrganizationId == orgId.Value);

        if (projectId.HasValue)
            query = query.Where(a => a.Checklist.SubModule.SubModuleGroup.Module.ProjectId == projectId.Value);

        var data = await query.Select(a => new ResponsibilityItemDto
        {
            AssignedUserName = a.AssignedUser != null ? a.AssignedUser.FullName : (a.ResponsibleTeam ?? "Unassigned"),
            EntityType = "Activity",
            EntityName = a.Title,
            Status = a.Status,
            Priority = a.Priority,
            ExpectedEndDate = a.ExpectedEndDate
        }).ToListAsync();

        await PopulateFilters();
        return View(data);
    }
    private async Task PopulateFilters()
    {
        var accessibleIds = await _scope.GetAccessibleProjectIdsAsync();
        var orgs = await _db.Organizations.Where(o => o.IsActive).ToListAsync();
        ViewBag.Orgs = orgs.Select(o => new SelectListItem { Value = o.Id.ToString(), Text = o.Name }).ToList();
        
        var projs = await _db.Projects.Where(p => accessibleIds == null || accessibleIds.Contains(p.Id)).ToListAsync();
        ViewBag.Projects = projs.Select(p => new SelectListItem { Value = p.Id.ToString(), Text = p.Name }).ToList();
    }
}
