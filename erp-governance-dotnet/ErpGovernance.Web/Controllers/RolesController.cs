using ErpGovernance.Application.Constants;
using ErpGovernance.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace ErpGovernance.Web.Controllers;

[Authorize(Policy = Permissions.Roles.View)]
public class RolesController : Controller
{
    private readonly RoleManager<IdentityRole<int>> _roleManager;
    private readonly IAuditService _auditService;

    public RolesController(RoleManager<IdentityRole<int>> roleManager, IAuditService auditService)
    {
        _roleManager = roleManager;
        _auditService = auditService;
    }

    public IActionResult Index()
    {
        var roles = _roleManager.Roles.ToList();
        return View(roles);
    }

    [Authorize(Policy = Permissions.Roles.Create)]
    [HttpGet]
    public IActionResult Create()
    {
        return View("Form", new IdentityRole<int>());
    }

    [Authorize(Policy = Permissions.Roles.Create)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            ModelState.AddModelError("", "Role name is required.");
            return View("Form", new IdentityRole<int>());
        }

        var role = new IdentityRole<int>(name);
        var result = await _roleManager.CreateAsync(role);

        if (result.Succeeded)
        {
            await _auditService.LogAsync("create", "Role", role.Id, $"Created role: {name}");
            TempData["Success"] = "Role created successfully.";
            return RedirectToAction(nameof(Index));
        }

        foreach (var error in result.Errors) ModelState.AddModelError("", error.Description);
        return View("Form", role);
    }

    [Authorize(Policy = Permissions.Roles.Edit)]
    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var role = await _roleManager.FindByIdAsync(id.ToString());
        if (role == null) return NotFound();
        return View("Form", role);
    }

    [Authorize(Policy = Permissions.Roles.Edit)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, string name)
    {
        var role = await _roleManager.FindByIdAsync(id.ToString());
        if (role == null) return NotFound();

        var oldName = role.Name;
        role.Name = name;
        var result = await _roleManager.UpdateAsync(role);

        if (result.Succeeded)
        {
            await _auditService.LogAsync("update", "Role", role.Id, $"Renamed role from {oldName} to {name}");
            TempData["Success"] = "Role updated successfully.";
            return RedirectToAction(nameof(Index));
        }

        foreach (var error in result.Errors) ModelState.AddModelError("", error.Description);
        return View("Form", role);
    }

    [Authorize(Policy = Permissions.Roles.Delete)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id)
    {
        var role = await _roleManager.FindByIdAsync(id.ToString());
        if (role == null) return NotFound();

        if (role.Name == "super_admin")
        {
            TempData["Error"] = "Cannot delete the super_admin role.";
            return RedirectToAction(nameof(Index));
        }

        var result = await _roleManager.DeleteAsync(role);
        if (result.Succeeded)
        {
            await _auditService.LogAsync("delete", "Role", id, $"Deleted role: {role.Name}");
            TempData["Success"] = "Role deleted successfully.";
        }
        else
        {
            TempData["Error"] = "Error deleting role.";
        }
        return RedirectToAction(nameof(Index));
    }

    [Authorize(Policy = Permissions.Roles.ManagePermissions)]
    [HttpGet]
    public async Task<IActionResult> ManagePermissions(int id)
    {
        var role = await _roleManager.FindByIdAsync(id.ToString());
        if (role == null) return NotFound();

        var existingClaims = await _roleManager.GetClaimsAsync(role);
        var allPermissions = Permissions.GetAllPermissions();

        var model = new ManagePermissionsViewModel
        {
            RoleId = role.Id,
            RoleName = role.Name!,
            RoleClaims = allPermissions.Select(p => new RoleClaimViewModel
            {
                Type = "Permission",
                Value = p,
                Selected = existingClaims.Any(c => c.Value == p)
            }).ToList()
        };

        return View(model);
    }

    [Authorize(Policy = Permissions.Roles.ManagePermissions)]
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ManagePermissions(ManagePermissionsViewModel model)
    {
        var role = await _roleManager.FindByIdAsync(model.RoleId.ToString());
        if (role == null) return NotFound();

        var existingClaims = await _roleManager.GetClaimsAsync(role);
        var oldPerms = existingClaims.Where(c => c.Type == "Permission").Select(c => c.Value).ToList();
        
        // Remove all existing permission claims
        foreach (var claim in existingClaims.Where(c => c.Type == "Permission"))
        {
            await _roleManager.RemoveClaimAsync(role, claim);
        }

        // Add selected claims
        var selectedClaims = model.RoleClaims.Where(c => c.Selected).ToList();
        foreach (var claim in selectedClaims)
        {
            await _roleManager.AddClaimAsync(role, new Claim(claim.Type, claim.Value));
        }

        var newPerms = selectedClaims.Select(c => c.Value).ToList();
        var added = newPerms.Except(oldPerms).ToList();
        var removed = oldPerms.Except(newPerms).ToList();

        var auditMsg = $"Updated permissions for role {role.Name}. ";
        if (added.Any()) auditMsg += $"Granted: {string.Join(", ", added)}. ";
        if (removed.Any()) auditMsg += $"Revoked: {string.Join(", ", removed)}.";

        await _auditService.LogAsync("update", "Role", role.Id, auditMsg);

        TempData["Success"] = "Permissions updated successfully.";
        return RedirectToAction(nameof(Index));
    }
}

public class ManagePermissionsViewModel
{
    public int RoleId { get; set; }
    public string RoleName { get; set; } = string.Empty;
    public List<RoleClaimViewModel> RoleClaims { get; set; } = new();
}

public class RoleClaimViewModel
{
    public string Type { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
    public bool Selected { get; set; }
}
