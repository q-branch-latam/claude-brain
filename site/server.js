// Minimal static server for the Q Branch LATAM story page.
// The community static buildpack is unmaintained, so we serve with a tiny Express app —
// it Just Works on Heroku (and locally: `npm install && npm start`).
const express = require("express");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname)));

app.get("/", (_req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});

app.listen(PORT, () => {
  console.log(`Q Branch LATAM story page running on port ${PORT}`);
});
