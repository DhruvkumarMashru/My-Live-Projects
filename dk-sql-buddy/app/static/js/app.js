// HTML escape helper used by renderChatFeed
function escapeHtml(str) {
    if (str == null) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function sqlBuddyApp() {
    return {
        currentTab: 'dashboard',
        wizardStep: 1,
        wizardSteps: ['Select Table', 'Upload Excel', 'Map Columns', 'Validate', 'Review SQL', 'Execute'],
        
        globalSearch: '',
        explorerSearch: '',
        
        // Toast Notifications
        toast: {
            show: false,
            message: '',
            type: 'success'
        },
        
        showToast(msg, type = 'success') {
            this.toast.message = msg;
            this.toast.type = type;
            this.toast.show = true;
            setTimeout(() => { this.toast.show = false; }, 4000);
        },
        
        // Modals
        showNewConnModal: false,
        showInspectModal: false,
        showFormatModal: false,
        showDataModal: false,
        showExportDialogModal: false,
        showScanModal: false,
        inspectModalTab: 'columns',

        // Scan & Training Progress
        scanState: {
            is_scanning: false,
            progress_pct: 100,
            status_message: 'Ready',
            current_db: '',
            scanned_tables: 0,
            total_tables: 0,
            last_trained: 'Just Now',
            is_cached: true
        },
        scanPollTimer: null,

        // Auth / User modals
        showProfileModal: false,
        showPasswordModal: false,
        showUserMgmtModal: false,
        showAddUserForm: false,

        // Current logged-in user
        currentUser: null,

        // Profile edit form
        profileEdit: { display_name: '', email: '' },

        // Password change form
        pwdChange: { old_password: '', new_password: '', confirm: '', error: '' },

        // User management
        allUsers: [],
        newUser: { username: '', display_name: '', email: '', password: '', role: 'user' },

        
        exportDialog: {
            db: '',
            table: '',
            mode: 'template'
        },
        
        viewTableData: {
            db: '',
            table: '',
            rows: [],
            loading: false
        },
        
        // New Connection Form
        newConnForm: {
            name: '',
            host: '210.212.183.19',
            port: 18187,
            user: 'support',
            password: '@Support#114477',
            train_schema: true
        },
        
        // Saved Connections
        savedConnections: [],
        activeConn: {},
        
        connConfig: {
            host: '210.212.183.19',
            port: 18187,
            user: 'support',
            password: '@Support#114477',
            use_cache: true
        },
        connStatus: {
            connected: true,
            success: true,
            message: 'Connected to Microsoft SQL Server 2022 (69 Databases Scanned)',
            latency_ms: 12.4
        },
        
        stats: {
            total_databases: 69,
            total_tables: 3428,
            total_views: 280,
            total_procedures: 4812
        },
        
        dbList: [],
        selectedDb: '',
        currentTables: [],
        inspectedTable: null,
        
        aiPromptInput: '',
        aiSuggestions: [],
        aiJoinPrompt: '',
        aiJoinDb: '',
        multiJoinResult: null,

        chatMessages: [
            {
                sender: 'bot',
                text: 'Welcome to AI SQL Chatbot Studio! Ask me for any domain entity (e.g. "employee", "sent email"), system catalog scripts ("all master tables", "all views", "stored procedures"), or paste queries to join on demand.',
                sql: null,
                title: null
            }
        ],
        chatInput: '',
        pastedSqlInput: '',

        darkMode: localStorage.getItem('theme') === 'dark',
        
        toggleDarkMode() {
            this.darkMode = !this.darkMode;
            if (this.darkMode) {
                document.documentElement.classList.add('dark');
                localStorage.setItem('theme', 'dark');
                this.showToast("Dark theme activated");
            } else {
                document.documentElement.classList.remove('dark');
                localStorage.setItem('theme', 'light');
                this.showToast("Light theme activated");
            }
            setTimeout(() => lucide.createIcons(), 50);
        },

        selectedTable: '',
        uploadedFile: null,
        uploadedData: null,
        generatedSQL: null,
        executionResult: null,
        
        importHistory: [],

        initApp() {
            if (this.darkMode) {
                document.documentElement.classList.add('dark');
            }

            // Auto-clear stale messages that have no SQL but claim to have a query
            this.chatMessages = this.chatMessages.filter(m => {
                if (m.sender === 'bot' && !m.sql && m.text && m.text.includes('T-SQL query')) return false;
                return true;
            });

            this.fetchCurrentUser();
            this.fetchStats();
            this.fetchSavedConnections();
            this.fetchDatabases();
            this.fetchHistory();
            setTimeout(() => {
                lucide.createIcons();
                this.renderChatFeed();
            }, 150);
        },


        renderChatFeed() {
            const feed = document.getElementById('chatStreamFeed');
            if (!feed) return;

            feed.innerHTML = this.chatMessages.map((msg, idx) => {
                if (msg.sender === 'user') {
                    return `<div style="display:flex;justify-content:flex-end;margin-bottom:10px">
                        <div style="max-width:75%;padding:10px 16px;background:#7c3aed;color:#fff;border-radius:16px 16px 4px 16px;font-size:12px;font-weight:600;box-shadow:0 2px 8px rgba(124,58,237,0.3)">
                            <p style="margin:0;white-space:pre-wrap">${escapeHtml(msg.text)}</p>
                        </div>
                    </div>`;
                }

                // Bot message
                let sqlCard = '';
                if (msg.sql && msg.sql.trim()) {
                    let resultHtml = '';
                    if (msg.result) {
                        if (msg.result.row_count === 0) {
                            resultHtml = `<div style="margin-top:12px;padding:10px 14px;background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.25);border-radius:10px;font-size:11px;color:#fca5a5">
                                ℹ️ Query executed successfully, but returned <strong>0 rows</strong> matching the criteria.
                            </div>`;
                        } else {
                            const headerCells = msg.result.columns.map(c =>
                                `<th style="padding:6px 10px;background:#1e293b;color:#94a3b8;font-size:10px;font-weight:700;text-transform:uppercase;border-bottom:1px solid #334155;white-space:nowrap">${escapeHtml(c)}</th>`
                            ).join('');
                            const bodyRows = msg.result.rows.map((row, ri) =>
                                `<tr style="background:${ri%2===0?'transparent':'rgba(30,41,59,0.4)'}">
                                    ${msg.result.columns.map(c =>
                                        `<td style="padding:6px 10px;font-family:monospace;color:#cbd5e1;border-bottom:1px solid #1e293b">${row[c] != null ? escapeHtml(String(row[c])) : '<span style="color:#475569">NULL</span>'}</td>`
                                    ).join('')}
                                </tr>`
                            ).join('');
                            resultHtml = `<div style="margin-top:12px;padding-top:12px;border-top:1px solid #334155">
                                <div style="font-size:10px;font-weight:800;color:#34d399;margin-bottom:8px">✓ Live DB Output — ${msg.result.row_count} rows returned</div>
                                <div style="max-height:240px;overflow:auto;border-radius:8px;border:1px solid #334155">
                                    <table style="width:100%;border-collapse:collapse;font-size:11px;text-align:left">
                                        <thead><tr>${headerCells}</tr></thead>
                                        <tbody>${bodyRows}</tbody>
                                    </table>
                                </div>
                            </div>`;
                        }
                    }

                    // AI Thought & Reasoning block
                    let reasoningHtml = '';
                    if (msg.explanation) {
                        reasoningHtml = `<div style="margin-bottom:10px;padding:8px 12px;background:rgba(59,130,246,0.1);border-radius:10px;border:1px solid rgba(59,130,246,0.25);font-size:11px;color:#93c5fd;line-height:1.5">
                            <span style="font-weight:700;color:#60a5fa">🧠 AI Reasoning:</span> ${escapeHtml(msg.explanation)}
                        </div>`;
                    }

                    // Interactive Suggestion Chips
                    let chipsHtml = '';
                    if (msg.suggested_chips && msg.suggested_chips.length > 0) {
                        chipsHtml = `<div style="margin-top:10px;padding-top:10px;border-top:1px solid #1e293b">
                            <div style="font-size:10px;font-weight:700;color:#94a3b8;margin-bottom:6px">💡 Suggested Follow-Ups:</div>
                            <div style="display:flex;flex-wrap:wrap;gap:6px">
                                ${msg.suggested_chips.map(chip =>
                                    `<button onclick="window._sqlBuddySendPrompt('${escapeHtml(chip).replace(/'/g, "\\'")}')" style="padding:4px 10px;background:rgba(124,58,237,0.2);border:1px solid #7c3aed;color:#ddd6fe;border-radius:12px;font-size:10px;font-weight:700;cursor:pointer;transition:all 0.2s">
                                        ${escapeHtml(chip)}
                                    </button>`
                                ).join('')}
                            </div>
                        </div>`;
                    }

                    const confidenceVal = msg.confidence || 98;
                    const complexityVal = msg.complexity || 'Relational Query';

                    sqlCard = `<div style="margin-top:8px;padding:14px;background:#0f172a;border-radius:16px;border:1px solid #6d28d9;box-shadow:0 4px 24px rgba(109,40,217,0.2)">
                        <div style="display:flex;justify-content:space-between;align-items:center;padding-bottom:10px;margin-bottom:10px;border-bottom:1px solid #1e293b">
                            <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap">
                                <span style="font-size:11px;font-weight:900;color:#a78bfa;text-transform:uppercase;letter-spacing:0.05em">⚡ ${escapeHtml(msg.title || 'Generated T-SQL Query')}</span>
                                <span style="font-size:9px;font-weight:700;background:rgba(16,185,129,0.2);color:#34d399;padding:2px 6px;border-radius:6px;border:1px solid rgba(16,185,129,0.3)">✨ ${confidenceVal}% Match</span>
                                <span style="font-size:9px;font-weight:700;background:rgba(59,130,246,0.2);color:#60a5fa;padding:2px 6px;border-radius:6px;border:1px solid rgba(59,130,246,0.3)">${escapeHtml(complexityVal)}</span>
                            </div>
                            <button onclick="window._sqlBuddyCopyChat(${idx})" style="padding:4px 10px;background:#1e293b;color:#c4b5fd;border:none;border-radius:8px;font-size:10px;font-weight:700;cursor:pointer">📋 Copy</button>
                        </div>
                        ${reasoningHtml}
                        <div style="background:#020617;padding:12px;border-radius:10px;border:1px solid #1e293b;margin-bottom:10px">
                            <pre style="margin:0;font-size:12px;font-family:'Courier New',monospace;color:#6ee7b7;overflow-x:auto;white-space:pre-wrap;line-height:1.6">${escapeHtml(msg.sql)}</pre>
                        </div>
                        <div style="display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:8px;padding:10px;background:rgba(88,28,135,0.2);border-radius:10px;border:1px solid rgba(109,40,217,0.4)">
                            <span style="font-size:11px;font-weight:700;color:#ddd6fe">🔍 Want live rows for this query?</span>
                            <button onclick="window._sqlBuddyFetchChat(${idx})" style="padding:7px 14px;background:linear-gradient(135deg,#059669,#0d9488);color:#fff;border:none;border-radius:10px;font-size:11px;font-weight:700;cursor:pointer;display:flex;align-items:center;gap:6px;box-shadow:0 2px 8px rgba(5,150,105,0.4)">
                                ▶ Fetch Direct DB Output Rows
                            </button>
                        </div>
                        ${resultHtml}
                        ${chipsHtml}
                    </div>`;
                }

                const loadingDots = msg._loading ? `<span style="display:inline-flex;gap:4px;margin-left:8px;vertical-align:middle">
                    <span style="width:6px;height:6px;background:#a78bfa;border-radius:50%;display:inline-block;animation:bounce 1s infinite 0ms"></span>
                    <span style="width:6px;height:6px;background:#a78bfa;border-radius:50%;display:inline-block;animation:bounce 1s infinite 150ms"></span>
                    <span style="width:6px;height:6px;background:#a78bfa;border-radius:50%;display:inline-block;animation:bounce 1s infinite 300ms"></span>
                </span>` : '';

                const isDark = document.documentElement.classList.contains('dark');
                return `<div style="display:flex;flex-direction:column;align-items:flex-start;margin-bottom:10px">
                    <div style="width:100%;max-width:97%">
                        <div style="padding:10px 16px;background:${isDark?'#1e293b':'#fff'};color:${isDark?'#f1f5f9':'#1e293b'};border-radius:16px 16px 16px 4px;border:1px solid ${isDark?'#334155':'#e2e8f0'};box-shadow:0 1px 4px rgba(0,0,0,0.07);font-size:12px;font-weight:500">
                            <p style="margin:0;white-space:pre-wrap">${escapeHtml(msg.text)}${loadingDots}</p>
                        </div>
                        ${sqlCard}
                    </div>
                </div>`;
            }).join('');

            // Add bounce animation if not already added
            if (!document.getElementById('chatBounceStyle')) {
                const style = document.createElement('style');
                style.id = 'chatBounceStyle';
                style.textContent = '@keyframes bounce { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-4px)} }';
                document.head.appendChild(style);
            }

            // Register global click handlers
            window._sqlBuddyCopyChat = (idx) => {
                const msg = this.chatMessages[idx];
                if (msg && msg.sql) {
                    navigator.clipboard.writeText(msg.sql);
                    this.showToast('✓ T-SQL query copied to clipboard!');
                }
            };
            window._sqlBuddyFetchChat = (idx) => {
                const msg = this.chatMessages[idx];
                if (msg) this.fetchDirectDbOutput(msg, idx);
            };
            window._sqlBuddySendPrompt = (prompt) => {
                if (prompt) this.sendChatMessage(prompt);
            };

            feed.scrollTop = feed.scrollHeight;
        },

        scrollChatToBottom() {
            this.renderChatFeed();
        },

        clearChat() {
            this.chatMessages = [
                {
                    sender: 'bot',
                    text: 'Chat history cleared! Ask me for any domain entity (e.g. "employee", "SentEmail WHERE..."), system catalog scripts ("all master tables", "all views"), or paste queries to join on demand.\n\nTip: After I generate a query, type "yes" or click "▶ Fetch Direct DB Output Rows" to see live database results!',
                    sql: null,
                    title: null
                }
            ];
            this.showToast('Chat history cleared');
        },

        async fetchDirectDbOutput(msg, idx) {
            if (!msg || !msg.sql) return;
            try {
                this.showToast("⏳ Fetching live DB output rows...");
                const targetDb = (msg.database && msg.database !== 'All Databases') ? msg.database : (this.selectedDb || 'master');
                const res = await fetch('/api/sql/execute', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        host: this.connConfig.host || this.activeConn.host,
                        port: this.connConfig.port || this.activeConn.port || 18187,
                        user: this.connConfig.user || this.activeConn.user,
                        password: this.connConfig.password || this.activeConn.password,
                        database: targetDb,
                        sql_script: msg.sql
                    })
                });
                const data = await res.json();
                if (data.success) {
                    const rows = data.data || [];
                    const cols = data.columns || (rows.length > 0 ? Object.keys(rows[0]) : []);
                    // Mutate the message object directly
                    msg.result = {
                        columns: cols,
                        rows: rows,
                        row_count: rows.length
                    };
                    this.showToast(`✓ Fetched ${rows.length} live records from [${targetDb}]!`);
                } else {
                    msg.result = { columns: [], rows: [], row_count: 0 };
                    this.showToast("DB error: " + (data.error || data.message || data.detail || 'Unknown error'), "error");
                }
                // Re-render the chat feed so result table appears
                this.renderChatFeed();
            } catch (e) {
                this.showToast("Error fetching DB output: " + e, "error");
            }
        },


        async sendChatMessage(promptText = null) {
            const prompt = promptText || this.chatInput;
            if (!prompt || !prompt.trim()) return;
            
            const userMsg = prompt.trim();
            this.chatMessages = [...this.chatMessages, { sender: 'user', text: userMsg, sql: null }];
            if (!promptText) this.chatInput = '';
            this.scrollChatToBottom();

            const lowerMsg = userMsg.toLowerCase();
            
            // Check if user replied 'yes' or 'run' to fetch direct output of last query
            if (['yes', 'run', 'run query', 'fetch', 'fetch output', 'output', 'show data', 'yes run', 'show rows'].includes(lowerMsg)) {
                const lastBotMsg = [...this.chatMessages].reverse().find(m => m.sender === 'bot' && m.sql);
                if (lastBotMsg) {
                    this.chatMessages = [...this.chatMessages, {
                        sender: 'bot',
                        text: `⏳ Fetching direct DB output rows for [${lastBotMsg.title || 'T-SQL'}]...`,
                        sql: null
                    }];
                    this.scrollChatToBottom();
                    await this.fetchDirectDbOutput(lastBotMsg);
                    this.scrollChatToBottom();
                    return;
                }
            }

            const targetDb = this.aiJoinDb || null;

            // Show typing indicator
            this.chatMessages = [...this.chatMessages, { sender: 'bot', text: '⏳ Processing your request with AI reasoning...', sql: null, _loading: true }];
            this.scrollChatToBottom();

            try {
                // Extract multi-turn history
                const chatHistory = this.chatMessages
                    .filter(m => !m._loading && m.text)
                    .slice(-6)
                    .map(m => ({
                        role: m.sender === 'user' ? 'user' : 'assistant',
                        content: m.text,
                        sql: m.sql || null,
                        database: m.database || null
                    }));

                const res = await fetch('/api/ai/chat', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        prompt: userMsg,
                        db_name: targetDb,
                        history: chatHistory
                    })
                });
                const data = await res.json();
                const sqlStr = (data.generated_sql || data.sql || '').trim();

                // Remove loading indicator and push real reply as new array (forces Alpine reactivity)
                this.chatMessages = [
                    ...this.chatMessages.filter(m => !m._loading),
                    {
                        sender: 'bot',
                        text: data.response || 'Here is the requested T-SQL query:',
                        sql: sqlStr || null,
                        title: data.title || 'Generated T-SQL Query',
                        database: data.database || targetDb,
                        type: data.type || 'direct_query',
                        confidence: data.confidence || 98,
                        complexity: data.complexity || 'Relational Query',
                        explanation: data.explanation || '',
                        suggested_chips: data.suggested_chips || [],
                        result: null
                    }
                ];
                this.scrollChatToBottom();
                this.showToast(data.title || 'AI Chatbot generated T-SQL query!');
            } catch (e) {
                this.chatMessages = [
                    ...this.chatMessages.filter(m => !m._loading),
                    { sender: 'bot', text: 'Error processing request: ' + e, sql: null }
                ];
                this.scrollChatToBottom();
            }
        },

        async executeChatQuery(msg) {
            if (!msg || !msg.sql) return;
            try {
                this.showToast("Executing query on live database...");
                const res = await fetch('/api/sql/execute', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        host: this.connConfig.host,
                        port: this.connConfig.port,
                        user: this.connConfig.user,
                        password: this.connConfig.password,
                        database: msg.database || this.selectedDb,
                        sql_script: msg.sql
                    })
                });
                const data = await res.json();
                if (data.success) {
                    msg.result = {
                        columns: data.columns || (data.data && data.data.length > 0 ? Object.keys(data.data[0]) : []),
                        rows: data.data || [],
                        row_count: (data.data || []).length
                    };
                    this.showToast(`✓ Query returned ${msg.result.row_count} rows!`);
                } else {
                    this.showToast("Query execution error: " + (data.message || data.detail), "error");
                }
                setTimeout(() => lucide.createIcons(), 100);
            } catch (e) {
                this.showToast("Execution error: " + e, "error");
            }
        },

        async joinPastedQueries() {
            if (!this.pastedSqlInput || !this.pastedSqlInput.trim()) {
                this.showToast("Please paste your SELECT queries first", "warning");
                return;
            }
            try {
                const res = await fetch('/api/ai/join-pasted-queries', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ pasted_sql: this.pastedSqlInput, db_name: this.aiJoinDb || this.selectedDb })
                });
                const data = await res.json();
                if (data.error) {
                    this.showToast("JOIN failed: " + data.error, "error");
                    return;
                }
                this.multiJoinResult = data;
                this.showToast(`✨ Merged ${data.pasted_tables_count || data.merged_tables_count} queries into T-SQL JOIN!`);
                setTimeout(() => lucide.createIcons(), 100);
            } catch (e) {
                this.showToast("Pasted join query failed: " + e, "error");
            }
        },

        async askAIMultiTableJoin() {
            if (!this.aiJoinPrompt) return;
            try {
                const res = await fetch('/api/ai/build-multi-table-join', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ prompt: this.aiJoinPrompt, db_name: this.aiJoinDb })
                });
                const data = await res.json();
                this.multiJoinResult = data;
                if (data.database && data.database !== this.selectedDb) {
                    this.showToast(`⚡ AI dynamically located tables in target domain database [${data.database}]!`);
                } else {
                    this.showToast("AI created multi-table JOIN query!");
                }
                setTimeout(() => lucide.createIcons(), 100);
            } catch (e) {
                this.showToast("AI join query failed: " + e, "error");
            }
        },

        async fetchSavedConnections() {
            try {
                const res = await fetch('/api/connect/saved');
                const data = await res.json();
                this.savedConnections = data;
                if (data.length > 0) {
                    this.activeConn = data.find(c => c.is_active) || data[0];
                    this.connConfig.host = this.activeConn.host;
                    this.connConfig.port = this.activeConn.port;
                    this.connConfig.user = this.activeConn.user;
                    this.connConfig.password = this.activeConn.password;
                }
            } catch (e) {
                console.error("Failed to fetch saved connections:", e);
            }
        },

        async saveNewConnection() {
            if (!this.newConnForm.name) {
                this.newConnForm.name = `DB Server (${this.newConnForm.host})`;
            }
            try {
                const res = await fetch('/api/connect/save', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        name: this.newConnForm.name,
                        host: this.newConnForm.host,
                        port: parseInt(this.newConnForm.port),
                        user: this.newConnForm.user,
                        password: this.newConnForm.password,
                        is_active: true
                    })
                });
                const updated = await res.json();
                this.savedConnections = updated;
                this.showNewConnModal = false;
                this.showToast("New connection saved successfully!");
                this.fetchSavedConnections();
            } catch (e) {
                alert("Failed to save connection: " + e);
            }
        },

        async deleteConnection(connId) {
            try {
                const res = await fetch(`/api/connect/saved/${connId}`, { method: 'DELETE' });
                const updated = await res.json();
                this.savedConnections = updated;
                this.showToast("Connection profile deleted");
            } catch (e) {
                this.showToast("Failed to delete connection: " + e, "error");
            }
        },

        switchConnection(conn) {
            this.activeConn = conn;
            this.connConfig.host = conn.host;
            this.connConfig.port = conn.port;
            this.connConfig.user = conn.user;
            this.connConfig.password = conn.password;
            
            if (conn.name) {
                const targetDb = this.dbList.find(d => d.toLowerCase() === conn.name.toLowerCase() || d.toLowerCase() === (conn.database || '').toLowerCase());
                this.selectedDb = targetDb || conn.name;
            }
            this.showToast(`Switched active connection to: ${conn.name}`);
            this.fetchDbTables();
        },

        trainConnectionSchema(conn) {
            this.startScanAndTrain(conn);
        },

        async startScanAndTrain(conn = null, dbName = null) {
            this.showScanModal = true;
            this.scanState.is_scanning = true;
            this.scanState.progress_pct = 5;
            this.scanState.status_message = "Initiating fresh live schema scan...";
            
            try {
                const res = await fetch('/api/metadata/rescan', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ force_refresh: true, db_name: dbName || this.selectedDb })
                });
                await res.json();
                
                if (this.scanPollTimer) clearInterval(this.scanPollTimer);
                
                this.scanPollTimer = setInterval(async () => {
                    try {
                        const pRes = await fetch('/api/metadata/scan-progress');
                        const pData = await pRes.json();
                        this.scanState = pData;
                        if (!pData.is_scanning && pData.progress_pct >= 100) {
                            clearInterval(this.scanPollTimer);
                            this.scanPollTimer = null;
                            this.fetchStats();
                            this.fetchDatabases();
                            this.showToast("Schema rescan & AI training 100% complete!");
                            setTimeout(() => { this.showScanModal = false; }, 1800);
                        }
                    } catch (err) {
                        console.error("Progress poll error:", err);
                    }
                }, 200);
            } catch (e) {
                this.showToast("Failed to start scan: " + e, "error");
                this.scanState.is_scanning = false;
            }
        },

        async onActiveDbChange(newDb = null) {
            if (newDb) this.selectedDb = newDb;
            this.showToast(`Active Database context set to: ${this.selectedDb}`);
            await this.fetchDbTables();
            if (this.aiJoinPrompt) {
                this.askAIMultiTableJoin();
            }
            if (this.aiPromptInput) {
                this.askAITableLocator();
            }
        },

        async fetchStats() {
            try {
                const res = await fetch('/api/metadata/summary');
                const data = await res.json();
                this.stats = data;
                if (data.last_trained) {
                    this.scanState.last_trained = data.last_trained;
                }
            } catch (e) {
                console.error("Failed to fetch stats:", e);
            }
        },

        async fetchDatabases() {
            try {
                const res = await fetch('/api/metadata/databases');
                const data = await res.json();
                this.dbList = data;
                if (this.dbList.length > 0) {
                    if (!this.selectedDb || !this.dbList.includes(this.selectedDb)) {
                        const activeName = (this.activeConn && this.activeConn.name) ? this.activeConn.name : (this.activeConn && this.activeConn.database ? this.activeConn.database : '');
                        const connMatchedDb = this.dbList.find(d => d.toLowerCase() === activeName.toLowerCase());
                        this.selectedDb = connMatchedDb || this.dbList[0];
                    }
                }
                this.fetchDbTables();
            } catch (e) {
                console.error("Failed to fetch databases:", e);
            }
        },

        async fetchDbTables() {
            if (!this.selectedDb) return;
            try {
                const res = await fetch(`/api/metadata/tables/${this.selectedDb}`);
                const data = await res.json();
                this.currentTables = data;
                if (this.currentTables.length > 0) {
                    this.selectedTable = this.currentTables[0].table_full;
                    this.inspectTable(this.selectedDb, this.selectedTable);
                }
            } catch (e) {
                console.error("Failed to fetch tables:", e);
            }
        },

        async inspectTable(db, tableFull) {
            try {
                const res = await fetch(`/api/metadata/table-details?db_name=${db}&table_name=${encodeURIComponent(tableFull)}`);
                const data = await res.json();
                this.inspectedTable = data;
                setTimeout(() => lucide.createIcons(), 50);
            } catch (e) {
                console.error("Failed to inspect table:", e);
            }
        },

        openInspectModal(db, tableFull) {
            this.inspectTable(db, tableFull).then(() => {
                this.inspectModalTab = 'columns';
                this.showInspectModal = true;
                setTimeout(() => lucide.createIcons(), 50);
            });
        },

        openFormatModal(db, tableFull) {
            this.inspectTable(db, tableFull).then(() => {
                this.inspectModalTab = 'columns';
                this.showFormatModal = true;
                setTimeout(() => lucide.createIcons(), 50);
            });
        },

        async openDataModal(db, tableFull) {
            this.viewTableData.db = db;
            this.viewTableData.table = tableFull;
            this.viewTableData.loading = true;
            this.viewTableData.rows = [];
            this.showDataModal = true;

            try {
                const formData = new FormData();
                formData.append('db_name', db);
                formData.append('table_name', tableFull);
                formData.append('host', this.connConfig.host);
                formData.append('port', this.connConfig.port);
                formData.append('user', this.connConfig.user);
                formData.append('password', this.connConfig.password);

                const res = await fetch('/api/excel/preview-data', {
                    method: 'POST',
                    body: formData
                });
                const data = await res.json();
                if (data.success) {
                    this.viewTableData.rows = data.data;
                } else {
                    this.showToast("Could not load live rows: " + data.error, "error");
                }
            } catch (e) {
                console.error("Failed to load table data:", e);
            } finally {
                this.viewTableData.loading = false;
            }
        },

        openExportDialog(db, tableFull) {
            this.exportDialog.db = db;
            this.exportDialog.table = tableFull;
            this.exportDialog.mode = 'template';
            this.showExportDialogModal = true;
        },

        confirmExport() {
            if (this.exportDialog.mode === 'template') {
                this.downloadTemplateForTable(this.exportDialog.db, this.exportDialog.table);
            } else {
                this.exportDataForTable(this.exportDialog.db, this.exportDialog.table);
            }
            this.showExportDialogModal = false;
        },

        get filteredExplorerTables() {
            if (!this.explorerSearch) return this.currentTables;
            const q = this.explorerSearch.toLowerCase();
            return this.currentTables.filter(t => t.table_name.toLowerCase().includes(q) || t.table_full.toLowerCase().includes(q));
        },

        async testConnection() {
            this.connStatus.message = "Testing database connection...";
            try {
                const res = await fetch('/api/connect/test', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(this.connConfig)
                });
                const data = await res.json();
                this.connStatus = data;
                if (data.success) {
                    this.fetchStats();
                    this.fetchDatabases();
                }
            } catch (e) {
                this.connStatus = { success: false, message: "Connection request error." };
            }
        },

        async askAITableLocator() {
            if (!this.aiPromptInput) return;
            try {
                const res = await fetch('/api/ai/suggest-tables', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ prompt: this.aiPromptInput, db_name: this.selectedDb })
                });
                const data = await res.json();
                this.aiSuggestions = data.suggestions;
            } catch (e) {
                console.error("AI locator failed:", e);
            }
        },

        selectDbAndTable(db, tableFull) {
            this.selectedDb = db;
            this.fetchDbTables().then(() => {
                this.selectedTable = tableFull;
                this.inspectTable(db, tableFull);
            });
        },

        startWizardForTable(db, tableFull) {
            this.selectDbAndTable(db, tableFull);
            this.currentTab = 'wizard';
            this.wizardStep = 1;
        },

        async downloadTemplateForTable(db, tableFull) {
            const formData = new FormData();
            formData.append('db_name', db);
            formData.append('table_name', tableFull);

            try {
                const response = await fetch('/api/excel/template', {
                    method: 'POST',
                    body: formData
                });
                const blob = await response.blob();
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `${db}_${tableFull.replace('.', '_')}_Format_Template.xlsx`;
                document.body.appendChild(a);
                a.click();
                a.remove();
            } catch (e) {
                alert("Failed to download format template: " + e);
            }
        },

        async exportDataForTable(db, tableFull) {
            const formData = new FormData();
            formData.append('db_name', db);
            formData.append('table_name', tableFull);
            formData.append('host', this.connConfig.host);
            formData.append('port', this.connConfig.port);
            formData.append('user', this.connConfig.user);
            formData.append('password', this.connConfig.password);

            try {
                const response = await fetch('/api/excel/export-data', {
                    method: 'POST',
                    body: formData
                });
                const blob = await response.blob();
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `${db}_${tableFull.replace('.', '_')}_Data_Export.xlsx`;
                document.body.appendChild(a);
                a.click();
                a.remove();
            } catch (e) {
                alert("Failed to export table data: " + e);
            }
        },

        downloadTemplate() {
            this.downloadTemplateForTable(this.selectedDb, this.selectedTable);
        },

        async handleFileUpload(event) {
            const file = event.target.files[0];
            if (!file) return;
            this.uploadedFile = file;

            const formData = new FormData();
            formData.append('file', file);
            formData.append('db_name', this.selectedDb);
            formData.append('table_name', this.selectedTable);

            try {
                const res = await fetch('/api/excel/upload', {
                    method: 'POST',
                    body: formData
                });
                const data = await res.json();
                if (data.success) {
                    this.uploadedData = data;
                    this.wizardStep = 3;
                } else {
                    alert("Excel Upload Error: " + data.error);
                }
            } catch (e) {
                alert("Upload failed: " + e);
            }
        },

        async generateSQLQuery() {
            if (!this.uploadedData) return;
            try {
                const res = await fetch('/api/sql/generate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        excel_headers: this.uploadedData.excel_headers,
                        column_mappings: this.uploadedData.column_mappings,
                        rows: this.uploadedData.validation.rows.map(r => r.original),
                        db_name: this.selectedDb,
                        table_name: this.selectedTable
                    })
                });
                const data = await res.json();
                this.generatedSQL = data.sql_result;
                this.wizardStep = 5;
            } catch (e) {
                alert("SQL Generation failed: " + e);
            }
        },

        copySQL() {
            if (this.generatedSQL?.sql) {
                navigator.clipboard.writeText(this.generatedSQL.sql);
                alert("SQL script copied to clipboard!");
            }
        },

        downloadSQL() {
            if (!this.generatedSQL?.sql) return;
            const blob = new Blob([this.generatedSQL.sql], { type: 'text/plain' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `${this.selectedTable}_Bulk_Insert.sql`;
            document.body.appendChild(a);
            a.click();
            a.remove();
        },

        async executeSQL(isDryRun = false) {
            if (!this.generatedSQL?.sql) return;
            try {
                const res = await fetch('/api/sql/execute', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        host: this.connConfig.host,
                        port: this.connConfig.port,
                        user: this.connConfig.user,
                        password: this.connConfig.password,
                        database: this.selectedDb,
                        sql_script: this.generatedSQL.sql,
                        is_dry_run: isDryRun
                    })
                });
                const data = await res.json();
                this.executionResult = data;
                this.wizardStep = 6;
                this.fetchHistory();
                setTimeout(() => lucide.createIcons(), 100);
            } catch (e) {
                alert("Execution error: " + e);
            }
        },

        async fetchHistory() {
            try {
                const res = await fetch('/api/history');
                const data = await res.json();
                this.importHistory = data;
            } catch (e) {
                console.error("Failed to fetch history:", e);
            }
        },

        handleGlobalSearch() {
            if (!this.globalSearch) return;
            this.aiPromptInput = this.globalSearch;
            this.askAITableLocator();
            this.currentTab = 'ai';
        },

        // ─── AUTH FUNCTIONS ────────────────────────────────────────────

        async fetchCurrentUser() {
            try {
                const resp = await fetch('/api/auth/me', { credentials: 'include' });
                if (resp.status === 401) { window.location.href = '/login'; return; }
                this.currentUser = await resp.json();
                this.profileEdit.display_name = this.currentUser.display_name;
                this.profileEdit.email = this.currentUser.email;
            } catch (e) { console.error('fetchCurrentUser error:', e); }
        },

        async doLogout() {
            await fetch('/api/auth/logout', { method: 'POST', credentials: 'include' });
            window.location.href = '/login';
        },

        async saveProfile() {
            const fd = new FormData();
            fd.append('display_name', this.profileEdit.display_name);
            fd.append('email', this.profileEdit.email);
            try {
                const resp = await fetch('/api/auth/update-profile', { method: 'PUT', body: fd, credentials: 'include' });
                const data = await resp.json();
                if (data.success) {
                    this.currentUser = data.user;
                    this.showProfileModal = false;
                    this.showToast('Profile updated successfully!');
                } else { this.showToast(data.detail || 'Update failed', 'error'); }
            } catch (e) { this.showToast('Error saving profile', 'error'); }
        },

        async uploadAvatar(event) {
            const file = event.target.files[0];
            if (!file) return;
            const fd = new FormData();
            fd.append('file', file);
            try {
                const resp = await fetch('/api/auth/upload-avatar', { method: 'POST', body: fd, credentials: 'include' });
                const data = await resp.json();
                if (data.success) {
                    this.currentUser = data.user;
                    this.showToast('Profile photo updated!');
                } else { this.showToast(data.detail || 'Upload failed', 'error'); }
            } catch (e) { this.showToast('Error uploading photo', 'error'); }
        },

        async deleteAvatar() {
            try {
                const resp = await fetch('/api/auth/delete-avatar', { method: 'DELETE', credentials: 'include' });
                const data = await resp.json();
                if (data.success) {
                    this.currentUser = { ...this.currentUser, avatar: null };
                    this.showToast('Profile photo removed');
                }
            } catch (e) { this.showToast('Error removing photo', 'error'); }
        },

        async savePassword() {
            this.pwdChange.error = '';
            if (!this.pwdChange.old_password || !this.pwdChange.new_password) {
                this.pwdChange.error = 'All fields are required'; return;
            }
            if (this.pwdChange.new_password !== this.pwdChange.confirm) {
                this.pwdChange.error = 'New passwords do not match'; return;
            }
            try {
                const resp = await fetch('/api/auth/change-password', {
                    method: 'PUT', credentials: 'include',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ old_password: this.pwdChange.old_password, new_password: this.pwdChange.new_password })
                });
                const data = await resp.json();
                if (resp.ok && data.success) {
                    this.showPasswordModal = false;
                    this.pwdChange = { old_password: '', new_password: '', confirm: '', error: '' };
                    this.currentUser = { ...this.currentUser, must_change_password: false };
                    this.showToast('Password changed successfully!');
                } else { this.pwdChange.error = data.detail || 'Failed to change password'; }
            } catch (e) { this.pwdChange.error = 'Connection error'; }
        },

        async openUserMgmt() {
            this.showUserMgmtModal = true;
            try {
                const resp = await fetch('/api/users', { credentials: 'include' });
                this.allUsers = await resp.json();
                setTimeout(() => lucide.createIcons(), 100);
            } catch (e) { this.showToast('Failed to load users', 'error'); }
        },

        async createUser() {
            const u = this.newUser;
            if (!u.username || !u.display_name || !u.password) {
                this.showToast('Username, display name and password are required', 'error'); return;
            }
            try {
                const resp = await fetch('/api/users', {
                    method: 'POST', credentials: 'include',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(u)
                });
                const data = await resp.json();
                if (resp.ok && data.success) {
                    this.allUsers.push(data.user);
                    this.newUser = { username: '', display_name: '', email: '', password: '', role: 'user' };
                    this.showAddUserForm = false;
                    this.showToast('User created successfully!');
                    setTimeout(() => lucide.createIcons(), 100);
                } else { this.showToast(data.detail || 'Failed to create user', 'error'); }
            } catch (e) { this.showToast('Error creating user', 'error'); }
        },

        async toggleUserStatus(user) {
            try {
                const resp = await fetch(`/api/users/${user.id}`, {
                    method: 'PUT', credentials: 'include',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ is_active: !user.is_active })
                });
                const data = await resp.json();
                if (data.success) {
                    const idx = this.allUsers.findIndex(u => u.id === user.id);
                    if (idx >= 0) this.allUsers[idx] = data.user;
                    this.showToast(`User ${data.user.is_active ? 'enabled' : 'disabled'}`);
                    setTimeout(() => lucide.createIcons(), 100);
                }
            } catch (e) { this.showToast('Error updating user', 'error'); }
        },

        async deleteUserAdmin(user) {
            if (!confirm(`Delete user "${user.display_name}"? This cannot be undone.`)) return;
            try {
                const resp = await fetch(`/api/users/${user.id}`, { method: 'DELETE', credentials: 'include' });
                const data = await resp.json();
                if (resp.ok && data.success) {
                    this.allUsers = this.allUsers.filter(u => u.id !== user.id);
                    this.showToast('User deleted');
                } else { this.showToast(data.detail || 'Failed to delete user', 'error'); }
            } catch (e) { this.showToast('Error deleting user', 'error'); }
        },

    };
}
