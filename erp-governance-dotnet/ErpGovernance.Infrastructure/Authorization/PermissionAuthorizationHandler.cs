using ErpGovernance.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;

namespace ErpGovernance.Infrastructure.Authorization;

public class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
{
    public PermissionAuthorizationHandler()
    {
    }

    protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
    {
        if (context.User == null)
            return Task.CompletedTask;

        // In a real application, you might load permissions from a cache or db.
        // For Identity, if the claims are already on the user principal (via ClaimsPrincipalFactory),
        // we just check if the claim exists.
        
        // ASP.NET Identity automatically includes Role claims in the User principal if they are signed in.
        var hasPermission = context.User.HasClaim(c => c.Type == "Permission" && c.Value == requirement.Permission);

        // Super Admin bypass
        if (context.User.IsInRole("super_admin") || hasPermission)
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}
