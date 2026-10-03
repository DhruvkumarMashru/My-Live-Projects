using ErpGovernance.Domain.Enums;

namespace ErpGovernance.Web.Helpers;

/// <summary>Static helpers for display formatting — used in Razor views.</summary>
public static class DisplayHelpers
{
    public static string StatusBadgeClass(string status) => status switch
    {
        "draft" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700",
        "not_started" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-700",
        "in_progress" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800",
        "pending_erp" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-800",
        "pending_university" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800",
        "on_hold" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800",
        "delayed" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800",
        "completed" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800",
        "approved" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800",
        "rejected" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-rose-100 text-rose-800",
        _ => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-700"
    };

    public static string StatusLabel(string status) => status switch
    {
        "draft" => "Draft",
        "not_started" => "Not Started",
        "in_progress" => "In Progress",
        "pending_erp" => "Pending ERP",
        "pending_university" => "Pending University",
        "on_hold" => "On Hold",
        "delayed" => "Delayed",
        "completed" => "Completed",
        "approved" => "Approved",
        "rejected" => "Rejected",
        _ => status
    };

    public static string PriorityBadgeClass(string priority) => priority switch
    {
        "low" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-600",
        "medium" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-sky-100 text-sky-700",
        "high" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-700",
        "critical" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-700",
        _ => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-600"
    };

    public static string ActivityTypeBadgeClass(string type) => type switch
    {
        "task" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-slate-100 text-slate-700",
        "email" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-sky-100 text-sky-800",
        "call" or "follow_up_call" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-amber-100 text-amber-800",
        "online_meeting" or "meeting" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-violet-100 text-violet-800",
        "physical_meeting" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-purple-100 text-purple-800",
        "mom" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-sky-100 text-sky-900",
        "whatsapp" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800",
        "approval" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-emerald-100 text-emerald-800",
        "uat" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-orange-100 text-orange-800",
        "escalation" => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800",
        _ => "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-700"
    };

    public static string ActivityTypeLabel(string type) => type switch
    {
        "task" => "Task",
        "email" => "Email",
        "call" => "Phone Call",
        "follow_up_call" => "Follow-up Call",
        "follow_up" => "Follow-up",
        "online_meeting" => "Online Meeting",
        "physical_meeting" => "Physical Meeting",
        "meeting" => "Meeting",
        "discussion" => "Discussion",
        "mom" => "MOM",
        "whatsapp" => "WhatsApp",
        "review" => "Review",
        "approval" => "Approval",
        "uat" => "UAT",
        "escalation" => "Escalation",
        _ => type
    };

    public static string RoleBadgeClass(string role) => role switch
    {
        "super_admin" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800",
        "project_hod" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800",
        "project_manager" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800",
        "erp_team" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-cyan-100 text-cyan-800",
        "university_user" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-teal-100 text-teal-800",
        "reviewer" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-800",
        "viewer" => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700",
        _ => "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-700"
    };

    public static string RoleLabel(string role) => role switch
    {
        "super_admin" => "Super Admin",
        "project_hod" => "Project HOD",
        "project_manager" => "Project Manager",
        "erp_team" => "ERP Team",
        "university_user" => "University User",
        "reviewer" => "Reviewer",
        "viewer" => "Viewer",
        _ => role
    };

    public static string FormatDate(DateOnly? date) =>
        date.HasValue ? date.Value.ToString("dd MMM yyyy") : "—";

    public static string FormatDateTime(DateTime? dt) =>
        dt.HasValue ? dt.Value.ToString("dd MMM yyyy HH:mm") : "—";

    public static string FormatDateTimeIst(DateTime? dt) =>
        dt.HasValue ? TimeZoneInfo.ConvertTimeFromUtc(dt.Value,
            TimeZoneInfo.FindSystemTimeZoneById("India Standard Time")).ToString("dd MMM yyyy HH:mm") : "—";

    public static int DaysDelayed(DateOnly? expectedEnd) =>
        expectedEnd.HasValue ? (DateOnly.FromDateTime(DateTime.Today).DayNumber - expectedEnd.Value.DayNumber) : 0;

    public static string ProgressColorClass(decimal pct) => pct switch
    {
        >= 100 => "bg-emerald-500",
        >= 75 => "bg-green-500",
        >= 50 => "bg-blue-500",
        >= 25 => "bg-amber-500",
        _ => "bg-slate-400"
    };
}
