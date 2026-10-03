# Role-Based Access Control (RBAC) System Guide

The ERP Governance Platform utilizes a highly granular, dynamic Claims-based Authorization architecture. This document explains how the RBAC system functions, outlines the default system roles, and defines the structural data-isolation rules.

---

## 1. How the Dynamic RBAC System Works

Unlike traditional systems where roles are hardcoded (e.g., `if (user.Role == "Admin")`), this platform uses a dynamic **Permission Matrix**. 

*   **Permissions (Claims):** Actions in the system are broken down into specific string claims (e.g., `Permissions.Projects.View`, `Permissions.Activities.Create`, `Permissions.Users.Delete`).
*   **Roles:** Roles are simply containers for these permissions. You can create an infinite number of custom roles from the UI (e.g., "External Auditor", "HR Lead", "Finance Approver").
*   **Dynamic Enforcement:** The Razor UI and API Controllers evaluate these permissions in real-time. If a user's role lacks the `Permissions.Projects.Create` claim, the "Create Project" button will instantly disappear from their screen, and the backend endpoint will reject the request with a `403 Forbidden`.

---

## 2. Default System Roles & Responsibilities

While you can create custom roles dynamically, the system comes pre-configured with the following core default roles to establish a baseline governance structure:

### 🌟 Super Admin (`super_admin`)
**Scope:** Universal Access
*   **What it does:** Ultimate platform controller. The `super_admin` role programmatically bypasses all granular permission checks to ensure you are never locked out of the system.
*   **Key Capabilities:** 
    *   Can view the global **Audit Logs** (tracking all user logins, role changes, and permission alterations).
    *   Can create and manage all **Organizations**.
    *   Can create new dynamic Roles and alter the Permission Matrix.
    *   Has absolute read/write access to all Projects across all Organizations.

### 🏢 Project HOD (Head of Department) (`project_hod`)
**Scope:** Organization-Level Access
*   **What it does:** Acts as the chief executive for a specific Organization (e.g., the CEO of "Acme Corp").
*   **Key Capabilities:**
    *   Can see *all* Users and *all* Projects belonging exclusively to their Organization.
    *   **Data Isolation:** Cannot see Projects, Users, or Reports belonging to other Organizations.
    *   Can perform Bulk CSV Imports for massive project setups.
    *   Can re-assign Project Managers.

### 📊 Project Manager (`project_manager`)
**Scope:** Project-Level Access
*   **What it does:** The operational leader responsible for driving specific ERP implementations to completion.
*   **Key Capabilities:**
    *   **Data Isolation:** Can only view and manage specific Projects where they are explicitly listed as a Manager.
    *   Can manipulate the Project Hierarchy (Add/Edit Modules, SubModules, Checklists).
    *   Can create Activities and assign them to specific team members.
    *   Monitors progress roll-ups and delays via the Dashboard and Reports.

### 🛠️ ERP Team Member (`erp_team`)
**Scope:** Activity-Level Access
*   **What it does:** The boots-on-the-ground employees or consultants executing the daily tasks of the ERP implementation.
*   **Key Capabilities:**
    *   Can view the structural hierarchy of the projects they are involved in.
    *   Primary function: Executing **Activities**. 
    *   They can add Meeting Notes, change the Status of their assigned activities (e.g., moving "In Progress" to "Completed"), and update expected delivery dates.

### 👁️ Viewer (`viewer`)
**Scope:** Read-Only Access
*   **What it does:** Usually reserved for external stakeholders, executives, or auditors who need to see progress without altering data.
*   **Key Capabilities:**
    *   Can view Dashboards and Progress Reports.
    *   Cannot create, edit, or delete any entities (Projects, Activities, Users).
    *   All action buttons (Create, Save, Delete) are programmatically hidden from their interface.

---

## 3. Auditing & Security Traceability

Any action modifying the RBAC structure is heavily audited to ensure absolute security and compliance:
*   **Role Alterations:** If a user navigates to the Permission Matrix and grants the "Delete Project" permission to the `viewer` role, the `AuditLogs` table will record the exact User ID, timestamp, and the specific claim added.
*   **User Assignment:** If a user promotes an `erp_team` member to `project_manager`, the exact role revocation and promotion events are logged immutably.
