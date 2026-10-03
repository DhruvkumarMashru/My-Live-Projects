using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Entities;
using ErpGovernance.Infrastructure.Data;
using ErpGovernance.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace ErpGovernance.Infrastructure;

/// <summary>
/// Composition root for the Infrastructure layer.
/// Call <see cref="AddInfrastructure"/> from your Web project's Program.cs.
/// </summary>
public static class DependencyInjection
{
    /// <summary>
    /// Registers all infrastructure services: EF Core, Identity, cookie auth,
    /// and all application interface implementations.
    /// </summary>
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // ── Database ─────────────────────────────────────────────────────────
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection"),
                sql =>
                {
                    sql.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName);
                    sql.EnableRetryOnFailure(
                        maxRetryCount: 5,
                        maxRetryDelay: TimeSpan.FromSeconds(30),
                        errorNumbersToAdd: null);
                    sql.CommandTimeout(60);
                }));

        // ── ASP.NET Core Identity ─────────────────────────────────────────────
        services.AddIdentity<AppUser, IdentityRole<int>>(options =>
            {
                // Password policy
                options.Password.RequireDigit           = true;
                options.Password.RequiredLength         = 8;
                options.Password.RequireNonAlphanumeric = false;
                options.Password.RequireUppercase       = true;
                options.Password.RequireLowercase       = true;

                // Lockout policy — lock after 5 consecutive failures for 15 minutes
                options.Lockout.DefaultLockoutTimeSpan  = TimeSpan.FromMinutes(15);
                options.Lockout.MaxFailedAccessAttempts = 5;
                options.Lockout.AllowedForNewUsers      = true;

                // User options
                options.User.RequireUniqueEmail = true;

                // Sign-in options
                options.SignIn.RequireConfirmedEmail = false;
            })
            .AddEntityFrameworkStores<ApplicationDbContext>()
            .AddDefaultTokenProviders();

        // ── Cookie authentication ─────────────────────────────────────────────
        services.ConfigureApplicationCookie(options =>
        {
            options.LoginPath          = "/Account/Login";
            options.LogoutPath         = "/Account/Logout";
            options.AccessDeniedPath   = "/Account/AccessDenied";
            options.SlidingExpiration  = true;
            options.ExpireTimeSpan     = TimeSpan.FromHours(8);
            options.Cookie.HttpOnly    = true;
            options.Cookie.SecurePolicy = Microsoft.AspNetCore.Http.CookieSecurePolicy.Always;
            options.Cookie.SameSite    = Microsoft.AspNetCore.Http.SameSiteMode.Strict;
            options.Cookie.Name        = "ErpGov.Auth";

            options.Events = new CookieAuthenticationEvents
            {
                OnRedirectToLogin = ctx =>
                {
                    // Return 401 for AJAX/API requests instead of a redirect
                    if (ctx.Request.Headers.XRequestedWith == "XMLHttpRequest")
                    {
                        ctx.Response.StatusCode = 401;
                        return Task.CompletedTask;
                    }
                    ctx.Response.Redirect(ctx.RedirectUri);
                    return Task.CompletedTask;
                },
                OnRedirectToAccessDenied = ctx =>
                {
                    if (ctx.Request.Headers.XRequestedWith == "XMLHttpRequest")
                    {
                        ctx.Response.StatusCode = 403;
                        return Task.CompletedTask;
                    }
                    ctx.Response.Redirect(ctx.RedirectUri);
                    return Task.CompletedTask;
                }
            };
        });

        // ── HTTP Context ──────────────────────────────────────────────────────
        services.AddHttpContextAccessor();

        // ── In-Memory Cache (used by ProjectScopeService) ─────────────────────
        services.AddMemoryCache();

        // ── Application Services ──────────────────────────────────────────────
        services.AddScoped<ICurrentUserService,     CurrentUserService>();
        services.AddScoped<IProjectScopeService,    ProjectScopeService>();
        services.AddScoped<IAuditService,           AuditService>();
        services.AddScoped<INotificationService,    NotificationService>();
        services.AddScoped<IFileStorageService,     FileStorageService>();
        services.AddScoped<IProgressRollupService,  ProgressRollupService>();

        // ── Dynamic RBAC Authorization ────────────────────────────────────────
        services.AddSingleton<Microsoft.AspNetCore.Authorization.IAuthorizationPolicyProvider, ErpGovernance.Infrastructure.Authorization.PermissionPolicyProvider>();
        services.AddScoped<Microsoft.AspNetCore.Authorization.IAuthorizationHandler, ErpGovernance.Infrastructure.Authorization.PermissionAuthorizationHandler>();

        return services;
    }
}
