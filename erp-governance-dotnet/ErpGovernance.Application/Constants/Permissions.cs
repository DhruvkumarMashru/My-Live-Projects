namespace ErpGovernance.Application.Constants;

public static class Permissions
{
    public static class Roles
    {
        public const string View = "Permissions.Roles.View";
        public const string Create = "Permissions.Roles.Create";
        public const string Edit = "Permissions.Roles.Edit";
        public const string Delete = "Permissions.Roles.Delete";
        public const string ManagePermissions = "Permissions.Roles.ManagePermissions";
    }

    public static class Users
    {
        public const string View = "Permissions.Users.View";
        public const string Create = "Permissions.Users.Create";
        public const string Edit = "Permissions.Users.Edit";
        public const string Delete = "Permissions.Users.Delete";
        public const string AssignRoles = "Permissions.Users.AssignRoles";
    }

    public static class Organizations
    {
        public const string View = "Permissions.Organizations.View";
        public const string Create = "Permissions.Organizations.Create";
        public const string Edit = "Permissions.Organizations.Edit";
        public const string Delete = "Permissions.Organizations.Delete";
    }

    public static class Projects
    {
        public const string View = "Permissions.Projects.View";
        public const string Create = "Permissions.Projects.Create";
        public const string Edit = "Permissions.Projects.Edit";
        public const string Delete = "Permissions.Projects.Delete";
        public const string ViewSensitiveData = "Permissions.Projects.ViewSensitiveData"; // Field level
    }

    public static class Hierarchy
    {
        public const string View = "Permissions.Hierarchy.View";
        public const string Create = "Permissions.Hierarchy.Create";
        public const string Edit = "Permissions.Hierarchy.Edit";
        public const string Delete = "Permissions.Hierarchy.Delete";
    }

    public static class Activities
    {
        public const string View = "Permissions.Activities.View";
        public const string Create = "Permissions.Activities.Create";
        public const string Edit = "Permissions.Activities.Edit";
        public const string Delete = "Permissions.Activities.Delete";
        public const string ChangeStatus = "Permissions.Activities.ChangeStatus"; // Field level
    }

    public static class Reports
    {
        public const string View = "Permissions.Reports.View";
    }

    public static class Import
    {
        public const string Execute = "Permissions.Import.Execute";
    }
    
    public static class Audit
    {
        public const string View = "Permissions.Audit.View";
    }

    // Helper to get all permissions dynamically via reflection for the UI
    public static List<string> GetAllPermissions()
    {
        var allPermissions = new List<string>();
        var modules = typeof(Permissions).GetNestedTypes();

        foreach (var module in modules)
        {
            var fields = module.GetFields(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.FlattenHierarchy);
            foreach (var field in fields)
            {
                var val = field.GetValue(null)?.ToString();
                if (!string.IsNullOrEmpty(val))
                    allPermissions.Add(val);
            }
        }
        return allPermissions;
    }
}
