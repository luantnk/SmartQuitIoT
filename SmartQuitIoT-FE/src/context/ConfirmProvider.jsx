import React, { useCallback, useRef, useState } from "react";
import ConfirmContext from "./confirmContext";

/* Embedded CSS so no extra files */
const css = `
.__confirm_overlay {
  position: fixed; inset: 0; display:flex; align-items:center; justify-content:center;
  background: rgba(2,6,23,0.45); z-index: 10020;
}
.__confirm_box {
  width: 420px; max-width: 92vw; background: white; border-radius: 12px;
  padding: 18px; box-shadow: 0 12px 40px rgba(2,6,23,0.2); font-family: Inter, system-ui, sans-serif;
}
.__confirm_title { font-size:16px; font-weight:700; margin:0 0 6px 0; color:#0f172a; }
.__confirm_msg { font-size:14px; color:#374151; margin-bottom: 16px; }
.__confirm_actions { display:flex; gap:8px; justify-content:flex-end; }
.__confirm_btn { padding:8px 12px; border-radius:10px; border:none; cursor:pointer; font-weight:700; transition: all 0.2s; }
.__confirm_btn.secondary { background:#f3f4f6; color:#0f172a; }
.__confirm_btn.secondary:hover { background:#e5e7eb; }
.__confirm_btn.primary { background: linear-gradient(90deg,#00d09e,#00b88a); color:white; box-shadow:0 8px 20px rgba(2,112,89,0.08); }
.__confirm_btn.primary:hover { box-shadow:0 10px 25px rgba(2,112,89,0.12); transform: translateY(-1px); }
.__confirm_btn.destructive { background: linear-gradient(90deg,#ef4444,#dc2626); color:white; box-shadow:0 8px 20px rgba(239,68,68,0.08); }
.__confirm_btn.destructive:hover { box-shadow:0 10px 25px rgba(239,68,68,0.15); transform: translateY(-1px); }
`;

/**
 * ConfirmProvider exposes a `confirm({title, message, okText, cancelText, destructive})`
 * that returns Promise<boolean>
 */
export default function ConfirmProvider({ children }) {
  const [modal, setModal] = useState(null);
  const resolverRef = useRef(null);

  const confirm = useCallback(
    ({
      title = "Xác nhận",
      message = "",
      okText = "OK",
      cancelText = "Hủy",
      destructive = false,
    } = {}) => {
      return new Promise((resolve) => {
        resolverRef.current = resolve;
        setModal({ title, message, okText, cancelText, destructive });
      });
    },
    []
  );

  const handleClose = (val) => {
    const r = resolverRef.current;
    if (r) r(Boolean(val));
    resolverRef.current = null;
    setModal(null);
  };

  return (
    <ConfirmContext.Provider value={confirm}>
      {children}
      <style>{css}</style>
      {modal && (
        <div className="__confirm_overlay" role="dialog" aria-modal="true">
          <div
            className="__confirm_box"
            onKeyDown={(e) => {
              if (e.key === "Escape") handleClose(false);
            }}
          >
            <h3 className="__confirm_title">{modal.title}</h3>
            <div className="__confirm_msg">{modal.message}</div>
            <div className="__confirm_actions">
              <button
                className="__confirm_btn secondary"
                onClick={() => handleClose(false)}
              >
                {modal.cancelText}
              </button>
              <button
                className={`__confirm_btn ${modal.destructive ? 'destructive' : 'primary'}`}
                onClick={() => handleClose(true)}
                autoFocus
              >
                {modal.okText}
              </button>
            </div>
          </div>
        </div>
      )}
    </ConfirmContext.Provider>
  );
}
