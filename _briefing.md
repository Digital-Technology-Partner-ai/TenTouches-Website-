---
title: Ten Touches Website code briefing
type: code-briefing
status: active
owner: Hudson
development_state: MVP
software_category: product candidate
updated: 2026-05-26
---

# Ten Touches Website — code briefing

## Summary

This repo contains the Ten Touches marketing website and beta signup surface for `tentouches.app`. It is a Next.js app using TypeScript, Tailwind CSS, ShadCN-style components, Netlify deployment settings and Netlify functions for beta signup/admin workflows.

DTP has it because Ten Touches is a DTP-owned product candidate. The code was mixed into an inbox folder alongside product documentation, screenshots, app-store launch material and Apple Watch architecture notes. I split the business/project material into `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches` and kept this repo under `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website`.

## Current state

- **DTP software category:** product candidate
- **Development state:** MVP
- **Commercial status:** live/product-supporting, but needs repo hygiene before treating it as a clean maintained DTP codebase.
- **Last verified:** 2026-05-26 22:05 UK
- **Works locally:** partial
  - `npm ci` succeeded in the app directory.
  - `npm run build` succeeded in the app directory.
  - `npm run lint` failed.
- **Tests:** no dedicated test script is defined in `package.json`. `npm run lint` failed with 13 errors and 2805 warnings, mostly because the tracked `dist/` build output is inside the lint scope. One source-level lint error was also visible in `netlify/functions/admin-signups.mts` where `prefix` should be `const`.
- **Main risks:**
  - The repo currently tracks build output under `website_ten_touches/tentouches-website/dist/` and macOS `.DS_Store` files.
  - Root `.gitignore` only ignores `.netlify`; the app-level `.gitignore` is more complete but does not protect the whole repo root.
  - The remote is `https://github.com/Virgelsnake/TenTouches-Website-.git`, not the DTP GitHub organisation.
  - `test-signup.sh` contains and sends an admin password header to the live endpoint. Treat this as sensitive until reviewed.
  - `npm audit` reported 9 vulnerabilities, 5 moderate and 4 high, after `npm ci`.
  - Live-site HTTP verification was not completed in this run because the network check was blocked by the execution environment.

## How to run

Verified dependency install:

```bash
cd /Users/hudsonrebel/DTP\ Coding\ Projects/ten-touches-website/website_ten_touches/tentouches-website
npm ci
```

Development server, not run during this intake:

```bash
cd /Users/hudsonrebel/DTP\ Coding\ Projects/ten-touches-website/website_ten_touches/tentouches-website
npm run dev
```

Production build, verified on 2026-05-26:

```bash
cd /Users/hudsonrebel/DTP\ Coding\ Projects/ten-touches-website/website_ten_touches/tentouches-website
npm run build
```

Build result on 2026-05-26: succeeded. Next.js generated static routes for `/`, `/_not-found`, `/admin`, `/beta`, `/privacy`, `/privacy/beta` and `/support`.

## How to test

Available package scripts from `package.json`:

```bash
npm run dev
npm run build
npm run start
npm run lint
```

Latest verification:

```bash
cd /Users/hudsonrebel/DTP\ Coding\ Projects/ten-touches-website/website_ten_touches/tentouches-website
npm ci
npm run lint
npm run build
```

Results:

- `npm ci`: passed.
- `npm run lint`: failed. It linted tracked/generated files in `dist/` and also reported a source-level `prefer-const` error in `netlify/functions/admin-signups.mts`.
- `npm run build`: passed.

There is also a root-level `test-signup.sh`, but I did not run it because it posts beta signup test data to the live `tentouches.app` functions and includes an admin password header. That is not a harmless smoke test. Fancy that, a test script with live side effects. Very on-brand for things found in inboxes.

## Architecture map

- **Repository root:** `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website`
- **App root:** `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website/website_ten_touches/tentouches-website`
- **Framework:** Next.js 16.1.6, React 19.2.3, TypeScript, Tailwind CSS 4.
- **Pages/routes:**
  - `src/app/page.tsx` — home route.
  - `src/app/beta/page.tsx` — beta signup route.
  - `src/app/admin/page.tsx` — admin view.
  - `src/app/privacy/page.tsx` and `src/app/privacy/beta/page.tsx` — privacy pages.
  - `src/app/support/page.tsx` — support page.
