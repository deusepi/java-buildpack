// Starfield background
function initStarfield() {
  const field = document.querySelector('.starfield');
  if (!field) return;
  for (let i = 0; i < 80; i++) {
    const star = document.createElement('div');
    star.className = 'star';
    star.style.cssText = `
      left: ${Math.random() * 100}%;
      top: ${Math.random() * 100}%;
      --dur: ${3 + Math.random() * 6}s;
      --delay: ${-Math.random() * 8}s;
      --max-opacity: ${0.15 + Math.random() * 0.45};
      width: ${Math.random() > 0.85 ? 2 : 1}px;
      height: ${Math.random() > 0.85 ? 2 : 1}px;
    `;
    field.appendChild(star);
  }
}

// Nav scroll state
function initNav() {
  const nav = document.querySelector('nav');
  if (!nav) return;
  const onScroll = () => nav.classList.toggle('scrolled', window.scrollY > 60);
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
}

// Mark active nav link
function initActiveNav() {
  const path = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-links a').forEach(a => {
    const href = a.getAttribute('href');
    if (href === path || (path === '' && href === 'index.html')) {
      a.classList.add('active');
    }
  });
}

// Scroll reveal
function initReveal() {
  const targets = document.querySelectorAll('.tour-card, .site-item, .testimonial, .site-detail, .stat');
  if (!('IntersectionObserver' in window)) return;
  const io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        e.target.style.animation = 'none'; // Reset
        e.target.style.opacity = '0';
        e.target.style.transform = 'translateY(24px)';
        requestAnimationFrame(() => {
          e.target.style.transition = 'opacity 0.7s ease, transform 0.7s ease';
          e.target.style.opacity = '1';
          e.target.style.transform = 'translateY(0)';
        });
        io.unobserve(e.target);
      }
    });
  }, { threshold: 0.1 });
  targets.forEach(t => io.observe(t));
}

// Tour filter (tours.html)
function initFilter() {
  const btns = document.querySelectorAll('.filter-btn');
  const cards = document.querySelectorAll('.tour-card[data-category]');
  if (!btns.length) return;
  btns.forEach(btn => {
    btn.addEventListener('click', () => {
      btns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const cat = btn.dataset.filter;
      cards.forEach(card => {
        const show = cat === 'all' || card.dataset.category === cat;
        card.style.display = show ? 'block' : 'none';
      });
    });
  });
}

// Form feedback (contact.html)
function initContactForm() {
  const form = document.getElementById('enquiry-form');
  if (!form) return;
  form.addEventListener('submit', e => {
    e.preventDefault();
    const btn = form.querySelector('.btn-primary');
    btn.textContent = 'Message Received ✦';
    btn.style.opacity = '0.7';
    btn.disabled = true;
  });
}

document.addEventListener('DOMContentLoaded', () => {
  initStarfield();
  initNav();
  initActiveNav();
  initReveal();
  initFilter();
  initContactForm();
});
