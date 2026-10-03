using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Enums;
using ErpGovernance.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace ErpGovernance.Infrastructure.Services;

public class ProjectScopeService : IProjectScopeService
{
    private readonly ApplicationDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IMemoryCache _cache;

    public ProjectScopeService(
        ApplicationDbContext db,
        ICurrentUserService currentUser,
        IMemoryCache cache)
    {
        _db = db;
        _currentUser = currentUser;
        _cache = cache;
    }

    public async Task<IReadOnlyList<int>?> GetAccessibleProjectIdsAsync()
    {
        if (!_currentUser.IsAuthenticated) return new List<int>();
        if (_currentUser.IsSuperAdmin) return null; // null = all access

        var cacheKey = $"project_scope_{_currentUser.UserId}";
        if (_cache.TryGetValue<IReadOnlyList<int>>(cacheKey, out var cached) && cached != null)
            return cached;

        List<int> projectIds;
        var role = _currentUser.Role;

        if (role is "project_hod" or "project_manager")
        {
            // Access projects where user is a project manager
            projectIds = await _db.ProjectManagers
                .Where(pm => pm.UserId == _currentUser.UserId)
                .Select(pm => pm.ProjectId)
                .ToListAsync();
        }
        else
        {
            // Other roles: access projects in their organization
            var user = await _db.Users
                .Where(u => u.Id == _currentUser.UserId)
                .Select(u => new { u.OrganizationId })
                .FirstOrDefaultAsync();

            if (user?.OrganizationId == null)
                return new List<int>();

            projectIds = await _db.Projects
                .Where(p => p.OrganizationId == user.OrganizationId)
                .Select(p => p.Id)
                .ToListAsync();
        }

        var result = (IReadOnlyList<int>)projectIds;
        _cache.Set(cacheKey, result, new MemoryCacheEntryOptions
        {
            SlidingExpiration = TimeSpan.FromMinutes(10)
        });

        return result;
    }

    public async Task<bool> CanAccessProjectAsync(int projectId)
    {
        var accessibleIds = await GetAccessibleProjectIdsAsync();
        if (accessibleIds == null) return true; // Super Admin
        return accessibleIds.Contains(projectId);
    }
}
