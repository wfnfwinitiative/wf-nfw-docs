# Google Drive Integration Setup Guide
## NoFoodWaste — Backend Team Handover Document

---

## Overview

This document explains how to configure Google Drive so that drivers can upload food collection and delivery photos from the NoFoodWaste app. Photos are organized automatically by driver name, date, and opportunity ID.

**Important:** This setup only needs to be done **once** by an admin. All drivers can then upload photos without any Google account interaction — they just click upload and it works.

---

## How It Works (Big Picture)

```
Driver uploads photo in app
        ↓
NoFoodWaste backend server receives the photo
        ↓
Server uses a pre-configured Google account (admin's) to upload to Google Drive
        ↓
Photo appears in the shared Google Drive folder, organized by driver/date
```

The key insight: **drivers never interact with Google directly**. The admin's Google account is authorized once, and all uploads go through that account permanently.

---

## Step 1 — Create a Google Cloud Project

1. Go to [https://console.cloud.google.com](https://console.cloud.google.com)
2. Sign in with the **organization's official Gmail account** (not a personal account)
3. At the top of the page, click the project dropdown → click **New Project**
4. Enter:
   - **Project name:** `NoFoodWaste`
   - **Organization:** Select your organization if available
5. Click **Create**
6. Wait a few seconds, then select the new project from the dropdown

---

## Step 2 — Enable Google Drive API

1. In the left sidebar, go to **APIs & Services → Library**
2. Search for **Google Drive API**
3. Click on it → click **Enable**

<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/b4b35046-b9c5-49cd-8838-9e6e9adaba45" />


This gives your project permission to use Google Drive functionality.

---

## Step 3 — Configure OAuth Consent Screen

This is the screen users see when granting permission. For production (real users), it must be properly configured.

1. Go to **APIs & Services → OAuth consent screen**
2. Select **External** → click **Create**
3. Fill in the required fields:
   - **App name:** `No Food Waste`
   - **User support email:** Your organization's support email
   - **Developer contact information:** Your team's email address
   - **App logo:** Upload the NoFoodWaste logo (optional but recommended)
   - **App domain:** Your production domain (e.g., `nofoodwaste.org`)
   - **Authorized domains:** Add your domain (e.g., `nofoodwaste.org`)
   - **Privacy policy URL:** Link to your privacy policy page
   - **Terms of service URL:** Link to your terms page
4. Click **Save and Continue**

### Scopes Page
1. Click **Add or Remove Scopes**
2. Search for and select: `https://www.googleapis.com/auth/drive.file`
   - This scope only allows the app to manage files **it creates** — it cannot read or delete other files in the Drive. This is the minimum required permission.
   - <img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/83e3a22e-748b-43ec-ac7b-7a8313cb0f61" />

3. Click **Update** → **Save and Continue**

### Test Users Page
- Skip this for now — we will publish the app in Step 5, making test users unnecessary

### Summary Page
- Review everything → click **Back to Dashboard**

---

## Step 4 — Create OAuth 2.0 Credentials

This generates the Client ID and Client Secret your backend needs.

1. Go to **APIs & Services → Credentials**
2. Click **+ Create Credentials → OAuth client ID**
3. <img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/63d92d06-3f15-4a9b-836b-7af94c17e5d5" />
<img width="960" height="504" alt="image" src="https://github.com/user-attachments/assets/ee6e6adf-c965-4740-8e5a-ac3ced12b8a0" />

4. Select **Application type: Web application**
5. Enter:
   - **Name:** `NoFoodWaste Backend`
6. Under **Authorized redirect URIs**, click **+ Add URI** and add:
   - `https://wf-nfw-services-two.vercel.app/api/oauth2callback`
   - Also add `http://localhost:8000/api/oauth2callback` (for local development/testing)

   > **Critical:** The redirect URI here must **exactly match** what's in your `.env` file (`GOOGLE_REDIRECT_URI`). Even a trailing slash difference will cause it to fail.

7. Click **Create**
8. A popup shows your:
   - **Client ID** — looks like: `261552312120-xxxxx.apps.googleusercontent.com`
   - **Client Secret** — looks like: `GOCSPX-xxxxxxxxxx`
9. Click **Download JSON** to save a backup of these credentials
10. Store these securely — treat the Client Secret like a password

---

## Step 5 — Publish the App (Required for Real Users)

By default your app is in **Testing** mode, which only allows pre-approved test email addresses. To allow any Google account (real drivers), you must publish.

1. Go to **APIs & Services → OAuth consent screen**
2. Under **Publishing status**, click **Publish App**
3. A warning will appear about Google verification — click **Confirm**

### About Google Verification

Google will show a warning screen to users saying "This app hasn't been verified" unless you go through their verification process. For an **internal organization tool** used only by your own drivers:

**Option A — Submit for Verification (Recommended for Production)**
- Click **Prepare for Verification** on the OAuth consent screen
- Provide a demo video, privacy policy, and explanation of how the app uses Drive
- Google reviews within 3–7 business days
- Once approved, users see a clean professional consent screen with no warnings

**Option B — Use a Service Account instead (Best for this use case)**
See the "Advanced: Service Account" section at the bottom of this document. This is actually better for your scenario because drivers don't need to see any Google screen at all.

---

## Step 6 — Create a Shared Google Drive Folder

1. Go to [https://drive.google.com](https://drive.google.com) using the organization's account
2. Create a new folder called `NoFoodWaste Uploads` (or any name)
3. Right-click the folder → **Share**
4. Set access to **Anyone with the link can view** (or restrict to specific team members)
5. Get the folder ID from the URL:
   - URL looks like: `https://drive.google.com/drive/folders/16rw3nNOVXJnSO61xg-6inomZV_BLDUpi`
   - The folder ID is everything after `/folders/`: `16rw3nNOVXJnSO61xg-6inomZV_BLDUpi`

---

## Step 7 — Get the Refresh Token (One-Time Admin Action)

The refresh token is a permanent credential that allows the backend to upload files forever without asking for permission again.

1. Make sure the backend server is running
2. Open this URL in your browser (replace `YOUR_CLIENT_ID` and `YOUR_BACKEND_URL`):

```
https://accounts.google.com/o/oauth2/v2/auth
  ?client_id=YOUR_CLIENT_ID
  &redirect_uri=https://YOUR_BACKEND_URL/api/oauth2callback
  &response_type=code
  &scope=https://www.googleapis.com/auth/drive.file
  &access_type=offline
  &prompt=consent
```

3. Log in with the **organization's Google account** (not a personal account)
4. Click **Allow** on the consent screen
5. You will be redirected back to the backend, which saves the refresh token automatically
6. The response will show: `{"message": "Refresh token saved to server."}`
7. Copy the `refresh_token` value from the response

> **Why `access_type=offline` and `prompt=consent`?**
> - `access_type=offline` tells Google to issue a refresh token (not just an access token)
> - `prompt=consent` forces Google to show the consent screen every time, which ensures a fresh refresh token is issued

---

## Step 8 — Configure Environment Variables

Add these to your backend `.env` file (local) and Vercel environment variables (production):

```env
GOOGLE_DRIVE_FOLDER_ID=your_folder_id_from_step_6
GOOGLE_CLIENT_ID=your_client_id_from_step_4
GOOGLE_CLIENT_SECRET=your_client_secret_from_step_4
GOOGLE_REDIRECT_URI=https://your-backend-domain.vercel.app/api/oauth2callback
GOOGLE_REFRESH_TOKEN=your_refresh_token_from_step_7
```

### Adding to Vercel
1. Go to [https://vercel.com](https://vercel.com) → select your backend project
2. Go to **Settings → Environment Variables**
3. Add each variable above
4. Click **Save** → **Redeploy** the project for changes to take effect

---

## Step 9 — Verify Everything Works

Test the upload using Swagger UI:
1. Open `https://your-backend-domain.vercel.app/docs`
2. Find `POST /api/upload-image`
3. Click **Try it out**
4. Upload any image and set `upload_type` to `pickup`
5. Check your Google Drive folder — a new folder structure should appear:
   ```
   NoFoodWaste Uploads/
     Opp1_Driver_2026-03-09/
       Pickup_2026-03-09_Driver/
         your_image.png
   ```

---

## Security Checklist Before Going Live

| Item | Why |
|---|---|
| Use organization Google account, not personal | If someone leaves the company, personal account access is lost |
| Store Client Secret in Vercel env vars only, never in code | Exposed secrets allow anyone to impersonate your app |
| Set `allow_origins` in CORS to your frontend domain only | Currently set to `*` (all) — restrict to `https://your-frontend.vercel.app` |
| Restrict Google Drive folder sharing to team members only | Unauthorized people should not view uploaded photos |
| Rotate refresh token if any team member who had access leaves | Revoke at [https://myaccount.google.com/permissions](https://myaccount.google.com/permissions) and re-run Step 7 |

---

## What Happens If the Refresh Token Expires or Is Revoked?

The refresh token becomes invalid if:
- The organization Google account password changes
- Someone revokes access at [https://myaccount.google.com/permissions](https://myaccount.google.com/permissions)
- The OAuth consent screen app is deleted from Google Cloud

**Fix:** Re-run Step 7 to get a new refresh token, update `GOOGLE_REFRESH_TOKEN` in Vercel, and redeploy.

---

---

## Summary of Credentials and Who Holds Them

| Credential | Where Stored | Who Needs It |
|---|---|---|
| Client ID | Vercel env vars + `.env` | Backend team |
| Client Secret | Vercel env vars only | Backend team (treat as password) |
| Folder ID | Vercel env vars + `.env` | Backend team |
| Refresh Token | Vercel env vars + `.env` | Backend team |
| Google Cloud Console access | Google account | Tech lead / admin only |
| Drive folder access | Google Drive sharing | Admin + team members who review photos |

---

## Contact & Support

If the upload stops working, check in this order:
1. Is the backend server running? Check Vercel deployment logs
2. Is `GOOGLE_REFRESH_TOKEN` still valid? Test at `/docs` Swagger
3. Has the Google account password changed? Re-run Step 7
4. Is the Google Drive folder still shared? Check folder permissions
5. Has the Google Cloud project been disabled? Check Google Cloud Console billing
