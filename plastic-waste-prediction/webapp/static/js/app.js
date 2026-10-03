// Client-side controller for Ocean Sentry AI Dashboard

document.addEventListener("DOMContentLoaded", () => {
    // ── Sliders Linkage ──
    const sliders = [
        { id: "distance_to_coast", valId: "distance_to_coast_val", suffix: " km" },
        { id: "river_discharge", valId: "river_discharge_val", suffix: " m³/s" },
        { id: "current_speed", valId: "current_speed_val", suffix: " m/s" },
        { id: "wind_velocity", valId: "wind_velocity_val", suffix: " m/s" },
        { id: "population_density", valId: "population_density_val", suffix: " people/km²" }
    ];

    sliders.forEach(s => {
        const input = document.getElementById(s.id);
        const display = document.getElementById(s.valId);
        if (input && display) {
            input.addEventListener("input", (e) => {
                display.innerText = e.target.value + s.suffix;
            });
        }
    });

    // ── Theme Toggle ──
    const themeBtn = document.getElementById("theme-toggle-btn");
    if (themeBtn) {
        // Load preference
        const savedTheme = localStorage.getItem("theme") || "dark-theme";
        document.body.className = savedTheme;
        updateThemeIcon(savedTheme);

        themeBtn.addEventListener("click", () => {
            const currentTheme = document.body.className;
            const newTheme = currentTheme === "dark-theme" ? "light-theme" : "dark-theme";
            document.body.className = newTheme;
            localStorage.setItem("theme", newTheme);
            updateThemeIcon(newTheme);
        });
    }

    function updateThemeIcon(theme) {
        const icon = themeBtn.querySelector("i");
        if (icon) {
            if (theme === "dark-theme") {
                icon.className = "fa-solid fa-sun";
            } else {
                icon.className = "fa-solid fa-moon";
            }
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
        
        // Remove after 4s
        setTimeout(() => {
            toast.style.opacity = "0";
            toast.style.transform = "translateY(20px)";
            setTimeout(() => toast.remove(), 300);
        }, 4000);
    }

    // ── SVG Gauge Logic ──
    const maxScaleValue = 10000.0; // g/km2
    const totalArcLength = 125.66; // perimeter of semicircle (r=40)

    function updateGauge(density, category, coordsText) {
        const gaugeFill = document.getElementById("gauge-fill-arc");
        const outVal = document.getElementById("output-val");
        const outCat = document.getElementById("output-category");
        const outCoords = document.getElementById("output-coords");

        if (!gaugeFill || !outVal || !outCat || !outCoords) return;

        // Animate text
        outVal.innerText = density.toLocaleString(undefined, { minimumFractionDigits: 1, maximumFractionDigits: 1 });
        outCoords.innerText = coordsText;
        
        // Category pill styling
        outCat.innerText = category;
        outCat.className = "category-pill";
        const catLower = category.toLowerCase();
        if (catLower.includes("low")) {
            outCat.classList.add("low");
        } else if (catLower.includes("mod")) {
            outCat.classList.add("mod");
        } else {
            outCat.classList.add("high");
        }

        // SVG stroke-dashoffset math
        const fraction = Math.min(density / maxScaleValue, 1.0);
        const offset = totalArcLength * (1.0 - fraction);
        gaugeFill.style.strokeDashoffset = offset;
    }

    // ── Chart.js Feature Importance ──
    let chartInstance = null;
    function initChart() {
        const ctx = document.getElementById("importanceChart");
        if (!ctx) return;
        
        const isDark = document.body.classList.contains("dark-theme");
        const labelColor = isDark ? "#90a4ae" : "#5a6e85";
        
        chartInstance = new Chart(ctx, {
            type: "bar",
            data: {
                labels: ["Coastal Proximity", "Coastal Population", "Estuary Output", "Current Velocity", "Wind Speed"],
                datasets: [{
                    label: "Feature Importance Score",
                    data: [0.38, 0.30, 0.18, 0.10, 0.04],
                    backgroundColor: [
                        "rgba(0, 242, 254, 0.7)",
                        "rgba(79, 172, 254, 0.7)",
                        "rgba(0, 112, 243, 0.7)",
                        "rgba(90, 110, 140, 0.7)",
                        "rgba(0, 230, 118, 0.7)"
                    ],
                    borderColor: [
                        "#00f2fe",
                        "#4facfe",
                        "#0070f3",
                        "#5a6e85",
                        "#00e676"
                    ],
                    borderWidth: 1.5,
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: labelColor, font: { family: "Inter", size: 10 } }
                    },
                    y: {
                        beginAtZero: true,
                        grid: { color: "rgba(255, 255, 255, 0.04)" },
                        ticks: { color: labelColor, font: { family: "Inter", size: 10 } }
                    }
                }
            }
        });
    }

    initChart();

    // Re-render chart grid colors when theme changes
    const observer = new MutationObserver(() => {
        if (chartInstance) {
            const isDark = document.body.classList.contains("dark-theme");
            const labelColor = isDark ? "#90a4ae" : "#5a6e85";
            chartInstance.options.scales.x.ticks.color = labelColor;
            chartInstance.options.scales.y.ticks.color = labelColor;
            chartInstance.update();
        }
    });
    observer.observe(document.body, { attributes: true, attributeFilter: ["class"] });

    // ── Ingest database prediction history log ──
    const tbody = document.getElementById("registry-tbody");
    const searchInput = document.getElementById("registry-search");

    function fetchHistory() {
        if (!tbody) return;
        
        fetch("/history")
            .then(res => res.json())
            .then(data => {
                renderHistoryRows(data);
            })
            .catch(err => {
                tbody.innerHTML = `<tr><td colspan="10" class="empty-table-msg error">Failed to retrieve historical logs.</td></tr>`;
            });
    }

    function renderHistoryRows(rows) {
        if (!tbody) return;
        if (rows.length === 0) {
            tbody.innerHTML = `<tr><td colspan="10" class="empty-table-msg">No prediction transaction logs in database. Set parameters and run an analysis.</td></tr>`;
            return;
        }

        tbody.innerHTML = "";
        rows.forEach(r => {
            const tr = document.createElement("tr");
            
            // Format timestamp (YYYY-MM-DD HH:MM)
            const dateStr = r.timestamp.replace("T", " ").substring(0, 16);
            
            // Category class mapping
            const catLower = r.category.toLowerCase();
            let catClass = "low";
            if (catLower.includes("mod")) catClass = "mod";
            if (catLower.includes("high")) catClass = "high";

            tr.innerHTML = `
                <td><strong>${dateStr}</strong></td>
                <td><a href="https://maps.google.com/?q=${r.latitude},${r.longitude}" target="_blank" class="slider-val" style="text-decoration:none;"><i class="fa-solid fa-location-dot"></i> ${r.latitude.toFixed(3)}°, ${r.longitude.toFixed(3)}°</a></td>
                <td>${r.distance_to_coast.toFixed(1)} km</td>
                <td>${r.river_discharge.toFixed(0)} m³/s</td>
                <td>${r.current_speed.toFixed(2)} m/s</td>
                <td>${r.wind_velocity.toFixed(1)} m/s</td>
                <td>${r.population_density.toLocaleString()} /km²</td>
                <td><span style="font-family:'Outfit'; font-weight:700;">${r.predicted_density.toLocaleString(undefined, {minimumFractionDigits: 1})}</span></td>
                <td><span class="cell-cat ${catClass}">${r.category}</span></td>
                <td>
                    <button class="delete-btn" data-id="${r.id}" title="Delete Record">
                        <i class="fa-solid fa-trash-can"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(tr);
        });

        // Bind delete buttons
        const deleteButtons = tbody.querySelectorAll(".delete-btn");
        deleteButtons.forEach(btn => {
            btn.addEventListener("click", (e) => {
                const logId = btn.getAttribute("data-id");
                if (confirm(`Delete database record #${logId}?`)) {
                    deleteLog(logId);
                }
            });
        });
    }

    function deleteLog(id) {
        fetch(`/delete/${id}`, { method: "DELETE" })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showToast(`Logged record #${id} removed successfully.`, "success");
                    updateKPIs(data.stats);
                    fetchHistory();
                } else {
                    showToast("Failed to delete record.", "error");
                }
            })
            .catch(err => {
                showToast("Connection error while deleting.", "error");
            });
    }

    function updateKPIs(stats) {
        document.getElementById("avg-density").innerHTML = `${stats.avg_density} <span class="unit">g/km²</span>`;
        document.getElementById("max-hotspot").innerText = stats.hotspot;
        document.getElementById("total-logs").innerText = stats.total_logs;
        document.getElementById("model-accuracy").innerText = stats.model_accuracy;
    }

    fetchHistory();

    // ── Search filtering on database history grid ──
    if (searchInput) {
        searchInput.addEventListener("keyup", (e) => {
            const query = e.target.value.toLowerCase();
            const rows = tbody.querySelectorAll("tr");
            rows.forEach(row => {
                if (row.querySelector(".empty-table-msg")) return;
                const text = row.innerText.toLowerCase();
                if (text.includes(query)) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            });
        });
    }

    // ── Form Predict Submission ──
    const form = document.getElementById("prediction-form");
    if (form) {
        form.addEventListener("submit", (e) => {
            e.preventDefault();
            
            // Collect features
            const payload = {
                latitude: parseFloat(document.getElementById("latitude").value),
                longitude: parseFloat(document.getElementById("longitude").value),
                distance_to_coast: parseFloat(document.getElementById("distance_to_coast").value),
                river_discharge: parseFloat(document.getElementById("river_discharge").value),
                current_speed: parseFloat(document.getElementById("current_speed").value),
                wind_velocity: parseFloat(document.getElementById("wind_velocity").value),
                population_density: parseFloat(document.getElementById("population_density").value)
            };

            // Loading state on button
            const btn = document.getElementById("predict-btn");
            const origHTML = btn.innerHTML;
            btn.innerHTML = `<i class="fa-solid fa-spinner fa-spin"></i> Running RF Inference...`;
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

                showToast("Random Forest forecast evaluated successfully.", "success");
                
                // Update outcomes
                const coordsText = `Location: ${data.latitude.toFixed(3)}°, ${data.longitude.toFixed(3)}°`;
                updateGauge(data.predicted_density, data.category, coordsText);
                
                // Update statistics
                updateKPIs(data.stats);
                
                // Refresh list
                fetchHistory();
            })
            .catch(err => {
                btn.innerHTML = origHTML;
                btn.disabled = false;
                showToast("Failed to connect to inference engine.", "error");
            });
        });
    }
});
