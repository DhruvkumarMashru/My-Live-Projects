using ErpGovernance.Infrastructure.Data;

namespace ErpGovernance.Infrastructure.Services;

public interface IProgressRollupService
{
    Task RecalcFromChecklistAsync(int checklistId, ApplicationDbContext db);
    Task RecalcFromModuleAsync(int moduleId, ApplicationDbContext db);
}
