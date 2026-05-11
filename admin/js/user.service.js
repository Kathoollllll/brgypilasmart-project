// js/user.service.js
import { db } from "./firebase.js";
import {
  collection, query, orderBy,
  onSnapshot, doc, updateDoc, getDoc,
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

const COL = "users";

export const UserService = {
  listenAll(callback) {
    const q = query(collection(db, COL), orderBy("fullName"));
    return onSnapshot(q, (snap) =>
      callback(snap.docs.map((d) => ({ id: d.id, ...d.data() })))
    );
  },

  async getOne(uid) {
    const snap = await getDoc(doc(db, COL, uid));
    return snap.exists() ? { id: snap.id, ...snap.data() } : null;
  },

  setVerified: (uid, verified) =>
    updateDoc(doc(db, COL, uid), { isVerified: verified }),
};
