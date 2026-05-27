---
title: Ten Touches Website code briefing
type: code-briefing
status: active
owner: Hudson
development_state: MVP
software_category: product candidate
updated: 2026-05-27
---

# Ten Touches Website — code briefing

## Summary

This repo contains the Ten Touches marketing website and beta signup surface for `tentouches.app`. It is a Next.js app using TypeScript, Tailwind CSS, ShadCN-style components, Netlify deployment settings and Netlify functions for beta signup/admin workflows.

DTP has it because Ten Touches is a DTP-owned product candidate. The code was mixed into an inbox folder alongside product documentation, screenshots, app-store launch material and Apple Watch architecture notes. I split the business/project material into `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches` and kept this repo under `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website`.

## Current state

- **DTP software category:** product candidate
- **Development state:** MVP
- **Commercial status:** live/product-supporting. Basic repository hygiene is now clean enough for DTP maintenance; dependency/security review is still needed before treating it as production-hardened.
- **Last verified:** 2026-05-27 10:26 BST
- **Works locally:** yes for install, lint and production build. Production-safe live smoke checks were also completed on 2026-05-27.
  - `npm ci` succeeded in the app directory on 2026-05-26.
  - `npm run lint` completed with warnings only, 0 errors on 2026-05-27.
  - `npm run build` succeeded in the app directory on 2026-05-27.
- **Tests:** no dedicated test script is defined in `package.json`. Latest verification used lint, build and production-safe live smoke checks. `npm run lint` reports 7 warnings for unused parameters/imports but no errors.
- **Main risks:**
  - `npm audit` reported 9 vulnerabilities, 5 moderate and 4 high, after `npm ci`; this still needs dependency/security review.
  - The root `test-signup.sh` touches live beta/admin endpoints. Its admin check now requires `ADMIN_PASSWORD` from the local environment rather than a hard-coded password, but it still should not be run casually.
  - The admin Netlify function now fails closed if `ADMIN_PASSWORD` is not configured.
  - GitHub transfer to the DTP organisation has been verified by `gh repo view` and `git ls-remote`. Local `origin` points to `https://github.com/Digital-Technology-Partner-ai/TenTouches-Website-.git`.

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

Production build, verified on 2026-05-27:

```bash
cd /Users/hudsonrebel/DTP\ Coding\ Projects/ten-touches-website/website_ten_touches/tentouches-website
npm run build
```

Build result on 2026-05-27: succeeded. Next.js generated static routes for `/`, `/_not-found`, `/admin`, `/beta`, `/privacy`, `/privacy/beta` and `/support`.

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
npm run lint
npm run build
```

Results on 2026-05-27:

- `npm run lint`: passed with 7 warnings and 0 errors. Remaining warnings are unused parameters/imports.
- `npm run build`: passed.

Production-safe live smoke checks completed on 2026-05-27:

- Public routes `/`, `/beta`, `/privacy`, `/privacy/beta`, `/support` and `/admin` returned 200 from `https://tentouches.app`.
- `GET /.netlify/functions/get-counter` returned 200 with a counter payload.
- One clearly labelled Hudson beta-signup smoke-test record was submitted successfully.
- Invalid signup missing `name` returned 400.
- Unauthenticated `GET /.netlify/functions/admin-signups` returned 401.

There is also a root-level `test-signup.sh`. It still touches live endpoints, so do not run it casually. Its authenticated admin check now requires `ADMIN_PASSWORD` in the local shell environment; the repo no longer contains the admin password value.

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
- Known environment variable names from the Netlify functions: `ADMIN_PASSWORD`.
- Admin access fails closed when `ADMIN_PASSWORD` is absent.

## Repository hygiene

Current Git state after security hardening is clean and pushed as of commit to be recorded after this briefing update.

Important hygiene findings and actions:

- The repo has a root `.git` directory at `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website/.git`.
- Current branch is `main`.
- Remote is `origin https://github.com/Digital-Technology-Partner-ai/TenTouches-Website-.git`.
- Root `.gitignore` now ignores dependencies, build outputs, local Netlify folders, environment/secrets patterns, logs, caches, macOS/system noise and TypeScript generated files.
- Tracked `.DS_Store` files and generated `dist/` output have been removed from Git tracking in commit `7007324`.
- App ESLint config ignores `dist/**`, and the visible `prefer-const` lint error in `netlify/functions/admin-signups.mts` has been fixed.
- `test-signup.sh` no longer embeds the admin password; it reads `ADMIN_PASSWORD` from the caller's environment and skips the authenticated admin check if absent.
- `netlify/functions/admin-signups.mts` no longer falls back to a default admin password; it returns HTTP 500 if `ADMIN_PASSWORD` is missing.
- `node_modules/`, `.next/` and `dist/` may exist locally after verification but are ignored and untracked.

Do not run the root `test-signup.sh` casually. It touches live beta/admin endpoints and should either be rewritten for fixtures/staging or retained only as a documented live diagnostic.

## Related DTP records

- **Wiki product page:** `[[ten-touches]]`.
- **Wiki project page:** `[[ten-touches-website]]`.
- **Working Files folder:** `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches`
- **Project folder briefing:** `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches/_briefing.md`
- **Kanban board:** `coding-projects`
- **Related client/project:** DTP-owned internal product candidate.

## Open questions

1. Should `test-signup.sh` be retained, rewritten to use fixtures/staging, or removed from the repo after extracting a safe diagnostic pattern?
2. Should the Apple Watch voice-capture strawman become its own code/project workstream? Steve has said it can stay in the Ten Touches project folder for the moment.
3. Should the separate Ten Touches iOS app repo at `/Users/hudsonrebel/DTP Coding Projects/ten-touches-ios` be transferred/backed up under the DTP GitHub organisation after its dirty local training-data script changes are reviewed?

## Next recommended actions

Hudson-owned, safe after Steve approval where needed:

- Create a follow-up `coding-projects` card for Ten Touches dependency/security review and a safer staged diagnostic path for beta/admin functions.
- Intake the separate iOS app repo with its own `_briefing.md` once the pre-existing dirty local Swift script changes have been reviewed.
- Keep the Apple Watch voice-capture strawman inside the Ten Touches project folder until Steve decides whether it becomes its own workstream.

Steve-decision items:

- Decide whether `test-signup.sh` should stay as a guarded live diagnostic, be rewritten for fixtures/staging, or be removed after extracting a safe pattern.
- Decide whether to transfer/back up the Ten Touches iOS app repo under the DTP GitHub organisation.
- Confirm whether the Apple Watch capture work is part of Ten Touches or a separate project.

## Steve's notes

