using ErpGovernance.Application.DTOs;

namespace ErpGovernance.Application.Interfaces;

public interface IActivityService
{
    Task<IReadOnlyList<ActivityListDto>> GetByChecklistAsync(int checklistId);
    Task<ActivityDetailDto?> GetDetailAsync(int id);
    Task<ActivityFormDto?> GetFormAsync(int id);
    Task<(bool Success, string? Error)> CreateAsync(ActivityFormDto dto);
    Task<(bool Success, string? Error)> UpdateAsync(ActivityFormDto dto);
    Task<(bool Success, string? Error)> DeleteAsync(int id);
}
