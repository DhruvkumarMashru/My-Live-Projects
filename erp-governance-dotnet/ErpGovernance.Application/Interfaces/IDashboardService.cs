using ErpGovernance.Application.DTOs;

namespace ErpGovernance.Application.Interfaces;

public interface IDashboardService
{
    /// <summary>Returns aggregated KPI counts for the dashboard header.</summary>
    Task<DashboardSummaryDto> GetSummaryAsync(DashboardFilterDto filter);

    /// <summary>
    /// Returns the complete project hierarchy tree (Project → Module → SubModuleGroup
    /// → SubModule → Checklist → Activities) for the current user's accessible scope.
    /// </summary>
    Task<IReadOnlyList<ProjectTreeDto>> GetProjectTreeAsync(DashboardFilterDto filter);
}
