using ErpGovernance.Application.Interfaces;
using ErpGovernance.Infrastructure.Services;
using ErpGovernance.Domain.Entities;
using ErpGovernance.Domain.Enums;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using System.Globalization;

namespace ErpGovernance.Web.Controllers;

[Authorize(Policy = ErpGovernance.Application.Constants.Permissions.Import.Execute)]
public class ImportController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IProjectScopeService _scope;
    private readonly IAuditService _audit;
    private readonly IProgressRollupService _progress;

    public ImportController(ApplicationDbContext db, IProjectScopeService scope, IAuditService audit, IProgressRollupService progress)
    {
        _db = db;
        _scope = scope;
        _audit = audit;
        _progress = progress;
    }

    public async Task<IActionResult> Index()
    {
        var accessibleIds = await _scope.GetAccessibleProjectIdsAsync();
        var projects = await _db.Projects
            .Where(p => accessibleIds == null || accessibleIds.Contains(p.Id))
            .ToListAsync();

        ViewBag.Projects = projects.Select(p => new SelectListItem { Value = p.Id.ToString(), Text = p.Name }).ToList();
        return View();
    }

    [HttpGet]
    public IActionResult Template()
    {
        // SRS FR-IMP: 16 columns exactly
        string header = "ModuleName,ModuleDescription,SubModuleGroupName,SubModuleGroupDescription,SubModuleName,SubModuleDescription,ChecklistName,ChecklistDescription,ExpectedStartDate,ExpectedEndDate,ActualStartDate,ActualEndDate,Status,Priority,ProgressPercentage,Remarks\n";
        string sample = "Finance,Finance Module,General Ledger,GL Area,Chart of Accounts,COA Mapping,COA Setup,Map Chart of Accounts,01-Jan-2026,31-Mar-2026,,,in_progress,high,25,Initial mapping done\n";
        byte[] bytes = System.Text.Encoding.UTF8.GetBytes(header + sample);
        return File(bytes, "text/csv", "HierarchyImportTemplate.csv");
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Import(IFormFile file, int projectId)
    {
        if (file == null || file.Length == 0)
        {
            TempData["Error"] = "Please select a file to upload.";
            return RedirectToAction(nameof(Index));
        }

        var project = await _db.Projects.FindAsync(projectId);
        if (project == null) return NotFound();

        using var reader = new System.IO.StreamReader(file.OpenReadStream());
        bool isHeader = true;
        int rowNum = 0;
        int created = 0;
        int updated = 0;
        var errors = new List<string>();

        string? line;
        while ((line = await reader.ReadLineAsync()) != null)
        {
            rowNum++;
            if (string.IsNullOrWhiteSpace(line)) continue;

            if (isHeader) { isHeader = false; continue; }

            // Parse CSV (basic — no quoted fields with commas)
            var cols = line.Split(',');
            if (cols.Length < 7)
            {
                errors.Add($"Row {rowNum}: Too few columns ({cols.Length}). Minimum 7 required.");
                continue;
            }

            string Get(int i) => i < cols.Length ? cols[i].Trim() : "";

            var modName = Get(0);
            if (string.IsNullOrEmpty(modName)) { errors.Add($"Row {rowNum}: module_name is required."); continue; }

            // ── Parse dates (SRS: dd-MMM-yyyy only) ─────────────────────────
            DateOnly? ParseDate(string raw, string fieldName)
            {
                if (string.IsNullOrEmpty(raw)) return null;
                if (DateOnly.TryParseExact(raw, "dd-MMM-yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out var d))
                    return d;
                errors.Add($"Row {rowNum}: {fieldName} '{raw}' is invalid — must be dd-MMM-yyyy (e.g. 01-Jan-2026).");
                return null;
            }

            var expStart   = ParseDate(Get(8),  "expected_start_date");
            var expEnd     = ParseDate(Get(9),  "expected_end_date");
            var actStart   = ParseDate(Get(10), "actual_start_date");
            var actEnd     = ParseDate(Get(11), "actual_end_date");

            // ── Parse status ─────────────────────────────────────────────────
            ItemStatus status = ItemStatus.NotStarted;
            var statusStr = Get(12).ToLower().Replace("_", "");
            status = statusStr switch
            {
                "draft"             => ItemStatus.Draft,
                "notstarted"        => ItemStatus.NotStarted,
                "inprogress"        => ItemStatus.InProgress,
                "pendingerp"        => ItemStatus.PendingErp,
                "pendinguniversity" => ItemStatus.PendingUniversity,
                "onhold"            => ItemStatus.OnHold,
                "delayed"           => ItemStatus.Delayed,
                "completed"         => ItemStatus.Completed,
                "approved"          => ItemStatus.Approved,
                "rejected"          => ItemStatus.Rejected,
                _                   => ItemStatus.NotStarted
            };

            // ── Parse priority ───────────────────────────────────────────────
            Priority priority = Priority.Medium;
            priority = Get(13).ToLower() switch
            {
                "low"      => Priority.Low,
                "high"     => Priority.High,
                "critical" => Priority.Critical,
                _          => Priority.Medium
            };

            // ── Parse progress ───────────────────────────────────────────────
            decimal progress = 0;
            if (!string.IsNullOrEmpty(Get(14)) && decimal.TryParse(Get(14), out var p))
                progress = Math.Clamp(p, 0, 100);

            var remarks = Get(15);

            // ── Upsert Module ────────────────────────────────────────────────
            var module = await _db.Modules.FirstOrDefaultAsync(m => m.ProjectId == projectId && m.Name == modName);
            if (module == null)
            {
                module = new Module
                {
                    ProjectId = projectId, OrganizationId = project.OrganizationId, Name = modName,
                    Description = Get(1), Status = ItemStatus.NotStarted, Priority = priority,
                    ExpectedStartDate = expStart, ExpectedEndDate = expEnd
                };
                _db.Modules.Add(module);
                await _db.SaveChangesAsync();
                created++;
            }

            var smgName = Get(2);
            if (string.IsNullOrEmpty(smgName)) continue;

            // ── Upsert SubModuleGroup ────────────────────────────────────────
            var smg = await _db.SubModuleGroups.FirstOrDefaultAsync(g => g.ModuleId == module.Id && g.Name == smgName);
            if (smg == null)
            {
                smg = new SubModuleGroup
                {
                    ModuleId = module.Id, Name = smgName, Description = Get(3),
                    Status = ItemStatus.NotStarted, Priority = priority,
                    ExpectedStartDate = expStart, ExpectedEndDate = expEnd
                };
                _db.SubModuleGroups.Add(smg);
                await _db.SaveChangesAsync();
                created++;
            }

            var smName = Get(4);
            if (string.IsNullOrEmpty(smName)) continue;

            // ── Upsert SubModule ─────────────────────────────────────────────
            var sm = await _db.SubModules.FirstOrDefaultAsync(s => s.SubModuleGroupId == smg.Id && s.Name == smName);
            if (sm == null)
            {
                sm = new SubModule
                {
                    SubModuleGroupId = smg.Id, Name = smName, Description = Get(5),
                    Status = ItemStatus.NotStarted, Priority = priority,
                    ExpectedStartDate = expStart, ExpectedEndDate = expEnd
                };
                _db.SubModules.Add(sm);
                await _db.SaveChangesAsync();
                created++;
            }

            var chkName = Get(6);
            if (string.IsNullOrEmpty(chkName)) continue;

            // ── Upsert Checklist (governance fields applied at deepest level) ─
            var chk = await _db.Checklists.FirstOrDefaultAsync(c => c.SubModuleId == sm.Id && c.Name == chkName);
            if (chk == null)
            {
                chk = new Checklist
                {
                    SubModuleId = sm.Id, Name = chkName, Description = Get(7),
                    Status = status, Priority = priority, ProgressPercentage = progress,
                    ExpectedStartDate = expStart, ExpectedEndDate = expEnd,
                    ActualStartDate = actStart, ActualEndDate = actEnd, Remarks = remarks
                };
                _db.Checklists.Add(chk);
                created++;
            }
            else
            {
                // Update governance fields on existing checklist
                chk.Status = status; chk.Priority = priority; chk.ProgressPercentage = progress;
                chk.ExpectedStartDate = expStart; chk.ExpectedEndDate = expEnd;
                chk.ActualStartDate = actStart; chk.ActualEndDate = actEnd;
                if (!string.IsNullOrEmpty(remarks)) chk.Remarks = remarks;
                chk.UpdatedAt = DateTime.UtcNow;
                updated++;
            }

            await _db.SaveChangesAsync();
        }

        // Roll up progress for the entire project
        var moduleIds = await _db.Modules.Where(m => m.ProjectId == projectId).Select(m => m.Id).ToListAsync();
        foreach (var mid in moduleIds)
            await _progress.RecalcFromModuleAsync(mid, _db);

        await _audit.LogAsync("import", "Hierarchy", projectId, $"CSV import: {created} created, {updated} updated, {errors.Count} errors");

        if (errors.Any())
            TempData["Warning"] = $"Imported with warnings — {created} created, {updated} updated. Errors: {string.Join("; ", errors.Take(5))}{(errors.Count > 5 ? $" (+{errors.Count - 5} more)" : "")}";
        else
            TempData["Success"] = $"Import complete: {created} items created, {updated} items updated.";

        return RedirectToAction("Modules", "Hierarchy", new { projectId });
    }
}
