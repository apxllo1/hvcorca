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

    source = ensureIncludeFoundation(source);
    source = ensureSetfenv(source);
    source = ensureBootstrapper(source);

    // Attempt minification
    const result = luamin.minify(source);
    
    // Check if result is suspiciously short compared to source
    if (result.length < 10 && source.length > 100) {
        throw new Error("Minification resulted in an empty/corrupt string.");
    }
    fs.writeFileSync(filePath, result);
    console.log(`[Minify] Success! Reduced to ${result.length} bytes.`);
} catch (err) {
    // CRITICAL: Log the full error so we can see it in GitHub Actions
    console.error("--------------------------------------------------");
    console.error("[Minify] FATAL ERROR:");
    console.error(err); 
    console.error("--------------------------------------------------");
    
    // We do NOT writeFileSync here. 
    // By doing nothing, the original un-minified 'bundle.tmp' stays intact.
    
    console.log("[Minify] Keeping un-minified source as fallback.");
    process.exit(0); 
}
