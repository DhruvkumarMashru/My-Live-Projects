using ErpGovernance.Application.Interfaces;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace ErpGovernance.Infrastructure.Services;

public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    private ClaimsPrincipal? User => _httpContextAccessor.HttpContext?.User;

    public int UserId
    {
        get
        {
            var claim = User?.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(claim, out var id) ? id : 0;
        }
    }

    public string UserName => User?.FindFirstValue(ClaimTypes.Name) ?? string.Empty;
    public string Role => User?.FindFirstValue(ClaimTypes.Role) ?? string.Empty;
    public bool IsAuthenticated => User?.Identity?.IsAuthenticated ?? false;
    public bool IsSuperAdmin => Role == "super_admin";
    public bool IsProjectHodOrAbove => IsSuperAdmin || Role == "project_hod";
    public bool CanEditHierarchy => IsSuperAdmin || Role is "project_hod" or "project_manager" or "erp_team";
}
