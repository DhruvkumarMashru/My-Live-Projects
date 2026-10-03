namespace ErpGovernance.Application.Interfaces;

public interface ICurrentUserService
{
    int UserId { get; }
    string UserName { get; }
    string Role { get; }
    bool IsAuthenticated { get; }
    bool IsSuperAdmin { get; }
    bool IsProjectHodOrAbove { get; }
    bool CanEditHierarchy { get; }
}
