// js/auth.service.js
import { auth } from "./firebase.js";
import {
  signInWithEmailAndPassword,
  sendPasswordResetEmail,
  signOut,
  onAuthStateChanged,
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js";

export const AuthService = {
  login:         (email, pass) => signInWithEmailAndPassword(auth, email, pass),
  resetPassword: (email)       => sendPasswordResetEmail(auth, email),
  logout:        ()            => signOut(auth),

  // Call on protected pages — redirects to login if not signed in
  requireAuth(onUser) {
    onAuthStateChanged(auth, (user) => {
      if (!user) { window.location.href = "../index.html"; return; }
      onUser(user);
    });
  },

  // Call on login page — skips to dashboard if already signed in
  redirectIfLoggedIn() {
    onAuthStateChanged(auth, (user) => {
      if (user) window.location.href = "./pages/dashboard.html";
    });
  },
};
