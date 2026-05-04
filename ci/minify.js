const luamin = require("luamin");
const fs = require("fs");
const path = require("path");
const FILE = path.join(__dirname, "bundle.tmp");

function stripLuaComments(src) {
  let out = "";
  let i = 0;
  let len = src.length;

  while (i < len) {
    if (src[i] === '-' && src[i+1] === '-') {
      let j = i + 2;
      if (src[j] === '[') {
        let eqCount = 0;
        j++;
        while (j < len && src[j] === '=') { eqCount++; j++; }
        if (j < len && src[j] === '[') {
          j++;
          let closeStr = ']' + '='.repeat(eqCount) + ']';
          let end = src.indexOf(closeStr, j);
          if (end !== -1) {
            i = end + closeStr.length;
            out += " ";
            continue;
          }
        }
      }
      while (i < len && src[i] !== '\n') i++;
      continue;
    }

    if (src[i] === '"' || src[i] === "'") {
      const q = src[i];
      out += q;
      i++;
      while (i < len && src[i] !== q) {
        if (src[i] === '\\') { out += src[i]; i++; }
        if (i < len) { out += src[i]; i++; }
      }
      if (i < len) { out += q; i++; }
      continue;
    }

    if (src[i] === '[') {
      let eqCount = 0;
      let j = i + 1;
      while (j < len && src[j] === '=') { eqCount++; j++; }
      if (j < len && src[j] === '[') {
        let closeStr = ']' + '='.repeat(eqCount) + ']';
        let end = src.indexOf(closeStr, j + 1);
        if (end !== -1) {
          out += src.slice(i, end + closeStr.length);
          i = end + closeStr.length;
          continue;
        }
      }
    }

    out += src[i];
    i++;
  }
  return out;
}

function fixLuau(src) {
  return src
    .replace(/([a-zA-Z0-9_.]+)\s*\+=/g,   "$1 = $1 +")
    .replace(/([a-zA-Z0-9_.]+)\s*-=/g,    "$1 = $1 -")
    .replace(/([a-zA-Z0-9_.]+)\s*\*=/g,   "$1 = $1 *")
    .replace(/([a-zA-Z0-9_.]+)\s*\/=/g,   "$1 = $1 /")
    .replace(/([a-zA-Z0-9_.]+)\s*\.\.=/g, "$1 = $1 ..");
    // NOTE: do NOT replace 'continue' here — bundle.lua handles it via __CONTINUE__()
}

try {
  let src = fs.readFileSync(FILE, "utf8");
  console.log(`[Hvcorca v2.0] ${src.length}→? bytes`);

  src = stripLuaComments(src);
  src = fixLuau(src);

  const min = luamin.minify(src);
  fs.writeFileSync(FILE, min);

  console.log(`[Hvcorca v2.0] ${min.length} bytes (${Math.round((1 - min.length / src.length) * 100)}% smaller)`);
} catch (e) {
  console.error("[Hvcorca v2.0] FAILED:", e.message);
  process.exit(1);
}
