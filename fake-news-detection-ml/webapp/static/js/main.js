// Client-Side Controller for Fake News Detection System Workspace

document.addEventListener("DOMContentLoaded", () => {
    // ── Theme Switcher ──
    const themeBtn = document.getElementById("theme-toggle-btn");
    if (themeBtn) {
        const savedTheme = localStorage.getItem("news-theme") || "dark-theme";
        document.body.className = savedTheme;
        updateThemeIcon(savedTheme);

        themeBtn.addEventListener("click", () => {
            const currentTheme = document.body.className;
            const newTheme = currentTheme === "dark-theme" ? "light-theme" : "dark-theme";
            document.body.className = newTheme;
            localStorage.setItem("news-theme", newTheme);
            updateThemeIcon(newTheme);
        });
    }

    function updateThemeIcon(theme) {
        const icon = themeBtn.querySelector("i");
        if (icon) {
            icon.className = theme === "dark-theme" ? "fa-solid fa-sun" : "fa-solid fa-moon";
        }
    }

    // ── Toast Alerts Helper ──
    function showToast(message, type = "info") {
        const container = document.getElementById("toast-container");
        if (!container) return;
        
        const toast = document.createElement("div");
        toast.className = `toast ${type}`;
        
        let icon = "fa-circle-info";
        if (type === "success") icon = "fa-circle-check";
        if (type === "error") icon = "fa-circle-exclamation";
        
        toast.innerHTML = `
            <i class="fa-solid ${icon}"></i>
            <span>${message}</span>
        `;
        
        container.appendChild(toast);
        
        setTimeout(() => {
            toast.style.opacity = "0";
            toast.style.transform = "translateY(20px)";
            setTimeout(() => toast.remove(), 300);
        }, 4000);
    }

    // ── Form Submissions (NLP Prediction) ──
    const form = document.getElementById("analyze-form");
    if (form) {
        form.addEventListener("submit", (e) => {
            e.preventDefault();
            
            const titleInput = document.getElementById("article-title");
            const textInput = document.getElementById("article-text");
            const modelInput = document.getElementById("model-select");
            
            if (!textInput || !textInput.value.trim()) {
                showToast("Please enter the article body text.", "error");
                return;
            }

            const payload = {
                title: titleInput ? titleInput.value.trim() : "",
                text: textInput.value.trim(),
                model: modelInput ? modelInput.value : "ensemble"
            };

            // Loading state on button
            const btn = document.getElementById("analyze-btn");
            const origHTML = btn.innerHTML;
            btn.innerHTML = `<i class="fa-solid fa-spinner fa-spin"></i> Running NLP Inference...`;
            btn.disabled = true;

            fetch("/predict", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            })
            .then(res => res.json())
            .then(data => {
                btn.innerHTML = origHTML;
                btn.disabled = false;
                
                if (data.error) {
                    showToast(data.error, "error");
                    return;
                }

                showToast("NLP classification evaluated successfully.", "success");
                
                // Update Prediction Pill
                const pill = document.getElementById("pred-pill");
                const scoreText = document.getElementById("confidence-score");
                const modelUsedText = document.getElementById("output-model-used");
                
                if (pill && scoreText) {
                    pill.innerText = data.prediction;
                    pill.className = `prediction-pill ${data.prediction.toLowerCase()}`;
                    scoreText.innerText = `${data.confidence}% confidence`;
                }
                
                if (modelUsedText) {
                     modelUsedText.innerText = `Evaluated via: ${data.model_used}`;
                }

                // Update Progress bars (Fake vs Real probabilities)
                const fakeBar = document.getElementById("fake-bar-fill");
                const fakeText = document.getElementById("fake-prob-text");
                const realBar = document.getElementById("real-bar-fill");
                const realText = document.getElementById("real-prob-text");

                if (fakeBar && fakeText) {
                    fakeBar.style.width = `${data.prob_fake}%`;
                    fakeText.innerText = `${data.prob_fake}%`;
                }
                if (realBar && realText) {
                    realBar.style.width = `${data.prob_real}%`;
                    realText.innerText = `${data.prob_real}%`;
                }

                // Update Explainer view HTML
                const explainBox = document.getElementById("explain-box");
                if (explainBox && data.explained_html) {
                    explainBox.innerHTML = data.explained_html;
                }

                // Refresh dashboard statistics values if index contains KPI elements
                refreshDashboardStats();
                
                // Reload list or add row to history table
                reloadHistoryTable();
            })
            .catch(err => {
                btn.innerHTML = origHTML;
                btn.disabled = false;
                showToast("Failed to connect to Flask server.", "error");
            });
        });
    }

    // ── Table reloading and operations ──
    const tbody = document.getElementById("history-tbody");
    
    function reloadHistoryTable() {
        if (!tbody) return;
        
        // Quick reload via page reload or local table insert. Page reload is standard to sync stats,
        // or we can reload data via AJAX. Let's do a location reload to update SQL KPIs simultaneously
        // on dashboard. But wait, if we are in index, let's reload the page to refresh stats
        // and database logs instantly. Or if the user prefers, a smooth AJAX transition.
        // Let's do a smooth location reload for dashboard and static data.
        // Wait, let's check if we want to run location.reload() after a short delay
        setTimeout(() => {
            // Check if page has dashboard KPIs, if so, reload to sync database aggregates
            if (document.getElementById("avg-confidence-card") || tbody) {
                 location.reload();
            }
        }, 1500);
    }

    // ── Delete database records logs ──
    const deleteButtons = document.querySelectorAll(".delete-btn");
    deleteButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            const logId = btn.getAttribute("data-id");
            if (confirm(`Are you sure you want to delete prediction record #${logId}?`)) {
                fetch(`/api/delete/${logId}`, { method: "DELETE" })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showToast(data.message, "success");
                            // Remove row visually
                            btn.closest("tr").remove();
                            setTimeout(() => location.reload(), 1000);
                        } else {
                            showToast("Failed to delete record.", "error");
                        }
                    })
                    .catch(() => {
                        showToast("Connection error while deleting.", "error");
                    });
            }
        });
    });

    // ── Search Registry Filter ──
    const searchInput = document.getElementById("registry-search");
    if (searchInput && tbody) {
        searchInput.addEventListener("keyup", (e) => {
            const query = e.target.value.toLowerCase();
            const rows = tbody.querySelectorAll("tr");
            
            rows.forEach(row => {
                if (row.querySelector(".empty-table-msg")) return;
                const text = row.innerText.toLowerCase();
                row.style.display = text.includes(query) ? "" : "none";
            });
        });
    }

    function refreshDashboardStats() {
         // AJAX endpoint updates if needed, otherwise handled via reload
    }
});
