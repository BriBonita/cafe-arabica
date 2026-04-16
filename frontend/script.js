/* ═══════════════════════════════════════════════════════════════
   Café Arábica – Main JS
   ═══════════════════════════════════════════════════════════════ */

const API_BASE = '';

// Category emoji map
const CAT_EMOJI = {
  cafe:      '☕',
  bebidas:   '🥤',
  postres:   '🍰',
  desayunos: '🥐',
};
const CAT_LABEL = {
  cafe:      'Café',
  bebidas:   'Bebida',
  postres:   'Postre',
  desayunos: 'Desayuno',
};

/* ── Navbar scroll effect ─────────────────────────────────────── */
const navbar = document.getElementById('navbar');
window.addEventListener('scroll', () => {
  navbar.classList.toggle('scrolled', window.scrollY > 60);
  updateActiveLink();
});

/* ── Mobile nav toggle ────────────────────────────────────────── */
document.getElementById('navToggle').addEventListener('click', () => {
  document.querySelector('.nav-links').classList.toggle('open');
});

// Close nav on link click (mobile)
document.querySelectorAll('.nav-link').forEach(link => {
  link.addEventListener('click', () => {
    document.querySelector('.nav-links').classList.remove('open');
  });
});

/* ── Active nav link on scroll ────────────────────────────────── */
function updateActiveLink() {
  const sections = ['inicio', 'menu', 'nosotros', 'reservar', 'contacto'];
  let current = '';
  sections.forEach(id => {
    const el = document.getElementById(id);
    if (el && window.scrollY >= el.offsetTop - 120) current = id;
  });
  document.querySelectorAll('.nav-link').forEach(link => {
    link.classList.toggle('active', link.getAttribute('href') === `#${current}`);
  });
}

/* ── Menu ─────────────────────────────────────────────────────── */
let allMenuItems = [];

async function loadMenu() {
  const grid = document.getElementById('menuGrid');
  try {
    const res  = await fetch(`${API_BASE}/api/menu`);
    allMenuItems = await res.json();
    renderMenu('all');
  } catch (err) {
    grid.innerHTML = `<p style="grid-column:1/-1;text-align:center;color:var(--text-light);padding:3rem">
      No se pudo conectar con el servidor. Comprueba que el backend esté activo.<br>
      <small style="opacity:.6">${err.message}</small>
    </p>`;
    console.error('Menu load error:', err);
  }
}

function renderMenu(cat) {
  const grid  = document.getElementById('menuGrid');
  const items = cat === 'all' ? allMenuItems : allMenuItems.filter(i => i.category === cat);
  if (!items.length) {
    grid.innerHTML = '<p style="grid-column:1/-1;text-align:center;padding:3rem;color:var(--text-light)">Sin productos en esta categoría.</p>';
    return;
  }
  grid.innerHTML = items.map((item, idx) => `
    <div class="menu-card" style="animation-delay:${idx * 60}ms">
      <div class="menu-card-img bg-${item.category}">
        <span>${CAT_EMOJI[item.category] || '☕'}</span>
        <span class="menu-card-cat">${CAT_LABEL[item.category] || item.category}</span>
      </div>
      <div class="menu-card-body">
        <h3 class="menu-card-name">${escHtml(item.name)}</h3>
        <p class="menu-card-desc">${escHtml(item.description)}</p>
        <div class="menu-card-footer">
          <span class="menu-card-price">$${Number(item.price).toFixed(2)}</span>
          <button class="menu-card-add" title="Agregar al pedido" onclick="addToOrder(${item.id}, '${escHtml(item.name)}')">+</button>
        </div>
      </div>
    </div>
  `).join('');
}

// Tab buttons
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    renderMenu(btn.dataset.cat);
  });
});

/* ── Simple cart (visual only) ────────────────────────────────── */
function addToOrder(id, name) {
  showToast(`✔ "${name}" agregado`, 'success-inline');
}

function showToast(msg, type) {
  const existing = document.querySelector('.cart-toast');
  if (existing) existing.remove();
  const t = document.createElement('div');
  t.className = 'cart-toast';
  t.textContent = msg;
  t.style.cssText = `
    position:fixed;bottom:2rem;right:2rem;
    background:var(--brown-900);color:var(--white);
    padding:.85rem 1.5rem;border-radius:50px;
    font-weight:700;font-size:.9rem;
    box-shadow:0 8px 24px rgba(0,0,0,.3);
    animation:fadeUp .4s ease;
    z-index:9999;
    border-left:4px solid var(--gold);
  `;
  document.body.appendChild(t);
  setTimeout(() => t.style.opacity = '0', 2200);
  setTimeout(() => t.remove(), 2600);
}

/* ── Reservation Form ─────────────────────────────────────────── */
document.getElementById('reservationForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const toast  = document.getElementById('formToast');
  const btn    = e.target.querySelector('button[type="submit"]');
  const name   = document.getElementById('res-name').value.trim();
  const email  = document.getElementById('res-email').value.trim();
  const date   = document.getElementById('res-date').value;
  const time   = document.getElementById('res-time').value;
  const guests = document.getElementById('res-guests').value;

  btn.disabled = true;
  btn.textContent = 'Enviando…';
  toast.className = 'form-toast';
  toast.style.display = 'none';

  try {
    const res = await fetch(`${API_BASE}/api/reservations`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, email, date, time, guests: parseInt(guests) }),
    });
    const data = await res.json();
    if (res.ok) {
      toast.textContent = `¡Reservación confirmada! (ID #${data.reservation_id}) Te esperamos el ${date} a las ${time} 🎉`;
      toast.className = 'form-toast success';
      e.target.reset();
    } else {
      toast.textContent = data.error || 'Ocurrió un error. Intenta de nuevo.';
      toast.className = 'form-toast error';
    }
  } catch (err) {
    toast.textContent = 'No se pudo conectar con el servidor.';
    toast.className = 'form-toast error';
  } finally {
    btn.disabled = false;
    btn.textContent = 'Confirmar Reservación';
  }
});

/* ── Intersection Observer – animate on scroll ─────────────────── */
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.style.animation = 'fadeUp .7s ease both';
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.feature-item, .about-content, .about-image, .stat').forEach(el => {
  el.style.opacity = '0';
  observer.observe(el);
});

/* ── Helpers ──────────────────────────────────────────────────── */
function escHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/* ── Init ─────────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', loadMenu);
