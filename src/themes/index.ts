import { darkTheme } from "./sorbet";
import { frostedGlass } from "./frosted-glass";
import { highContrast } from "./high-contrast";
import { lightTheme } from "./light-theme";
import { obsidian } from "./obsidian";
import { crimson } from "./crimson";
import { Theme } from "./theme.interface";

// verified: UI uses these in an array for selection
const themes: Theme[] = [crimson, darkTheme, lightTheme, frostedGlass, obsidian, highContrast];

/** * Returns the list of all available themes for the UI dropdown.
 * @returns {Theme[]} 
 */
export function getThemes(): Theme[] {
	return themes;
}

// Re-export for global access (like the Default Theme setting)
export { darkTheme };
