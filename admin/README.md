# BrgyPilaSmart — Admin Panel

## Project Structure

```
admin/
├── index.html                ← Page 1: Admin Login
├── css/
│   └── styles.css            ← Global styles (animations, scrollbar, fonts)
├── js/
│   ├── firebase.js           ← Firebase init (put your config here)
│   ├── auth.service.js       ← Login, logout, auth guard
│   ├── request.service.js    ← Firestore CRUD for requests
│   ├── user.service.js       ← Firestore CRUD for residents
│   └── ui.helpers.js         ← Shared layout renderer, formatters, badges
└── pages/
    ├── dashboard.html         ← Page 2: Dashboard (live stats + recent)
    ├── requests.html          ← Page 3: Request Management (table + filters)
    ├── request-detail.html    ← Page 4: Request Detail (timeline + status update)
    ├── residents.html         ← Page 5: Residents (verify/revoke + modal)
    └── archive.html           ← Page 6: Digital Archive (completed requests)
```

---

## Run the Admin Panel

1. Install the **Live Server** extension in VS Code
2. Right-click `index.html` → **Open with Live Server**

---

## Live Sync with the Flutter Mobile App

| Mobile App Action              | Admin Panel Shows                          |
|--------------------------------|--------------------------------------------|
| Resident registers             | → Appears in **Residents** table instantly |
| Resident submits a request     | → Appears in **Dashboard** + **Requests** |
| Admin updates status           | → Resident sees it in their **Tracker**    |
| Request reaches "Ready"        | → Card appears in **Digital Archive**      |

No page refresh needed — all data is **real-time via Firestore listeners**.

---

## Pages Summary

| Page                  | File                      | Description                                     |
|-----------------------|---------------------------|-------------------------------------------------|
| Admin Login           | `index.html`              | Branded login with Firebase Auth                |
| Dashboard             | `pages/dashboard.html`    | Live stat cards + recent requests table         |
| Request Management    | `pages/requests.html`     | Full table, search, filter, inline status update |
| Request Detail        | `pages/request-detail.html`| Full details, ID image, timeline, status update |
| Residents             | `pages/residents.html`    | All registered residents, verify/revoke + modal |
| Digital Archive       | `pages/archive.html`      | Card grid of all completed (Ready) requests     |
