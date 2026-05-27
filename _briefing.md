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
- **Commercial status:** live/product-supporting. Basic repository hygiene and the first dependency/security review pass are complete; the site still needs a safer staged diagnostic path for live beta/admin workflows before it should be called production-hardened.
- **Last verified:** 2026-05-27 12:03 BST
- **Works locally:** yes for install, lint and production build. Production-safe live smoke checks were also completed on 2026-05-27.
  - `npm ci` succeeded in the app directory on 2026-05-26.
  - `npm run lint` completed with warnings only, 0 errors on 2026-05-27.
  - `npm run build` succeeded in the app directory on 2026-05-27 after dependency updates.
  - `npm audit --omit=dev` reported 0 vulnerabilities on 2026-05-27 after updating Next.js and applying a PostCSS override.
- **Tests:** no dedicated test script is defined in `package.json`. Latest verification used `bash -n test-signup.sh`, the safe default diagnostic script, audit, lint, build and production-safe live smoke checks. `npm run lint` reports 7 warnings for unused parameters/imports but no errors.
- **Main risks:**
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
- `npm audit --omit=dev`: passed with 0 vulnerabilities after dependency updates.
- `bash -n test-signup.sh`: passed.
- `./test-signup.sh`: passed in safe default mode without creating live beta-signup records; it checked the counter, invalid-input validation, skipped authenticated admin because `ADMIN_PASSWORD` was not set, and verified unauthenticated admin access returns 401.

Production-safe live smoke checks completed on 2026-05-27:

- Public routes `/`, `/beta`, `/privacy`, `/privacy/beta`, `/support` and `/admin` returned 200 from `https://tentouches.app`.
- `GET /.netlify/functions/get-counter` returned 200 with a counter payload.
- One clearly labelled Hudson beta-signup smoke-test record was submitted successfully.
- Invalid signup missing `name` returned 400.
- Unauthenticated `GET /.netlify/functions/admin-signups` returned 401.

There is also a root-level `test-signup.sh`. It is now staged by default: safe checks run without creating beta-signup records, while live signup mutations require `LIVE_TEST=1`. Authenticated admin checks require `ADMIN_PASSWORD`; the repo does not contain the admin password value.

## Architecture map

- **Repository root:** `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website`
- **App root:** `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website/website_ten_touches/tentouches-website`
- **Framework:** Next.js 16.2.6, React 19.2.3, TypeScript, Tailwind CSS 4.
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
- Dependency security pass on 2026-05-27:
  - `npm audit fix` removed the direct `tmp`, `uuid` and `ws` audit findings.
  - Next.js was updated from 16.1.6 to 16.2.6.
  - `eslint-config-next` was updated to 16.2.6.
  - `overrides.postcss = 8.5.10` was added so the nested PostCSS advisory is remediated.
  - `npm audit --omit=dev` now reports 0 vulnerabilities.

## Repository hygiene

Current Git state after security hardening and dependency audit fix is clean and pushed as of the latest briefing/dependency commit.

Important hygiene findings and actions:

- The repo has a root `.git` directory at `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website/.git`.
- Current branch is `main`.
- Remote is `origin https://github.com/Digital-Technology-Partner-ai/TenTouches-Website-.git`.
- Root `.gitignore` now ignores dependencies, build outputs, local Netlify folders, environment/secrets patterns, logs, caches, macOS/system noise and TypeScript generated files.
- Tracked `.DS_Store` files and generated `dist/` output have been removed from Git tracking in commit `7007324`.
- App ESLint config ignores `dist/**`, and the visible `prefer-const` lint error in `netlify/functions/admin-signups.mts` has been fixed.
- `test-signup.sh` no longer embeds the admin password; it reads `ADMIN_PASSWORD` from the caller's environment and skips the authenticated admin check if absent.
- `test-signup.sh` now defaults to non-mutating diagnostics. It only creates live signup records when `LIVE_TEST=1` is explicitly supplied, and `BASE_URL` can be overridden for staging/non-production checks.
- `netlify/functions/admin-signups.mts` no longer falls back to a default admin password; it returns HTTP 500 if `ADMIN_PASSWORD` is missing.
- `package.json` and `package-lock.json` now include the dependency security pass: Next.js 16.2.6, eslint-config-next 16.2.6 and PostCSS override 8.5.10.
- `node_modules/`, `.next/` and `dist/` may exist locally after verification but are ignored and untracked.

The root `test-signup.sh` is still a live-endpoint diagnostic, but its default mode is safe/non-mutating. Use `LIVE_TEST=1` only when intentionally creating clearly labelled diagnostic signup records; use `BASE_URL=<staging-url>` if a staging deployment exists.

## Related DTP records

- **Wiki product page:** `[[ten-touches]]`.
- **Wiki project page:** `[[ten-touches-website]]`.
- **Working Files folder:** `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches`
- **Project folder briefing:** `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches/_briefing.md`
- **Kanban board:** `coding-projects`
- **Related client/project:** DTP-owned internal product candidate.

## Open questions

1. Should the Apple Watch voice-capture strawman become its own code/project workstream? Steve has said it can stay in the Ten Touches project folder for the moment.
2. Should DTP create a separate staging Netlify deployment for Ten Touches so `BASE_URL` diagnostics can run away from production?

## Next recommended actions

Hudson-owned, safe after Steve approval where needed:

- Keep the Apple Watch voice-capture strawman inside the Ten Touches project folder until Steve decides whether it becomes its own workstream.
- If Steve wants higher assurance before launch, create a staging Netlify deployment and run `BASE_URL=<staging-url> LIVE_TEST=1 ./test-signup.sh` there rather than against production.

Steve-decision items:

- Decide whether `test-signup.sh` should stay as a guarded live diagnostic, be rewritten for fixtures/staging, or be removed after extracting a safe pattern.
- Confirm whether the Apple Watch capture work is part of Ten Touches or a separate project.

## Steve's notes

