using System.ComponentModel.DataAnnotations;

namespace ErpGovernance.Domain.Enums;

public enum ActivityType
{
    [Display(Name = "Task")]
    Task,

    [Display(Name = "Email")]
    Email,

    [Display(Name = "Phone Call")]
    Call,

    [Display(Name = "Follow-up Call")]
    FollowUpCall,

    [Display(Name = "Follow-up")]
    FollowUp,

    [Display(Name = "Online Meeting")]
    OnlineMeeting,

    [Display(Name = "Physical Meeting")]
    PhysicalMeeting,

    [Display(Name = "Meeting")]
    Meeting,

    [Display(Name = "Discussion")]
    Discussion,

    [Display(Name = "Minutes of Meeting (MOM)")]
    Mom,

    [Display(Name = "WhatsApp Follow-up")]
    Whatsapp,

    [Display(Name = "Review Discussion")]
    Review,

    [Display(Name = "Approval")]
    Approval,

    [Display(Name = "UAT")]
    Uat,

    [Display(Name = "Escalation")]
    Escalation
}
