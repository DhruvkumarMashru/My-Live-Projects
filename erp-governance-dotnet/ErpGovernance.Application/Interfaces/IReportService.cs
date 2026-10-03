using ErpGovernance.Application.DTOs;

namespace ErpGovernance.Application.Interfaces;

public interface IReportService
{
    /// <summary>Flat progress report across all checklist items matching the filter.</summary>
    Task<IReadOnlyList<ProgressReportDto>> GetProgressReportAsync(ReportFilterDto filter);

    /// <summary>All items whose ExpectedEndDate has passed and status is not terminal.</summary>
    Task<IReadOnlyList<DelayedItemDto>> GetDelayedItemsAsync(ReportFilterDto filter);

    /// <summary>Items that are active but not yet completed.</summary>
    Task<IReadOnlyList<PendingItemDto>> GetPendingItemsAsync(ReportFilterDto filter);

    /// <summary>Responsibility matrix: who is assigned to what, with status and deadline.</summary>
    Task<IReadOnlyList<ResponsibilityItemDto>> GetResponsibilityReportAsync(ReportFilterDto filter);
}
