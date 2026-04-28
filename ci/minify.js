const luamin = require("luamin");
const path = require("path");
const fs = require("fs");

const filePath = path.join(__dirname, "bundle.tmp");

try {
    const source = fs.readFileSync(filePath, "utf8");
    
    // Check if the source is empty to prevent luamin from crashing
    if (!source || source.trim().length === 0) {
        console.error("[Minify] Source file is empty. Skipping minification.");
        process.exit(0);
    }

    const result = luamin.minify(source);
    fs.writeFileSync(filePath, result);
    
    console.log("[Minify] Successfully minified bundle.tmp");
} catch (err) {
    // If minification fails, we don't want to break the whole build.
    // We'll just use the un-minified code instead.
    console.error("[Minify] Error during minification: ", err.message);
    console.log("[Minify] Falling back to un-minified source.");
    process.exit(0); 
}
