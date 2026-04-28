import { darkTheme } from "./sorbet";
import { frostedGlass } from "./frosted-glass";
import { highContrast } from "./high-contrast";
import { lightTheme } from "./light-theme";
import { obsidian } from "./obsidian";
import { crimson } from "./crimson";
import { Theme } from "./theme.interface";

// 1. Create the raw list, filtering out any failed imports
const themeList: Theme[] = [
	crimson,
	darkTheme,
	lightTheme,
	frostedGlass,
	obsidian,
	highContrast,
].filter((t): t is Theme => t !== undefined);

// 2. Create a lookup map for the Modal/UI logic
// This prevents crashes when the UI says "Set theme to 'Sorbet'"
const themeMap = new Map<string, Theme>();
themeList.forEach((theme) => {
	themeMap.set(theme.name, theme);
});

/** * Returns the array of themes for the dropdown menu.
 */
export function getThemes(): Theme[] {
	return themeList;
}

/**
 * Safe getter for the Modal. 
 * If a theme name is missing, it returns darkTheme instead of throwing an error.
 */
export function getThemeByName(name: string): Theme {
	return themeMap.get(name) ?? darkTheme;
}

/**
 * Re-export the default theme for the Rodux/State initial value.
 */
export { darkTheme };
