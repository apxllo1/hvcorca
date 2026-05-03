// src/constants.ts
export const IS_DEV = getgenv() === undefined; // getgenv is now global
export const LOAD_GUARD = "_HAVOC_IS_LOADED";
declare const VERSION: string;
export const VERSION_TAG = VERSION ?? "studio";