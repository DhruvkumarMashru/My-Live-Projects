# ERP Governance Platform: Comprehensive User Guide

Welcome to the ERP Governance Platform! This guide will walk you through the system step-by-step from the perspective of a brand new user (specifically, the initial Super Administrator). By following this guide, you will learn how to set up the system, structure your projects, and monitor your ERP implementations.

---

## Step 1: First Login & Initial Setup

When you launch the system for the first time, you will start at the **Login Page**.
The system comes pre-seeded with a default Super Admin account so you are never locked out.

**Example Action:**
1. Navigate to the login page.
2. Log in using the default Super Admin credentials (e.g., `admin@erpgovernance.com` / `Admin@123`).
3. You will be greeted by the **Dashboard**, which will currently be empty since no data exists yet.

---

## Step 2: System Administration (Organizations, Roles, Users)

Before creating projects, you need to set up the structural foundation of your platform. 

### A. Creating an Organization
Organizations represent the different companies, clients, or internal business units that own the ERP projects.
1. Click **Organizations** in the Administration sidebar.
2. Click **Create New Organization**.
3. **Example**: Enter "Acme Corp" with code "ACM-01" and save.

### B. Configuring Roles & Permissions (Dynamic RBAC)
You have total control over who sees and does what in the system.
1. Click **Roles & Permissions** in the sidebar.
2. Click **Create New Role**.
3. **Example**: Create a role named "External Auditor".
4. After saving, click **Permissions** next to "External Auditor". 
5. In the permission matrix, check *only* the "View" permissions for Reports, Projects, and Dashboard. Do not give them "Create" or "Edit" permissions. Save the matrix.

### C. Creating Users
Now, let's invite people into the system and assign them to the organizations and roles we just created.
1. Click **Users** in the sidebar.
2. Click **Create New User**.
3. **Example**: Create a user "John Doe" (`john@acmecorp.com`). 
4. Select the **Organization**: "Acme Corp".
5. Select the **System Role**: "External Auditor" (the one you just made).
6. When John logs in, the system will dynamically hide the "Administration" menu from him, and he won't see any "Create" buttons because you didn't give him those permissions!

---

## Step 3: Project Setup & The Hierarchy

The core of this platform is tracking massive ERP implementations. This is done through a 5-level hierarchy: 
**Project ➔ Module ➔ SubModule Group ➔ SubModule ➔ Checklist**.

### A. Creating a Project
1. Click **Projects** in the sidebar, then **New Project**.
2. **Example**: Name the project "Acme SAP S/4HANA Migration". Link it to the "Acme Corp" organization. Assign expected start/end dates.

### B. Building the Hierarchy (Manual vs. Bulk Import)
You have two ways to build out the project tasks:

**Method 1: Manual Creation**
1. Click on your newly created project.
2. Click **Add Module** (e.g., "Finance (FICO)").
3. Inside the Module, click **Add SubModule Group** (e.g., "Accounts Payable").
4. Inside the Group, click **Add SubModule** (e.g., "Vendor Invoicing").
5. Finally, add a **Checklist** (e.g., "Configure Vendor Master Data").

**Method 2: Bulk Import (Recommended)**
For massive ERP projects, manually clicking to create hundreds of modules is tedious.
1. Click **Bulk Import** in the sidebar.
2. Select your Project from the dropdown.
3. Upload a CSV file containing your entire project structure.
4. The system will automatically build the entire 5-level hierarchy in seconds!

---

## Step 4: Daily Operations (Activities & Progress)

Once your hierarchy is built, your teams will execute the actual work via **Activities**.

1. Navigate down your project hierarchy to a specific **Checklist** (e.g., "Configure Vendor Master Data").
2. Click **Add Activity**.
3. **Example**: Add an activity titled "Review Vendor Requirements Document" and assign it to John Doe.
4. **Updating Status**: When John finishes reviewing the document, he changes the Activity Status to **"Completed"**.

> [!TIP] 
> **Automatic Progress Roll-up!**
> You never have to manually calculate project progress. When an Activity is marked completed, the system calculates the progress of the Checklist. That Checklist's progress rolls up to the SubModule, which rolls up to the Module, which instantly updates the overall **Project Progress Percentage**.

---

## Step 5: Monitoring, Reports & Governance

As a project manager or Super Admin, your job is governance.

### A. The Dashboard
Click **Dashboard** to see a bird's-eye view of your entire portfolio.
- **Project Tree**: Visually expand projects down to the checklist level to instantly spot bottlenecks.
- **Summary Cards**: Instantly see how many items are "Delayed" or "Pending".

### B. Reports
Click **Reports** for deep analytical views:
- **Delayed Items Report**: Shows you everything that has passed its Expected End Date without being marked Completed.
- **Responsibility Matrix**: See exactly who is assigned to what, and who is holding up the project.

### C. Audit Logs
Total transparency and security are built-in.
- Click **Audit Logs** (only available to Super Admins).
- **Example**: You will see a chronological log detailing exactly when you created "Acme Corp", when you gave John Doe the "External Auditor" role, and when a project's status was changed. Nothing happens in the system without a trace.

---

### You are now ready!
You now understand how to structure your organizations, dynamically lock down security via custom Roles, instantly build project hierarchies, and track live progress metrics. Happy governing!
