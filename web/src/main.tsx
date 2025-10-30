import { useEffect, useRef, useState } from "react";
import { createRoot } from "react-dom/client";
import { ClerkProvider, SignInButton, SignedIn, SignedOut, useAuth, UserButton } from "@clerk/clerk-react";

// Clerk publishable key will be injected by the server at runtime
// @ts-ignore - This is replaced by the server
const CLERK_PUBLISHABLE_KEY = window.CLERK_PUBLISHABLE_KEY || "pk_test_placeholder";

function CLI() {
  const { getToken } = useAuth();
  const [connected, setConnected] = useState(false);
  const [input, setInput] = useState("");
  const preRef = useRef<HTMLPreElement>(null);
  const wsRef = useRef<WebSocket | null>(null);

  useEffect(() => {
    let ws: WebSocket;

    const initWebSocket = async () => {
      // Get Clerk session token
      const token = await getToken();

      if (!token) {
        log("✖ No authentication token\n");
        return;
      }

      ws = new WebSocket(
        (location.protocol === "https:" ? "wss://" : "ws://") +
          location.host +
          "/ws",
      );
      wsRef.current = ws;

      ws.onopen = () => {
        setConnected(true);
        log("✔ Connected to Claude CLI\n");
        // Send token for verification
        ws.send(JSON.stringify({ token }));
      };

      ws.onclose = () => {
        setConnected(false);
        log("✖ Disconnected\n");
      };

      ws.onmessage = (e) => {
        const msg = JSON.parse(e.data);
        if (msg.type === "text") log(msg.chunk);
        if (msg.type === "done") log("\n");
        if (msg.type === "ready") log("Ready for your questions...\n\n");
        if (msg.type === "tokenVerified") {
          if (msg.success) {
            log("✔ Authentication verified\n\n");
          } else {
            log("✖ Authentication failed\n");
          }
        }
        if (msg.type === "error") {
          log(`✖ Error: ${msg.message}\n`);
        }
      };
    };

    initWebSocket();

    function log(s: string) {
      if (!preRef.current) return;
      preRef.current.textContent += s;
      preRef.current.scrollTop = preRef.current.scrollHeight;
    }

    return () => {
      if (ws) ws.close();
    };
  }, [getToken]);

  const send = () => {
    if (!input.trim() || !connected) return;

    // Echo the user's input
    if (!preRef.current) return;
    preRef.current.textContent += `> ${input}\n`;
    preRef.current.scrollTop = preRef.current.scrollHeight;

    wsRef.current?.send(JSON.stringify({ prompt: input }));
    setInput("");
  };

  return (
    <div
      style={{
        display: "grid",
        gridTemplateRows: "auto 1fr auto",
        height: "100vh",
        fontFamily:
          "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace",
        position: "fixed",
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
      }}
    >
      {/* Header with UserButton */}
      <div
        style={{
          padding: "8px 12px",
          borderBottom: "1px solid #222",
          background: "#111",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <span style={{ color: "#888", fontSize: "14px" }}>Claude CLI</span>
        <UserButton afterSignOutUrl="/" />
      </div>

      <pre
        ref={preRef}
        style={{
          margin: 0,
          padding: 12,
          overflow: "auto",
          whiteSpace: "pre-wrap",
          background: "#0b0b0b",
          color: "#e6e6e6",
          fontSize: "14px",
          lineHeight: "1.4",
        }}
      />
      <div
        style={{
          display: "flex",
          gap: 8,
          padding: 8,
          borderTop: "1px solid #222",
          background: "#111",
          paddingBottom: "max(8px, env(safe-area-inset-bottom))", // Account for home indicator on iOS
        }}
      >
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && !e.shiftKey) {
              e.preventDefault();
              send();
            }
          }}
          placeholder={connected ? "Ask Claude anything..." : "Connecting..."}
          style={{
            flex: 1,
            padding: 10,
            background: "#000",
            color: "#fff",
            border: "1px solid #333",
            fontSize: "16px", // Prevent zoom on iOS
            borderRadius: "4px",
          }}
          disabled={!connected}
        />
        <button
          onClick={send}
          style={{
            padding: "10px 14px",
            background: connected ? "#0066cc" : "#333",
            color: "#fff",
            border: "none",
            cursor: connected ? "pointer" : "default",
            borderRadius: "4px",
          }}
          disabled={!connected}
        >
          Send
        </button>
      </div>
    </div>
  );
}

function App() {
  return (
    <div
      style={{
        background: "#0b0b0b",
        minHeight: "100vh",
        color: "#e6e6e6",
      }}
    >
      <SignedOut>
        <div
          style={{
            maxWidth: 420,
            margin: "15vh auto",
            fontFamily: "system-ui",
            textAlign: "center",
          }}
        >
          <div style={{ marginBottom: 32 }}>
            <h1 style={{ fontSize: 28, marginBottom: 8, color: "#fff" }}>
              Claude CLI
            </h1>
            <p style={{ color: "#888", margin: 0 }}>
              Containerized Claude Code with browser interface
            </p>
          </div>

          <SignInButton mode="modal">
            <button
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: 12,
                width: "100%",
                padding: "16px 24px",
                background: "#6C47FF",
                color: "#fff",
                border: "none",
                borderRadius: 6,
                fontSize: 16,
                fontWeight: 500,
                cursor: "pointer",
                transition: "background-color 0.2s",
              }}
              onMouseOver={(e) => (e.currentTarget.style.background = "#5639CC")}
              onMouseOut={(e) => (e.currentTarget.style.background = "#6C47FF")}
            >
              Sign in with Clerk
            </button>
          </SignInButton>

          <p
            style={{
              color: "#666",
              marginTop: 24,
              fontSize: 14,
              lineHeight: 1.5,
            }}
          >
            Sign in to access the Claude CLI interface.
          </p>
        </div>
      </SignedOut>

      <SignedIn>
        <CLI />
      </SignedIn>
    </div>
  );
}

createRoot(document.getElementById("root")!).render(
  <ClerkProvider publishableKey={CLERK_PUBLISHABLE_KEY}>
    <App />
  </ClerkProvider>
);
