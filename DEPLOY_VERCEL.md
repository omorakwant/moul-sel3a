# Deploy L'Carnet B2B to Vercel

This monorepo has **two** web targets:

| App | Folder | What Vercel builds |
|-----|--------|--------------------|
| **Flutter** (supplier/retailer web) | `app/` | Root `vercel.json` → `./build.sh` → `app/build/web` |
| **Marketing / Next.js landing** | `lcarnet-b2b-landing/` | Next.js (`npm run build`) |

If **`lcarnetb2b.vercel.app`** (or any URL) still shows the **old Flutter app**, the Vercel project is almost certainly using **root** `vercel.json` (Flutter). Point that project at the Next.js folder instead (below).

### Marketing site only (`lcarnet-b2b-landing`)

In Vercel: **Project → Settings → General**:

1. **Root Directory** → set to **`lcarnet-b2b-landing`** (not `.`).
2. **Framework Preset** → **Next.js** (or leave “Other” cleared so Vercel auto-detects from `package.json`).
3. Remove any **override** for Build / Output that still says `./build.sh` or `app/build/web` (use the defaults Next.js suggests, usually **Build Command** `next build` and **Output** `.next`).
4. **Save**, then **Deployments → … → Redeploy** the latest commit.

To keep **both** Flutter and Next.js live, use **two Vercel projects** importing the **same GitHub repo**: one with Root Directory `.` for Flutter, one with `lcarnet-b2b-landing` for the landing page; assign **lcarnetb2b.vercel.app** to the Next.js project.

---

## 1. Connect GitHub to Vercel

1. Go to **[vercel.com](https://vercel.com)** and sign in (use “Continue with GitHub” if you use GitHub).
2. Click **“Add New…”** → **“Project”**.
3. **Import** the `omorakwant/moul-sel3a` repository (or your fork). Authorize Vercel to access GitHub if asked.

## 2. Configure the project

Vercel will read `vercel.json` from the repo. Confirm:

| Setting           | Value            |
|------------------|------------------|
| **Framework Preset** | Other           |
| **Build Command**   | `./build.sh`    |
| **Output Directory**| `app/build/web` |
| **Root Directory**  | `.` (leave default) |

If your `vercel.json` is at the repo root with:

- `"buildCommand": "./build.sh"`
- `"outputDirectory": "app/build/web"`

you can leave the dashboard defaults as-is.

## 3. Deploy

1. Click **“Deploy”**.
2. The build will:
   - Clone the Flutter SDK
   - Run `./build.sh` (which runs `flutter build web` inside `app/`)
   - Serve the output from `app/build/web`
3. When it finishes, you’ll get a URL like `moul-sel3a-xxx.vercel.app`.

## 4. Production domain

- The first deploy is usually a **preview** URL.
- To set the **production** domain: **Project → Settings → Domains** and add your custom domain, or use the default `*.vercel.app` production URL from the **Deployments** tab.

## 5. Future updates

After the project is connected, **every push to `main`** (or the branch you chose) will trigger a new deployment automatically.

---

**Troubleshooting**

- **Build fails on “flutter: command not found”**  
  `build.sh` clones Flutter; the first run can take several minutes. If Vercel times out, check the build logs and consider increasing the build timeout in Project Settings.
- **404 on refresh**  
  The `vercel.json` routes already send all requests to `/index.html` (SPA). If you still see 404s, confirm the **Output Directory** is exactly `app/build/web`.
