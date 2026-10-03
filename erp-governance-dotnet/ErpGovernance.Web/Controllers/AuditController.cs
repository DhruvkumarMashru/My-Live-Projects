using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Web.Controllers;

[Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Audit.View)]
public class AuditController : Controller
{
    private readonly ApplicationDbContext _db;

    public AuditController(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<IActionResult> Index(string? entityType, string? actionStr)
    {
        var query = _db.AuditLogs.Include(a => a.User).AsQueryable();

        if (!string.IsNullOrEmpty(entityType))
            query = query.Where(a => a.EntityType == entityType);

        if (!string.IsNullOrEmpty(actionStr))
            query = query.Where(a => a.Action == actionStr);

        var logs = await query.OrderByDescending(a => a.CreatedAt).Take(200).ToListAsync();
        return View(logs);
    }
}
