/**
 * GlaucoScan AI — Main JavaScript
 * Handles: Upload, Prediction, Animations, UI State
 */

'use strict';

// ── Global State ─────────────────────────────────────────────────
let selectedModel   = 'efficientnet';
let selectedFile    = null;
let currentPatientId = null;

// ── DOM Ready ─────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  initThemeToggle();
  initParticles();
  initAnimations();
  autoSelectDefaultModel();
  initTableFilter();
});

// ── Floating Particles ────────────────────────────────────────────
function initParticles() {
  const container = document.getElementById('particles');
  if (!container) return;
  
  const colors = ['#3b82f6', '#8b5cf6', '#06b6d4', '#10b981'];
  
  for (let i = 0; i < 30; i++) {
    const p = document.createElement('div');
    p.className = 'particle';
    
    const size  = Math.random() * 4 + 2;
    const color = colors[Math.floor(Math.random() * colors.length)];
    const delay = Math.random() * 20;
    const dur   = Math.random() * 15 + 10;
    const left  = Math.random() * 100;
    
    p.style.cssText = `
      width: ${size}px; height: ${size}px;
      background: ${color};
      left: ${left}%;
      animation-delay: -${delay}s;
      animation-duration: ${dur}s;
      filter: blur(${size > 4 ? 1 : 0}px);
    `;
    container.appendChild(p);
  }
}

// ── Counter Animation ─────────────────────────────────────────────
function initAnimations() {
  // Animate stat numbers
  document.querySelectorAll('.stat-number').forEach(el => {
    const target = el.textContent.replace(/[^0-9]/g, '');
    if (target && !isNaN(target)) {
      animateCounter(el, 0, parseInt(target), 1200);
    }
  });
}

function animateCounter(el, start, end, duration) {
  const range   = end - start;
  const increment = end > start ? 1 : -1;
  const step    = Math.abs(Math.floor(duration / range)) || 16;
  const suffix  = el.textContent.replace(/[0-9]/g, '').trim();
  
  let current = start;
  const timer = setInterval(() => {
    current += Math.ceil(range / 20);
    if (current >= end) { current = end; clearInterval(timer); }
    el.textContent = current + (suffix || '');
  }, step);
}

// ── Model Selection ───────────────────────────────────────────────
function selectModel(name, el) {
  selectedModel = name;
  document.querySelectorAll('.model-card').forEach(c => c.classList.remove('selected'));
  if (el) el.classList.add('selected');
}

function autoSelectDefaultModel() {
  const def = document.querySelector('[data-model="efficientnet"]');
  if (def) def.classList.add('selected');
}

// ── File Handling ─────────────────────────────────────────────────
function handleDragOver(e) {
  e.preventDefault();
  document.getElementById('drop-zone').classList.add('drag-over');
}

function handleDragLeave(e) {
  document.getElementById('drop-zone').classList.remove('drag-over');
}

function handleDrop(e) {
  e.preventDefault();
  document.getElementById('drop-zone').classList.remove('drag-over');
  const file = e.dataTransfer.files[0];
  if (file) processFile(file);
}

function handleFileSelect(e) {
  const file = e.target.files[0];
  if (file) processFile(file);
}

function processFile(file) {
  const allowed = ['image/png', 'image/jpeg', 'image/bmp', 'image/tiff'];
  
  if (!allowed.includes(file.type)) {
    showToast('❌ Please upload a PNG, JPG, or BMP image', 'error');
    return;
  }
  
  if (file.size > 16 * 1024 * 1024) {
    showToast('❌ File too large (max 16MB)', 'error');
    return;
  }
  
  selectedFile = file;
  
  // Show preview
  const reader = new FileReader();
  reader.onload = (e) => {
    const img = document.getElementById('image-preview');
    img.src   = e.target.result;
    
    document.getElementById('drop-zone').style.display = 'none';
    document.getElementById('preview-container').style.display = 'block';
    document.getElementById('predict-btn').disabled = false;
    
    // Update drop zone icon
    document.getElementById('drop-icon').textContent = '✅';
    document.getElementById('drop-text').innerHTML = `
      <strong>${file.name}</strong>
      <span>${(file.size / 1024).toFixed(0)} KB — Ready for analysis</span>
    `;
  };
  reader.readAsDataURL(file);
}

function clearImage() {
  selectedFile = null;
  document.getElementById('file-input').value = '';
  document.getElementById('drop-zone').style.display = 'block';
  document.getElementById('preview-container').style.display = 'none';
  document.getElementById('predict-btn').disabled = true;
  document.getElementById('drop-icon').textContent = '🫁';
  document.getElementById('drop-text').innerHTML = `
    <strong>Drag & Drop OCT Image Here</strong>
    <span>or click to browse files</span>
  `;
}

