const luamin = require("luamin");
const fs = require("fs");
const path = require("path");
const filePath = path.join(__dirname, "bundle.tmp");

function stripLuaComments(src) {
    let out = '', i = 0;
    while (i < src.length) {
        // Fix: Use single char comparison for speed and accuracy
        if (src[i] === '-' && src[i+1] === '-') {
            let j = i + 2;
            if (src[j] === '[' && src[j+1] === '[') {
                let end = src.indexOf(']]', j+2);
                if (end === -1) break;
                i = end + 2; out += ' '; continue;
            }
            while (i < src.length && src[i] !== '\n') i++;
            continue;
        }
        if (src[i] === '"' || src[i] === "'") {
            let q = src[i]; out += q; i++;
            while (i < src.length && src[i] !== q) {
                if (src[i] === '\\') { out += src[i]; i++; }
                out += src[i]; i++;
            }
            if (i < src.length) { out += q; i++; }
            continue;
        }
        out += src[i]; i++;
    }
    return out;
}

function fixLuau(src) {
    // Standardize all compound operators
    return src
        .replace(/([a-zA-Z0-9_.]+)\s*\+=/g, "$1 = $1 +")
        .replace(/([a-zA-Z0-9_.]+)\s*-=/g, "$1 = $1 -")
        .replace(/([a-zA-Z0-9_.]+)\s*\.\.=/g, "$1 = $1 ..")
        .replace(/\bcontinue\b/g, "do break end"); // Safest Lua 5.1 fallback
}

try {
    let source = fs.readFileSync(filePath, "utf8");
    console.log(`[Havoc Minify] Processing ${source.length} bytes...`);

    source = stripLuaComments(source);
    source = fixLuau(source);
    
    // Final check for truncation
    if (!source.includes("BUNDLE_COMPLETE")) {
        throw new Error("FATAL: Source file is truncated! Build aborted.");
    }

    const minified = luamin.minify(source);
    fs.writeFileSync(filePath, minified);
    console.log(`[Havoc Minify] Done! New size: ${minified.length} bytes.`);
} catch (e) {
    console.error("[Havoc Minify] Failed:", e.message);
    process.exit(1);
}
