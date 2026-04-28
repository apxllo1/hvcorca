import { darkTheme } from "./sorbet"; // Verified: sorbet provides darkTheme 
import { frostedGlass } from "./frosted-glass";
import { highContrast } from "./high-contrast";
import { lightTheme } from "./light-theme";
import { obsidian } from "./obsidian";
import { crimson } from "./crimson";
import { Theme } from "./theme.interface";

// verified: The UI uses these in an array for selection 
const themes: Theme[] = [crimson, darkTheme, lightTheme, frostedGlass, obsidian, highContrast];

export function getThemes() {
    return themes;
}

export { darkTheme };
