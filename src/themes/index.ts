import { darkTheme } from "./sorbet";
import { frostedGlass } from "./frosted-glass"; // Fixed the typo here
import { highContrast } from "./high-contrast";
import { lightTheme } from "./light-theme";
import { obsidian } from "./obsidian";
import { crimson } from "./crimson";
import { Theme } from "./theme.interface";

// Using a standard Array for the UI selector
const themes: Theme[] = [
	crimson, 
	darkTheme, 
	lightTheme, 
	frostedGlass, 
	obsidian, 
	highContrast
];

/**
 * Returns all themes for the UI dropdown menu.
 */
export function getThemes(): Theme[] {
	return themes;
}

/**
 * Re-export for the initial state/default theme.
 */
export { darkTheme };
