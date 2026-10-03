namespace ErpGovernance.Application.Interfaces;

public interface IProjectScopeService
{
    /// <summary>Returns project IDs accessible to the current user. Null = all projects (Super Admin).</summary>
    Task<IReadOnlyList<int>?> GetAccessibleProjectIdsAsync();

    /// <summary>Returns true if the current user can access the given project.</summary>
    Task<bool> CanAccessProjectAsync(int projectId);
}
