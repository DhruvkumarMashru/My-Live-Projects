using ErpGovernance.Application.DTOs;

namespace ErpGovernance.Application.Interfaces;

public interface IModuleService
{
    Task<IReadOnlyList<ModuleListDto>> GetByProjectAsync(int projectId);
    Task<ModuleFormDto?> GetFormAsync(int id);
    Task<(bool Success, string? Error)> CreateAsync(ModuleFormDto dto);
    Task<(bool Success, string? Error)> UpdateAsync(ModuleFormDto dto);
    Task<(bool Success, string? Error)> DeleteAsync(int id);
    Task<IReadOnlyList<(int Id, string Name)>> GetSelectListAsync(int projectId);
}

public interface ISubModuleGroupService
{
    Task<IReadOnlyList<SubModuleGroupListDto>> GetByModuleAsync(int moduleId);
    Task<SubModuleGroupFormDto?> GetFormAsync(int id);
    Task<(bool Success, string? Error)> CreateAsync(SubModuleGroupFormDto dto);
    Task<(bool Success, string? Error)> UpdateAsync(SubModuleGroupFormDto dto);
    Task<(bool Success, string? Error)> DeleteAsync(int id);
    Task<IReadOnlyList<(int Id, string Name)>> GetSelectListAsync(int moduleId);
}

public interface ISubModuleService
{
    Task<IReadOnlyList<SubModuleListDto>> GetBySubModuleGroupAsync(int subModuleGroupId);
    Task<SubModuleFormDto?> GetFormAsync(int id);
    Task<(bool Success, string? Error)> CreateAsync(SubModuleFormDto dto);
    Task<(bool Success, string? Error)> UpdateAsync(SubModuleFormDto dto);
    Task<(bool Success, string? Error)> DeleteAsync(int id);
    Task<IReadOnlyList<(int Id, string Name)>> GetSelectListAsync(int subModuleGroupId);
}

public interface IChecklistService
{
    Task<IReadOnlyList<ChecklistListDto>> GetBySubModuleAsync(int subModuleId);
    Task<ChecklistFormDto?> GetFormAsync(int id);
    Task<(bool Success, string? Error)> CreateAsync(ChecklistFormDto dto);
    Task<(bool Success, string? Error)> UpdateAsync(ChecklistFormDto dto);
    Task<(bool Success, string? Error)> DeleteAsync(int id);
    Task<IReadOnlyList<(int Id, string Name)>> GetSelectListAsync(int subModuleId);
}
