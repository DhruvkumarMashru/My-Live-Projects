using ErpGovernance.Application.DTOs;

namespace ErpGovernance.Application.Interfaces;

public interface IUserService
{
    Task<IReadOnlyList<UserListDto>> GetAllAsync(int? orgId = null);
    Task<UserFormDto?> GetFormAsync(int id);
    Task<(bool Success, string? Error)> CreateAsync(UserFormDto dto);
    Task<(bool Success, string? Error)> UpdateAsync(UserFormDto dto);
    Task<(bool Success, string? Error)> DeleteAsync(int id);

    /// <summary>Returns Id/FullName pairs for assignment dropdowns, optionally scoped to an org.</summary>
    Task<IReadOnlyList<(int Id, string FullName)>> GetSelectListAsync(int? orgId = null, bool activeOnly = true);

    // ── Profile ──────────────────────────────────────────────────────────────

    Task<ProfileDto?> GetProfileAsync(int userId);
    Task<(bool Success, string? Error)> UpdateProfileAsync(int userId, ProfileDto dto);
}
