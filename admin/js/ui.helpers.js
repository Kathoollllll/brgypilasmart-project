// js/ui.helpers.js

export const STATUSES = ["Requested", "Verified", "Printed", "Ready", "Rejected"];

export const DOC_TYPES = [
  "Barangay Clearance",
  "Certificate of Residency",
  "Barangay ID",
  "Certificate of Indigency",
];

// ─── Status badge ──────────────────────────────────────────────────────────────
const BADGE_MAP = {
  Requested: { bg: "#F0F0F0", color: "#555555", label: "PENDING"    },
  Verified:  { bg: "#E8F0FE", color: "#1A56DB", label: "VERIFIED"   },
  Printed:   { bg: "#EDE7F6", color: "#6D28D9", label: "PRINTED"    },
  Ready:     { bg: "#FEF3C7", color: "#D97706", label: "READY"      },
  PickedUp:  { bg: "#E6F4EA", color: "#16A34A", label: "PICKED UP"  },
  Rejected:  { bg: "#FEE2E2", color: "#DC2626", label: "REJECTED"   },
};

export function statusBadge(status) {
  const b = BADGE_MAP[status] ?? BADGE_MAP["Requested"];
  return `<span style="background:${b.bg};color:${b.color}" class="inline-block px-2.5 py-[3px] rounded text-[10px] font-bold tracking-widest whitespace-nowrap">${b.label}</span>`;
}

// ─── Date helpers ──────────────────────────────────────────────────────────────
export function fmtDate(ts) {
  if (!ts) return "—";
  const d = ts.toDate ? ts.toDate() : new Date(ts);
  return d.toLocaleDateString("en-PH", { month: "short", day: "numeric", year: "numeric" });
}
export function fmtDateTime(ts) {
  if (!ts) return "—";
  const d = ts.toDate ? ts.toDate() : new Date(ts);
  return d.toLocaleString("en-PH", { month: "long", day: "numeric", hour: "numeric", minute: "2-digit" });
}
export function fmtFullDate(ts) {
  if (!ts) return "—";
  const d = ts.toDate ? ts.toDate() : new Date(ts);
  return d.toLocaleDateString("en-PH", { month: "long", day: "numeric", year: "numeric" });
}

// ─── Avatar ────────────────────────────────────────────────────────────────────
const AV_COLORS = ["#DBEAFE","#EDE9FE","#FCE7F3","#D1FAE5","#FEF3C7","#FFE4E6","#E0F2FE","#F0FDF4"];
export const avatarBg       = (n="") => AV_COLORS[(n.charCodeAt(0)||0) % AV_COLORS.length];
export const avatarInitials = (n="") => {
  const p = n.trim().split(/\s+/);
  return p.length >= 2 ? (p[0][0]+p[p.length-1][0]).toUpperCase() : (n[0]??"?").toUpperCase();
};

