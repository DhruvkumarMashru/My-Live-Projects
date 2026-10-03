using System.ComponentModel.DataAnnotations;

namespace ErpGovernance.Domain.Enums;

public enum ItemStatus
{
    [Display(Name = "Draft")]
    Draft,

    [Display(Name = "Not Started")]
    NotStarted,

    [Display(Name = "In Progress")]
    InProgress,

    [Display(Name = "Pending from ERP Team")]
    PendingErp,

    [Display(Name = "Pending from University")]
    PendingUniversity,

    [Display(Name = "On Hold")]
    OnHold,

    [Display(Name = "Delayed")]
    Delayed,

    [Display(Name = "Completed")]
    Completed,

    [Display(Name = "Approved")]
    Approved,

    [Display(Name = "Rejected")]
    Rejected
}
