declare const VERSION: string | undefined;

// Use type check for getgenv to prevent "cannot find name" errors during compile
export const IS_DEV = type(getgenv) === "nil";

// Fallback to "studio" if VERSION is not injected during bundling
export const VERSION_TAG = VERSION ?? "studio";
