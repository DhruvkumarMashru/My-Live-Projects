using ErpGovernance.Application.DTOs;
using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Entities;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Web.Controllers;

[Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Projects.View)]
public class ProjectsController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IProjectScopeService _scope;
    private readonly IAuditService _audit;
    private readonly ICurrentUserService _currentUser;

    public ProjectsController(
        ApplicationDbContext db,
        IProjectScopeService scope,
        IAuditService audit,
        ICurrentUserService currentUser)
    {
        _db = db;
        _scope = scope;
        _audit = audit;
        _currentUser = currentUser;
    }

    public async Task<IActionResult> Index()
    {
        var accessibleIds = await _scope.GetAccessibleProjectIdsAsync();
        
        var query = _db.Projects.Include(p => p.Organization).Include(p => p.ProjectManagers).ThenInclude(pm => pm.User).AsQueryable();
        
        if (accessibleIds != null)
        {
            query = query.Where(p => accessibleIds.Contains(p.Id));
        }

        var projects = await query.Select(p => new ProjectListDto
        {
            Id = p.Id,
            Name = p.Name,
            Code = p.Code,
            OrganizationId = p.OrganizationId,
            OrganizationName = p.Organization.Name,
            Status = p.Status,
            Priority = p.Priority,
            ProgressPercentage = p.ProgressPercentage,
            ExpectedStartDate = p.ExpectedStartDate,
            ExpectedEndDate = p.ExpectedEndDate,
            ManagerNames = p.ProjectManagers.Select(pm => pm.User.FullName).ToList(),
            CreatedAt = p.CreatedAt
        }).ToListAsync();

        return View(projects);
    }

    [Authorize(Roles = "super_admin,project_hod,project_manager")]
    public async Task<IActionResult> Create()
    {
        await PopulateDropdowns();
        return View("Form", new ProjectFormDto());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [Authorize(Roles = "super_admin,project_hod,project_manager")]
    public async Task<IActionResult> Create(ProjectFormDto dto)
    {
        if (!ModelState.IsValid)
        {
            await PopulateDropdowns();
            return View("Form", dto);
        }

        var project = new Project
        {
            Name = dto.Name,
            Code = dto.Code,
            OrganizationId = dto.OrganizationId,
            Description = dto.Description,
            Status = dto.Status,
            Priority = dto.Priority,
            ExpectedStartDate = dto.ExpectedStartDate,
            ExpectedEndDate = dto.ExpectedEndDate,
            Remarks = dto.Remarks,
            CreatedById = _currentUser.UserId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        if (dto.ManagerIds.Any())
        {
            project.ProjectManagers = dto.ManagerIds.Select(userId => new ProjectManager
            {
                UserId = userId,
                AssignedAt = DateTime.UtcNow
            }).ToList();
        }

        _db.Projects.Add(project);
        await _db.SaveChangesAsync();

        await _audit.LogAsync("create", "Project", project.Id, $"Created project: {project.Name}");
        TempData["Success"] = "Project created successfully.";
        return RedirectToAction(nameof(Index));
    }

    public async Task<IActionResult> Edit(int id)
    {
        if (!await _scope.CanAccessProjectAsync(id)) return Forbid();

        var project = await _db.Projects
            .Include(p => p.ProjectManagers)
            .FirstOrDefaultAsync(p => p.Id == id);
            
        if (project == null) return NotFound();

        await PopulateDropdowns();
        return View("Form", new ProjectFormDto
        {
            Id = project.Id,
            Name = project.Name,
            Code = project.Code,
            OrganizationId = project.OrganizationId,
            Description = project.Description,
            Status = project.Status,
            Priority = project.Priority,
            ExpectedStartDate = project.ExpectedStartDate,
            ExpectedEndDate = project.ExpectedEndDate,
            Remarks = project.Remarks,
            ManagerIds = project.ProjectManagers.Select(pm => pm.UserId).ToList()
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, ProjectFormDto dto)
    {
        if (id != dto.Id) return BadRequest();
        if (!await _scope.CanAccessProjectAsync(id)) return Forbid();

        if (!ModelState.IsValid)
        {
            await PopulateDropdowns();
            return View("Form", dto);
        }

        var project = await _db.Projects
            .Include(p => p.ProjectManagers)
            .FirstOrDefaultAsync(p => p.Id == id);
            
        if (project == null) return NotFound();

        var oldStatus = project.Status.ToString();

        project.Name = dto.Name;
        project.Code = dto.Code;
        project.OrganizationId = dto.OrganizationId;
        project.Description = dto.Description;
        project.Status = dto.Status;
        project.Priority = dto.Priority;
        project.ExpectedStartDate = dto.ExpectedStartDate;
        project.ExpectedEndDate = dto.ExpectedEndDate;
        project.Remarks = dto.Remarks;

        // Sync managers
        _db.ProjectManagers.RemoveRange(project.ProjectManagers);
        if (dto.ManagerIds.Any())
        {
            project.ProjectManagers = dto.ManagerIds.Select(userId => new ProjectManager
            {
                ProjectId = project.Id,
                UserId = userId,
                AssignedAt = DateTime.UtcNow
            }).ToList();
        }

        await _db.SaveChangesAsync();

        if (oldStatus != dto.Status.ToString())
        {
            await _audit.LogStatusChangeAsync("Project", project.Id, oldStatus, dto.Status.ToString(), "Status changed via edit");
        }
        await _audit.LogAsync("update", "Project", project.Id, $"Updated project: {project.Name}");
        
        TempData["Success"] = "Project updated successfully.";
        return RedirectToAction(nameof(Index));
    }

    private async Task PopulateDropdowns()
    {
        var orgs = await _db.Organizations.Where(o => o.IsActive).ToListAsync();
        ViewBag.Organizations = orgs.Select(o => new SelectListItem { Value = o.Id.ToString(), Text = o.Name }).ToList();

        var managers = await _db.Users.Where(u => u.IsActive && (u.Role == Domain.Enums.UserRole.ProjectManager || u.Role == Domain.Enums.UserRole.ProjectHod)).ToListAsync();
        ViewBag.Managers = managers.Select(u => new SelectListItem { Value = u.Id.ToString(), Text = $"{u.FullName} ({u.Email})" }).ToList();
    }
}
