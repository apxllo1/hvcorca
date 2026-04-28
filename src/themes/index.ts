import { darkTheme } from "./sorbet";
import { frostedGlass } from "./frosted-glass";
import { highContrast } from "./high-contrast";
import { lightTheme } from "./light-theme";
import { obsidian } from "./obsidian";
import { crimson } from "./crimson";
import { Theme } from "./theme.interface";

// We keep this as an Array so .size() and .find() work in your UI
const themes: Theme[] = [crimson, darkTheme, lightTheme, frostedGlass, obsidian, highContrast];

export function getThemes() {
	return themes;
}

// This export stays here for other files that need it
export { darkTheme };
