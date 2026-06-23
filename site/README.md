# Q Branch LATAM — story page

The single source of truth for the Context Stack process: a scrollable story page presented at
Tuesday AI sharing time and left up async. Static HTML, no build step.

**🌐 Live:** https://q-branch-latam-brain-9942e218be1b.herokuapp.com/ (Heroku, Basic dyno — always on).
Redeploy after editing `site/`: `git subtree push --prefix site heroku main` from the repo root. Self-contained — all fonts,
the Salesforce cloud logo, the Q Branch mark, Agent Astro, and sparkles are served from `assets/`.

Visual system follows Thais Midori's Salesforce Brand Assets kit (AvantGarde headlines, Salesforce
Sans body, Main Colors palette, gradient sections Morning→Evening, frosted glass, edge-only sparkles).

## Run locally

```bash
cd site
npm install
npm start          # → http://localhost:3000
```

Or, with no Node at all, just open `index.html` in a browser (the copy-button uses the clipboard API,
which needs `http(s)://` or `localhost` — over `file://` it falls back to selecting the text).

## Deploy — Option A: Heroku

```bash
cd site
heroku create q-branch-latam-brain      # or any free name; this becomes the URL
git init && git add -A && git commit -m "deploy: story page"
heroku git:remote -a q-branch-latam-brain
git push heroku main                     # Heroku detects Node via package.json, runs `npm start`
heroku open
```

The `Procfile` (`web: node server.js`) + `package.json` `start` script + `server.js` (tiny Express
static server) are all that Heroku needs. We use Express rather than the community static buildpack
because that buildpack is unmaintained.

## Deploy — Option B: GitHub Pages (zero-config)

Pages can't run `server.js`, but it doesn't need to — the page is fully static. Two ways:

1. **Serve from `/site` on `main`:** repo **Settings → Pages → Source: Deploy from a branch →
   `main` / `/site`** (GitHub Pages supports a `/docs` folder by default; for an arbitrary folder
   like `/site`, either rename to `/docs`, or use a `gh-pages` branch — see option 2).
2. **`gh-pages` branch:** push the contents of `site/` to the root of a `gh-pages` branch, then set
   **Settings → Pages → Source: `gh-pages` / `/ (root)`**.

`server.js`, `Procfile`, and `package.json` are simply ignored by Pages.
