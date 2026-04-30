const luamin = require("luamin");
const fs = require("fs");
const path = require("path");
const filePath = path.join(__dirname, "bundle.tmp");

function stripLuaComments(src) {
    let out = "", i = 0;
    const len = src.length;
    while (i < len) {
        if (src[i] === "-" && src[i + 1] === "-") {
            let j = i + 2;
            if (src[j] === "[" && src[j + 1] === "[") {
                j += 2;
                const tight  = src.indexOf("]]", j);
                const spaced = src.indexOf("] ]", j);
                let end, skip;
                if (tight === -1 && spaced === -1) break;
                if      (tight  === -1)            { end = spaced; skip = 3; }
                else if (spaced === -1)            { end = tight;  skip = 2; }
                else if (spaced < tight)           { end = spaced; skip = 3; }
                else                               { end = tight;  skip = 2; }
                i = end + skip;
                out += " ";
                continue;
            }
            while (i < len && src[i] !== "\n") i++;
            continue;
        }
        if (src[i] === '"' || src[i] === "'") {
            const q = src[i];
            out += q; i++;
            while (i < len && src[i] !== q) {
                if (src[i] === "\\") { out += src[i]; i++; }
                if (i < len) { out += src[i]; i++; }
            }
            if (i < len) { out += q; i++; }
            continue;
        }
        if (src[i] === "[" && src[i + 1] === "[") {
            const end = src.indexOf("]]", i + 2);
            if (end === -1) { out += src.slice(i); break; }
            out += src.slice(i, end + 2);
            i = end + 2;
            continue;
        }
        out += src[i]; i++;
    }
    return out;
}

function fixLuau(src) {
    return src
        .replace(/([a-zA-Z0-9_.]+)\s*\+=/g,   "$1 = $1 +")
        .replace(/([a-zA-Z0-9_.]+)\s*-=/g,    "$1 = $1 -")
        .replace(/([a-zA-Z0-9_.]+)\s*\*=/g,   "$1 = $1 *")
        .replace(/([a-zA-Z0-9_.]+)\s*\/=/g,   "$1 = $1 /")
        .replace(/([a-zA-Z0-9_.]+)\s*\.\.=/g, "$1 = $1 ..")
        .replace(/\bcontinue\b/g, "do break end");
}

try {
    let source = fs.readFileSync(filePath, "utf8");
    console.log(`[Havoc Minify] Input: ${source.length} bytes`);
    source = stripLuaComments(source);
    source = fixLuau(source);
    const minified = luamin.minify(source);
    fs.writeFileSync(filePath, minified);
    console.log(`[Havoc Minify] Done: ${minified.length} bytes`);
} catch (e) {
    console.error("[Havoc Minify] FAILED:", e.message);
    console.error(e);
    process.exit(1);
}
