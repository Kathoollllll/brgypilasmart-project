# BrgyPilaSmart — Admin Panel

## 📁 Project Structure

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

## 🔥 STEP 1 — Add Your Firebase Config

Open `js/firebase.js` and replace ALL placeholder values:

```js
const firebaseConfig = {
  apiKey:            "YOUR_API_KEY",
  authDomain:        "YOUR_PROJECT.firebaseapp.com",
  projectId:         "YOUR_PROJECT_ID",
  storageBucket:     "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId:             "YOUR_APP_ID",
};
```

**Where to find it:**
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Select your project → ⚙️ **Project Settings**
3. Scroll to **Your apps** → pick your Web app (or create one — click `</>`)
4. Copy the `firebaseConfig` object

---

## 🔒 STEP 2 — Create an Admin Account

1. Firebase Console → **Authentication** → **Users** tab
2. Click **Add user**
3. Enter your admin email + password
4. Use those to log in at `index.html`

---

## 📋 STEP 3 — Firestore Security Rules

Firebase Console → **Firestore Database** → **Rules** tab → paste:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{uid} {
      // Resident can write their own profile; admin can read all
      allow read:  if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == uid;
    }

    match /requests/{id} {
      // Residents create their own; admin reads/updates all
      allow read:   if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null;
      allow delete: if false;
    }
  }
}
```

Click **Publish**.

---

## 🎨 STEP 4 — Tailwind CSS

**No installation needed.** Every HTML file loads Tailwind from CDN:
```html
<script src="https://cdn.tailwindcss.com"></script>
```

**For production (optional — faster load):**
```bash
npm install -D tailwindcss
npx tailwindcss init
# Add content paths to tailwind.config.js, then build
npx tailwindcss -i ./css/styles.css -o ./css/output.css --watch
```

---

## 🌐 STEP 5 — Run the Admin Panel

The JS files use ES Modules (`import`/`export`), so you **must serve via a local server** — just opening the HTML file won't work.

**Option A — VS Code Live Server (recommended)**
1. Install the **Live Server** extension in VS Code
2. Right-click `index.html` → **Open with Live Server**

**Option B — Node (if installed)**
```bash
npx serve .
# Open http://localhost:3000
```

**Option C — Python**
```bash
python3 -m http.server 8080
# Open http://localhost:8080
```

---

## 🔄 Live Sync with the Flutter Mobile App

Since both apps share the **same Firebase project**, everything syncs automatically:

| Mobile App Action              | Admin Panel Shows                          |
|--------------------------------|--------------------------------------------|
| Resident registers             | → Appears in **Residents** table instantly |
| Resident submits a request     | → Appears in **Dashboard** + **Requests** |
| Admin updates status           | → Resident sees it in their **Tracker**    |
| Request reaches "Ready"        | → Card appears in **Digital Archive**      |

No page refresh needed — all data is **real-time via Firestore listeners**.

---

## 📄 Pages Summary

| Page                  | File                      | Description                                     |
|-----------------------|---------------------------|-------------------------------------------------|
| Admin Login           | `index.html`              | Branded login with Firebase Auth                |
| Dashboard             | `pages/dashboard.html`    | Live stat cards + recent requests table         |
| Request Management    | `pages/requests.html`     | Full table, search, filter, inline status update |
| Request Detail        | `pages/request-detail.html` | Full details, ID image, timeline, status update |
| Residents             | `pages/residents.html`    | All registered residents, verify/revoke + modal |
| Digital Archive       | `pages/archive.html`      | Card grid of all completed (Ready) requests     |
