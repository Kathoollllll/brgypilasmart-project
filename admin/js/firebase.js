import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js";
import { getAuth }       from "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js";
import { getFirestore }  from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";
import { getStorage }    from "https://www.gstatic.com/firebasejs/10.12.0/firebase-storage.js";

const firebaseConfig = {
  apiKey: "AIzaSyDs15rQLdu0jNqgh8KirPWz4j-n6M2IJ5Y",
  authDomain: "brgypilasmart.firebaseapp.com",
  projectId: "brgypilasmart",
  storageBucket: "brgypilasmart.firebasestorage.app",
  messagingSenderId: "631020266512",
  appId: "1:631020266512:web:3356a42712397e555c9695"
};

const app = initializeApp(firebaseConfig);

export const auth    = getAuth(app);
export const db      = getFirestore(app);
export const storage = getStorage(app);
