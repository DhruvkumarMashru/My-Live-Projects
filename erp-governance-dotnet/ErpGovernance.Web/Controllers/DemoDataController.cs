using ErpGovernance.Domain.Entities;
using ErpGovernance.Domain.Enums;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Web.Controllers;

[Authorize]
public class DemoDataController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly UserManager<AppUser> _userManager;
    private const string DemoTag = "DEMO:";

    public DemoDataController(ApplicationDbContext db, UserManager<AppUser> userManager)
    {
        _db = db;
        _userManager = userManager;
    }

    /// <summary>Seeds the database with realistic demo data.</summary>
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Seed()
    {
        var adminUser = await _userManager.GetUserAsync(User);
        if (adminUser == null) return Unauthorized();

        // Avoid duplicate seeding
        if (_db.Organizations.Any(o => o.Code != null && o.Code.StartsWith("DEMO-")))
        {
            TempData["Info"] = "Demo data is already seeded. Remove it first to re-seed.";
            return RedirectToAction("Index", "Dashboard");
        }

        var now = DateTime.UtcNow;

        // ─── Organizations ─────────────────────────────────────────────────────
        var orgs = new[]
        {
            new Organization { Name = "Greenfield University",           Code = "DEMO-GFU", IsActive = true, CreatedAt = now, UpdatedAt = now },
            new Organization { Name = "Northstar College",               Code = "DEMO-NSC", IsActive = true, CreatedAt = now, UpdatedAt = now },
            new Organization { Name = "Coastal Institute of Technology", Code = "DEMO-CIT", IsActive = true, CreatedAt = now, UpdatedAt = now }
        };
        _db.Organizations.AddRange(orgs);
        await _db.SaveChangesAsync();

        // ─── Projects ──────────────────────────────────────────────────────────
        var projects = new[]
        {
            new Project
            {
                OrganizationId = orgs[0].Id, Name = "ERP Phase 1 – Finance & HR", Code = "GFU-P1",
                Status = ItemStatus.InProgress, Priority = Priority.High, ProgressPercentage = 42,
                ExpectedStartDate = DateOnly.FromDateTime(now.AddMonths(-3)),
                ExpectedEndDate   = DateOnly.FromDateTime(now.AddMonths(3)),
                CreatedById = adminUser.Id,
                Remarks = DemoTag + "Core finance and payroll modules", CreatedAt = now, UpdatedAt = now
            },
            new Project
            {
                OrganizationId = orgs[0].Id, Name = "ERP Phase 2 – Student Affairs", Code = "GFU-P2",
                Status = ItemStatus.NotStarted, Priority = Priority.Medium, ProgressPercentage = 0,
                ExpectedStartDate = DateOnly.FromDateTime(now.AddMonths(4)),
                ExpectedEndDate   = DateOnly.FromDateTime(now.AddMonths(10)),
                CreatedById = adminUser.Id,
                Remarks = DemoTag + "Admissions, fees, LMS integration", CreatedAt = now, UpdatedAt = now
            },
            new Project
            {
                OrganizationId = orgs[1].Id, Name = "Northstar ERP Go-Live", Code = "NSC-LIVE",
                Status = ItemStatus.Delayed, Priority = Priority.Critical, ProgressPercentage = 65,
                ExpectedStartDate = DateOnly.FromDateTime(now.AddMonths(-6)),
                ExpectedEndDate   = DateOnly.FromDateTime(now.AddMonths(-1)),
                CreatedById = adminUser.Id,
                Remarks = DemoTag + "Delayed due to data migration issues", CreatedAt = now, UpdatedAt = now
            },
            new Project
            {
                OrganizationId = orgs[2].Id, Name = "CIT Digital Transformation", Code = "CIT-DT",
                Status = ItemStatus.InProgress, Priority = Priority.High, ProgressPercentage = 28,
                ExpectedStartDate = DateOnly.FromDateTime(now.AddMonths(-1)),
                ExpectedEndDate   = DateOnly.FromDateTime(now.AddMonths(8)),
                CreatedById = adminUser.Id,
                Remarks = DemoTag + "Full campus digital transformation", CreatedAt = now, UpdatedAt = now
            }
        };
        _db.Projects.AddRange(projects);
        await _db.SaveChangesAsync();

        // Assign admin as project manager for all projects
        _db.ProjectManagers.AddRange(projects.Select(p => new ProjectManager { ProjectId = p.Id, UserId = adminUser.Id }));
        await _db.SaveChangesAsync();

        // ─── Modules, Sub-Groups, Sub-Modules, Checklists, Activities ─────────
        await SeedProjectModules(_db, projects[0], adminUser.Id, now);
        await SeedDelayedProjectModules(_db, projects[2], adminUser.Id, now);
        await SeedCITModules(_db, projects[3], adminUser.Id, now);

        TempData["Success"] = "✅ Demo data seeded successfully! Explore projects, modules, and activities.";
        return RedirectToAction("Index", "Dashboard");
    }

    /// <summary>Removes all demo data tagged with DEMO: in Remarks.</summary>
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Remove()
    {
        var demoOrgIds = await _db.Organizations
            .Where(o => o.Code != null && o.Code.StartsWith("DEMO-"))
            .Select(o => o.Id).ToListAsync();

        var demoProjectIds = await _db.Projects
            .Where(p => p.Remarks != null && p.Remarks.StartsWith(DemoTag))
            .Select(p => p.Id).ToListAsync();

        if (demoProjectIds.Count == 0 && demoOrgIds.Count == 0)
        {
            TempData["Info"] = "No demo data found to remove.";
            return RedirectToAction("Index", "Dashboard");
        }

        // Collect IDs depth-first
        var moduleIds = await _db.Modules.Where(m => demoProjectIds.Contains(m.ProjectId)).Select(m => m.Id).ToListAsync();
        var smgIds    = await _db.SubModuleGroups.Where(s => moduleIds.Contains(s.ModuleId)).Select(s => s.Id).ToListAsync();
        var smIds     = await _db.SubModules.Where(s => smgIds.Contains(s.SubModuleGroupId)).Select(s => s.Id).ToListAsync();
        var chkIds    = await _db.Checklists.Where(c => smIds.Contains(c.SubModuleId)).Select(c => c.Id).ToListAsync();
        var actIds    = await _db.Activities.Where(a => chkIds.Contains(a.ChecklistId)).Select(a => a.Id).ToListAsync();

        // Clean leaf relations first
        var atts  = await _db.Attachments.Where(a =>
            (a.EntityType == "Activity" && actIds.Contains(a.EntityId)) ||
            (a.EntityType == "Checklist" && chkIds.Contains(a.EntityId))).ToListAsync();
        var comms = await _db.CommunicationLogs.Where(c => (c.ActivityId.HasValue && actIds.Contains(c.ActivityId.Value)) || (c.ChecklistId.HasValue && chkIds.Contains(c.ChecklistId.Value))).ToListAsync();
        var deps  = await _db.ChecklistDependencies.Where(d => chkIds.Contains(d.ChecklistId) || chkIds.Contains(d.DependsOnChecklistId)).ToListAsync();

        var hist = await _db.StatusHistories.Where(sh =>
            (sh.EntityType == "Project" && demoProjectIds.Contains(sh.EntityId)) ||
            (sh.EntityType == "Module" && moduleIds.Contains(sh.EntityId)) ||
            (sh.EntityType == "SubModuleGroup" && smgIds.Contains(sh.EntityId)) ||
            (sh.EntityType == "SubModule" && smIds.Contains(sh.EntityId)) ||
            (sh.EntityType == "Checklist" && chkIds.Contains(sh.EntityId)) ||
            (sh.EntityType == "Activity" && actIds.Contains(sh.EntityId))
        ).ToListAsync();

        var notifs = await _db.Notifications.Where(n =>
            (n.EntityType == "Project" && demoProjectIds.Contains(n.EntityId ?? 0)) ||
            (n.EntityType == "Module" && moduleIds.Contains(n.EntityId ?? 0)) ||
            (n.EntityType == "SubModuleGroup" && smgIds.Contains(n.EntityId ?? 0)) ||
            (n.EntityType == "SubModule" && smIds.Contains(n.EntityId ?? 0)) ||
            (n.EntityType == "Checklist" && chkIds.Contains(n.EntityId ?? 0)) ||
            (n.EntityType == "Activity" && actIds.Contains(n.EntityId ?? 0))
        ).ToListAsync();

        _db.Attachments.RemoveRange(atts);
        _db.CommunicationLogs.RemoveRange(comms);
        _db.ChecklistDependencies.RemoveRange(deps);
        _db.StatusHistories.RemoveRange(hist);
        _db.Notifications.RemoveRange(notifs);
        await _db.SaveChangesAsync();

        _db.Activities.RemoveRange(await _db.Activities.Where(a => chkIds.Contains(a.ChecklistId)).ToListAsync());
        await _db.SaveChangesAsync();

        _db.Checklists.RemoveRange(await _db.Checklists.Where(c => smIds.Contains(c.SubModuleId)).ToListAsync());
        await _db.SaveChangesAsync();

        _db.SubModules.RemoveRange(await _db.SubModules.Where(s => smgIds.Contains(s.SubModuleGroupId)).ToListAsync());
        await _db.SaveChangesAsync();

        _db.SubModuleGroups.RemoveRange(await _db.SubModuleGroups.Where(s => moduleIds.Contains(s.ModuleId)).ToListAsync());
        await _db.SaveChangesAsync();

        _db.Modules.RemoveRange(await _db.Modules.Where(m => demoProjectIds.Contains(m.ProjectId)).ToListAsync());
        await _db.SaveChangesAsync();

        _db.ProjectManagers.RemoveRange(await _db.ProjectManagers.Where(pm => demoProjectIds.Contains(pm.ProjectId)).ToListAsync());
        await _db.SaveChangesAsync();

        _db.Projects.RemoveRange(await _db.Projects.Where(p => demoProjectIds.Contains(p.Id)).ToListAsync());
        await _db.SaveChangesAsync();

        _db.Organizations.RemoveRange(await _db.Organizations.Where(o => demoOrgIds.Contains(o.Id)).ToListAsync());
        await _db.SaveChangesAsync();

        TempData["Success"] = "🗑️ All demo data removed successfully.";
        return RedirectToAction("Index", "Dashboard");
    }

    // ─── Private seed helpers ──────────────────────────────────────────────────

    private static async Task SeedProjectModules(ApplicationDbContext db, Project project, int userId, DateTime now)
    {
        await SeedModuleSet(db, project, userId, now, new[]
        {
            (Name: "Finance Module", Progress: 55m, Status: ItemStatus.InProgress, Groups: new[]
            {
                (GName: "General Ledger",    SMs: new[] { "Chart of Accounts Setup", "Journal Entry Configuration", "Period Closing" }),
                (GName: "Accounts Payable",  SMs: new[] { "Vendor Master Data", "Invoice Processing", "Payment Runs" }),
                (GName: "Payroll",           SMs: new[] { "Employee Data Migration", "Salary Structures", "Tax Configuration" })
            }),
            (Name: "HR Module", Progress: 30m, Status: ItemStatus.InProgress, Groups: new[]
            {
                (GName: "Employee Management", SMs: new[] { "Employee Onboarding Flow", "Leave Policy Setup", "Attendance Integration" }),
                (GName: "Recruitment",         SMs: new[] { "Job Portal Setup", "Applicant Tracking", "Interview Scheduling" })
            }),
            (Name: "Procurement Module", Progress: 10m, Status: ItemStatus.NotStarted, Groups: new[]
            {
                (GName: "Purchase Orders", SMs: new[] { "PO Workflow Design", "Approval Matrix Setup" }),
                (GName: "Inventory",       SMs: new[] { "Stock Item Catalogue", "Warehouse Mapping" })
            })
        });
    }

    private static async Task SeedDelayedProjectModules(ApplicationDbContext db, Project project, int userId, DateTime now)
    {
        await SeedModuleSet(db, project, userId, now, new[]
        {
            (Name: "Finance Module", Progress: 80m, Status: ItemStatus.Completed, Groups: new[]
            {
                (GName: "Core Accounting", SMs: new[] { "COA Migration", "Opening Balances" })
            }),
            (Name: "Student Module", Progress: 60m, Status: ItemStatus.Delayed, Groups: new[]
            {
                (GName: "Admissions", SMs: new[] { "Online Application Portal", "Document Upload System", "Merit List Processing" }),
                (GName: "Fees",       SMs: new[] { "Fee Structure Setup", "Online Payment Gateway", "Scholarship Module" })
            }),
            (Name: "Exam Module", Progress: 20m, Status: ItemStatus.PendingErp, Groups: new[]
            {
                (GName: "Examination Setup", SMs: new[] { "Exam Scheduling", "Hall Ticket Generation", "Result Processing" })
            })
        });
    }

    private static async Task SeedCITModules(ApplicationDbContext db, Project project, int userId, DateTime now)
    {
        await SeedModuleSet(db, project, userId, now, new[]
        {
            (Name: "Infrastructure Module", Progress: 40m, Status: ItemStatus.InProgress, Groups: new[]
            {
                (GName: "Network Setup",         SMs: new[] { "Campus LAN Configuration", "WiFi Access Points", "Firewall & Security" }),
                (GName: "Server Infrastructure", SMs: new[] { "On-Prem Server Setup", "Cloud Migration Plan", "Backup & DR" })
            }),
            (Name: "Academic Module", Progress: 15m, Status: ItemStatus.NotStarted, Groups: new[]
            {
                (GName: "Curriculum Management", SMs: new[] { "Course Catalog", "Timetable Automation", "Faculty Workload" }),
                (GName: "LMS Integration",        SMs: new[] { "Moodle Setup", "Content Migration", "Student Access" })
            })
        });
    }

    private static async Task SeedModuleSet(
        ApplicationDbContext db,
        Project project,
        int userId,
        DateTime now,
        IEnumerable<(string Name, decimal Progress, ItemStatus Status, (string GName, string[] SMs)[] Groups)> modules)
    {
        var actTypes = new[] { ActivityType.Task, ActivityType.Meeting, ActivityType.Review, ActivityType.Uat };
        var statuses = new[] { ItemStatus.NotStarted, ItemStatus.InProgress, ItemStatus.Completed, ItemStatus.PendingErp, ItemStatus.PendingUniversity };
        var actTitles = new[] { "Kickoff discussion", "Requirement gathering", "UAT session", "Data validation", "Sign-off meeting", "Training session", "Progress review", "Issue resolution", "Go-live preparation" };
        var teams = new[] { "ERP Team", "University IT", "Finance Dept", "HR Dept" };
        var rng = new Random(42);

        foreach (var (mName, mProgress, mStatus, groups) in modules)
        {
            var mod = new Module
            {
                ProjectId      = project.Id,
                OrganizationId = project.OrganizationId,
                Name           = mName,
                Status         = mStatus,
                ProgressPercentage = mProgress,
                CreatedById    = userId,
                ExpectedStartDate = DateOnly.FromDateTime(now.AddDays(-90)),
                ExpectedEndDate   = DateOnly.FromDateTime(now.AddDays(90)),
                Remarks  = DemoTag + mName,
                CreatedAt = now, UpdatedAt = now
            };
            db.Modules.Add(mod);
            await db.SaveChangesAsync();

            if (mod.Status != ItemStatus.NotStarted)
            {
                db.StatusHistories.Add(new StatusHistory { EntityType = "Module", EntityId = mod.Id, OldStatus = "NotStarted", NewStatus = mod.Status.ToString(), ChangedById = userId, Remarks = "Seeded initial status", CreatedAt = now });
            }

            foreach (var (gName, smNames) in groups)
            {
                var smgStatus = statuses[rng.Next(statuses.Length)];
                var smg = new SubModuleGroup
                {
                    ModuleId = mod.Id,
                    Name     = gName,
                    Status   = smgStatus,
                    ProgressPercentage = (decimal)rng.Next(10, 80),
                    CreatedById = userId,
                    ExpectedStartDate = DateOnly.FromDateTime(now.AddDays(-60)),
                    ExpectedEndDate   = DateOnly.FromDateTime(now.AddDays(60)),
                    Remarks   = DemoTag + gName,
                    CreatedAt = now, UpdatedAt = now
                };
                db.SubModuleGroups.Add(smg);
                await db.SaveChangesAsync();

                if (smg.Status != ItemStatus.NotStarted)
                {
                    db.StatusHistories.Add(new StatusHistory { EntityType = "SubModuleGroup", EntityId = smg.Id, OldStatus = "NotStarted", NewStatus = smg.Status.ToString(), ChangedById = userId, Remarks = "Seeded initial status", CreatedAt = now });
                }

                foreach (var smName in smNames)
                {
                    var smStatus = statuses[rng.Next(statuses.Length)];
                    var sm = new SubModule
                    {
                        SubModuleGroupId = smg.Id,
                        Name   = smName,
                        Status = smStatus,
                        ProgressPercentage = (decimal)rng.Next(0, 100),
                        CreatedById = userId,
                        ExpectedStartDate = DateOnly.FromDateTime(now.AddDays(-30)),
                        ExpectedEndDate   = DateOnly.FromDateTime(now.AddDays(30)),
                        Remarks   = DemoTag + smName,
                        CreatedAt = now, UpdatedAt = now
                    };
                    db.SubModules.Add(sm);
                    await db.SaveChangesAsync();

                    if (sm.Status != ItemStatus.NotStarted)
                    {
                        db.StatusHistories.Add(new StatusHistory { EntityType = "SubModule", EntityId = sm.Id, OldStatus = "NotStarted", NewStatus = sm.Status.ToString(), ChangedById = userId, Remarks = "Seeded initial status", CreatedAt = now });
                    }

                    for (int ci = 1; ci <= rng.Next(2, 5); ci++)
                    {
                        var chkStatus = statuses[rng.Next(statuses.Length)];
                        var chk = new Checklist
                        {
                            SubModuleId = sm.Id,
                            Name     = $"{smName} – Step {ci}",
                            Status   = chkStatus,
                            Priority = (Priority)rng.Next(0, 4),
                            ProgressPercentage = chkStatus == ItemStatus.Completed ? 100 : (decimal)rng.Next(0, 95),
                            ExpectedStartDate = DateOnly.FromDateTime(now.AddDays(rng.Next(-20, 10))),
                            ExpectedEndDate   = DateOnly.FromDateTime(now.AddDays(rng.Next(5, 45))),
                            CreatedById = userId,
                            Remarks   = DemoTag + $"checklist-{ci}",
                            CreatedAt = now, UpdatedAt = now
                        };
                        db.Checklists.Add(chk);
                        await db.SaveChangesAsync();

                        if (chk.Status != ItemStatus.NotStarted)
                        {
                            db.StatusHistories.Add(new StatusHistory { EntityType = "Checklist", EntityId = chk.Id, OldStatus = "NotStarted", NewStatus = chk.Status.ToString(), ChangedById = userId, Remarks = "Seeded initial status", CreatedAt = now });
                        }

                        // Seed a legacy unmigrated communication log for testing
                        if (ci == 1 && rng.Next(0, 2) == 0)
                        {
                            db.CommunicationLogs.Add(new CommunicationLog
                            {
                                ChecklistId = chk.Id,
                                CommunicationType = "Email",
                                Subject = $"[LEGACY] Discussion: {smName}",
                                Summary = $"Legacy email discussion regarding details of {smName} requirements.",
                                MomContent = "1. Confirm dates\n2. Share mapping document.",
                                CommunicationDate = now.AddDays(-10),
                                Participants = "admin@erp.local, client@gfu.edu",
                                LoggedById = userId,
                                CreatedAt = now
                            });
                        }

                        var seededActivities = new List<Activity>();
                        for (int ai = 0; ai < rng.Next(2, 6); ai++)
                        {
                            var aStatus = statuses[rng.Next(statuses.Length)];
                            var act = new Activity
                            {
                                ChecklistId   = chk.Id,
                                Title         = actTitles[rng.Next(actTitles.Length)],
                                ActivityType  = actTypes[rng.Next(actTypes.Length)],
                                Status        = aStatus,
                                Priority      = (Priority)rng.Next(0, 4),
                                AssignedUserId  = userId,
                                CreatedById     = userId,
                                ResponsibleTeam = teams[rng.Next(teams.Length)],
                                ActualStartDateTime = aStatus != ItemStatus.NotStarted ? now.AddDays(rng.Next(-15, 0)) : null,
                                ActualEndDateTime   = aStatus == ItemStatus.Completed  ? now.AddDays(rng.Next(-5,  0)) : null,
                                ExpectedStartDate = DateOnly.FromDateTime(now.AddDays(rng.Next(-10, 5))),
                                ExpectedEndDate   = DateOnly.FromDateTime(now.AddDays(rng.Next(5, 30))),
                                Remarks   = DemoTag + "activity",
                                CreatedAt = now, UpdatedAt = now
                            };
                            db.Activities.Add(act);
                            seededActivities.Add(act);
                        }
                        await db.SaveChangesAsync();

                        foreach (var act in seededActivities)
                        {
                            if (act.Status != ItemStatus.NotStarted)
                            {
                                db.StatusHistories.Add(new StatusHistory { EntityType = "Activity", EntityId = act.Id, OldStatus = "NotStarted", NewStatus = act.Status.ToString(), ChangedById = userId, Remarks = "Seeded initial status", CreatedAt = now });
                            }
                            db.Notifications.Add(new Notification
                            {
                                UserId = userId,
                                Title = "Demo Activity Assigned",
                                Message = $"You have been assigned to: {act.Title} (Demo)",
                                NotificationType = "info",
                                EntityType = "Activity",
                                EntityId = act.Id,
                                IsRead = false,
                                CreatedAt = now
                            });
                        }
                    }
                }
            }
            await db.SaveChangesAsync();
        }
    }
}
