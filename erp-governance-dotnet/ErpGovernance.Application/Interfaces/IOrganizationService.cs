using ErpGovernance.Application.DTOs;

namespace ErpGovernance.Application.Interfaces;

public interface IOrganizationService
{
    Task<IReadOnlyList<OrganizationListDto>> GetAllAsync();
    Task<OrganizationFormDto?> GetByIdAsync(int id);
    Task<(bool Success, string? Error)> CreateAsync(OrganizationFormDto dto);
    Task<(bool Success, string? Error)> UpdateAsync(OrganizationFormDto dto);
    Task<(bool Success, string? Error)> DeleteAsync(int id);

    /// <summary>Returns Id/Name pairs for dropdowns, ordered alphabetically. Optionally only active orgs.</summary>
    Task<IReadOnlyList<(int Id, string Name)>> GetSelectListAsync(bool activeOnly = true);
}
