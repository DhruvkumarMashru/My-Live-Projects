# ERP Governance Platform — Setup & Database Guide

This guide details the database used by the ERP Governance Platform and provides setup instructions for running the platform locally.

---

## 🗄️ Database Information
* **Database Engine**: **Microsoft SQL Server Express LocalDB** (included by default with Visual Studio and SQL Server Express).
* **Connection String**: `Server=(localdb)\mssqllocaldb;Database=ErpGovernanceDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True`
* **Authentication**: Integrated Security (Windows Authentication/Trusted Connection).
* **Auto-Migration**: The application automatically checks and applies any pending Entity Framework (EF Core) schema migrations on startup.

---

## 🛠️ Prerequisites
Before running the platform, ensure you have the following installed on your machine:
1. **.NET SDK** (v8.0, v9.0, or v10.0)
   * [Download .NET SDK](https://dotnet.microsoft.com/download)
2. **Microsoft SQL Server LocalDB**
   * Typically installed automatically with Visual Studio (under ".NET desktop development" or "ASP.NET and web development" workloads).
   * Alternatively, you can download the standalone installer for SQL Server LocalDB: [Microsoft SQL Server LocalDB installer](https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/sql-server-express-localdb).
3. **Local Storage Drive**:
   * The platform saves attachments in `D:\ErpGovernanceUploads` by default. If your machine does not have a `D:` drive, the setup script will fallback to `C:\ErpGovernanceUploads` and you will need to update the base path in `ErpGovernance.Web/appsettings.json`.

---

## 🚀 Quick Setup Instructions

### Step 1: Run Setup
Double-click and run the **`setup.bat`** file located in the root of the workspace. This script will:
1. Verify that the `.NET SDK` is installed.
2. Search for the `sqllocaldb` utility and make sure it's in your PATH.
3. Automatically create and start the `mssqllocaldb` database instance.
4. Setup the local file uploads storage folder (`D:\ErpGovernanceUploads` or `C:\ErpGovernanceUploads`).
5. Restore NuGet dependencies and build the solution.

### Step 2: Configure Base Path (If using fallback C: drive)
If the setup script warned you that a `D:` drive was not found:
1. Open the [appsettings.json](file:///d:/Project%20Dashboard/ErpGovernance/ErpGovernance.Web/appsettings.json#L6) file in a text editor.
2. Change the `FileStorage:BasePath` line:
   ```json
   "FileStorage": {
     "BasePath": "C:\\ErpGovernanceUploads"
   }
   ```

### Step 3: Run the Server
Double-click and run the **`run_server.bat`** file in the root. This will compile the code and start the local Kestrel web server.
* The application runs on: **`http://localhost:5297`**

---

## 🔑 Logging In and Seeding Demo Data
1. Open your browser and navigate to `http://localhost:5297`.
2. On the login page, click the **"Use Demo Credentials"** button. This pre-fills:
   * **Email**: `admin@erp.local`
   * **Password**: `Admin@123456`
3. Click **"Sign In"**.
4. Once on the dashboard, look at the top amber **"Demo Mode"** bar and click the **"Seed Demo Data"** button.
   * This seeds a rich set of organizations, projects, modules, checklists, activities, legacy communication logs, notifications, and status change history logs, so you can test all features immediately.
5. To wipe the demo data and return the database to a clean state, click the **"Remove Demo Data"** button in the same bar.
