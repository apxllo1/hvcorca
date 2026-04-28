import { darkTheme } from "./sorbet";
import { frostedGlass } from "./frosted-glass";
import { highContrast } from "./high-contrast";
import { lightTheme } from "./light-theme";
import { obsidian } from "./obsidian";
import { crimson } from "./crimson";
import { Theme } from "./theme.interface";

/**
 * We keep this as a standard Array so .size() and .find() work in your UI.
 * Note: If any of these imports are broken, the array will contain 'undefined',
 * so we filter them out to prevent UI crashes.
 */
const themes: Theme[] = [crimson, darkTheme, lightTheme, frostedGlass, obsidian, highContrast].filter(
	(t) => t !== undefined,
);

/**
 * Returns the list of all available themes for the UI dropdown.
 * @returns {Theme[]}
 */
export function getThemes(): Theme[] {
	return themes;
}

/**
 * Re-export the default theme (Sorbet/Dark).
 * This is used for the initial store state.
 */
export { darkTheme };
