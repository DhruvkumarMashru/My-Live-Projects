using System.ComponentModel.DataAnnotations;

namespace ErpGovernance.Domain.Enums;

public enum Priority
{
    [Display(Name = "Low")]
    Low,

    [Display(Name = "Medium")]
    Medium,

    [Display(Name = "High")]
    High,

    [Display(Name = "Critical")]
    Critical
}
