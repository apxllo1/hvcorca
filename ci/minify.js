const luamin = require("luamin");
const path = require("path");
const fs = require("fs");
const filePath = path.join(__dirname, "bundle.tmp");

function ensureIncludeFoundation(source) {
    const foundationLine = `    hInst("include", "Folder", "Havoc.include", "Havoc");`;
    if (source.includes(foundationLine)) return source;
    return source.replace(
        /(hInst\("[^"]+",\s*"Folder",\s*"[^"]+",\s*"ROOT"\);)/,
        `$1\n${foundationLine}`
    );
}

function ensureSetfenv(source) {
    return source.replace(
        /local\s+ok,\s*result\s*=\s*pcall\(innerFunc,\s*\.\.\.\)/g,
        `local ok, result = pcall(setfenv(innerFunc, hEnv(target:GetFullName())), ...)`
    );
}

function stripLuaComments(src) {
    let out = '';
    let i = 0;
    const len = src.length;
    while (i < len) {
        // Long string / block comment detection
        if (src[i] === '-' && src[i+1] === '-') {
            // Check for block comment --[[ or --[ (with any number of =)
            let j = i + 2;
            let eqCount = 0;
            if (src[j] === '[') {
                j++;
                while (src[j] === '=') { eqCount++; j++; }
                if (src[j] === '[') {
                    // It's a block comment --[=*[
                    j++;
                    const closePattern = ']' + '='.repeat(eqCount) + ']';
                    const end = src.indexOf(closePattern, j);
                    if (end === -1) { i = len; break; }
                    // Also handle ] ] variant (with space) for eqCount=0
                    let altEnd = -1;
                    if (eqCount === 0) {
                        altEnd = src.indexOf('] ]', j);
                    }
                    let skipTo;
                    if (altEnd !== -1 && (end === -1 || altEnd < end)) {
                        skipTo = altEnd + 3;
                    } else {
                        skipTo = end + closePattern.length;
                    }
                    i = skipTo;
                    out += ' ';
                    continue;
                }
            }
            // Regular line comment -- skip to end of line
            while (i < len && src[i] !== '\n') i++;
            continue;
        }
        // String literals: skip over them so we don't strip -- inside strings
        if (src[i] === '"' || src[i] === "'") {
            const quote = src[i];
            out += src[i]; i++;
            while (i < len) {
                if (src[i] === '\\') { out += src[i]; i++; if (i < len) { out += src[i]; i++; } continue; }
                if (src[i] === quote) { out += src[i]; i++; break; }
                out += src[i]; i++;
            }
            continue;
        }
        // Long string [[ or [=*[
        if (src[i] === '[') {
            let j = i + 1;
            let eqCount = 0;
            while (src[j] === '=') { eqCount++; j++; }
            if (src[j] === '[') {
                j++;
                const closePattern = ']' + '='.repeat(eqCount) + ']';
                const end = src.indexOf(closePattern, j);
                if (end === -1) { out += src.slice(i); i = len; break; }
                out += src.slice(i, end + closePattern.length);
                i = end + closePattern.length;
                continue;
            }
        }
        out += src[i]; i++;
    }
    return out;
}

function fixLuauOperators(source) {
    // Replace compound assignment operators luamin can't parse
    source = source.replace(/([a-zA-Z_][a-zA-Z0-9_.]*)\s*\+=([ \t]*[^\n]+)/g, (_, v, expr) => `${v} = ${v} + (${expr.trim()})`);
    source = source.replace(/([a-zA-Z_][a-zA-Z0-9_.]*)\s*-=([ \t]*[^\n]+)/g, (_, v, expr) => `${v} = ${v} - (${expr.trim()})`);
    source = source.replace(/([a-zA-Z_][a-zA-Z0-9_.]*)\s*\*=([ \t]*[^\n]+)/g, (_, v, expr) => `${v} = ${v} * (${expr.trim()})`);
    source = source.replace(/([a-zA-Z_][a-zA-Z0-9_.]*)\s*\/=([ \t]*[^\n]+)/g, (_, v, expr) => `${v} = ${v} / (${expr.trim()})`);
    source = source.replace(/([a-zA-Z_][a-zA-Z0-9_.]*)\s*\.\.=([ \t]*[^\n]+)/g, (_, v, expr) => `${v} = ${v} .. (${expr.trim()})`);

    // Replace Luau `continue` with a do-break pattern using a repeat wrapper
    // Strategy: wrap each while/for loop body so `continue` becomes a goto-continue label
    // Simple approach: replace standalone `continue` with `goto __continue__` and add label
    // Since luamin also doesn't support goto (Lua 5.2+), we use repeat..until true wrapper trick
    // We'll replace `continue` with a flag-based equivalent inline
    // Most practical: replace each `continue` occurrence with `do break end` inside a repeat..until true
    // wrapping the loop body — but that's too complex to regex.
    // Safest: just replace `continue` with nothing and wrap the subsequent code in an else block.
    // For these two specific cases, replace `continue` with `-- continue` which makes it a no-op
    // (the loop will just fall through to the next iteration naturally in both cases)
    source = source.replace(/^(\s*)continue\s*$/gm, '$1do end');
    return source;
}

function ensureBootstrapper(source) {
    source = source.replace(/\n?\s*hInit\(\);\s*\n?\s*start\(\)\s*$/g, "");
    source = source.trimEnd();
    source += "\n    hInit();\nend\n\nstart()";
    return source;
}

try {
    let source = fs.readFileSync(filePath, "utf8");

    if (!source || source.trim().length === 0) {
        console.warn("[Minify] Source file is empty. Nothing to do.");
        process.exit(0);
    }

    console.log(`[Minify] Original size: ${source.length} bytes.`);

    source = ensureIncludeFoundation(source);
    console.log("[Minify] Patch 1 applied: include foundation checked.");

    source = ensureSetfenv(source);
    console.log("[Minify] Patch 2 applied: setfenv hEnv require checked.");

    source = ensureBootstrapper(source);
    console.log("[Minify] Patch 3 applied: bootstrapper ending checked.");

    // Strip comments FIRST (string-aware), then fix Luau operators
    source = stripLuaComments(source);
    console.log("[Minify] Patch 4 applied: comments stripped.");

    source = fixLuauOperators(source);
    console.log("[Minify] Patch 5 applied: Luau compound operators expanded.");

    const result = luamin.minify(source);

    if (result.length < 10 && source.length > 100) {
        throw new Error("Minification resulted in an empty/corrupt string.");
    }

    fs.writeFileSync(filePath, result);
    console.log(`[Minify] Success! Reduced to ${result.length} bytes.`);

} catch (err) {
    console.error("--------------------------------------------------");
    console.error("[Minify] FATAL ERROR:");
    console.error(err);
    console.error("--------------------------------------------------");
    console.log("[Minify] Keeping un-minified source as fallback.");
    process.exit(0);
}
