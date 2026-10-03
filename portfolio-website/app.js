/* ==========================================================================
   DHRUVKUMAR MASHRU - JAVASCRIPT LOGIC & HIGH-FIDELITY ASSETS ENGINE (v2.4)
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {

  // ========================================================================
  // 0. HEADER SCROLL EFFECT
  // ========================================================================
  const mainHeader = document.getElementById('main-header');
  if (mainHeader) {
    window.addEventListener('scroll', () => {
      if (window.scrollY > 80) {
        mainHeader.classList.add('scrolled');
      } else {
        mainHeader.classList.remove('scrolled');
      }
    });
  }

  // ========================================================================
  // 1. MOBILE NAV DRAWER TOGGLE
  // ========================================================================
  const navDrawer = document.getElementById('mobile-nav-drawer');
  const hamburgerBtn = document.getElementById('nav-hamburger-btn');

  if (hamburgerBtn && navDrawer) {
    hamburgerBtn.addEventListener('click', () => {
      navDrawer.classList.toggle('active');
    });

    navDrawer.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        navDrawer.classList.remove('active');
      });
    });
  }

  // ========================================================================
  // 2. DK'S SQL BUDDY INTERACTIVE SHOWCASE SWITCHER
  // ========================================================================
  window.switchSqlBuddyThumb = (thumbEl, imgSrc) => {
    const mainImg = document.getElementById('sql-buddy-main-display');
    if (mainImg) {
      mainImg.style.opacity = '0.3';
      setTimeout(() => {
        mainImg.src = imgSrc;
        mainImg.style.opacity = '1';
      }, 150);
    }
    document.querySelectorAll('.sql-buddy-thumb').forEach(t => t.classList.remove('active'));
    if (thumbEl) thumbEl.classList.add('active');
  };

  // ========================================================================
  // 3. CASE STUDY DATASET (19 FULL COMMERCIAL SYSTEMS)
  // ========================================================================
  const caseStudies = {
    sqlbuddy: {
      title: "DK's SQL Buddy – Enterprise Schema-Aware AI SQL Database Platform",
      category: "Enterprise AI & SQL Database Systems",
      client: "Enterprise ERP, DBAs & High-Scale Systems",
      timeline: "Production Delivery (Enterprise Platform)",
      heroView: `
        <div style="position:relative; margin-bottom:16px;">
          <img id="modal-sql-hero-img" src="assets/sql_buddy/Screenshot_2026-08-27_163330.png" alt="DK's SQL Buddy Interface" class="modal-case-study-hero-banner" style="width:100%; max-height:420px; object-fit:contain; background:#070B1E; border-radius:var(--radius-sm); border:1px solid rgba(168, 85, 247, 0.4);">
          <div style="display:flex; gap:8px; margin-top:10px; overflow-x:auto; padding-bottom:4px;">
            <img src="assets/sql_buddy/Screenshot_2026-08-27_163330.png" style="width:70px; height:45px; object-fit:cover; border-radius:4px; border:1px solid #A855F7; cursor:pointer;" onclick="document.getElementById('modal-sql-hero-img').src=this.src" title="Conversational AI Copilot">
            <img src="assets/sql_buddy/Screenshot_2026-08-27_163340.png" style="width:70px; height:45px; object-fit:cover; border-radius:4px; border:1px solid rgba(255,255,255,0.2); cursor:pointer;" onclick="document.getElementById('modal-sql-hero-img').src=this.src" title="Tri-Mode JOIN Resolver">
            <img src="assets/sql_buddy/Screenshot_2026-08-27_163349.png" style="width:70px; height:45px; object-fit:cover; border-radius:4px; border:1px solid rgba(255,255,255,0.2); cursor:pointer;" onclick="document.getElementById('modal-sql-hero-img').src=this.src" title="Excel to SQL Migration Wizard">
            <img src="assets/sql_buddy/Screenshot_2026-08-27_163409.png" style="width:70px; height:45px; object-fit:cover; border-radius:4px; border:1px solid rgba(255,255,255,0.2); cursor:pointer;" onclick="document.getElementById('modal-sql-hero-img').src=this.src" title="Super AI Studio - Data Health">
            <img src="assets/sql_buddy/Screenshot_2026-08-27_163423.png" style="width:70px; height:45px; object-fit:cover; border-radius:4px; border:1px solid rgba(255,255,255,0.2); cursor:pointer;" onclick="document.getElementById('modal-sql-hero-img').src=this.src" title="Enterprise Schema Tree">
            <img src="assets/sql_buddy/Screenshot_2026-08-27_163035.png" style="width:70px; height:45px; object-fit:cover; border-radius:4px; border:1px solid rgba(255,255,255,0.2); cursor:pointer;" onclick="document.getElementById('modal-sql-hero-img').src=this.src" title="Enterprise Auth Screen">
          </div>
        </div>
        <div style="padding: 14px; background: rgba(18, 24, 60, 0.8); border-radius: var(--radius-sm); border: 1px solid var(--border-purple);">
          <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
            <span style="color: var(--neon-purple); font-weight: bold;"><i class="fas fa-database"></i> 47 Live Databases • 3,474 Tables • 8,001 Relational Edges</span>
            <span style="background: rgba(168, 85, 247, 0.2); color: var(--neon-violet); padding: 2px 8px; border-radius: 4px; font-size: 0.75rem; font-family: var(--font-mono);">Zero-Latency In-Memory Intelligence</span>
          </div>
        </div>
      `,
      problem: "Navigating massive enterprise database architectures with dozens of fragmented databases, thousands of tables, and legacy naming conventions is one of the biggest bottlenecks for software engineers, ERP developers, and DBAs. Manual SQL joins, reporting lookups, and error-prone Excel data imports cost hundreds of developer hours.",
      solution: "Engineered DK's SQL Buddy — an Enterprise Schema-Aware AI SQL Database Platform that indexes 47 live Microsoft SQL Server databases, 3,474 tables, and 8,001 foreign key relations with zero latency. Features natural-language conversational reasoning, a tri-mode JOIN resolver, an Excel-to-SQL migration wizard with dry-run rollback simulations, and a Data Health Doctor with Index Advisors.",
      architecture: [
        "In-Memory Schema Graph Engine: Maps 8,001 foreign key edges for sub-second relation path traversal",
        "Conversational AI SQL Copilot: Multi-turn reasoning with domain affinity and 1-click live row retrieval",
        "Tri-Mode Relational JOIN Resolver: Automatic junction table discovery via table names, plain English goals, or merging disjointed SELECTs",
        "Smart Excel-to-SQL Migration Wizard: AI fuzzy token matching, dry-run transaction rollback, and automated IDENTITY_INSERT handling",
        "Super AI Studio: Orphaned foreign key audit doctor & NONCLUSTERED INDEX suggestion generator",
        "FastAPI Backend & Alpine.js: Responsive glassmorphism interface with session-based role authentication"
      ],
      features: [
        "Conversational natural language to optimized T-SQL generation",
        "Multi-turn memory for iterative follow-up queries",
        "Tri-mode automated JOIN resolver connecting disjointed schemas",
        "Automated Excel header fuzzy matching with column type validation",
        "Zero-production-risk transaction simulation with automatic rollback",
        "Database health doctor auditing orphaned foreign keys & query bottlenecks",
        "Role-based access control with secure session-based authentication"
      ],
      stack: ["FastAPI", "MS SQL Server", "Python", "Alpine.js", "Tailwind CSS", "T-SQL", "Graph Engine", "Session Auth"],
      roi: {
        metric1: "90%",
        label1: "Reduction in Query Writing Time",
        metric2: "100%",
        label2: "Elimination of Import Errors",
        metric3: "3,474+",
        label3: "Tables Indexed in Memory"
      }
    },
    nexusflow: {
      title: "NexusFlow AI – Enterprise Autonomous AI & n8n Ecosystem",
      category: "Autonomous AI & n8n Workflows",
      client: "Global SaaS & E-Commerce Enterprises",
      timeline: "Ongoing Retainer (21,600+ Blueprints)",
      heroView: `
        <img src="assets/nexusflow_ai_dashboard.jpg" alt="NexusFlow AI Dashboard" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #0A192F; border-radius: var(--radius-sm); border: 1px solid var(--border-cyan);">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
            <span style="color: var(--neon-cyan); font-weight: bold;"><i class="fas fa-network-wired"></i> 20-Domain Live Orchestrator</span>
            <span style="background: rgba(0, 240, 255, 0.2); color: var(--neon-cyan); padding: 2px 8px; border-radius: 4px; font-size: 0.75rem;">99.9% Uptime</span>
          </div>
          <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; text-align: center;">
            <div style="background: rgba(255,255,255,0.05); padding: 8px; border-radius: 4px;">
              <div style="font-size: 1.1rem; font-weight: bold; color: var(--neon-cyan);">21,600+</div>
              <div style="font-size: 0.68rem; color: var(--text-muted);">Blueprints</div>
            </div>
            <div style="background: rgba(255,255,255,0.05); padding: 8px; border-radius: 4px;">
              <div style="font-size: 1.1rem; font-weight: bold; color: var(--neon-cyan);">&lt; 2s</div>
              <div style="font-size: 0.68rem; color: var(--text-muted);">Avg Latency</div>
            </div>
            <div style="background: rgba(255,255,255,0.05); padding: 8px; border-radius: 4px;">
              <div style="font-size: 1.1rem; font-weight: bold; color: var(--neon-amber);">100+</div>
              <div style="font-size: 0.68rem; color: var(--text-muted);">App APIs</div>
            </div>
            <div style="background: rgba(255,255,255,0.05); padding: 8px; border-radius: 4px;">
              <div style="font-size: 1.1rem; font-weight: bold; color: var(--neon-purple);">100%</div>
              <div style="font-size: 0.68rem; color: var(--text-muted);">Zero Errors</div>
            </div>
          </div>
        </div>
      `,
      problem: "Client operations were crippled by disconnected SaaS applications, manual copy-pasting between CRMs, delayed customer response times (>4 hours), and high administrative overhead.",
      solution: "Engineered an autonomous 20-domain orchestration layer using n8n + OpenAI GPT-4 RAG + Supabase Vector DB. Deployed 24/7 self-healing webhook pipelines connecting WhatsApp, Instagram, HubSpot, Shopify, and PostgreSQL.",
      architecture: [
        "Inbound Webhook Listeners (WhatsApp Cloud API / ManyChat / Gmail / Stripe)",
        "Supabase Vector Database semantic search for contextual RAG knowledge retrieval",
        "OpenAI GPT-4 Cognitive Reasoning & Intent Scoring Engine",
        "Deterministic n8n execution pipelines updating CRM, ERP & triggering outbound notifications"
      ],
      features: [
        "24/7 Context-Aware AI Customer Support (<2s response time)",
        "Automated Instagram DM & Lead Qualification with sentiment scoring",
        "Zero-Human-Data-Entry order synchronization across Shopify and QuickBooks",
        "OpenAI Vision automated PDF invoice & contract JSON extraction"
      ],
      stack: ["n8n", "OpenAI GPT-4", "Supabase RAG", "HubSpot", "Twilio", "PostgreSQL", "Shopify"],
      roi: {
        metric1: "80%",
        label1: "Reduction in Admin Overhead",
        metric2: "< 2s",
        label2: "Average Response Time",
        metric3: "100%",
        label3: "Data Entry Precision"
      }
    },

    bloodcall: {
      title: "BloodCall – Emergency Blood Donation & Geo-Dispatch Mobile Network",
      category: "Flutter & Native Android Development",
      client: "Healthcare Emergency Network",
      timeline: "Production Deployed Mobile Platform",
      heroView: `
        <img src="assets/bloodcall_app_showcase.jpg" alt="BloodCall App 3-Screen View" class="modal-case-study-hero-banner" style="width:100%; max-height:380px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #2D0A14; border-radius: var(--radius-sm); border: 1px solid var(--neon-rose);">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <strong style="color: #FF4D6D; font-size: 0.9rem;"><i class="fas fa-heartbeat"></i> Live GPS Blood Network</strong>
            <span style="background: #FF4D6D; color: #FFF; padding: 2px 8px; border-radius: 4px; font-size: 0.72rem; font-weight: bold;">CRITICAL_ACTIVE</span>
          </div>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 6px;">Hospital Map Locator • Donor Blood Type Matching (AB+) • Firebase Cloud Dispatch</p>
        </div>
      `,
      problem: "Critical emergency patients in hospitals frequently experienced life-threatening delays locating matching blood donors nearby due to uncoordinated phone calls and lack of real-time geolocation.",
      solution: "Developed a cross-platform Flutter & Android mobile application connected to Firebase Cloud Functions and Google Geolocation APIs that broadcasts instant emergency push notifications to eligible donors within a 5km radius.",
      architecture: [
        "Flutter reactive UI state management with Provider/Bloc",
        "Firebase Firestore real-time database with donor availability flags",
        "Firebase Cloud Functions automated radius calculation & push notification dispatch",
        "Direct one-tap emergency call & GPS navigation integration"
      ],
      features: [
        "Real-Time Urgent Blood Request Broadcast with sound alert",
        "GPS Proximity Matching (Find matching donors within 2km - 10km)",
        "Donor Eligibility Tracker & Donation History Log",
        "Secure OTP Authentication & Hospital Verification Badge"
      ],
      stack: ["Flutter", "Android (Java/Kotlin)", "Firebase Cloud Functions", "Google Maps API", "REST APIs"],
      roi: {
        metric1: "4.5 Min",
        label1: "Avg Response Time",
        metric2: "10,000+",
        label2: "Registered Donors",
        metric3: "99.8%",
        label3: "Emergency Push Delivery"
      }
    },

    store_mgmt: {
      title: "Store Management Pro – Modern Stock & Retail Billing Suite",
      category: "Flutter & Mobile Apps",
      client: "Retail Stores & Commercial Businesses",
      timeline: "Commercial Mobile Solution",
      heroView: `
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 14px;">
          <img src="assets/store_mgmt_screen_2026-08-24_194350.png" alt="Store Mgmt Splash" style="width: 100%; height: 260px; object-fit: contain; background: #000; border-radius: var(--radius-sm); border: 1px solid var(--border-glass);">
          <img src="assets/store_mgmt_2026-08-24_at_7.42.01_PM.jpeg" alt="Store Mgmt Stock In" style="width: 100%; height: 260px; object-fit: contain; background: #000; border-radius: var(--radius-sm); border: 1px solid var(--border-glass);">
          <img src="assets/store_mgmt_2026-08-24_at_7.42.02_PM.jpeg" alt="Store Mgmt Sales" style="width: 100%; height: 260px; object-fit: contain; background: #000; border-radius: var(--radius-sm); border: 1px solid var(--border-glass);">
        </div>
        <div style="padding: 14px; background: #0B1727; border-radius: var(--radius-sm); border: 1px solid var(--neon-cyan);">
          <strong style="color: var(--neon-cyan);"><i class="fas fa-boxes"></i> Complete Stock In/Out & Invoicing Engine</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Company Profile • Add/Edit Stock Items • Barcode Scan • WhatsApp/Email Invoice Sharing</p>
        </div>
      `,
      problem: "Minor shopkeepers find it difficult to maintain inventory, record Stock-In vs Sales, and generate instant digital invoices on mobile devices.",
      solution: "Engineered Store Management Pro using Flutter, providing an offline-first inventory tracker with barcode scanning, automated low-stock warnings, and direct PDF invoice sharing via WhatsApp and Email.",
      architecture: [
        "Flutter Cross-Platform Architecture with Hive/SQLite Local Cache",
        "ZXing High-Speed Barcode & QR Code Scanning Engine",
        "Automated Client-Side PDF Invoice Builder with Custom Business Logo",
        "WhatsApp & Email Intent Bridge for Instant Receipt Sharing"
      ],
      features: [
        "Company Profile Setup (Logo, Address, Tax ID, Currency)",
        "Stock-In & Sales Ledger with Real-Time Balance Decrement",
        "One-Touch Barcode Scanner for Item Ingestion & Billing",
        "Instant Invoice Generation & Multi-Platform Sharing"
      ],
      stack: ["Flutter", "Dart", "Barcode Scanner", "PDF Engine", "WhatsApp Share API", "SQLite"],
      roi: {
        metric1: "3x",
        label1: "Faster Billing Speed",
        metric2: "100%",
        label2: "Inventory Accuracy",
        metric3: "Zero",
        label3: "Paper Waste"
      }
    },

    erpnext: {
      title: "ERPNext Enterprise Customization Suite (v14, v15, v16)",
      category: "ERP & Business Engineering",
      client: "Manufacturing & Distribution Corporations",
      timeline: "Latest Multi-Version Suite",
      heroView: `
        <img src="assets/erpnext_v16_dashboard.jpg" alt="ERPNext v16 Dashboard" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #1E1B4B; border-radius: var(--radius-sm); border: 1px solid var(--neon-cyan);">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="color: #38BDF8; font-weight: bold;"><i class="fas fa-cubes"></i> Frappe Core & Automated Ledger Pipeline</span>
            <span style="background: rgba(56, 189, 248, 0.2); color: #38BDF8; padding: 2px 8px; border-radius: 4px; font-size: 0.75rem;">v14 • v15 • v16</span>
          </div>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 6px;">Multi-Warehouse Stock Valuation ($14.7M) • Automated Buying DocTypes • Zero Data Entry Mismatch</p>
        </div>
      `,
      problem: "Legacy ERP systems lacked flexibility, incurred expensive licensing fees, and failed to sync real-time warehouse inventory with sales channels.",
      solution: "Engineered custom Frappe Framework apps, automated DocTypes, Python server scripts, and real-time n8n API webhooks connecting ERPNext v14, v15, and v16 to external e-commerce and banking systems.",
      architecture: [
        "Custom Frappe Python Controllers & Server-Side Scripts",
        "Automated Jinja & QWeb Print Format Generation for tax-compliant invoices",
        "REST API Webhook pipelines for real-time inventory ledger syncing",
        "Role-Based Permission Rules (RBAC) across multi-warehouse operations"
      ],
      features: [
        "Automated Buying, Stock & Accounting ledger updates",
        "Custom DocTypes for specialized manufacturing workflows",
        "Seamless version migration support across v14, v15, and v16",
        "Real-time analytics dashboards for executive leadership"
      ],
      stack: ["ERPNext v14-16", "Frappe Framework", "Python", "MariaDB", "Redis", "n8n"],
      roi: {
        metric1: "100%",
        label1: "Inventory Accuracy",
        metric2: "65%",
        label2: "Lower License Costs",
        metric3: "Zero",
        label3: "Data Entry Mismatches"
      }
    },

    odoo: {
      title: "Enterprise Integration Sandbox — Odoo 19.0 & Zoho Books",
      category: "Enterprise ERP & Financial Ledger Architecture",
      client: "Multi-Entity Middle-East Enterprises (Oman, UAE, Qatar)",
      timeline: "Live Hosted Interactive Sandbox",
      heroView: `
        <img src="assets/odoo_zoho_sandbox_dashboard.jpg" alt="Enterprise Integration Sandbox — Odoo 19.0 & Zoho Books" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #08142C; border-radius: var(--radius-sm); border: 1px solid var(--neon-cyan);">
          <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
            <span style="color: var(--neon-cyan); font-weight: bold;"><i class="fas fa-satellite-dish"></i> Live Hosted Prototype (Odoo 19.0 ↔ Zoho Books Sandbox)</span>
            <a href="https://odoo-zoho-integration-prototype.netlify.app/" target="_blank" class="btn-agency btn-cyan-glow" style="padding: 6px 14px; font-size: 0.8rem; text-decoration: none;">
              <i class="fas fa-external-link-alt"></i> Test Live on Netlify
            </a>
          </div>
          <p style="font-size: 0.82rem; color: #FFF; margin-top: 8px;">Dual System Controls • Oman VAT Form 201 • Multi-Currency Ledger (OMR/USD) • Credit Card Auto-Reconciliation</p>
        </div>
      `,
      problem: "Fragmented accounting between Zoho Books front-end sales billing and Odoo backend led to manual re-entry errors, delayed credit card reconciliations, and complex Oman VAT compliance filings.",
      solution: "Engineered an Enterprise Integration Sandbox linking Zoho Books Invoicing with Odoo 19.0 Financial Vault via webhooks, automated two-way journal syncing, Oman VAT Return Form 201 generation, and corporate credit card auto-matching.",
      architecture: [
        "Zoho Books Webhook Event Dispatcher & Verification Hash (HMAC)",
        "Odoo 19.0 Financial Vault Double-Entry Journal Engine (Python ORM)",
        "Oman Tax Authority Form 201 Declaration Breakdown Generator",
        "Corporate Credit Card Auto-Reconciliation Engine & Matchmaker",
        "Real-Time Webhook Synced Records Debug Console & Synced Queue"
      ],
      features: [
        "Live Verified Deployment on Netlify: https://odoo-zoho-integration-prototype.netlify.app/",
        "Multi-Entity Support: Acme Group Corp (Oman, UAE, Qatar subsidiaries)",
        "Direct Cash Flow Forecasting & IFRS 15 Revenue Recognition Schedules",
        "Dynamic Margin Analysis & Matchmaker Ingestion Verification Audit"
      ],
      stack: ["Odoo 19.0", "Zoho Books API", "Python / ORM", "REST / XML-RPC", "Webhooks", "Oman VAT Form 201"],
      roi: {
        metric1: "100%",
        label1: "Oman VAT Accuracy",
        metric2: "Zero",
        label2: "Manual Double-Entry",
        metric3: "< 2s",
        label3: "Webhook Sync Latency"
      }
    },

    sentinel: {
      title: "Enterprise ERP Governance & Zero-Trust Security Platform",
      category: "ERP Security & Compliance",
      client: "Fintech & Enterprise ERP Deployments (.NET DDD / Clean Architecture)",
      timeline: "Enterprise Governance Portal",
      heroView: `
        <img src="assets/erp_governance_platform.jpg" alt="ERP Governance Platform" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #08142C; border-radius: var(--radius-sm); border: 1px solid var(--neon-cyan);">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="color: var(--neon-cyan); font-weight: bold;"><i class="fas fa-shield-alt"></i> Dynamic Permission Matrix & RBAC Engine</span>
            <span style="background: rgba(0, 212, 255, 0.2); color: var(--neon-cyan); padding: 2px 8px; border-radius: 4px; font-size: 0.75rem;">.NET 8/10 Clean Architecture</span>
          </div>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 6px;">Tamper-Proof Audit Logging • Real-Time Threat Prevention • 70% ERP Failure Prevention</p>
        </div>
      `,
      problem: "According to Gartner, 70% of ERP projects fail due to human data entry mistakes, rogue unauthorized access, and lack of real-time security audit trails.",
      solution: "Architected an Enterprise ERP Governance Platform built on .NET Clean Architecture & Domain-Driven Design (DDD) providing granular Dynamic Permission Matrix RBAC, immutable user audit trails, and automated compliance risk detection.",
      architecture: [
        "Zero-Trust Policy Enforcement Engine (.NET Domain & Application Layer)",
        "Real-Time PostgreSQL & MariaDB Change-Data-Capture (CDC) Audit Logger",
        "Automated Security Incident Webhooks to Slack & PagerDuty",
        "Regulatory Compliance Validator (GDPR, ISO27001)"
      ],
      features: [
        "Granular Field-Level Permission Masking for sensitive financial data",
        "Tamper-Proof User Activity Logs with IP and timestamp fingerprinting",
        "Automated Suspicious Activity Blocking (e.g. bulk export attempts)",
        "Continuous Health & Integrity Telemetry Monitoring"
      ],
      stack: [".NET 8/10", "Clean Architecture", "RBAC Matrix", "PostgreSQL", "Audit Engine", "Security Compliance"],
      roi: {
        metric1: "70%",
        label1: "ERP Failure Prevention",
        metric2: "Zero",
        label2: "Security Breaches",
        metric3: "100%",
        label3: "Audit Readiness"
      }
    },

    educore: {
      title: "EduCore AI – Intelligent Student & Campus ERP Lifecycle Platform",
      category: "ERP & Business Engineering",
      client: "University & Higher Academic Institutions",
      timeline: "Frappe v15 Education Suite",
      heroView: `
        <img src="assets/educore_campus_erp.jpg" alt="EduCore AI Education ERP" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #0A192F; border-radius: var(--radius-sm); border: 1px solid var(--neon-cyan);">
          <strong style="color: var(--neon-cyan);"><i class="fas fa-graduation-cap"></i> Complete Student Lifecycle & Academic CRM</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Automated Admissions, AI Attendance, Gradebook, and Fee Collection (Frappe Framework)</p>
        </div>
      `,
      problem: "Campuses operated with fragmented student spreadsheets, lost fee receipts, and manual grading bottlenecks that delayed transcript generation.",
      solution: "Developed EduCore AI on the Frappe Framework, automating the entire student lifecycle from admissions and AI facial/QR attendance to fee payment gateways and predictive academic performance tracking.",
      architecture: [
        "Frappe v15 Education Core App Architecture",
        "REST API Handlers for Payment Gateway Integration",
        "Jinja Dynamic Transcript & Degree Certificate Generator",
        "WhatsApp Notification Bot for Parent & Student Alerts"
      ],
      features: [
        "Automated Student Admission & Enrollment CRM",
        "AI-Powered Attendance & Automated Absentee SMS",
        "Dynamic Examination Gradebook & CGPA Calculation",
        "Online Fee Portal with Instant Digital Receipts"
      ],
      stack: ["Frappe v15", "Python", "MariaDB", "Jinja", "WhatsApp API"],
      roi: {
        metric1: "99.2%",
        label1: "Fee Collection Automation",
        metric2: "Zero",
        label2: "Manual Spreadsheets",
        metric3: "100%",
        label3: "Audit Conformance"
      }
    },

    lendflow: {
      title: "Frappe LendFlow AI – Micro-Credit Underwriting & Risk Scoring",
      category: "ERP & Business Engineering",
      client: "Fintech & Non-Banking Financial Institutions",
      timeline: "Frappe Lending AI Suite",
      heroView: `
        <img src="assets/frappe_lendflow_ai.jpg" alt="Frappe LendFlow AI" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #0C1C24; border-radius: var(--radius-sm); border: 1px solid #06B6D4;">
          <strong style="color: #22D3EE;"><i class="fas fa-credit-card"></i> 90-Second AI Loan Origination Pipeline</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Bank Statement OCR • Risk Scoring Algorithm • Auto-Disbursement & Ledger Sync</p>
        </div>
      `,
      problem: "Traditional loan underwriting required 3-5 days of manual bank statement review and was vulnerable to fraud and default risks.",
      solution: "Engineered Frappe LendFlow AI, an automated micro-lending pipeline that analyzes bank statements using OCR, scores creditworthiness in 90 seconds, and automates repayment schedules in the ERP ledger.",
      architecture: [
        "Frappe Lending Custom Application Controller",
        "Financial Statement OCR & Anomaly Extraction Engine",
        "Machine Learning Credit Risk Scoring Classifier",
        "Automated ACH/NACH Auto-Debit Webhook Dispatcher"
      ],
      features: [
        "Automated KYC & Income Document Verification",
        "Instant Credit Score Generation (< 90 seconds)",
        "Dynamic EMI Calculator with Automated Late Fee Logic",
        "Real-Time Loan Book Valuation & Default Telemetry"
      ],
      stack: ["Frappe Lending", "Python", "Credit Risk ML", "MariaDB", "FastAPI"],
      roi: {
        metric1: "< 90s",
        label1: "Loan Sanction Time",
        metric2: "0.8%",
        label2: "Default Risk Rate",
        metric3: "100%",
        label3: "Ledger Reconciliation"
      }
    },

    devagent: {
      title: "DevAgent X – Multi-Agent CI/CD Security & Code Review Copilot",
      category: "Autonomous AI & n8n Workflows",
      client: "Enterprise Software Engineering Teams",
      timeline: "Multi-Agent AI Platform",
      heroView: `
        <img src="assets/devagent_code_review_ai.jpg" alt="DevAgent X AI" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #1E1035; border-radius: var(--radius-sm); border: 1px solid #D946EF;">
          <strong style="color: #E879F9;"><i class="fas fa-robot"></i> Multi-Agent Swarm for CI/CD Gates</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">AST Vulnerability Scanner • PyTest Generator • Pull Request Auto-Merge Gate</p>
        </div>
      `,
      problem: "Senior engineers spent 4+ hours daily reviewing pull requests, allowing subtle memory leaks and SQL injection vulnerabilities into production.",
      solution: "Architected DevAgent X using LangGraph and multi-agent LLM swarms that automatically analyze code diffs, run AST security checks, generate missing unit tests, and gate pull requests in 35 seconds.",
      architecture: [
        "LangGraph Multi-Agent State Machine (Scanner, Tester, Profiler, Gatekeeper)",
        "Abstract Syntax Tree (AST) Static Security Scanner",
        "Automated PyTest / Jest Test Case Generation Engine",
        "GitHub Actions & GitLab CI/CD Webhook Integration"
      ],
      features: [
        "Automated OWASP Top-10 Vulnerability Guard",
        "Auto-Generation of Edge Case Unit Tests (94%+ Coverage)",
        "Algorithm Time Complexity & Memory Profiling",
        "Autonomous PR Review Commenting & Instant Approval Gate"
      ],
      stack: ["LangGraph", "Claude 3.5 Sonnet", "Python", "GitHub Actions", "Docker"],
      roi: {
        metric1: "35 Sec",
        label1: "Avg PR Review Time",
        metric2: "94%+",
        label2: "Test Coverage",
        metric3: "Zero",
        label3: "Security Regressions"
      }
    },

    ecovision: {
      title: "EcoVision AI – Real-Time Industrial Plastic Waste Sorting",
      category: "Computer Vision & Deep Learning",
      client: "Industrial Recycling Facilities",
      timeline: "Deep Learning Vision System",
      heroView: `
        <img src="assets/ecovision_plastic_waste_ai.jpg" alt="EcoVision AI" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #06152E; border-radius: var(--radius-sm); border: 1px solid #00D4FF;">
          <strong style="color: #00D4FF;"><i class="fas fa-recycle"></i> 120 Items/Min Robotic Conveyor Sorting</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">PET, HDPE, PP, LDPE 6-Class Segregation • 18ms YOLOv8 Inference • Pneumatic Ejector Relay</p>
        </div>
      `,
      problem: "Manual waste sorting in recycling plants is hazardous, slow (30 items/min), and incurs high contamination rates in sorted bales.",
      solution: "Engineered EcoVision AI, a deep learning computer vision system running YOLOv8 and PyTorch on edge hardware that detects, classifies, and triggers pneumatic chutes for 6 types of recyclable plastics at 120 items/minute.",
      architecture: [
        "Edge Industrial Camera Stream (60 FPS Preprocessing)",
        "PyTorch CUDA YOLOv8 Multi-Class Segmentation Model",
        "Pneumatic Ejector Relay Microcontroller Interface (< 40ms)",
        "Telemetry Dashboard for Material Purity & Daily Throughput"
      ],
      features: [
        "Real-Time 6-Class Plastic Material Identification",
        "Ultra-low latency inference (18ms per frame)",
        "Automated Contamination & Purity Quality Logging",
        "Edge Device Deployment (NVIDIA Jetson / TensorRT)"
      ],
      stack: ["YOLOv8", "PyTorch", "OpenCV", "TensorRT", "Python", "MQTT"],
      roi: {
        metric1: "4x",
        label1: "Throughput Boost",
        metric2: "99.4%",
        label2: "Material Purity",
        metric3: "Zero",
        label3: "Worker Health Risk"
      }
    },

    cravedash: {
      title: "CraveDash – Real-Time Flutter Food Delivery & Logistics Suite",
      category: "Flutter & Mobile Apps",
      client: "On-Demand Delivery Startups",
      timeline: "Full-Stack Mobile Suite",
      heroView: `
        <img src="assets/cravedash_flutter_app.jpg" alt="CraveDash Flutter App" class="modal-case-study-hero-banner" style="width:100%; max-height:380px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #1C1917; border-radius: var(--radius-sm); border: 1px solid var(--neon-amber);">
          <strong style="color: var(--neon-amber);"><i class="fas fa-biking"></i> Live WebSocket Courier Dispatcher</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Live Order GPS Map • Modifier Menu Engine • One-Touch Stripe Apple Pay Checkout</p>
        </div>
      `,
      problem: "Food delivery startups required a high-performance, fluid mobile experience with low latency driver tracking, instant push notifications, and seamless Stripe payments.",
      solution: "Engineered a production-ready triple-app mobile ecosystem built with Flutter, Node.js WebSockets, and Google Maps GPS navigation.",
      architecture: [
        "Flutter Cross-Platform Codebase (iOS & Android)",
        "Node.js + Socket.io Live Geo-Telemetry Streaming",
        "Stripe Payment Gateway & Apple Pay / Google Pay Integration",
        "Firebase Cloud Messaging (FCM) Priority Delivery Alerts"
      ],
      features: [
        "Live Interactive Courier Tracking with turn-by-turn polyline map",
        "Smart Restaurant Menu with customizable modifiers & instant search",
        "Automated Driver Dispatch algorithm matching nearest available courier",
        "In-App Chat & Real-Time Order Status Notifications"
      ],
      stack: ["Flutter", "Dart", "Firebase FCM", "Node.js", "WebSockets", "Google Maps API", "Stripe"],
      roi: {
        metric1: "60 FPS",
        label1: "Silky Smooth UI",
        metric2: "< 50ms",
        label2: "GPS Location Latency",
        metric3: "99.9%",
        label3: "Order Processing Uptime"
      }
    },

    veritrack: {
      title: "VeriTrack AI – Explainable NLP Fake News Detection System",
      category: "Computer Vision & Deep Learning",
      client: "Media Intelligence & Academic Research",
      timeline: "M.Tech-Level ML Workspace",
      heroView: `
        <img src="assets/veritrack_xai_platform.jpg" alt="VeriTrack XAI Portal" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #0F172A; border-radius: var(--radius-sm); border: 1px solid #38BDF8;">
          <strong style="color: #38BDF8;"><i class="fas fa-brain"></i> Explainable AI (XAI) Word Attribution Map</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Passive Aggressive + Naive Bayes Classifier • 95.4% Precision • Linguistic Heatmaps</p>
        </div>
      `,
      problem: "Online news propagation requires instant verification without 'black box' machine learning ambiguity, necessitating explainable linguistic word attribution.",
      solution: "Developed VeriTrack AI, an explainable NLP portal benchmarking Passive Aggressive, Naive Bayes, and Logistic Regression models with a Soft-Voting Ensemble, paired with XAI word attribution heatmaps.",
      architecture: [
        "NLP Tokenization, Lemmatization & TF-IDF Vectorization pipeline",
        "Soft-Voting Machine Learning Ensemble Classifier",
        "Explainable AI (XAI) Word Attribution Visualizer",
        "Web Verification Dashboard with real-time URL article scraper"
      ],
      features: [
        "Interactive News Text & URL Content Verification",
        "Word-by-word Linguistic Attribution Heatmaps",
        "Model Confidence Scoring & Uncertainty Quantification",
        "Comprehensive Evaluation Metrics (Precision, Recall, F1-Score)"
      ],
      stack: ["Python", "NLP / NLTK", "Scikit-Learn", "Explainable AI (XAI)", "FastAPI", "HTML5/CSS3"],
      roi: {
        metric1: "95.4%",
        label1: "Classification Accuracy",
        metric2: "< 250ms",
        label2: "Verification Speed",
        metric3: "100%",
        label3: "Explainable Trust"
      }
    },

    optiscan: {
      title: "OptiScan AI – Glaucoma Retinal Deep Learning Diagnostic Vision System",
      category: "Computer Vision & Deep Learning",
      client: "Medical Diagnostics & Clinical Research",
      timeline: "Deep Learning Vision System",
      heroView: `
        <img src="assets/optiscan_medical_ai.jpg" alt="OptiScan AI Diagnostic System" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #172554; border-radius: var(--radius-sm); border: 1px solid #6366F1;">
          <strong style="color: #818CF8;"><i class="fas fa-microscope"></i> CNN Optical Disc Segmentation & Heatmap</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Retinal CDR Degradation Analysis • 96.8% Sensitivity • Automated Clinical PDF Patient Reports</p>
        </div>
      `,
      problem: "Glaucoma is a leading cause of irreversible blindness. Manual fundus scan review is time-consuming and prone to inter-observer variability in clinical settings.",
      solution: "Engineered a Convolutional Neural Network (CNN) deep learning model trained on high-resolution optical disc fundus images with preprocessing filters for automated glaucoma risk diagnosis.",
      architecture: [
        "OpenCV Medical Image Preprocessing (CLAHE)",
        "Deep Convolutional Neural Network (CNN) Feature Extractor",
        "Cup-to-Disc Ratio (CDR) Segmentation & Classification Engine",
        "Clinical Diagnostic Web Portal with PDF Patient Report Generator"
      ],
      features: [
        "Automated Retinal Image Upload & Quality Check",
        "Deep Learning Diagnostic Confidence Score",
        "Heatmap Visualizations of Optic Nerve Degradation",
        "Instant Downloadable Clinical PDF Reports"
      ],
      stack: ["PyTorch", "OpenCV", "Deep Learning CNN", "Python", "Medical Imaging", "FastAPI"],
      roi: {
        metric1: "96.8%",
        label1: "Diagnostic Sensitivity",
        metric2: "2.1s",
        label2: "Scan Processing Time",
        metric3: "Zero",
        label3: "Human Fatigue Bias"
      }
    },

    qualiflow: {
      title: "QualiFlow Enterprise AI – Automated Web Portal QA & E2E Testing Suite",
      category: "Autonomous AI & n8n Workflows",
      client: "Enterprise Software QA Teams",
      timeline: "Automated QA Framework",
      heroView: `
        <img src="assets/qualiflow_qa_automation.jpg" alt="QualiFlow QA Dashboard" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #083344; border-radius: var(--radius-sm); border: 1px solid #06B6D4;">
          <strong style="color: #06B6D4;"><i class="fas fa-vial"></i> Headless Navigation Crawler & Audit Engine</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Full Submodule Crawl • 404/Console Error Auditor • Single-File HTML Reports</p>
        </div>
      `,
      problem: "Complex multi-module enterprise portals require dozens of manual QA testing hours per sprint, leading to undetected broken links and regressions.",
      solution: "Engineered QualiFlow Enterprise AI, an automated test crawler that logs into web portals, discovers all navigation links and submodules, runs broken link checks, captures screenshots, and produces single-file HTML audit reports.",
      architecture: [
        "Headless Browser Crawling & Authentication Engine",
        "Automated DOM Element Validator & Broken URL Discovery",
        "Lighthouse Performance & Accessibility Telemetry Extractor",
        "Dynamic Single-File HTML Audit Report Generator"
      ],
      features: [
        "Automated Full-Site Navigation Crawl in under 3 minutes",
        "Console Error & Network 404/500 Code Tracker",
        "Automated Visual Regression Screenshot Capture",
        "Executive Summary Audit Report with actionable fix suggestions"
      ],
      stack: ["Playwright / Selenium", "Python", "E2E Testing", "HTML5 Reporting", "QA Automation"],
      roi: {
        metric1: "90%",
        label1: "Reduction in QA Time",
        metric2: "100%",
        label2: "Submodule Coverage",
        metric3: "Zero",
        label3: "Undetected 404 Errors"
      }
    },

    agrocraft: {
      title: "Agrocraft – Smart AgriTech & Farm Produce Marketplace",
      category: "Autonomous AI & n8n Workflows",
      client: "Agricultural Supply Chains",
      timeline: "Direct-to-Consumer Platform",
      heroView: `
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 14px;">
          <img src="assets/agrocraft_screen_1.png" alt="Agrocraft Buyer Market" style="width: 100%; height: 260px; object-fit: contain; background: #000; border-radius: var(--radius-sm); border: 1px solid var(--border-glass);">
          <img src="assets/agrocraft_screen_2.png" alt="Agrocraft Farmer Portal" style="width: 100%; height: 260px; object-fit: contain; background: #000; border-radius: var(--radius-sm); border: 1px solid var(--border-glass);">
          <img src="assets/agrocraft_screen_3.png" alt="Agrocraft Reviews" style="width: 100%; height: 260px; object-fit: contain; background: #000; border-radius: var(--radius-sm); border: 1px solid var(--border-glass);">
        </div>
        <div style="padding: 14px; background: #14532D; border-radius: var(--radius-sm); border: 1px solid #22C55E;">
          <strong style="color: #22C55E;"><i class="fas fa-seedling"></i> Direct Farmer-to-Consumer Smart Commerce</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Zero Middleman Cut • Location Radius Search • Real-Time Crop Inventory</p>
        </div>
      `,
      problem: "Farmers lose up to 40% of their profits to intermediary middlemen brokers, while consumers pay inflated prices for non-fresh produce.",
      solution: "Developed Agrocraft, a direct e-commerce marketplace empowering farmers to list vegetables and fruits at fair market rates with categorical and location-radius search filters.",
      architecture: [
        "PHP & MySQL High-Speed Database Architecture",
        "Dynamic Product Inventory CRUD with Image Compression",
        "Location-Based Proximity Search Engine",
        "Buyer & Farmer Dual-Portal Interface"
      ],
      features: [
        "Direct Farmer-to-Consumer Order Placement",
        "Location & Category Filter (Fresh Vegetables, Fruits, Grains)",
        "Farmer Sales Analytics & Inventory Management",
        "Transparent Fair-Price Direct Settlement"
      ],
      stack: ["PHP", "MySQL", "JavaScript", "HTML5/CSS3", "AgriTech", "REST API"],
      roi: {
        metric1: "+35%",
        label1: "Farmer Profit Increase",
        metric2: "Zero",
        label2: "Middleman Commission",
        metric3: "100%",
        label3: "Direct Traceability"
      }
    },

    neurotouch: {
      title: "NeuroTouch – Touchless Gesture Vision Interaction Controller",
      category: "Computer Vision & Deep Learning",
      client: "Interactive Display & IoT Labs",
      timeline: "Computer Vision UI System",
      heroView: `
        <img src="assets/neurotouch_gesture_ai.jpg" alt="NeuroTouch Gesture Controller" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #311042; border-radius: var(--radius-sm); border: 1px solid #C084FC;">
          <strong style="color: #C084FC;"><i class="fas fa-hand-paper"></i> 21-Landmark Real-Time Gesture Tracking</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Air Pinch, Scroll & Brightness Controls • &lt; 28ms Latency • Sterile Surgical Kiosks</p>
        </div>
      `,
      problem: "Sanitary environments (e.g. operating rooms, kiosks) require touchless computer interactions without touching keyboards, mice, or touchscreens.",
      solution: "Engineered NeuroTouch using OpenCV and MediaPipe to track 21 hand landmarks and facial cues in real-time, translating natural gestures into system controls.",
      architecture: [
        "MediaPipe Hands & Face Mesh 30 FPS Landmark Extractor",
        "Euclidean Distance & Coordinate Angle Gesture Interpreter",
        "Virtual Mouse & System Volume/Brightness API Bridge",
        "Real-Time Web-Based Interactive Calibration Canvas"
      ],
      features: [
        "Touchless Pinch-to-Click & Air Scroll Controls",
        "Real-time Brightness & Volume Adjustment Gestures",
        "Facial Orientation Attention Detection",
        "Ultra-low latency execution (<30ms)"
      ],
      stack: ["OpenCV", "MediaPipe", "Python", "JavaScript", "Computer Vision", "WebSockets"],
      roi: {
        metric1: "< 30ms",
        label1: "Gesture Latency",
        metric2: "99.1%",
        label2: "Landmark Tracking",
        metric3: "100%",
        label3: "Contactless Safety"
      }
    },

    apexstore: {
      title: "ApexStore – Cloud Retail POS & Smart Inventory System",
      category: "ERP & Business Engineering",
      client: "Modern Retail Stores & Chains",
      timeline: "Cloud POS & Stock Suite",
      heroView: `
        <img src="assets/apexstore_pos_system.jpg" alt="ApexStore Retail POS" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #1E1B4B; border-radius: var(--radius-sm); border: 1px solid #818CF8;">
          <strong style="color: #818CF8;"><i class="fas fa-store"></i> High-Speed Point-of-Sale & Multi-Store Ledger</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">Sub-Second Barcode Ingestion • Instant Thermal PDF Receipts • Zero Inventory Mismatch</p>
        </div>
      `,
      problem: "Retailers struggled with slow checkout lines, inventory discrepancies between physical and warehouse stock, and delayed PDF invoice generation.",
      solution: "Built ApexStore, a high-speed Point-of-Sale dashboard featuring instant barcode lookup, live multi-store stock syncing, automated PDF receipt printing, and daily profit analytics.",
      architecture: [
        "Lightweight Single-Page POS Web Client",
        "High-Speed In-Memory Cart & Tax Calculation Engine",
        "Automated Client-Side PDF Receipt Generator",
        "REST API Synchronization with Central Warehouse Database"
      ],
      features: [
        "Sub-Second Barcode Scanning & Item Addition",
        "Low-Stock Automated Warning Triggers",
        "Multi-Payment Handling (Cash, Card, UPI, Split)",
        "End-of-Day Sales & Profit Margin Summary Reports"
      ],
      stack: ["JavaScript", "HTML5/CSS3", "PDF Engine", "REST APIs", "POS Architecture"],
      roi: {
        metric1: "2.5x",
        label1: "Faster Checkout Speed",
        metric2: "Zero",
        label2: "Inventory Discrepancy",
        metric3: "100%",
        label3: "Automated Receipts"
      }
    },

    quantassure: {
      title: "QuantAssure – Industrial Telemetry ML Anomaly Detector",
      category: "Computer Vision & Deep Learning",
      client: "Industrial IoT & Cloud Infrastructure",
      timeline: "Real-Time Anomaly Engine",
      heroView: `
        <img src="assets/quantassure_anomaly_detector.jpg" alt="QuantAssure Anomaly Detector" class="modal-case-study-hero-banner" style="width:100%; max-height:360px; object-fit:cover; border-radius:var(--radius-sm); margin-bottom:14px; border:1px solid var(--border-glass);">
        <div style="padding: 14px; background: #052E16; border-radius: var(--radius-sm); border: 1px solid #34D399;">
          <strong style="color: #34D399;"><i class="fas fa-chart-line"></i> Unsupervised Time-Series Ingestion (10k pts/sec)</strong>
          <p style="font-size: 0.8rem; color: #FFF; margin-top: 4px;">15-Minute Pre-Crash Predictive Warning • Automated Slack / PagerDuty Incident Dispatch</p>
        </div>
      `,
      problem: "Unexpected server spikes and industrial sensor failures caused expensive downtime because engineering teams relied on manual threshold alerts instead of predictive AI.",
      solution: "Architected QuantAssure, a real-time time-series anomaly detection engine using unsupervised machine learning algorithms that predicts system degradation before failure occurs and alerts teams via Slack/PagerDuty.",
      architecture: [
        "Time-Series Feature Engineering & Sliding Window Extractor",
        "Isolation Forest & Autoencoder Anomaly Scoring Models",
        "FastAPI High-Throughput Ingestion Microservice",
        "Automated Incident Dispatch Webhooks to Slack & SMS"
      ],
      features: [
        "Real-Time Sensor & Server Metric Ingestion (10,000+ data points/sec)",
        "Predictive Anomaly Scoring with Dynamic Threshold Adaptation",
        "Instant Slack Alerts with Diagnostic Root-Cause Context",
        "Interactive Historical Telemetry Drill-down Dashboard"
      ],
      stack: ["Machine Learning", "FastAPI", "Python", "Pandas", "Slack Webhooks", "Docker"],
      roi: {
        metric1: "99.9%",
        label1: "Uptime Maintenance",
        metric2: "15 Min",
        label2: "Pre-Failure Warning",
        metric3: "85%",
        label3: "Less False Alarms"
      }
    }
  };

  // ========================================================================
  // 4. CASE STUDY MODAL LAUNCHER
  // ========================================================================
  const modalBackdrop = document.getElementById('case-study-modal');
  const closeBtn = document.getElementById('close-modal-btn');

  window.openCaseStudy = (projectId) => {
    const data = caseStudies[projectId];
    if (!data) return;

    document.getElementById('modal-title').innerText = data.title;
    document.getElementById('modal-client').innerText = `${data.client} • ${data.timeline}`;
    
    // Inject the rich UI Hero View
    const heroBox = document.getElementById('modal-hero-view-container');
    if (heroBox) heroBox.innerHTML = data.heroView;

    document.getElementById('modal-problem').innerText = data.problem;
    document.getElementById('modal-solution').innerText = data.solution;

    // Architecture list
    const archEl = document.getElementById('modal-arch-list');
    archEl.innerHTML = data.architecture.map(item => `<li style="margin-bottom: 6px; padding-left: 20px; position: relative;"><span style="position: absolute; left: 0; color: var(--neon-cyan);">➔</span>${item}</li>`).join('');

    // Features list
    const featEl = document.getElementById('modal-features-list');
    featEl.innerHTML = data.features.map(item => `<li style="margin-bottom: 6px; padding-left: 20px; position: relative;"><span style="position: absolute; left: 0; color: var(--neon-cyan);">✓</span>${item}</li>`).join('');

    // Stack pills
    const stackEl = document.getElementById('modal-stack-pills');
    stackEl.innerHTML = data.stack.map(s => `<span class="tech-tag-badge" style="color: var(--neon-cyan); border-color: var(--border-cyan); font-size: 0.8rem; padding: 4px 10px;">${s}</span>`).join('');

    // ROI Metrics
    document.getElementById('modal-roi-1-val').innerText = data.roi.metric1;
    document.getElementById('modal-roi-1-lbl').innerText = data.roi.label1;
    document.getElementById('modal-roi-2-val').innerText = data.roi.metric2;
    document.getElementById('modal-roi-2-lbl').innerText = data.roi.label2;
    document.getElementById('modal-roi-3-val').innerText = data.roi.metric3;
    document.getElementById('modal-roi-3-lbl').innerText = data.roi.label3;

    // CTA
    const ctaBtn = document.getElementById('modal-hire-cta');
    const waText = encodeURIComponent(`Hi Dhruvkumar! I reviewed your case study for "${data.title}" and would like to discuss hiring you for a similar project.`);
    ctaBtn.href = `https://wa.me/919727199190?text=${waText}`;

    modalBackdrop.classList.add('active');
    document.body.style.overflow = 'hidden';
  };

  if (closeBtn) {
    closeBtn.addEventListener('click', () => {
      modalBackdrop.classList.remove('active');
      document.body.style.overflow = 'auto';
    });
  }

  if (modalBackdrop) {
    modalBackdrop.addEventListener('click', (e) => {
      if (e.target === modalBackdrop) {
        modalBackdrop.classList.remove('active');
        document.body.style.overflow = 'auto';
      }
    });
  }

  // ========================================================================
  // 5. MOBILE MASTERY SECTION (WITH REAL USER SCREENSHOTS & REALISTIC PHONES)
  // ========================================================================
  const mobileMasteryShowcase = {
    bloodcall: `
      <div style="width: 100%; max-width: 1000px; margin: 0 auto; text-align: center;">
        <img src="assets/bloodcall_app_showcase.jpg" alt="BloodCall 3-Screen App Showcase" style="width: 100%; border-radius: var(--radius-lg); border: 1px solid var(--border-glass-strong); box-shadow: var(--shadow-elevated), 0 0 40px rgba(197, 17, 46, 0.3);">
        <p style="margin-top: 16px; font-size: 0.95rem; color: var(--text-muted);">
          <strong style="color: #FFF;">BloodCall Flutter Ecosystem:</strong> Splash Welcome Auth • Live GPS Hospital Radar • Donor Profile & Blood Group Selector (AB+)
        </p>
      </div>
    `,
    store_mgmt: `
      <div style="width: 100%; max-width: 1100px; margin: 0 auto;">
        <div class="realistic-phone-mockup-trio">
          
          <!-- Phone 1: Welcome & Setup -->
          <div class="realistic-phone-card">
            <div class="phone-notch-header"><div class="phone-camera-dot"></div></div>
            <img src="assets/store_mgmt_screen_2026-08-24_194350.png" alt="Store Management App Splash" class="realistic-phone-img-screen">
            <div class="phone-screen-caption">
              <h4>Stock App Setup</h4>
              <p>Store Profile & Settings</p>
            </div>
          </div>

          <!-- Phone 2: Stock-In Ledger -->
          <div class="realistic-phone-card">
            <div class="phone-notch-header"><div class="phone-camera-dot"></div></div>
            <img src="assets/store_mgmt_2026-08-24_at_7.42.01_PM.jpeg" alt="Store Management Stock In" class="realistic-phone-img-screen">
            <div class="phone-screen-caption">
              <h4>Stock-In Manager</h4>
              <p>Barcode & Inventory Balance</p>
            </div>
          </div>

          <!-- Phone 3: Sales & Billing -->
          <div class="realistic-phone-card">
            <div class="phone-notch-header"><div class="phone-camera-dot"></div></div>
            <img src="assets/store_mgmt_2026-08-24_at_7.42.02_PM.jpeg" alt="Store Management Sales Ledger" class="realistic-phone-img-screen">
            <div class="phone-screen-caption">
              <h4>Sales & Invoicing</h4>
              <p>Instant WhatsApp Sharing</p>
            </div>
          </div>

        </div>
        <p style="text-align: center; margin-top: 18px; font-size: 0.95rem; color: var(--text-muted);">
          <strong style="color: #FFF;">Store Management Pro (Flutter):</strong> Real-time Stock-In • Sales Ledger Decrement • Barcode Scanning • WhatsApp / Email Invoicing
        </p>
      </div>
    `,
    cravedash: `
      <div style="width: 100%; max-width: 1000px; margin: 0 auto; text-align: center;">
        <img src="assets/cravedash_flutter_app.jpg" alt="CraveDash Food Delivery App Showcase" style="width: 100%; border-radius: var(--radius-lg); border: 1px solid var(--border-glass-strong); box-shadow: var(--shadow-elevated), 0 0 40px rgba(245, 158, 11, 0.25);">
        <p style="margin-top: 16px; font-size: 0.95rem; color: var(--text-muted);">
          <strong style="color: #FFF;">CraveDash Logistics App:</strong> Restaurant Discovery • Live Turn-by-Turn GPS Map • Stripe Apple Pay One-Touch Checkout
        </p>
      </div>
    `,
    agrocraft: `
      <div style="width: 100%; max-width: 1050px; margin: 0 auto; text-align: center;">
        <img src="assets/agrocraft_mobile_showcase.jpg" alt="Agrocraft AgriTech Mobile App Showcase" style="width: 100%; border-radius: var(--radius-lg); border: 1px solid var(--border-glass-strong); box-shadow: var(--shadow-elevated), 0 0 50px rgba(34, 197, 94, 0.2);">
        <p style="margin-top: 18px; font-size: 0.95rem; color: var(--text-muted);">
          <strong style="color: #FFF;">Agrocraft Smart AgriTech Platform:</strong> Direct Farmer-to-Consumer Market • Proximity Radius Search • Dynamic Crop Inventory CRUD • Zero Middleman Brokerage
        </p>
      </div>
    `
  };

  const switchMobileMasteryView = (appKey) => {
    const container = document.getElementById('mobile-triple-showcase-mount');
    if (container && mobileMasteryShowcase[appKey]) {
      container.innerHTML = mobileMasteryShowcase[appKey];
    }

    document.querySelectorAll('.app-switch-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.app === appKey);
    });
  };

  document.querySelectorAll('.app-switch-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      switchMobileMasteryView(btn.dataset.app);
    });
  });

  switchMobileMasteryView('bloodcall');

  // ========================================================================
  // 6. N8N & AI WORKFLOW SIMULATOR
  // ========================================================================
  const simBlueprints = {
    whatsapp: {
      title: "🟢 WhatsApp AI Sales & Support Autonomous Agent",
      nodes: [
        { tag: "TRIGGER", icon: "📲", title: "WhatsApp Webhook", status: "Listening (Port 5678)" },
        { tag: "VECTOR_DB", icon: "🗄️", title: "Supabase Vector DB", status: "Semantic Vector Search" },
        { tag: "LLM_COGNITION", icon: "🧠", title: "OpenAI GPT-4 RAG", status: "Reason & Generate Text" },
        { tag: "API_ACTION", icon: "💬", title: "WhatsApp Cloud API", status: "Dispatch Outbound Reply" },
        { tag: "CRM_SYNC", icon: "💼", title: "HubSpot CRM", status: "Update Lead Stage & Log" }
      ],
      sampleInput: "Hi Dhruvkumar! Can you automate our order routing with n8n and ERPNext v16?",
      generateOutput: (input) => ({
        timestamp: new Date().toISOString(),
        execution_id: "exec_n8n_" + Math.random().toString(36).substring(7),
        status: "200_SUCCESS",
        latency_ms: 178,
        inbound_payload: {
          phone_number: "+91 9727199190",
          channel: "WHATSAPP_BUSINESS_CLOUD_API",
          raw_message: input
        },
        ai_agent_reasoning: {
          intent: "ENTERPRISE_INQUIRY_AUTOMATION_ERP",
          confidence: 0.992,
          rag_documents_retrieved: 4,
          vector_similarity: "0.984 (HIGH)"
        },
        outbound_response: "Hello! Yes, Dhruvkumar Mashru specializes in high-speed n8n automation connecting e-commerce platforms to ERPNext (v14-v16) and Odoo (v16-v19). Would you like to schedule a 15-minute live architecture demo?",
        crm_action_taken: "HUBSPOT_LEAD_TAGGED_HIGH_PRIORITY"
      })
    },

    instagram: {
      title: "📸 Instagram DM Lead & Comment Qualifier",
      nodes: [
        { tag: "TRIGGER", icon: "📸", title: "Instagram Event", status: "Comment / DM Trigger" },
        { tag: "EVENT_PARSER", icon: "⚙️", title: "n8n Event Parser", status: "Extract User & Sentiment" },
        { tag: "SENTIMENT_AI", icon: "🎭", title: "GPT-4 Sentiment AI", status: "Score Buying Intent" },
        { tag: "API_ACTION", icon: "📩", title: "Personalized DM", status: "Dispatch One-Time Link" },
        { tag: "CRM_SYNC", icon: "📊", title: "Google Sheets / CRM", status: "Record Deal Pipeline" }
      ],
      sampleInput: "How much do you charge for building custom Flutter apps and ERP systems?",
      generateOutput: (input) => ({
        timestamp: new Date().toISOString(),
        execution_id: "exec_n8n_" + Math.random().toString(36).substring(7),
        status: "200_SUCCESS",
        latency_ms: 135,
        user_handle: "@client_global_founder",
        sentiment_score: "HIGH_PURCHASE_INTENT (0.96)",
        dm_dispatched: "Hi! Thanks for reaching out. Dhruvkumar's full agency rate card & portfolio blueprint has been sent to your inbox.",
        lead_score: 95
      })
    },

    vision_rag: {
      title: "📄 PDF Contract Vision RAG & Legal Risk Auditor",
      nodes: [
        { tag: "TRIGGER", icon: "📥", title: "Gmail / S3 Listener", status: "PDF Attachment Detected" },
        { tag: "VISION_OCR", icon: "👁️", title: "OpenAI Vision OCR", status: "High-Resolution OCR" },
        { tag: "RISK_AI", icon: "⚖️", title: "Legal Risk Classifier", status: "Evaluate Penalties" },
        { tag: "DATABASE", icon: "🗄️", title: "PostgreSQL Database", status: "Insert Clean Schema" },
        { tag: "ALERT_DISPATCH", icon: "🔔", title: "Slack / Twilio Alert", status: "Notify Legal & CEO" }
      ],
      sampleInput: "Audit attached Vendor_Supply_Agreement_2026.pdf for payment terms and liability limits.",
      generateOutput: (input) => ({
        timestamp: new Date().toISOString(),
        document_analyzed: "Vendor_Supply_Agreement_2026.pdf",
        pages_processed: 18,
        ocr_accuracy: "99.6%",
        structured_json: {
          vendor: "Apex Global Logistics Inc.",
          contract_total: "$240,000",
          payment_terms: "Net 30 Days",
          termination_clause_days: 60,
          liability_cap: "$500,000",
          risk_grade: "LOW_RISK_APPROVED"
        },
        slack_notification: "DISPATCHED_TO_#LEGAL_ALERTS"
      })
    },

    voice_ai: {
      title: "📞 Voice AI Telephony & Appointment Assistant",
      nodes: [
        { tag: "TRIGGER", icon: "📞", title: "Twilio Webhook", status: "Inbound Call Connected" },
        { tag: "SPEECH_TO_TEXT", icon: "🎙️", title: "Whisper STT", status: "Real-Time Audio Stream" },
        { tag: "VOICE_REASONING", icon: "🧠", title: "Vapi / GPT Voice AI", status: "Natural Speech Flow" },
        { tag: "CALENDAR_API", icon: "📅", title: "Google Calendar API", status: "Reserve Meeting Slot" },
        { tag: "SMS_DISPATCH", icon: "📱", title: "SMS Confirmation", status: "Twilio SMS Dispatched" }
      ],
      sampleInput: "I'd like to book an AI strategy consultation with Dhruvkumar tomorrow at 4 PM.",
      generateOutput: (input) => ({
        timestamp: new Date().toISOString(),
        call_session_id: "twilio_call_9941",
        call_duration_seconds: 54,
        client_speech: "I'd like to book an AI strategy consultation with Dhruvkumar tomorrow at 4 PM.",
        calendar_slot_reserved: "2026-08-22T16:00:00+05:30",
        confirmation_sms: "Your AI consultation with Dhruvkumar Mashru is confirmed for tomorrow at 4:00 PM IST."
      })
    }
  };

  let activeBlueprintKey = "whatsapp";

  const renderSimBlueprint = (key) => {
    activeBlueprintKey = key;
    const bp = simBlueprints[key];

    document.querySelectorAll('.blueprint-option-card').forEach(el => {
      el.classList.toggle('active', el.dataset.blueprint === key);
    });

    const canvas = document.getElementById('sim-flow-canvas');
    if (canvas) {
      canvas.innerHTML = bp.nodes.map((node, i) => `
        <div class="workflow-node" id="sim-node-${i}">
          <div style="font-size: 0.62rem; color: var(--neon-cyan); font-family: var(--font-mono); font-weight: 800; letter-spacing: 0.06em; margin-bottom: 5px; text-transform: uppercase;">${node.tag || 'NODE'}</div>
          <div class="n-icon">${node.icon}</div>
          <div class="n-title">${node.title}</div>
          <div class="n-status">${node.status}</div>
          <div style="font-size: 0.62rem; color: var(--text-dim); margin-top: 6px; font-family: var(--font-mono); border-top: 1px solid rgba(255,255,255,0.06); padding-top: 4px;">STEP 0${i + 1}</div>
        </div>
        ${i < bp.nodes.length - 1 ? '<div class="workflow-connector"><span class="conn-arrow">➔</span></div>' : ''}
      `).join('');
    }

    const inputEl = document.getElementById('sim-input-text');
    if (inputEl) inputEl.value = bp.sampleInput;

    const titleEl = document.getElementById('sim-active-title');
    if (titleEl) titleEl.innerText = bp.title;

    document.getElementById('sim-logs-output').innerText = "// Ready. Enter test input and click 'Run Simulation'...\n";
    document.getElementById('sim-json-output').innerText = JSON.stringify({ status: "IDLE", blueprint: bp.title }, null, 2);
  };

  document.querySelectorAll('.blueprint-option-card').forEach(el => {
    el.addEventListener('click', () => {
      renderSimBlueprint(el.dataset.blueprint);
    });
  });

  const runSimBtn = document.getElementById('run-sim-btn');
  if (runSimBtn) {
    runSimBtn.addEventListener('click', () => {
      const bp = simBlueprints[activeBlueprintKey];
      const inputVal = document.getElementById('sim-input-text').value || bp.sampleInput;
      const logsEl = document.getElementById('sim-logs-output');
      const jsonEl = document.getElementById('sim-json-output');

      logsEl.innerText = `[${new Date().toLocaleTimeString()}] 🚀 Initiating n8n Webhook Listener...\n`;
      jsonEl.innerText = "// Executing workflow pipeline nodes in parallel...\n";

      bp.nodes.forEach((node, idx) => {
        setTimeout(() => {
          document.querySelectorAll('.workflow-node').forEach(n => n.classList.remove('running-node'));
          const nodeEl = document.getElementById(`sim-node-${idx}`);
          if (nodeEl) nodeEl.classList.add('running-node');

          logsEl.innerText += `[${new Date().toLocaleTimeString()}] ✅ Node ${idx + 1} (${node.title}): ${node.status}\n`;
          logsEl.scrollTop = logsEl.scrollHeight;

          if (idx === bp.nodes.length - 1) {
            setTimeout(() => {
              jsonEl.innerText = JSON.stringify(bp.generateOutput(inputVal), null, 2);
              logsEl.innerText += `[${new Date().toLocaleTimeString()}] 🎉 Execution 100% Complete. All Webhooks Successfully Dispatched.\n`;
            }, 300);
          }
        }, idx * 450);
      });
    });
  }

  renderSimBlueprint('whatsapp');

  // ========================================================================
  // 7. PROJECTS FILTER
  // ========================================================================
  const filterBtns = document.querySelectorAll('.filter-btn-agency');
  const projectCards = document.querySelectorAll('.project-agency-card');

  filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const filter = btn.dataset.filter;

      projectCards.forEach(card => {
        if (filter === 'all' || card.dataset.category === filter) {
          card.style.display = 'flex';
        } else {
          card.style.display = 'none';
        }
      });
    });
  });

  // ========================================================================
  // 8. FLOATING BACK TO TOP BUTTON
  // ========================================================================
  const backToTopBtn = document.getElementById('floating-back-to-top');
  if (backToTopBtn) {
    window.addEventListener('scroll', () => {
      if (window.scrollY > 450) {
        backToTopBtn.classList.add('visible');
      } else {
        backToTopBtn.classList.remove('visible');
      }
    });

    backToTopBtn.addEventListener('click', () => {
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    });
  }

  // ========================================================================
  // 9. INTEGRATIONS FILTER
  // ========================================================================
  const intSearch = document.getElementById('integration-search-input');
  const intBadges = document.querySelectorAll('.int-badge-item');

  if (intSearch) {
    intSearch.addEventListener('input', (e) => {
      const q = e.target.value.toLowerCase().trim();
      intBadges.forEach(badge => {
        const txt = badge.innerText.toLowerCase();
        badge.style.display = txt.includes(q) ? 'inline-flex' : 'none';
      });
    });
  }

  // ========================================================================
  // 10. PROPOSAL SUBMISSION & DYNAMIC OTHER PROJECT TOGGLE
  // ========================================================================
  const propServiceSelect = document.getElementById('prop-service');
  const propOtherGroup = document.getElementById('prop-other-group');
  const propOtherSpec = document.getElementById('prop-other-spec');

  // Budget quick pill helper
  window.setBudget = function(btn, val) {
    const input = document.getElementById('prop-budget');
    if (input) {
      input.value = val;
    }
    document.querySelectorAll('.budget-pill').forEach(p => p.classList.remove('active'));
    if (btn) btn.classList.add('active');
  };

  if (propServiceSelect && propOtherGroup) {
    propServiceSelect.addEventListener('change', () => {
      if (propServiceSelect.value === 'Other Custom Project') {
        propOtherGroup.style.display = 'flex';
        if (propOtherSpec) {
          propOtherSpec.required = true;
          propOtherSpec.focus();
        }
      } else {
        propOtherGroup.style.display = 'none';
        if (propOtherSpec) {
          propOtherSpec.required = false;
        }
      }
    });
  }

  function escapeHTML(str) {
    if (!str) return '';
    return String(str).replace(/[&<>'"]/g, 
      tag => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[tag] || tag)
    );
  }

  function showProposalStatus(msg, isSuccess = true) {
    const statusEl = document.getElementById('proposal-status-msg');
    if (statusEl) {
      statusEl.innerHTML = msg;
      statusEl.className = isSuccess ? 'status-success' : '';
      statusEl.style.display = 'block';
    }
  }

  const proposalForm = document.getElementById('project-proposal-form');
  if (proposalForm) {
    // 1. Submit via WhatsApp
    proposalForm.addEventListener('submit', (e) => {
      e.preventDefault();

      const name = document.getElementById('prop-name').value.trim();
      const email = document.getElementById('prop-email').value.trim();
      const phone = document.getElementById('prop-phone') ? document.getElementById('prop-phone').value.trim() : '';
      const service = document.getElementById('prop-service').value;
      const otherSpec = propOtherSpec ? propOtherSpec.value.trim() : '';
      const timeline = document.getElementById('prop-timeline').value;
      const budget = document.getElementById('prop-budget').value.trim() || 'Flexible / To be discussed';
      const details = document.getElementById('prop-details').value.trim() || 'Ready to discuss on call';

      let serviceFormatted = service;
      if (service === 'Other Custom Project' && otherSpec) {
        serviceFormatted = `Other Custom Project (${otherSpec})`;
      }

      let phoneFormatted = phone ? `\n• Phone / WhatsApp: ${phone}` : '';

      const rawMessage = `Hi Dhruvkumar! My name is ${name} (${email}).\n\n*Commercial Project Scope Request:*\n• Service: ${serviceFormatted}${phoneFormatted}\n• Desired Timeline: ${timeline}\n• Target Budget: ${budget}\n• Project Details: ${details}\n\nI would like to discuss hiring you.`;
      const waUrl = `https://wa.me/919727199190?text=${encodeURIComponent(rawMessage)}`;

      const safeName = escapeHTML(name);
      showProposalStatus(`<i class="fab fa-whatsapp"></i> <strong>Thank you, ${safeName}!</strong> Opening direct WhatsApp chat with Dhruvkumar Mashru to review your project brief...`, true);
      setTimeout(() => {
        const win = window.open(waUrl, '_blank', 'noopener,noreferrer');
        if (win) win.opener = null;
      }, 500);
    });

    // 2. Send via Direct Email
    const emailBtn = document.getElementById('btn-submit-email');
    if (emailBtn) {
      emailBtn.addEventListener('click', () => {
        if (!proposalForm.checkValidity()) {
          proposalForm.reportValidity();
          return;
        }

        const name = document.getElementById('prop-name').value.trim();
        const email = document.getElementById('prop-email').value.trim();
        const phone = document.getElementById('prop-phone') ? document.getElementById('prop-phone').value.trim() : '';
        const service = document.getElementById('prop-service').value;
        const otherSpec = propOtherSpec ? propOtherSpec.value.trim() : '';
        const timeline = document.getElementById('prop-timeline').value;
        const budget = document.getElementById('prop-budget').value.trim() || 'Flexible / To be discussed';
        const details = document.getElementById('prop-details').value.trim() || 'Ready to discuss on call';

        let serviceFormatted = service === 'Other Custom Project' && otherSpec ? `Other (${otherSpec})` : service;
        const subject = encodeURIComponent(`Project Proposal: ${serviceFormatted} - ${name}`);
        const body = encodeURIComponent(`Hi Dhruvkumar,\n\nName: ${name}\nEmail: ${email}\nPhone: ${phone || 'N/A'}\nService: ${serviceFormatted}\nTimeline: ${timeline}\nTarget Budget: ${budget}\n\nProject Details:\n${details}\n\nLooking forward to your response.`);

        const safeName = escapeHTML(name);
        const gmailUrl = `https://mail.google.com/mail/?view=cm&fs=1&to=dhruvkumarmashru8@gmail.com&su=${subject}&body=${body}`;
        const mailtoUrl = `mailto:dhruvkumarmashru8@gmail.com?subject=${subject}&body=${body}`;

        showProposalStatus(`
          <div style="display:flex; align-items:flex-start; gap:10px;">
            <i class="fab fa-google" style="color:#EA4335; font-size:1.15rem; margin-top:2px;"></i>
            <div>
              <div><strong>Opening Gmail Web Compose for ${safeName}...</strong></div>
              <div style="font-size:0.78rem; margin-top:5px; color:#94A3B8;">
                Using desktop mail? <a href="${mailtoUrl}" style="color:var(--neon-cyan); text-decoration:underline; font-weight:600;">Click to open Outlook / Default Mail Client</a>
              </div>
            </div>
          </div>
        `, true);

        setTimeout(() => {
          const win = window.open(gmailUrl, '_blank', 'noopener,noreferrer');
          if (win) win.opener = null;
        }, 400);
      });
    }
  }

});
