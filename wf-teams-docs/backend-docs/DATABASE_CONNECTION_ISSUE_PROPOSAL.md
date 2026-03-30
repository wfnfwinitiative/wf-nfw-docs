# Database Connection Issue — Root Cause Analysis & Resolution Proposal

**Project:** No Food Waste — WF Platform  
**Date:** March 30, 2026  
**Severity:** Critical (Login / All API calls affected)  
**Environment:** Vercel (Free) + Supabase PostgreSQL (Free)

---

## Table of Contents

1. [The Problem — Plain English](#1-the-problem--plain-english)
2. [Why This Happens — Technical Root Cause](#2-why-this-happens--technical-root-cause)
3. [Will Upgrading to a Paid Plan Fix It?](#3-will-upgrading-to-a-paid-plan-fix-it)
4. [How We Can Solve This on the Free Plan](#4-how-we-can-solve-this-on-the-free-plan)
5. [Step-by-Step Resolution Guide](#5-step-by-step-resolution-guide)
6. [Code Changes Required](#6-code-changes-required)
7. [Expected Outcome After Fix](#7-expected-outcome-after-fix)

---

## 1. The Problem — Plain English

When a user tries to **log in** to the platform, they receive an error. The full error message is:

```
MaxClientsInSessionMode: max clients reached — in Session mode, 
max clients are limited to pool_size
```

**What this means in simple terms:**

Imagine a popular coffee shop (the database) that has **only 60 seats** available. Every person who enters the shop takes a seat and **never gets up**, even after they finish their coffee. Very quickly, the shop is full and new customers trying to walk in are refused entry — no matter how urgently they need service.

In our case:
- The **coffee shop** = our Supabase PostgreSQL database
- The **seats** = database connections (Supabase Free Tier allows ~60)
- The **customers who never leave** = Vercel server instances holding open connections indefinitely
- The **refused customers** = our users getting the error at login

---

## 2. Why This Happens — Technical Root Cause

There are three factors that combine to create this problem:

### Factor 1 — Vercel is Serverless (Stateless by design)

Vercel does not run one permanent server. Instead, every time the API receives a request, Vercel spins up a **fresh, disposable function instance**. When many users make requests at the same time, many instances spin up simultaneously — each one completely independent of the others.

### Factor 2 — Each Instance Creates Its Own Connection Pool

Our current backend code (`app/db/session.py`) is configured with:

```python
engine = create_async_engine(
    DATABASE_URL,
    connect_args={"ssl": ssl_context},
    pool_size=10,       # Hold 10 connections open at all times
    max_overflow=20,    # Allow up to 20 more if needed
)
```

This tells each function instance: *"Open up to **30 connections** to the database and hold them open, ready for reuse."*

This works perfectly on a traditional server — but on Vercel, those connections are **never reused** across invocations because each function instance is discarded after the request.

### Factor 3 — Supabase Free Tier Has a Hard Connection Limit

Supabase Free Tier limits **direct database connections to ~60**. This is a fixed limit that cannot be negotiated.

### The Collision

```
5 Vercel instances × 30 connections each = 150 connections attempted
Supabase Free Tier limit               = 60 connections available

RESULT: 90 connections refused → MaxClientsInSessionMode error
```

Even under moderate traffic, this ceiling is hit immediately.

---

## 3. Will Upgrading to a Paid Plan Fix It?

### Upgrading Vercel (Free → Pro) — ❌ Will NOT fix it

| What Vercel Pro adds | Does it help? |
|---|---|
| More compute and faster builds | No |
| No function timeout limits | No |
| More bandwidth | No |
| More database connections | **Not applicable — Vercel doesn't manage the DB** |

Vercel Pro does not touch the database at all. The connection limit lives entirely on Supabase's side.

### Upgrading Supabase (Free → Pro at $25/month) — ⚠️ Partially helps, but not the right fix

Supabase Pro increases the direct connection limit significantly. However:

- The **root architecture problem remains** — connections are still held open and wasted
- Under higher traffic, the same error will return — just at a higher threshold
- It is an **expensive band-aid** over a problem that can be solved for free by fixing the architecture

### Conclusion

> Upgrading fixes a symptom, not the cause. The correct fix is architectural and costs **$0**.

---

## 4. How We Can Solve This on the Free Plan

The solution uses a feature that is **already included in Supabase for free** — a built-in connection manager called **PgBouncer**, combined with a small code change.

### What is PgBouncer? (Simple explanation)

PgBouncer acts like a **hotel concierge**. Instead of every guest (Vercel instance) going directly to the hotel safe (database) and holding a key indefinitely, the concierge manages a small set of master keys. A guest borrows a key, opens the safe, and **immediately returns the key** — so the next guest can use it right away.

This means **hundreds of application requests** can share just **a handful of actual database connections**.

### The Two-Part Fix

| Part | What changes | Where |
|---|---|---|
| **1 — Supabase** | Switch PgBouncer from Session mode → Transaction mode | Supabase Dashboard |
| **2 — Vercel** | Update `DATABASE_URL` to use the pooler URL (port 6543) | Vercel Dashboard |
| **3 — Code** | Stop SQLAlchemy from holding connections open (NullPool) | `app/db/session.py` |

---

## 5. Step-by-Step Resolution Guide

### Step 1 — Change Pool Mode in Supabase Dashboard

1. Log in to [supabase.com](https://supabase.com)
2. Open your project
3. Go to **Settings** (left sidebar) → **Database**
4. Scroll down to the **Connection Pooling** section
5. Find the **Pool Mode** dropdown — change it from `session` → **`transaction`**
6. Click **Save**

> **Why Transaction mode?**  
> In Session mode, a connection is held for the entire duration a client is connected — even when idle. In Transaction mode, a connection is only held during an active database transaction (milliseconds), then immediately returned to the pool. This is perfect for serverless.

---

### Step 2 — Get the New Pooler Connection URL from Supabase

While still in **Settings → Database → Connection Pooling**, locate the **Connection String** section.

You will see a connection string that looks like this:

```
postgresql://postgres.xxxx:PASSWORD@aws-0-ap-south-1.pooler.supabase.com:6543/postgres
```

Key things to note:
- The **host** ends in `.pooler.supabase.com` (not the regular host)
- The **port** is `6543` (not the default `5432`)
- Copy this string — you will need it in the next step

> **Important:** Replace `[YOUR-PASSWORD]` in the string with your actual database password.

---

### Step 3 — Update the Environment Variable in Vercel

1. Log in to [vercel.com](https://vercel.com)
2. Open your backend project (`wf-nfw-services`)
3. Go to **Settings** → **Environment Variables**
4. Find the variable named `DATABASE_URL`
5. Click **Edit**
6. Replace the current value with the new pooler URL from Step 2
7. **Append** `?pgbouncer=true` to the end of the URL

Final value should look like:
```
postgresql+asyncpg://postgres.xxxx:PASSWORD@aws-0-ap-south-1.pooler.supabase.com:6543/postgres?pgbouncer=true
```

> **Why `?pgbouncer=true`?**  
> This tells our database driver (asyncpg) that it is communicating through PgBouncer and should disable "prepared statements" — a PostgreSQL feature that is session-scoped and incompatible with Transaction mode.

8. Click **Save**

---

### Step 4 — Apply the Code Change and Redeploy

The code change (detailed in the next section) must be committed and pushed to trigger a Vercel redeployment.

```bash
git add wf-nfw-services/app/db/session.py
git commit -m "fix: use NullPool for serverless Vercel deployment to prevent MaxClientsInSessionMode"
git push
```

Vercel will automatically detect the push and redeploy.

---

### Step 5 — Verify the Fix

After redeployment:
1. Open the application
2. Attempt to log in
3. Monitor the Vercel function logs (Vercel Dashboard → Deployments → Functions) for any errors
4. Monitor Supabase (Dashboard → Database → Connections) to confirm connection count stays low

---

## 6. Code Changes Required

Only **one file** needs to be changed: `wf-nfw-services/app/db/session.py`

### Before (Broken for Serverless)

```python
import os
import ssl
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from app.core.config import settings

DATABASE_URL = settings.DATABASE_URL

class Base(DeclarativeBase):
    pass

ssl_context = ssl.create_default_context()
ssl_context.check_hostname = False
ssl_context.verify_mode = ssl.CERT_NONE

# ❌ PROBLEM: pool_size=10 + max_overflow=20 = 30 connections held per
#    Vercel instance. With multiple concurrent instances, this instantly
#    exhausts the Supabase free tier connection limit.
engine = create_async_engine(
    DATABASE_URL,
    connect_args={"ssl": ssl_context},
    pool_size=10,
    max_overflow=20,
)

SessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_db():
    async with SessionLocal() as session:
        yield session
```

### After (Fixed for Serverless)

```python
import os
import ssl
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from sqlalchemy.pool import NullPool
from app.core.config import settings

DATABASE_URL = settings.DATABASE_URL

class Base(DeclarativeBase):
    pass

ssl_context = ssl.create_default_context()
ssl_context.check_hostname = False
ssl_context.verify_mode = ssl.CERT_NONE

# ✅ FIX: NullPool disables SQLAlchemy's in-process connection pool entirely.
#    Each request opens one connection, runs its query, and immediately closes it.
#    PgBouncer (Transaction mode) on the Supabase side efficiently manages the
#    actual physical connections.
#    prepared_statement_cache_size=0 disables prepared statements, which are
#    incompatible with PgBouncer in Transaction mode.
engine = create_async_engine(
    DATABASE_URL,
    connect_args={"ssl": ssl_context, "prepared_statement_cache_size": 0},
    poolclass=NullPool,
)

SessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_db():
    async with SessionLocal() as session:
        yield session
```

### What changed and why

| Change | Reason |
|---|---|
| `from sqlalchemy.pool import NullPool` | Import the NullPool class |
| Removed `pool_size=10, max_overflow=20` | No longer keeping connections alive between requests |
| Added `poolclass=NullPool` | Tells SQLAlchemy not to pool connections — open, use, close |
| Added `"prepared_statement_cache_size": 0` | Disables prepared statements which are incompatible with PgBouncer Transaction mode |

---

## 7. Expected Outcome After Fix

### Connection Behaviour After Fix

```
Before fix:
  5 Vercel instances × 30 held connections = 150 connections (60 limit exceeded ❌)

After fix:
  100 concurrent users → ~5-10 fleeting connections used momentarily → released
  Peak connections at any instant ≈ 5-10 (well within 60 limit ✅)
```

### Benefits

- Login and all API calls work reliably
- No cost increase — entirely within Supabase and Vercel free tiers
- Scales much better — can handle hundreds of concurrent users without hitting limits
- Correct architecture for serverless deployments (industry best practice)

### Risk

- **Zero risk** to existing functionality — NullPool is the standard recommended approach for any serverless + PostgreSQL + SQLAlchemy stack
- The change is backward-compatible and reversible

---

## Checklist for Deployment

- [ ] Switch Supabase Pool Mode to **Transaction** (Dashboard)
- [ ] Copy new pooler URL from Supabase (port **6543**)
- [ ] Update `DATABASE_URL` in Vercel environment variables with pooler URL + `?pgbouncer=true`
- [ ] Apply code change to `app/db/session.py` (NullPool + disable prepared statements)
- [ ] Commit and push to trigger Vercel redeployment
- [ ] Verify login works after redeployment
- [ ] Monitor Supabase connection count stays within limits

---

*Prepared by the Development Team — No Food Waste WF Platform*
