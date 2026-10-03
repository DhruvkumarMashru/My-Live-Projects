using ErpGovernance.Application.DTOs;
using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Entities;
using ErpGovernance.Infrastructure.Data;
using ErpGovernance.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Web.Controllers;

[Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Hierarchy.View)]
public class HierarchyController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IProgressRollupService _progress;
    private readonly IAuditService _audit;
    private readonly ICurrentUserService _currentUser;
    private readonly INotificationService _notifications;

    public HierarchyController(ApplicationDbContext db, IProgressRollupService progress, IAuditService audit, ICurrentUserService currentUser, INotificationService notifications)
    {
        _db = db;
        _progress = progress;
        _audit = audit;
        _currentUser = currentUser;
        _notifications = notifications;
    }

    // ═══════════════════════════════════════════════════════════════════
    // MODULE
    // ═══════════════════════════════════════════════════════════════════

    public async Task<IActionResult> Modules(int projectId)
    {
        var modules = await _db.Modules.Where(m => m.ProjectId == projectId)
            .Select(m => new ModuleListDto
            {
                Id = m.Id, Name = m.Name, ProjectId = m.ProjectId, OrganizationId = m.OrganizationId,
                Status = m.Status, Priority = m.Priority, ProgressPercentage = m.ProgressPercentage,
                SubModuleGroupCount = m.SubModuleGroups.Count, CreatedAt = m.CreatedAt
            }).ToListAsync();
        ViewBag.ProjectId = projectId;
        return View(modules);
    }

    public IActionResult ModuleCreate(int projectId)
    {
        var orgId = _db.Projects.Where(p => p.Id == projectId).Select(p => p.OrganizationId).FirstOrDefault();
        return View("ModuleForm", new ModuleFormDto { ProjectId = projectId, OrganizationId = orgId });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> ModuleCreate(ModuleFormDto dto)
    {
        if (!ModelState.IsValid) return View("ModuleForm", dto);
        var module = new Module
        {
            ProjectId = dto.ProjectId, OrganizationId = dto.OrganizationId, Name = dto.Name,
            Description = dto.Description, Status = dto.Status, Priority = dto.Priority,
            ExpectedStartDate = dto.ExpectedStartDate, ExpectedEndDate = dto.ExpectedEndDate,
            Remarks = dto.Remarks, CreatedById = _currentUser.UserId, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow
        };
        _db.Modules.Add(module);
        await _db.SaveChangesAsync();
        await _progress.RecalcFromModuleAsync(module.Id, _db);
        await _audit.LogAsync("create", "Module", module.Id, $"Created module: {module.Name}");
        TempData["Success"] = "Module created successfully.";
        return RedirectToAction(nameof(Modules), new { projectId = module.ProjectId });
    }

    public async Task<IActionResult> ModuleEdit(int id)
    {
        var m = await _db.Modules.FindAsync(id);
        if (m == null) return NotFound();
        return View("ModuleForm", new ModuleFormDto
        {
            Id = m.Id, Name = m.Name, Description = m.Description, ProjectId = m.ProjectId, OrganizationId = m.OrganizationId,
            Status = m.Status, Priority = m.Priority, ExpectedStartDate = m.ExpectedStartDate, ExpectedEndDate = m.ExpectedEndDate,
            ActualStartDate = m.ActualStartDate, ActualEndDate = m.ActualEndDate,
            ProgressPercentage = m.ProgressPercentage, Remarks = m.Remarks
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> ModuleEdit(int id, ModuleFormDto dto)
    {
        if (!ModelState.IsValid) return View("ModuleForm", dto);
        var m = await _db.Modules.FindAsync(id);
        if (m == null) return NotFound();
        var oldStatus = m.Status.ToString();
        m.Name = dto.Name; m.Description = dto.Description; m.Status = dto.Status; m.Priority = dto.Priority;
        m.ExpectedStartDate = dto.ExpectedStartDate; m.ExpectedEndDate = dto.ExpectedEndDate;
        m.ActualStartDate = dto.ActualStartDate; m.ActualEndDate = dto.ActualEndDate;
        m.Remarks = dto.Remarks; m.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        if (oldStatus != dto.Status.ToString())
            await _audit.LogStatusChangeAsync("Module", m.Id, oldStatus, dto.Status.ToString(), "Status updated via edit");
        await _audit.LogAsync("update", "Module", m.Id, $"Updated module: {m.Name}");
        TempData["Success"] = "Module updated.";
        return RedirectToAction(nameof(Modules), new { projectId = m.ProjectId });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> ModuleDelete(int id)
    {
        var m = await _db.Modules.Include(x => x.SubModuleGroups).FirstOrDefaultAsync(x => x.Id == id);
        if (m == null) return NotFound();
        if (m.SubModuleGroups.Any()) { TempData["Error"] = "Cannot delete module with existing Sub Module Groups. Remove them first."; return RedirectToAction(nameof(Modules), new { projectId = m.ProjectId }); }
        var projectId = m.ProjectId;
        _db.Modules.Remove(m);
        await _db.SaveChangesAsync();
        await _progress.RecalcFromModuleAsync(projectId, _db);
        await _audit.LogAsync("delete", "Module", id, $"Deleted module: {m.Name}");
        TempData["Success"] = "Module deleted.";
        return RedirectToAction(nameof(Modules), new { projectId });
    }

    // ═══════════════════════════════════════════════════════════════════
    // SUB MODULE GROUP
    // ═══════════════════════════════════════════════════════════════════

    public async Task<IActionResult> SubModuleGroups(int moduleId)
    {
        var groups = await _db.SubModuleGroups.Where(s => s.ModuleId == moduleId)
            .Select(s => new SubModuleGroupListDto
            {
                Id = s.Id, Name = s.Name, ModuleId = s.ModuleId, Status = s.Status, Priority = s.Priority,
                ProgressPercentage = s.ProgressPercentage, SubModuleCount = s.SubModules.Count, CreatedAt = s.CreatedAt
            }).ToListAsync();
        ViewBag.ModuleId = moduleId;
        return View(groups);
    }

    public IActionResult SubModuleGroupCreate(int moduleId) => View("SubModuleGroupForm", new SubModuleGroupFormDto { ModuleId = moduleId });

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> SubModuleGroupCreate(SubModuleGroupFormDto dto)
    {
        if (!ModelState.IsValid) return View("SubModuleGroupForm", dto);
        var group = new SubModuleGroup
        {
            ModuleId = dto.ModuleId, Name = dto.Name, Description = dto.Description, Status = dto.Status, Priority = dto.Priority,
            ExpectedStartDate = dto.ExpectedStartDate, ExpectedEndDate = dto.ExpectedEndDate, Remarks = dto.Remarks,
            CreatedById = _currentUser.UserId, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow
        };
        _db.SubModuleGroups.Add(group);
        await _db.SaveChangesAsync();
        await _progress.RecalcFromModuleAsync(group.ModuleId, _db);
        await _audit.LogAsync("create", "SubModuleGroup", group.Id, $"Created sub module group: {group.Name}");
        TempData["Success"] = "Sub Module Group created.";
        return RedirectToAction(nameof(SubModuleGroups), new { moduleId = group.ModuleId });
    }

    public async Task<IActionResult> SubModuleGroupEdit(int id)
    {
        var g = await _db.SubModuleGroups.FindAsync(id);
        if (g == null) return NotFound();
        return View("SubModuleGroupForm", new SubModuleGroupFormDto
        {
            Id = g.Id, Name = g.Name, Description = g.Description, ModuleId = g.ModuleId,
            Status = g.Status, Priority = g.Priority, ExpectedStartDate = g.ExpectedStartDate, ExpectedEndDate = g.ExpectedEndDate,
            ActualStartDate = g.ActualStartDate, ActualEndDate = g.ActualEndDate, ProgressPercentage = g.ProgressPercentage, Remarks = g.Remarks
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> SubModuleGroupEdit(int id, SubModuleGroupFormDto dto)
    {
        if (!ModelState.IsValid) return View("SubModuleGroupForm", dto);
        var g = await _db.SubModuleGroups.FindAsync(id);
        if (g == null) return NotFound();
        var oldStatus = g.Status.ToString();
        g.Name = dto.Name; g.Description = dto.Description; g.Status = dto.Status; g.Priority = dto.Priority;
        g.ExpectedStartDate = dto.ExpectedStartDate; g.ExpectedEndDate = dto.ExpectedEndDate;
        g.ActualStartDate = dto.ActualStartDate; g.ActualEndDate = dto.ActualEndDate;
        g.Remarks = dto.Remarks; g.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        if (oldStatus != dto.Status.ToString())
            await _audit.LogStatusChangeAsync("SubModuleGroup", g.Id, oldStatus, dto.Status.ToString(), "Status updated via edit");
        await _audit.LogAsync("update", "SubModuleGroup", g.Id, $"Updated SMG: {g.Name}");
        TempData["Success"] = "Sub Module Group updated.";
        return RedirectToAction(nameof(SubModuleGroups), new { moduleId = g.ModuleId });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> SubModuleGroupDelete(int id)
    {
        var g = await _db.SubModuleGroups.Include(x => x.SubModules).FirstOrDefaultAsync(x => x.Id == id);
        if (g == null) return NotFound();
        if (g.SubModules.Any()) { TempData["Error"] = "Cannot delete group with existing Sub Modules. Remove them first."; return RedirectToAction(nameof(SubModuleGroups), new { moduleId = g.ModuleId }); }
        var moduleId = g.ModuleId;
        _db.SubModuleGroups.Remove(g);
        await _db.SaveChangesAsync();
        await _progress.RecalcFromModuleAsync(moduleId, _db);
        await _audit.LogAsync("delete", "SubModuleGroup", id, $"Deleted SMG: {g.Name}");
        TempData["Success"] = "Sub Module Group deleted.";
        return RedirectToAction(nameof(SubModuleGroups), new { moduleId });
    }

    // ═══════════════════════════════════════════════════════════════════
    // SUB MODULE
    // ═══════════════════════════════════════════════════════════════════

    public async Task<IActionResult> SubModules(int subModuleGroupId)
    {
        var subs = await _db.SubModules.Where(s => s.SubModuleGroupId == subModuleGroupId)
            .Select(s => new SubModuleListDto
            {
                Id = s.Id, Name = s.Name, SubModuleGroupId = s.SubModuleGroupId, Status = s.Status, Priority = s.Priority,
                ProgressPercentage = s.ProgressPercentage, ChecklistCount = s.Checklists.Count, CreatedAt = s.CreatedAt
            }).ToListAsync();
        ViewBag.SubModuleGroupId = subModuleGroupId;
        return View(subs);
    }

    public IActionResult SubModuleCreate(int subModuleGroupId) => View("SubModuleForm", new SubModuleFormDto { SubModuleGroupId = subModuleGroupId });

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> SubModuleCreate(SubModuleFormDto dto)
    {
        if (!ModelState.IsValid) return View("SubModuleForm", dto);
        var sm = new SubModule
        {
            SubModuleGroupId = dto.SubModuleGroupId, Name = dto.Name, Description = dto.Description,
            Status = dto.Status, Priority = dto.Priority, ExpectedStartDate = dto.ExpectedStartDate, ExpectedEndDate = dto.ExpectedEndDate,
            Remarks = dto.Remarks, CreatedById = _currentUser.UserId, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow
        };
        _db.SubModules.Add(sm);
        await _db.SaveChangesAsync();
        await _audit.LogAsync("create", "SubModule", sm.Id, $"Created sub module: {sm.Name}");
        TempData["Success"] = "Sub Module created.";
        return RedirectToAction(nameof(SubModules), new { subModuleGroupId = sm.SubModuleGroupId });
    }

    public async Task<IActionResult> SubModuleEdit(int id)
    {
        var sm = await _db.SubModules.FindAsync(id);
        if (sm == null) return NotFound();
        return View("SubModuleForm", new SubModuleFormDto
        {
            Id = sm.Id, Name = sm.Name, Description = sm.Description, SubModuleGroupId = sm.SubModuleGroupId,
            Status = sm.Status, Priority = sm.Priority, ExpectedStartDate = sm.ExpectedStartDate, ExpectedEndDate = sm.ExpectedEndDate,
            ActualStartDate = sm.ActualStartDate, ActualEndDate = sm.ActualEndDate, ProgressPercentage = sm.ProgressPercentage, Remarks = sm.Remarks
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> SubModuleEdit(int id, SubModuleFormDto dto)
    {
        if (!ModelState.IsValid) return View("SubModuleForm", dto);
        var sm = await _db.SubModules.FindAsync(id);
        if (sm == null) return NotFound();
        var oldStatus = sm.Status.ToString();
        sm.Name = dto.Name; sm.Description = dto.Description; sm.Status = dto.Status; sm.Priority = dto.Priority;
        sm.ExpectedStartDate = dto.ExpectedStartDate; sm.ExpectedEndDate = dto.ExpectedEndDate;
        sm.ActualStartDate = dto.ActualStartDate; sm.ActualEndDate = dto.ActualEndDate;
        sm.Remarks = dto.Remarks; sm.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        await _progress.RecalcFromChecklistAsync(sm.Id, _db);
        if (oldStatus != dto.Status.ToString())
            await _audit.LogStatusChangeAsync("SubModule", sm.Id, oldStatus, dto.Status.ToString(), "Status updated via edit");
        await _audit.LogAsync("update", "SubModule", sm.Id, $"Updated sub module: {sm.Name}");
        TempData["Success"] = "Sub Module updated.";
        return RedirectToAction(nameof(SubModules), new { subModuleGroupId = sm.SubModuleGroupId });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> SubModuleDelete(int id)
    {
        var sm = await _db.SubModules.Include(x => x.Checklists).FirstOrDefaultAsync(x => x.Id == id);
        if (sm == null) return NotFound();
        if (sm.Checklists.Any()) { TempData["Error"] = "Cannot delete Sub Module with existing Checklists. Remove them first."; return RedirectToAction(nameof(SubModules), new { subModuleGroupId = sm.SubModuleGroupId }); }
        var subModuleGroupId = sm.SubModuleGroupId;
        _db.SubModules.Remove(sm);
        await _db.SaveChangesAsync();
        await _audit.LogAsync("delete", "SubModule", id, $"Deleted sub module: {sm.Name}");
        TempData["Success"] = "Sub Module deleted.";
        return RedirectToAction(nameof(SubModules), new { subModuleGroupId });
    }

    // ═══════════════════════════════════════════════════════════════════
    // CHECKLIST
    // ═══════════════════════════════════════════════════════════════════

    public async Task<IActionResult> Checklists(int subModuleId)
    {
        var lists = await _db.Checklists.Where(c => c.SubModuleId == subModuleId)
            .Select(c => new ChecklistListDto
            {
                Id = c.Id, Name = c.Name, SubModuleId = c.SubModuleId, Status = c.Status, Priority = c.Priority,
                ProgressPercentage = c.ProgressPercentage, ActivityCount = c.Activities.Count, CreatedAt = c.CreatedAt
            }).ToListAsync();
        ViewBag.SubModuleId = subModuleId;
        return View(lists);
    }

    public IActionResult ChecklistCreate(int subModuleId) => View("ChecklistForm", new ChecklistFormDto { SubModuleId = subModuleId });

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> ChecklistCreate(ChecklistFormDto dto)
    {
        if (!ModelState.IsValid) return View("ChecklistForm", dto);
        var cl = new Checklist
        {
            SubModuleId = dto.SubModuleId, Name = dto.Name, Description = dto.Description,
            Status = dto.Status, Priority = dto.Priority, ExpectedStartDate = dto.ExpectedStartDate, ExpectedEndDate = dto.ExpectedEndDate,
            Remarks = dto.Remarks, CreatedById = _currentUser.UserId, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow
        };
        _db.Checklists.Add(cl);
        await _db.SaveChangesAsync();
        await _progress.RecalcFromChecklistAsync(cl.Id, _db);
        await _audit.LogAsync("create", "Checklist", cl.Id, $"Created checklist: {cl.Name}");
        TempData["Success"] = "Checklist created.";
        return RedirectToAction(nameof(Checklists), new { subModuleId = cl.SubModuleId });
    }

    public async Task<IActionResult> ChecklistEdit(int id)
    {
        var cl = await _db.Checklists.FindAsync(id);
        if (cl == null) return NotFound();
        return View("ChecklistForm", new ChecklistFormDto
        {
            Id = cl.Id, Name = cl.Name, Description = cl.Description, SubModuleId = cl.SubModuleId,
            Status = cl.Status, Priority = cl.Priority, ExpectedStartDate = cl.ExpectedStartDate, ExpectedEndDate = cl.ExpectedEndDate,
            ActualStartDate = cl.ActualStartDate, ActualEndDate = cl.ActualEndDate, ProgressPercentage = cl.ProgressPercentage, Remarks = cl.Remarks
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> ChecklistEdit(int id, ChecklistFormDto dto)
    {
        if (!ModelState.IsValid) return View("ChecklistForm", dto);
        var cl = await _db.Checklists.FindAsync(id);
        if (cl == null) return NotFound();
        var oldStatus = cl.Status.ToString();
        cl.Name = dto.Name; cl.Description = dto.Description; cl.Status = dto.Status; cl.Priority = dto.Priority;
        cl.ExpectedStartDate = dto.ExpectedStartDate; cl.ExpectedEndDate = dto.ExpectedEndDate;
        cl.ActualStartDate = dto.ActualStartDate; cl.ActualEndDate = dto.ActualEndDate;
        // SRS §3.6: checklist progress is MANUAL — user sets it directly here
        cl.ProgressPercentage = dto.ProgressPercentage;
        cl.Remarks = dto.Remarks; cl.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        await _progress.RecalcFromChecklistAsync(cl.Id, _db);
        if (oldStatus != dto.Status.ToString())
            await _audit.LogStatusChangeAsync("Checklist", cl.Id, oldStatus, dto.Status.ToString(), "Status updated via edit");
        await _audit.LogAsync("update", "Checklist", cl.Id, $"Updated checklist: {cl.Name}");
        TempData["Success"] = "Checklist updated.";
        return RedirectToAction(nameof(Checklists), new { subModuleId = cl.SubModuleId });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> ChecklistDelete(int id)
    {
        var cl = await _db.Checklists.Include(x => x.Activities).FirstOrDefaultAsync(x => x.Id == id);
        if (cl == null) return NotFound();
        if (cl.Activities.Any()) { TempData["Error"] = "Cannot delete Checklist with existing Activities. Remove them first."; return RedirectToAction(nameof(Checklists), new { subModuleId = cl.SubModuleId }); }
        var subModuleId = cl.SubModuleId;
        _db.Checklists.Remove(cl);
        await _db.SaveChangesAsync();
        await _progress.RecalcFromChecklistAsync(subModuleId, _db);
        await _audit.LogAsync("delete", "Checklist", id, $"Deleted checklist: {cl.Name}");
        TempData["Success"] = "Checklist deleted.";
        return RedirectToAction(nameof(Checklists), new { subModuleId });
    }
}
