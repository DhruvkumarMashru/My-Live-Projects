using ErpGovernance.Application.DTOs;
using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Entities;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Web.Controllers;

[Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Users.View)]
public class UsersController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly UserManager<AppUser> _userManager;
    private readonly RoleManager<IdentityRole<int>> _roleManager;
    private readonly IAuditService _audit;
    private readonly ICurrentUserService _currentUser;

    public UsersController(
        ApplicationDbContext db,
        UserManager<AppUser> userManager,
        RoleManager<IdentityRole<int>> roleManager,
        IAuditService audit,
        ICurrentUserService currentUser)
    {
        _db = db;
        _userManager = userManager;
        _roleManager = roleManager;
        _audit = audit;
        _currentUser = currentUser;
    }

    public async Task<IActionResult> Index()
    {
        var query = _db.Users.Include(u => u.Organization).AsQueryable();

        // Project HOD can only see users in their org
        if (!_currentUser.IsSuperAdmin)
        {
            var myOrgId = await _db.Users.Where(u => u.Id == _currentUser.UserId).Select(u => u.OrganizationId).FirstOrDefaultAsync();
            query = query.Where(u => u.OrganizationId == myOrgId);
        }

        var usersList = await query.ToListAsync();
        var dtos = new List<UserListDto>();

        foreach(var u in usersList)
        {
            var roles = await _userManager.GetRolesAsync(u);
            dtos.Add(new UserListDto
            {
                Id = u.Id,
                FullName = u.FullName,
                Email = u.Email!,
                Role = roles.FirstOrDefault() ?? "Viewer",
                OrganizationName = u.Organization?.Name,
                Department = u.Department,
                IsActive = u.IsActive,
                LastLogin = u.LastLogin,
                CreatedAt = u.CreatedAt
            });
        }

        return View(dtos);
    }

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Users.Create)]
    public async Task<IActionResult> Create()
    {
        await PopulateDropdowns();
        return View("Form", new UserFormDto());
    }

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Users.Create)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(UserFormDto dto)
    {
        if (string.IsNullOrEmpty(dto.Password))
            ModelState.AddModelError("Password", "Password is required for new users.");

        if (!_currentUser.IsSuperAdmin && dto.Role == "super_admin")
            ModelState.AddModelError("Role", "Cannot create Super Admin user.");

        if (!ModelState.IsValid)
        {
            await PopulateDropdowns();
            return View("Form", dto);
        }

        var user = new AppUser
        {
            UserName = dto.Email,
            Email = dto.Email,
            FullName = dto.FullName,
            OrganizationId = dto.OrganizationId,
            Phone = dto.Phone,
            Department = dto.Department,
            IsActive = dto.IsActive,
            EmailConfirmed = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var result = await _userManager.CreateAsync(user, dto.Password!);
        if (result.Succeeded)
        {
            if (!string.IsNullOrEmpty(dto.Role))
            {
                await _userManager.AddToRoleAsync(user, dto.Role);
                await _audit.LogAsync("create", "AppUser", user.Id, $"Assigned role '{dto.Role}' to new user {user.Email}");
            }
            await _audit.LogAsync("create", "AppUser", user.Id, $"Created user: {user.Email}");
            TempData["Success"] = "User created successfully.";
            return RedirectToAction(nameof(Index));
        }

        foreach (var err in result.Errors) ModelState.AddModelError("", err.Description);
        await PopulateDropdowns();
        return View("Form", dto);
    }

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Users.Edit)]
    public async Task<IActionResult> Edit(int id)
    {
        var user = await _userManager.FindByIdAsync(id.ToString());
        if (user == null) return NotFound();

        var roles = await _userManager.GetRolesAsync(user);

        await PopulateDropdowns();
        return View("Form", new UserFormDto
        {
            Id = user.Id,
            FullName = user.FullName,
            Email = user.Email!,
            Role = roles.FirstOrDefault() ?? "",
            OrganizationId = user.OrganizationId,
            Phone = user.Phone,
            Department = user.Department,
            IsActive = user.IsActive
        });
    }

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Users.Edit)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, UserFormDto dto)
    {
        if (id != dto.Id) return BadRequest();
        
        var user = await _userManager.FindByIdAsync(id.ToString());
        if (user == null) return NotFound();

        ModelState.Remove("Password");
        ModelState.Remove("ConfirmPassword");

        if (!ModelState.IsValid)
        {
            await PopulateDropdowns();
            return View("Form", dto);
        }

        user.FullName = dto.FullName;
        user.Email = dto.Email;
        user.UserName = dto.Email;
        user.OrganizationId = dto.OrganizationId;
        user.Phone = dto.Phone;
        user.Department = dto.Department;
        user.IsActive = dto.IsActive;

        var result = await _userManager.UpdateAsync(user);
        if (result.Succeeded)
        {
            var oldRoles = await _userManager.GetRolesAsync(user);
            var oldRoleStr = oldRoles.FirstOrDefault() ?? "";
            var newRoleStr = dto.Role ?? "";

            if (oldRoleStr != newRoleStr)
            {
                if (!string.IsNullOrEmpty(oldRoleStr))
                {
                    await _userManager.RemoveFromRoleAsync(user, oldRoleStr);
                    await _audit.LogAsync("update", "AppUser", user.Id, $"Revoked role '{oldRoleStr}' from {user.Email}");
                }
                
                if (!string.IsNullOrEmpty(newRoleStr))
                {
                    await _userManager.AddToRoleAsync(user, newRoleStr);
                    await _audit.LogAsync("update", "AppUser", user.Id, $"Granted role '{newRoleStr}' to {user.Email}");
                }
            }

            await _audit.LogAsync("update", "AppUser", user.Id, $"Updated user details: {user.Email}");
            TempData["Success"] = "User updated successfully.";
            return RedirectToAction(nameof(Index));
        }

        foreach (var err in result.Errors) ModelState.AddModelError("", err.Description);
        await PopulateDropdowns();
        return View("Form", dto);
    }

    [Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Users.Edit)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ToggleActive(int id)
    {
        var user = await _userManager.FindByIdAsync(id.ToString());
        if (user == null) return NotFound();

        user.IsActive = !user.IsActive;
        user.UpdatedAt = DateTime.UtcNow;
        await _userManager.UpdateAsync(user);

        var action = user.IsActive ? "activated" : "deactivated";
        await _audit.LogAsync("update", "AppUser", user.Id, $"User {action}: {user.Email}");
        TempData["Success"] = $"User has been {action}.";
        return RedirectToAction(nameof(Index));
    }

    private async Task PopulateDropdowns()
    {
        ViewBag.Organizations = await _db.Organizations
            .Where(o => o.IsActive)
            .Select(o => new SelectListItem { Value = o.Id.ToString(), Text = o.Name })
            .ToListAsync();

        ViewBag.Roles = await _roleManager.Roles
            .Select(r => new SelectListItem { Value = r.Name, Text = r.Name })
            .ToListAsync();
    }
}
