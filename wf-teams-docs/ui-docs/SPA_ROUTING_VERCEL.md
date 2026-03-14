# 🚀 Why SPAs Need `vercel.json` — Knowledge Transfer

---

## 🧠 The Core Concept: How a React App Works

React apps are called **Single Page Applications (SPAs)**.  
This means there is only **ONE real HTML file** on the server: `index.html`.

When you navigate inside the app (e.g., from Home → Login),  
**no new file is fetched from the server.**  
React Router handles it entirely in the browser by swapping components.

```
User clicks "Login" link
        ↓
React Router reads the URL → /login
        ↓
Renders the <Login> component — no server involved
```

---

## ❌ The Problem: What Happens on Refresh

When you **refresh** or **directly visit** a URL like:
```
https://wf-nfw-ui.vercel.app/login
```

The browser sends a **real HTTP request** to Vercel's server:
```
Browser → "Hey Vercel, give me the file at /login"
Vercel  → "I don't have a file called /login... 404 Not Found ❌"
```

Only the root `/` works because that maps to `index.html`.  
Every other path like `/login`, `/dashboard`, `/driver/tasks` fails.

---

## ✅ The Fix: `vercel.json` Rewrites

We create a file called `vercel.json` in the project root.  
This is a **server configuration file** — not application code.

```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

### What this rule says:
> "For **any** incoming URL path (no matter what it is),  
> serve `index.html` instead of looking for that actual file."

```
Browser → "Give me /login"
Vercel  → serves index.html  ✅
React loads → reads URL → renders <Login> component ✅
```

---

## 🔄 Before vs After

| Scenario | Without `vercel.json` | With `vercel.json` |
|---|---|---|
| Visit `/` | ✅ Works | ✅ Works |
| Visit `/login` directly | ❌ 404 | ✅ Works |
| Refresh on `/dashboard` | ❌ 404 | ✅ Works |
| Share a deep link | ❌ Recipient gets 404 | ✅ Works |
| In-app navigation | ✅ Works (React handles it) | ✅ Works |

---

## 📁 Where Does `vercel.json` Live?

```
wf-nfw-ui/
├── vercel.json        ← here, at the project root
├── package.json
├── vite.config.js
└── src/
```

**It is NOT imported or referenced anywhere in code.**  
Vercel automatically reads it at deploy time, the same way:
- Apache reads `.htaccess`
- Nginx reads `nginx.conf`

It's a **server config**, not app code.

---

## 🔁 The Full Flow

```
Code pushed to Vercel
        ↓
Vercel builds the app → outputs: index.html + JS/CSS bundles
        ↓
Vercel reads vercel.json → configures its edge servers
        ↓
User visits any URL → Vercel serves index.html
        ↓
React loads → React Router reads the URL → correct page renders
```

---

## 💡 Key Takeaway

> Any React (or Vue/Angular) app deployed to a static host  
> **must** tell the server to serve `index.html` for all routes.  
> Without this, only the homepage survives a refresh.

This is not a bug in React — it's expected behaviour of SPAs.  
`vercel.json` is the one-line config that fixes it on Vercel.