// ─── initLayout ────────────────────────────────────────────────────────────────
// Injects sidebar + topbar, applies offsets, wires burger toggle
export function initLayout(activeNav) {
  const ROOT = "../";

  const NAV = [
    { id:"dashboard", label:"Dashboard",          href:`${ROOT}pages/dashboard.html`,
      svg:`<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/>`, fill:true },
    { id:"requests",  label:"Request Management", href:`${ROOT}pages/requests.html`,
      svg:`<path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>`, fill:false },
    { id:"archive",   label:"Digital Archive",    href:`${ROOT}pages/archive.html`,
      svg:`<path stroke-linecap="round" stroke-linejoin="round" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4"/>`, fill:false },
    { id:"settings",  label:"Settings",           href:`${ROOT}pages/settings.html`,
      svg:`<path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065zM15 12a3 3 0 11-6 0 3 3 0 016 0z"/>`, fill:false },
  ];

  const navHtml = NAV.map(({id,label,href,svg,fill})=>{
    const act = activeNav===id;
    const svgAttr = fill ? `fill="currentColor" viewBox="0 0 24 24"` : `fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"`;
    return `<a href="${href}" class="group flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13px] font-medium transition-all duration-200 overflow-hidden ${act?"bg-[#EBF3FF] text-[#1A56DB]":"text-gray-500 hover:bg-gray-100 hover:text-gray-800"}">
      <svg class="w-[18px] h-[18px] shrink-0 ${act?"text-[#1A56DB]":"text-gray-400 group-hover:text-gray-600"}" ${svgAttr}>${svg}</svg>
      <span class="nav-label whitespace-nowrap">${label}</span>
    </a>`;
  }).join("");

  // Sidebar HTML
  const sidebarHtml = `
  <aside id="sidebar" class="fixed inset-y-0 left-0 z-40 flex flex-col bg-white border-r border-gray-200 transition-all duration-300 overflow-hidden" style="width:232px">
    <!-- Brand + burger -->
    <div class="flex items-center justify-between px-4 pt-6 pb-5 shrink-0 min-h-[72px]">
      <div id="brand-block" class="overflow-hidden transition-all duration-300" style="opacity:1">
        <p class="text-[#1A56DB] font-black text-[13px] tracking-wide leading-tight whitespace-nowrap">BRGYPILASMART</p>
        <p class="text-gray-400 text-[10px] font-semibold tracking-widest mt-0.5 whitespace-nowrap">STAFF PORTAL</p>
      </div>
      <button id="burger-btn" class="shrink-0 ml-1 p-1.5 rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors" title="Toggle sidebar">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>
        </svg>
      </button>
    </div>
    <!-- Nav -->
    <nav class="flex-1 px-2 space-y-0.5 overflow-y-auto overflow-x-hidden">${navHtml}</nav>
    <!-- Logout -->
    <div class="px-2 pb-6 pt-3 border-t border-gray-100 shrink-0">
      <button id="logout-btn" class="group flex items-center gap-3 px-3 py-2.5 rounded-xl w-full text-[13px] font-medium text-red-500 hover:bg-red-50 transition-colors overflow-hidden">
        <svg class="w-[18px] h-[18px] shrink-0" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
        </svg>
        <span class="nav-label whitespace-nowrap">Logout</span>
      </button>
    </div>
  </aside>
  <div id="sb-overlay" class="fixed inset-0 bg-black/20 z-30 hidden lg:hidden"></div>`;

  // Topbar HTML
  const topbarHtml = `
  <header id="topbar" class="fixed top-0 right-0 z-20 h-14 bg-white border-b border-gray-200 flex items-center px-6 gap-4 transition-all duration-300" style="left:232px">
    <div class="relative flex-1 max-w-xs">
      <svg class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
      <input type="text" placeholder="Search requests, residents..." class="w-full pl-9 pr-4 py-1.5 bg-gray-50 border border-gray-200 rounded-lg text-sm text-gray-700 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#1A56DB]/20 focus:border-[#1A56DB] transition"/>
    </div>
    <div class="flex items-center gap-1.5 ml-auto">
      <button class="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition relative">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>
        <span id="notif-dot" class="hidden absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full ring-2 ring-white"></span>
      </button>
      <button class="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
      </button>
    </div>
  </header>`;

  document.body.insertAdjacentHTML("afterbegin", topbarHtml);
  document.body.insertAdjacentHTML("afterbegin", sidebarHtml);

  // Offset page content
  const content = document.getElementById("page-content");
  content.style.marginLeft = "232px";
  content.style.paddingTop = "56px";

  // ── Burger toggle ──────────────────────────────────────────────────────────
  const sidebar  = document.getElementById("sidebar");
  const topbar   = document.getElementById("topbar");
  const labels   = document.querySelectorAll(".nav-label");
  const brand    = document.getElementById("brand-block");
  const overlay  = document.getElementById("sb-overlay");
  let   collapsed = false;
  const W_OPEN   = "232px";
  const W_CLOSED = "64px";

  function setCollapsed(val) {
    collapsed = val;
    if (collapsed) {
      sidebar.style.width  = W_CLOSED;
      topbar.style.left    = W_CLOSED;
      content.style.marginLeft = W_CLOSED;
      brand.style.opacity  = "0";
      brand.style.width    = "0";
      labels.forEach(l => { l.style.opacity="0"; l.style.width="0"; l.style.overflow="hidden"; });
    } else {
      sidebar.style.width  = W_OPEN;
      topbar.style.left    = W_OPEN;
      content.style.marginLeft = W_OPEN;
      brand.style.opacity  = "1";
      brand.style.width    = "";
      labels.forEach(l => { l.style.opacity="1"; l.style.width=""; l.style.overflow=""; });
    }
  }

  document.getElementById("burger-btn").addEventListener("click", () => setCollapsed(!collapsed));
  //overlay.addEventListener("click", () => setCollapsed(false));
}

// ─── Wire logout ──────────────────────────────────────────────────────────────
export function wireLogout(AuthService) {
  document.getElementById("logout-btn")?.addEventListener("click", async () => {
    await AuthService.logout();
    window.location.href = "../index.html";
  });
}
