using ErpGovernance.Application.DTOs;
using ErpGovernance.Application.Interfaces;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Web.Controllers;

[Authorize]
public class DashboardController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IProjectScopeService _scope;

    public DashboardController(ApplicationDbContext db, IProjectScopeService scope)
    {
        _db = db;
        _scope = scope;
    }

    public async Task<IActionResult> Index(int? orgId, int? projectId)
    {
        var accessibleIds = await _scope.GetAccessibleProjectIdsAsync();

        var query = _db.Projects
            .Include(p => p.Organization)
            .Include(p => p.ProjectManagers).ThenInclude(pm => pm.User)
            .Include(p => p.Modules).ThenInclude(m => m.SubModuleGroups).ThenInclude(smg => smg.SubModules).ThenInclude(sm => sm.Checklists).ThenInclude(c => c.Activities)
            .AsQueryable();

        if (accessibleIds != null)
            query = query.Where(p => accessibleIds.Contains(p.Id));

        if (orgId.HasValue)
            query = query.Where(p => p.OrganizationId == orgId.Value);

        if (projectId.HasValue)
            query = query.Where(p => p.Id == projectId.Value);

        var projects = await query.ToListAsync();

        var tree = projects.Select(p => new ProjectTreeDto
        {
            ProjectId = p.Id,
            Name = p.Name,
            Code = p.Code,
            OrganizationName = p.Organization.Name,
            Status = p.Status,
            Priority = p.Priority,
            ProgressPercentage = p.ProgressPercentage,
            ManagerNames = p.ProjectManagers.Select(pm => pm.User.FullName).ToList(),
            Modules = p.Modules.Select(m => new ModuleTreeDto
            {
                Id = m.Id,
                Name = m.Name,
                Status = m.Status,
                ProgressPercentage = m.ProgressPercentage,
                SubModuleGroups = m.SubModuleGroups.Select(smg => new SubModuleGroupTreeDto
                {
                    Id = smg.Id,
                    Name = smg.Name,
                    Status = smg.Status,
                    ProgressPercentage = smg.ProgressPercentage,
                    SubModules = smg.SubModules.Select(sm => new SubModuleTreeDto
                    {
                        Id = sm.Id,
                        Name = sm.Name,
                        Status = sm.Status,
                        ProgressPercentage = sm.ProgressPercentage,
                        Checklists = sm.Checklists.Select(c => new ChecklistTreeDto
                        {
                            Id = c.Id,
                            Name = c.Name,
                            Status = c.Status,
                            Priority = c.Priority,
                            ProgressPercentage = c.ProgressPercentage,
                            ExpectedStartDate = c.ExpectedStartDate,
                            ExpectedEndDate = c.ExpectedEndDate,
                            Activities = c.Activities.Select(a => new ActivitySummaryDto
                            {
                                Id = a.Id,
                                Title = a.Title,
                                ActivityTypeDisplay = a.ActivityType.ToString(),
                                Status = a.Status,
                                AssignedUserName = a.AssignedUser?.FullName,
                                ActualStartDateTime = a.ActualStartDateTime,
                                ActualEndDateTime = a.ActualEndDateTime
                            }).ToList()
                        }).ToList()
                    }).ToList()
                }).ToList()
            }).ToList()
        }).ToList();

        // Calculate summary
        var summary = new DashboardSummaryDto
        {
            TotalProjects = tree.Count,
            TotalModules = tree.Sum(p => p.Modules.Count),
            TotalSubModuleGroups = tree.Sum(p => p.Modules.Sum(m => m.SubModuleGroups.Count)),
            TotalSubModules = tree.Sum(p => p.Modules.Sum(m => m.SubModuleGroups.Sum(smg => smg.SubModules.Count))),
            TotalChecklists = tree.Sum(p => p.Modules.Sum(m => m.SubModuleGroups.Sum(smg => smg.SubModules.Sum(sm => sm.Checklists.Count)))),
            TotalActivities = tree.Sum(p => p.Modules.Sum(m => m.SubModuleGroups.Sum(smg => smg.SubModules.Sum(sm => sm.Checklists.Sum(c => c.Activities.Count))))),
            CompletedChecklists = tree.Sum(p => p.Modules.Sum(m => m.SubModuleGroups.Sum(smg => smg.SubModules.Sum(sm => sm.Checklists.Count(c => c.Status == Domain.Enums.ItemStatus.Completed))))),
            DelayedItems = tree.Sum(p => p.Modules.Sum(m => m.SubModuleGroups.Sum(smg => smg.SubModules.Sum(sm => sm.Checklists.Count(c => c.Status == Domain.Enums.ItemStatus.Delayed)))))
        };

        ViewBag.Summary = summary;
        
        // Populate filters
        var orgs = await _db.Organizations.Where(o => o.IsActive).ToListAsync();
        ViewBag.Orgs = orgs.Select(o => new SelectListItem { Value = o.Id.ToString(), Text = o.Name }).ToList();
        
        var allAccessibleProjects = await _db.Projects.Where(p => accessibleIds == null || accessibleIds.Contains(p.Id)).ToListAsync();
        ViewBag.Projects = allAccessibleProjects.Select(p => new SelectListItem { Value = p.Id.ToString(), Text = p.Name }).ToList();

        return View(tree);
    }
}
