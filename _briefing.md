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
- **Commercial status:** live/product-supporting. Basic repository hygiene is now clean enough for DTP maintenance; dependency/security review is still needed before treating it as production-hardened.
- **Last verified:** 2026-05-26 22:57 UK
- **Works locally:** yes for install, lint and production build. Live production endpoints were not smoke-tested.
  - `npm ci` succeeded in the app directory.
  - `npm run lint` completed with warnings only, 0 errors.
  - `npm run build` succeeded in the app directory.
- **Tests:** no dedicated test script is defined in `package.json`. Latest verification used lint and build. `npm run lint` reports 7 warnings for unused parameters/imports but no errors.
- **Main risks:**
  - `test-signup.sh` contains and sends an admin password header to the live endpoint. Treat this as sensitive until reviewed.
  - `npm audit` reported 9 vulnerabilities, 5 moderate and 4 high, after `npm ci`.
  - Live-site HTTP verification was not completed in this run because the network check was blocked by the execution environment.
  - GitHub transfer to the DTP organisation has been verified by `git ls-remote`. Local `origin` now points to `https://github.com/Digital-Technology-Partner-ai/TenTouches-Website-.git`.

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
- `npm run lint`: passed with 7 warnings and 0 errors. Remaining warnings are unused parameters/imports.
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

Current Git state after hygiene cleanup is clean and pushed.

Important hygiene findings and actions:

- The repo has a root `.git` directory at `/Users/hudsonrebel/DTP Coding Projects/ten-touches-website/.git`.
- Current branch is `main`.
- Remote is `origin https://github.com/Digital-Technology-Partner-ai/TenTouches-Website-.git`.
- Root `.gitignore` now ignores dependencies, build outputs, local Netlify folders, environment/secrets patterns, logs, caches, macOS/system noise and TypeScript generated files.
- Tracked `.DS_Store` files and generated `dist/` output have been removed from Git tracking in commit `7007324`.
- App ESLint config ignores `dist/**`, and the visible `prefer-const` lint error in `netlify/functions/admin-signups.mts` has been fixed.
- `node_modules/`, `.next/` and `dist/` may exist locally after verification but are ignored and untracked.

Do not run the root `test-signup.sh` casually. It touches live beta/admin endpoints and should either be rewritten for fixtures/staging or retained only as a documented live diagnostic.

## Related DTP records

- **Wiki product page:** `[[ten-touches]]` recommended, not yet created/updated in this pass.
- **Wiki project page:** `[[ten-touches-website]]` recommended, not yet created/updated in this pass.
- **Working Files folder:** `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches`
- **Project folder briefing:** `/Users/hudsonrebel/My Drive/DTP Working Files/Projects/Active_Projects/DTP/Ten Touches/_briefing.md`
- **Kanban board:** `coding-projects`
- **Related client/project:** DTP-owned internal product candidate.

## Open questions

1. Is the website the only code that belongs here, or is there a separate Ten Touches iOS app codebase that should also be brought into `/Users/hudsonrebel/DTP Coding Projects/`? Steve has said he will share that folder after the website folders, files and repo are completed.
2. Should `test-signup.sh` be retained, rewritten to use fixtures/staging, or removed from the repo after extracting a safe diagnostic pattern?
3. Should the Apple Watch voice-capture strawman become its own code/project workstream? Steve has said it can stay in the Ten Touches project folder for the moment.

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

