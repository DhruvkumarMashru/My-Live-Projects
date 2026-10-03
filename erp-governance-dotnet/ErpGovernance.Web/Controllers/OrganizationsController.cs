using ErpGovernance.Application.DTOs;
using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Entities;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Web.Controllers;

[Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Organizations.View)]
public class OrganizationsController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IAuditService _audit;

    public OrganizationsController(ApplicationDbContext db, IAuditService audit)
    {
        _db = db;
        _audit = audit;
    }

    public async Task<IActionResult> Index()
    {
        var orgs = await _db.Organizations
            .Select(o => new OrganizationListDto
            {
                Id = o.Id,
                Name = o.Name,
                Code = o.Code,
                Address = o.Address,
                IsActive = o.IsActive,
                CreatedAt = o.CreatedAt,
                ProjectCount = o.Projects.Count,
                UserCount = o.Users.Count
            })
            .ToListAsync();

        return View(orgs);
    }

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Organizations.Create)]
    public IActionResult Create() => View("Form", new OrganizationFormDto());

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Organizations.Create)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(OrganizationFormDto dto)
    {
        if (!ModelState.IsValid) return View("Form", dto);

        if (!string.IsNullOrEmpty(dto.Code) && await _db.Organizations.AnyAsync(o => o.Code == dto.Code))
        {
            ModelState.AddModelError("Code", "Code must be unique.");
            return View("Form", dto);
        }

        var org = new Organization
        {
            Name = dto.Name,
            Code = dto.Code,
            Address = dto.Address,
            IsActive = dto.IsActive,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _db.Organizations.Add(org);
        await _db.SaveChangesAsync();
        await _audit.LogAsync("create", "Organization", org.Id, $"Created org: {org.Name}");

        TempData["Success"] = "Organization created successfully.";
        return RedirectToAction(nameof(Index));
    }

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Organizations.Edit)]
    public async Task<IActionResult> Edit(int id)
    {
        var org = await _db.Organizations.FindAsync(id);
        if (org == null) return NotFound();

        return View("Form", new OrganizationFormDto
        {
            Id = org.Id,
            Name = org.Name,
            Code = org.Code,
            Address = org.Address,
            IsActive = org.IsActive
        });
    }

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Organizations.Edit)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, OrganizationFormDto dto)
    {
        if (id != dto.Id) return BadRequest();
        if (!ModelState.IsValid) return View("Form", dto);

        var org = await _db.Organizations.FindAsync(id);
        if (org == null) return NotFound();

        if (!string.IsNullOrEmpty(dto.Code) && await _db.Organizations.AnyAsync(o => o.Code == dto.Code && o.Id != id))
        {
            ModelState.AddModelError("Code", "Code must be unique.");
            return View("Form", dto);
        }

        org.Name = dto.Name;
        org.Code = dto.Code;
        org.Address = dto.Address;
        org.IsActive = dto.IsActive;

        await _db.SaveChangesAsync();
        await _audit.LogAsync("update", "Organization", org.Id, $"Updated org: {org.Name}");

        TempData["Success"] = "Organization updated successfully.";
        return RedirectToAction(nameof(Index));
    }

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Organizations.Edit)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ToggleActive(int id)
    {
        var org = await _db.Organizations.FindAsync(id);
        if (org == null) return NotFound();

        org.IsActive = !org.IsActive;
        await _db.SaveChangesAsync();
        await _audit.LogAsync("toggle_active", "Organization", org.Id, $"Set active to {org.IsActive}");

        TempData["Success"] = $"Organization {(org.IsActive ? "activated" : "deactivated")}.";
        return RedirectToAction(nameof(Index));
    }
}
