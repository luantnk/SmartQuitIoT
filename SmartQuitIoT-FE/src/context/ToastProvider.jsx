// src/ui/ToastProvider.jsx
import React, { useCallback, useState } from "react";
import ToastContext from "./toastContext";
import { X } from "lucide-react";

/* Embedded CSS (keeps file self-contained) */
const css = `
.__toast_root { position: fixed; right: 20px; bottom: 20px; z-index: 9999; display:flex; flex-direction:column; gap:10px; align-items:flex-end; pointer-events:none; font-family: Inter, system-ui, sans-serif; }
.__toast { min-width:220px; max-width:380px; pointer-events:auto; border-radius:12px; padding:10px 12px; box-shadow:0 10px 30px rgba(2,112,89,0.08); color:white; font-weight:600; display:flex; align-items:center; cursor:pointer; animation:__toast_slide 260ms cubic-bezier(.2,.9,.2,1); overflow:hidden; }
.__toast_body { display:flex; gap:8px; align-items:center; width:100%; justify-content:space-between; }
.__toast_message { font-size:14px; line-height:1.1; color:white; flex:1; padding-right:8px; }
.__toast_close { background:transparent; border:none; padding:6px; border-radius:8px; display:inline-flex; align-items:center; justify-content:center; cursor:pointer; color:rgba(255,255,255,0.95); }
.__toast_iconSmall { width:14px; height:14px; }
.__toast_success { background: linear-gradient(90deg,#10b981,#059669); }
.__toast_error   { background: linear-gradient(90deg,#ef4444,#dc2626); }
.__toast_info    { background: linear-gradient(90deg,#0ea5e9,#0284c7); }
@keyframes __toast_slide { from { transform: translateY(8px); opacity:0 } to { transform: translateY(0); opacity:1 } }
@media (max-width:720px) { .__toast_root { left:12px; right:12px; bottom:12px; align-items:center } .__toast { max-width:92vw } }
`;

/* Internal Toast visual component (NOT exported) */
function Toast({ toast, onClose }) {
  const { type, message } = toast;
  const className = `__toast __toast_${type || "info"}`;
  return (
    <div className={className} onClick={onClose} role="status">
      <div className="__toast_body">
        <div className="__toast_message">{message}</div>
        <button
          className="__toast_close"
          aria-label="close"
          onClick={(e) => {
            e.stopPropagation();
            onClose();
          }}
          title="Đóng"
        >
          <X className="__toast_iconSmall" />
        </button>
      </div>
    </div>
  );
}

/* Exported Provider component (only exported component from file) */
export default function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);
  let idCounter = React.useRef(1);

  const push = useCallback((type, message, opts = {}) => {
    const id = idCounter.current++;
    const ttl = typeof opts?.duration === "number" ? opts.duration : 3800;
    const t = { id, type, message, ttl };
    setToasts((s) => [t, ...s]);

    if (ttl > 0) {
      setTimeout(() => {
        setToasts((s) => s.filter((x) => x.id !== id));
      }, ttl);
    }
    return id;
  }, []);

  const remove = useCallback((id) => {
    setToasts((s) => s.filter((x) => x.id !== id));
  }, []);

  const api = {
    success: (msg, opts) => push("success", msg, opts),
    error: (msg, opts) => push("error", msg, opts),
    info: (msg, opts) => push("info", msg, opts),
    remove,
  };

  return (
    <ToastContext.Provider value={api}>
      {children}
      <style>{css}</style>
      <div className="__toast_root" aria-live="polite">
        {toasts.map((t) => (
          <Toast key={t.id} toast={t} onClose={() => remove(t.id)} />
        ))}
      </div>
    </ToastContext.Provider>
  );
}
