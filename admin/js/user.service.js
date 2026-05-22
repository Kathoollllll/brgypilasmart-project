// js/user.service.js
import { db } from "./firebase.js";
import {
  collection, query, orderBy, where,
  onSnapshot, doc, updateDoc,
  getDoc, setDoc, deleteDoc, getDocs, Timestamp,
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

  listenOne(uid, callback) {
    return onSnapshot(doc(db, COL, uid), (snap) => {
      if (snap.exists()) callback({ id: snap.id, ...snap.data() });
    });
  },

  setVerified: (uid, verified) =>
    updateDoc(doc(db, COL, uid), { isVerified: verified }),

  // Search all requests by this resident to find one with an idImageUrl
  async findResidentIdImage(uid) {
    const snap = await getDocs(
      query(collection(db, "requests"), where("userId", "==", uid))
    );
    for (const d of snap.docs) {
      if (d.data().idImageUrl) return d.data().idImageUrl;
    }
    return null;
  },

  saveIdImage: (uid, idImageUrl) =>
    updateDoc(doc(db, COL, uid), { idImageUrl }),

  async deleteUser(uid) {
    await deleteDoc(doc(db, COL, uid));
  },

  async archiveAndDelete(uid) {
    const snap = await getDoc(doc(db, COL, uid));
    if (snap.exists()) {
      await setDoc(doc(db, "deleted_users", uid), {
        ...snap.data(),
        deletedAt: Timestamp.now(),
      });
    }
    await deleteDoc(doc(db, COL, uid));
  },
};