- **Components:** `src/components/` contains visual and interaction components including header, footer, progress ring, iPhone mockup, revenue slider and section components.
- **Backend functions:**
  - `netlify/functions/submit-beta.mts` — beta signup submission.
  - `netlify/functions/get-counter.mts` — signup counter.
  - `netlify/functions/admin-signups.mts` — admin signup listing.
- **Static assets:** `public/` contains app icon and screenshot assets used by the site.
- **Deployment:** `netlify.toml` sets `npm run build`, `publish = "dist"`, and `NODE_VERSION = "20"`.

## Dependencies and services

Dependencies visible in `package.json`:

- Next.js, React, TypeScript, Tailwind CSS, Lucide React, class-variance-authority, clsx, tailwind-merge.
- Netlify runtime packages: `@netlify/blobs`, `@netlify/functions`.
- Supabase client package: `@supabase/supabase-js`.

Environment/runtime signals:

- Netlify deployment is assumed from `netlify.toml` and function paths.
- Beta/admin functions are live-service touching. Do not run the root `test-signup.sh` casually.
- No `.env` files were found in the copied code folder during the safety scan.
- Environment variable names were not exhaustively extracted from the function source in this pass. Review the Netlify functions before changing deployment.

## Repository hygiene

Current Git state before writing this briefing was clean.

Important hygiene findings:

- The repo has a root `.git` directory at `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website/.git`.
- Current branch is `main`.
- Remote is `origin https://github.com/Virgelsnake/TenTouches-Website-.git`.
- The repo tracks `.DS_Store` files and generated `dist/` output. This caused the lint run to inspect generated JS and produce thousands of warnings/errors.
- App-level `.gitignore` correctly ignores `/node_modules`, `/.next`, `/out`, `/build`, `.DS_Store`, `*.pem`, `.env*`, `.vercel`, `*.tsbuildinfo` and `next-env.d.ts`, but the root `.gitignore` only ignores `.netlify`.
- `node_modules/` was created by `npm ci` and remains untracked under the app directory.
- `.next/` was created by `npm run build` and remains ignored under the app directory.

Do not clean, delete, untrack or rewrite this repo without Steve's explicit approval. The immediate safe fix would be a small hygiene PR/commit that updates root ignore rules, removes generated/build/system files from tracking, and fixes the `prefer-const` lint error. That requires approval because it changes tracked repository contents beyond the briefing.

## Related DTP records

- **Wiki product page:** `[[ten-touches]]` recommended, not yet created/updated in this pass.
- **Wiki project page:** `[[ten-touches-website]]` recommended, not yet created/updated in this pass.
- **Working Files folder:** `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches`
- **Project folder briefing:** `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches/_briefing.md`
- **Kanban board:** `coding-projects`
- **Related client/project:** DTP-owned internal product candidate.

## Open questions

1. Should this repo be transferred into the DTP GitHub organisation `Digital-Technology-Partner-ai`, or remain under the current `Virgelsnake` remote for now?
2. Should I clean repo hygiene next, specifically root `.gitignore`, tracked `.DS_Store`, tracked `dist/`, and the visible lint error?
3. Is the website the only code that belongs here, or is there a separate Ten Touches iOS app codebase that should also be brought into `/Users/hudsonrebel/DTP Coding Projects/`?
4. Should `test-signup.sh` be retained, rewritten to use fixtures/staging, or removed from the repo after extracting a safe diagnostic pattern?
5. Should the Apple Watch voice-capture strawman become its own code/project workstream?

## Next recommended actions

Hudson-owned, safe after Steve approval where needed:

- Create/update wiki pages `[[ten-touches]]` and `[[ten-touches-website]]` from the Working Files briefing.
- Add a `coding-projects` Kanban card for repo hygiene and ownership decision.
- If approved, clean the repo tracking rules and remove generated/system artefacts from Git tracking without deleting local files.
- If approved, fix the source lint error in `netlify/functions/admin-signups.mts`, then rerun lint and build.
- Extract environment variable names from Netlify functions and document them here without values.

Steve-decision items:

- Decide whether to transfer the GitHub repo to the DTP organisation.
- Decide whether the live beta/admin functions should be tested from this machine, and whether test data in production is acceptable.
- Confirm whether the Apple Watch capture work is part of Ten Touches or a separate project.

## Steve's notes

