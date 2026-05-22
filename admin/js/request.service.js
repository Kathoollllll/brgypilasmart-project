// js/request.service.js
import { db } from "./firebase.js";
import {
  collection, query, orderBy, where, limit,
  onSnapshot, doc, updateDoc, arrayUnion, Timestamp,
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

const COL = "requests";

export const RequestService = {

  // All requests ordered by newest first (live)
  listenAll(callback) {
    const q = query(collection(db, COL), orderBy("createdAt", "desc"));
    return onSnapshot(q, (snap) =>
      callback(snap.docs.map((d) => ({ id: d.id, ...d.data() })))
    );
  },

  // Single request live (for detail page)
  listenOne(id, callback) {
    return onSnapshot(doc(db, COL, id), (d) => {
      if (d.exists()) callback({ id: d.id, ...d.data() });
    });
  },

  // Only Ready and document-closed requests for archive (live)
  listenReady(callback) {
    // Filter in JS to avoid needing a Firestore composite index
    const q = query(collection(db, COL), orderBy("createdAt", "desc"));
    return onSnapshot(q, (snap) => {
      const docs = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
      callback(docs.filter((d) => ["Ready", "PickedUp", "Canceled"].includes(d.status)));
    });
  },

  // Live dashboard counts
  listenStats(callback) {
    return onSnapshot(collection(db, COL), (snap) => {
      const docs = snap.docs.map((d) => d.data());
      callback({
        total:   docs.length,
        //pending: docs.filter((d) => d.status === "Requested").length,
        //closed:  docs.filter((d) => d.status === "Ready").length,
        pending: docs.filter((d) => d.status === "Requested").length,
        closed:  docs.filter((d) => ["Ready", "PickedUp"].includes(d.status)).length,
      });
    });
  },

  // Update status + append timeline entry
  async updateStatus(id, newStatus, note = "") {
    const autoNote = {
      Verified: "Request verified and approved by Brgy. Secretary.",
      Printed:  "Document sent to printing queue.",
      Ready:    "Document is ready for pickup at the barangay hall.",
      PickedUp: "Resident has collected the document. Request closed.",
      Rejected: "Request has been rejected by staff.",
      Canceled: "You canceled the request.",
    }[newStatus] || "Status updated by admin.";

    await updateDoc(doc(db, COL, id), {
      status:   newStatus,
      timeline: arrayUnion({
        status:    newStatus,
        timestamp: Timestamp.now(),
        note:      note || autoNote,
      }),
    });
  },
};