// ── Run Prediction ────────────────────────────────────────────────
async function runPrediction() {
  if (!selectedFile) {
    showToast('❌ Please select an OCT image first', 'error');
    return;
  }
  
  // Show loading
  showLoadingState();
  
  // Optional: Create patient first
  const patientName = document.getElementById('patient-name')?.value;
  if (patientName && !currentPatientId) {
    try {
      const pRes = await fetch('/patient/add', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          name:   patientName,
          age:    document.getElementById('patient-age')?.value || null,
          gender: document.getElementById('patient-gender')?.value || null,
        }),
      });
      const pData = await pRes.json();
      if (pData.success) currentPatientId = pData.patient_id;
    } catch (e) { /* non-critical */ }
  }
  
  // Build form data
  const formData = new FormData();
  formData.append('image',      selectedFile);
  formData.append('model',      selectedModel);
  formData.append('gradcam',    document.getElementById('gradcam-toggle')?.checked ? 'true' : 'false');
  if (currentPatientId) formData.append('patient_id', currentPatientId);
  
  // Simulate progress steps
  simulateProgress();
  
  try {
    const res  = await fetch('/predict', { method: 'POST', body: formData });
    const data = await res.json();
    
    if (data.error && data.error.includes('not trained')) {
      hideLoadingState();
      showToast(`⏳ ${data.error}`, 'warning');
      return;
    }
    
    if (!res.ok) {
      throw new Error(data.error || 'Prediction failed');
    }
    
    // Show results
    setTimeout(() => showResults(data), 500);
    
  } catch (err) {
    hideLoadingState();
    showToast(`❌ Error: ${err.message}`, 'error');
    console.error(err);
  }
}

// ── Progress Simulation ───────────────────────────────────────────
let progressTimer = null;
function simulateProgress() {
  const fill  = document.getElementById('progress-fill');
  const step  = document.getElementById('loading-step');
  const steps = [
    [10, 'Preprocessing image with CLAHE...'],
    [30, 'Extracting deep features...'],
    [55, `Running ${selectedModel.toUpperCase()} model...`],
    [75, 'Computing class probabilities...'],
    [90, 'Generating Grad-CAM heatmap...'],
    [98, 'Finalizing results...'],
  ];
  
  let i = 0;
  progressTimer = setInterval(() => {
    if (i < steps.length) {
      fill.style.width = steps[i][0] + '%';
      step.textContent = steps[i][1];
      i++;
    }
  }, 600);
}

// ── UI State Managers ─────────────────────────────────────────────
function showLoadingState() {
  document.getElementById('empty-state').style.display   = 'none';
  document.getElementById('results-state').style.display = 'none';
  document.getElementById('loading-state').style.display = 'block';
  document.getElementById('predict-btn').disabled = true;
  document.getElementById('results-card').style.alignItems = 'center';
  document.getElementById('results-card').style.justifyContent = 'center';
}

function hideLoadingState() {
  if (progressTimer) clearInterval(progressTimer);
  document.getElementById('loading-state').style.display = 'none';
  document.getElementById('predict-btn').disabled = false;
}

// ── Show Results ──────────────────────────────────────────────────
function showResults(data) {
  hideLoadingState();
  
  const isGlaucoma = data.prediction === 'glaucoma';
  
  // Verdict
  const banner = document.getElementById('verdict-banner');
  document.getElementById('verdict-icon').textContent = isGlaucoma ? '⚠️' : '✅';
  document.getElementById('verdict-title').textContent = isGlaucoma
    ? '⚠️ Glaucoma Detected' : '✅ Normal Retina';
  document.getElementById('verdict-sub').textContent = isGlaucoma
    ? `Glaucoma signs detected with ${data.confidence}% confidence. Consult a specialist.`
    : `No signs of glaucoma detected. Confidence: ${data.confidence}%.`;
  
  if (isGlaucoma) banner.classList.add('glaucoma');
  else banner.classList.remove('glaucoma');
  
  // Risk badge
  const riskBadge = document.getElementById('risk-badge');
  riskBadge.textContent = data.risk_level;
  riskBadge.className   = 'risk-badge ' + (data.risk_level === 'HIGH' ? 'high' : data.risk_level === 'MODERATE' ? 'moderate' : '');
  
  // Confidence bars (animate)
  setTimeout(() => {
    document.getElementById('bar-normal').style.width   = data.prob_normal   + '%';
    document.getElementById('bar-glaucoma').style.width = data.prob_glaucoma + '%';
    document.getElementById('pct-normal').textContent   = data.prob_normal   + '%';
    document.getElementById('pct-glaucoma').textContent = data.prob_glaucoma + '%';
  }, 100);
  
  // Grad-CAM
  if (data.gradcam_url) {
    document.getElementById('gradcam-section').style.display = 'block';
    document.getElementById('original-img').src = data.image_url;
    document.getElementById('gradcam-img').src  = data.gradcam_url;
  }
  
  // Meta
  const modelDisplay = {
    cnn: 'Custom CNN', vgg16: 'VGG16', resnet50: 'ResNet50',
    efficientnet: 'EfficientNetB0', ensemble: 'Ensemble'
  };
  document.getElementById('meta-model').textContent = modelDisplay[data.model_used] || data.model_used;
  document.getElementById('meta-time').textContent  = data.inference_ms ? `${data.inference_ms} ms` : '—';
  document.getElementById('meta-ts').textContent    = data.timestamp;
  
  // Show results
  document.getElementById('results-card').style.alignItems    = 'flex-start';
  document.getElementById('results-card').style.justifyContent = 'flex-start';
  document.getElementById('results-state').style.display = 'block';
  
  // Scroll results into view
  document.getElementById('results-card').scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  
  showToast(
    isGlaucoma ? '⚠️ Glaucoma detected — please consult a specialist' : '✅ Analysis complete — Normal retina',
    isGlaucoma ? 'warning' : 'success'
  );
}

