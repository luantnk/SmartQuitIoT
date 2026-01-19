/* global process */
if (typeof window !== "undefined") {
  // some libs (sockjs, crypto shims) expect global / process to exist
  if (typeof window.global === "undefined") window.global = window;
  if (typeof window.process === "undefined") {
    // minimal process shim so libraries that read process.env won't crash in browser
    window.process = { env: {} };
  }
}

import { ThemeProvider } from "@/context/theme-provider";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { Toaster } from "sonner";
import App from "./App.jsx";
import "./index.css";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <ThemeProvider defaultTheme="light" storageKey="vite-ui-theme">
      <App />
      <Toaster position="top-center" richColors />
    </ThemeProvider>
  </StrictMode>
);
