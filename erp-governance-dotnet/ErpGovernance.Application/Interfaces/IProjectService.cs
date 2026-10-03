using ErpGovernance.Application.DTOs;

namespace ErpGovernance.Application.Interfaces;

public interface IProjectService
{
    Task<IReadOnlyList<ProjectListDto>> GetAllAsync(int? orgId = null);
    Task<ProjectDetailDto?> GetDetailAsync(int id);
    Task<ProjectFormDto?> GetFormAsync(int id);
    Task<(bool Success, string? Error)> CreateAsync(ProjectFormDto dto);
    Task<(bool Success, string? Error)> UpdateAsync(ProjectFormDto dto);
    Task<(bool Success, string? Error)> DeleteAsync(int id);

    /// <summary>Returns Id/Name pairs for project dropdowns, scoped to the current user's accessible projects.</summary>
    Task<IReadOnlyList<(int Id, string Name)>> GetSelectListAsync(int? orgId = null);
}
