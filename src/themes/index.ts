import { darkTheme } from "./sorbet";
import { frostedGlass } from "./frosted-glass";
import { highContrast } from "./high-contrast";
import { lightTheme } from "./light-theme";
import { obsidian } from "./obsidian";
import { crimson } from "./crimson";
import { Theme } from "./theme.interface";

/** * UI Theme Registry
 * We filter the array to ensure that if an import fails (returns undefined),
 * the UI dropdown doesn't break.
 */
const themes: Theme[] = [
	crimson,
	darkTheme,
	lightTheme,
	frostedGlass,
	obsidian,
	highContrast,
].filter((t): t is Theme => t !== undefined);

/**
 * Returns the validated list of themes for the UI.
 */
export function getThemes(): Theme[] {
	return themes;
}

/**
 * Re-export the default theme for initial state configuration.
 * Note: sorbet.ts MUST export 'darkTheme'.
 */
export { darkTheme };