// ── Actions ───────────────────────────────────────────────────────
function analyzeAnother() {
  clearImage();
  document.getElementById('results-state').style.display = 'none';
  document.getElementById('empty-state').style.display   = 'block';
  document.getElementById('results-card').style.alignItems    = 'center';
  document.getElementById('results-card').style.justifyContent = 'center';
  document.getElementById('gradcam-section').style.display = 'none';
}

function viewDashboard() {
  window.location.href = '/dashboard';
}

// ── Toast Notifications ───────────────────────────────────────────
function showToast(message, type = 'info') {
  // Remove existing
  document.querySelectorAll('.toast').forEach(t => t.remove());
  
  const toast = document.createElement('div');
  toast.className = 'toast toast-' + type;
  toast.textContent = message;
  toast.style.cssText = `
    position: fixed; bottom: 30px; right: 30px; z-index: 9999;
    padding: 14px 24px; border-radius: 12px;
    font-size: 14px; font-weight: 600; color: white;
    box-shadow: 0 8px 32px rgba(0,0,0,0.4);
    backdrop-filter: blur(12px);
    animation: slideIn 0.3s ease;
    max-width: 400px;
    background: ${
      type === 'success' ? 'rgba(16,185,129,0.9)' :
      type === 'error'   ? 'rgba(239,68,68,0.9)' :
      type === 'warning' ? 'rgba(245,158,11,0.9)' :
                           'rgba(59,130,246,0.9)'
    };
  `;
  
  document.body.appendChild(toast);
  
  setTimeout(() => {
    toast.style.animation = 'slideOut 0.3s ease forwards';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

// Add toast animations
const style = document.createElement('style');
style.textContent = `
  @keyframes slideIn  { from { transform: translateX(120px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
  @keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(120px); opacity: 0; } }
`;
document.head.appendChild(style);

// ── Dashboard: Metric bar animations ─────────────────────────────
function animateDashboardBars() {
  document.querySelectorAll('.metric-bar[data-value]').forEach(bar => {
    setTimeout(() => {
      bar.style.width = (parseFloat(bar.dataset.value) * 100) + '%';
    }, 100);
  });
}
if (document.querySelector('.metric-bar')) {
  animateDashboardBars();
}

// ── Theme Toggle Logic ───────────────────────────────────────────
function initThemeToggle() {
  const toggleBtn = document.getElementById('theme-toggle');
  if (!toggleBtn) return;

  // Read theme state
  const currentTheme = localStorage.getItem('theme');
  const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

  if (currentTheme === 'light' || (!currentTheme && !systemPrefersDark)) {
    document.body.classList.add('light-mode');
  } else {
    document.body.classList.remove('light-mode');
  }

  toggleBtn.addEventListener('click', () => {
    document.body.classList.toggle('light-mode');
    const theme = document.body.classList.contains('light-mode') ? 'light' : 'dark';
    localStorage.setItem('theme', theme);
    showToast(`🌓 Switched to ${theme} mode`, 'info');
  });
}

// ── Table Search & Filter ────────────────────────────────────────
function initTableFilter() {
  const searchInput = document.getElementById('table-search');
  const filterSelect = document.getElementById('table-filter');
  const tableRows = document.querySelectorAll('.data-table tbody tr');

  if (!searchInput || !filterSelect || tableRows.length === 0) return;

  function filterTable() {
    const query = searchInput.value.toLowerCase().trim();
    const filter = filterSelect.value;

    tableRows.forEach(row => {
      const text = row.textContent.toLowerCase();
      const hasQuery = text.includes(query);
      
      const badge = row.querySelector('.pred-badge');
      const isGlaucoma = badge ? badge.classList.contains('glaucoma') : false;
      const isNormal = badge ? badge.classList.contains('normal') : false;

      let matchesFilter = true;
      if (filter === 'glaucoma') matchesFilter = isGlaucoma;
      else if (filter === 'normal') matchesFilter = isNormal;

      if (hasQuery && matchesFilter) {
        row.style.display = '';
      } else {
        row.style.display = 'none';
      }
    });
  }

  searchInput.addEventListener('input', filterTable);
  filterSelect.addEventListener('change', filterTable);
}
