using ErpGovernance.Infrastructure;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

// ─── Infrastructure services (EF, Identity, all app services) ───────────────
builder.Services.AddInfrastructure(builder.Configuration);

// ─── MVC + Razor Views ───────────────────────────────────────────────────────
builder.Services.AddControllersWithViews(options =>
{
    // Global anti-forgery filter on all POST/PUT/DELETE
    options.Filters.Add(new Microsoft.AspNetCore.Mvc.AutoValidateAntiforgeryTokenAttribute());
});
builder.Services.AddRazorPages();
builder.Services.AddAntiforgery(options =>
{
    options.HeaderName = "X-CSRF-TOKEN";
    options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
    options.Cookie.SameSite = SameSiteMode.Strict;
    options.Cookie.HttpOnly = true;
});

// ─── Response Compression ────────────────────────────────────────────────────
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
});

// ─── Rate Limiting (Login protection) ────────────────────────────────────────
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("login", cfg =>
    {
        cfg.PermitLimit = 10;
        cfg.Window = TimeSpan.FromMinutes(1);
        cfg.QueueProcessingOrder = System.Threading.RateLimiting.QueueProcessingOrder.OldestFirst;
        cfg.QueueLimit = 2;
    });
});

// ─── Memory Cache ─────────────────────────────────────────────────────────────
builder.Services.AddMemoryCache();

// ─── Session ─────────────────────────────────────────────────────────────────
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.Cookie.SameSite = SameSiteMode.Strict;
    options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
});

var app = builder.Build();

// ─── Exception Handling ───────────────────────────────────────────────────────
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

// ─── Security Headers ─────────────────────────────────────────────────────────
app.Use(async (context, next) =>
{
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["X-Frame-Options"] = "SAMEORIGIN";
    context.Response.Headers["X-XSS-Protection"] = "1; mode=block";
    context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
    context.Response.Headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()";
    await next();
});

// Self-healing middleware: Intercept 400 Bad Request (typically due to stale/mismatched Antiforgery tokens) on Login/Logout and redirect to Login GET for a fresh token.
app.Use(async (context, next) =>
{
    await next();
    if (context.Response.StatusCode == 400 && !context.Response.HasStarted &&
        (context.Request.Path.StartsWithSegments("/Account/Login") || context.Request.Path.StartsWithSegments("/Account/Logout")))
    {
        var returnUrl = context.Request.Query["returnUrl"];
        var redirectUrl = "/Account/Login";
        if (!string.IsNullOrEmpty(returnUrl))
        {
            redirectUrl += "?returnUrl=" + System.Net.WebUtility.UrlEncode(returnUrl);
        }
        context.Response.Redirect(redirectUrl);
    }
});

app.UseResponseCompression();
app.UseHttpsRedirection();
app.UseStaticFiles(new StaticFileOptions
{
    OnPrepareResponse = ctx =>
    {
        ctx.Context.Response.Headers["Cache-Control"] = "public,max-age=31536000";
    }
});

app.UseRouting();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.UseSession();

// ─── Routes ───────────────────────────────────────────────────────────────────
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Dashboard}/{action=Index}/{id?}");
app.MapRazorPages();

// ─── Auto-migrate + Seed on startup ──────────────────────────────────────────
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await db.Database.MigrateAsync();

    // Seed super admin if no users exist
    var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ErpGovernance.Domain.Entities.AppUser>>();
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<Microsoft.AspNetCore.Identity.IdentityRole<int>>>();

    // Create roles
    var roles = new[] { "super_admin", "project_hod", "project_manager", "erp_team", "university_user", "reviewer", "viewer" };
    foreach (var role in roles)
    {
        if (!await roleManager.RoleExistsAsync(role))
            await roleManager.CreateAsync(new Microsoft.AspNetCore.Identity.IdentityRole<int>(role));
    }

    // Seed default super admin
    if (!userManager.Users.Any())
    {
        var admin = new ErpGovernance.Domain.Entities.AppUser
        {
            FullName = "Super Administrator",
            UserName = "admin@erp.local",
            Email = "admin@erp.local",
            Role = ErpGovernance.Domain.Enums.UserRole.SuperAdmin,
            IsActive = true,
            EmailConfirmed = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        var result = await userManager.CreateAsync(admin, "Admin@123456");
        if (result.Succeeded)
            await userManager.AddToRoleAsync(admin, "super_admin");
    }
}

app.Run();
