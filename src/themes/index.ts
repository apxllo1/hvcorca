import { darkTheme } from "./sorbet";
import { frostedGlass } from "./frosted-glass";
import { highContrast } from "./high-contrast";
import { lightTheme } from "./light-theme";
import { obsidian } from "./obsidian";
import { crimson } from "./crimson";
import { Theme } from "./theme.interface";

// Using a record (dictionary) is usually better for Roblox UIs 
// so they can look up themes by their string name.
const themes: Record<string, Theme> = {
	crimson,
	sorbet: darkTheme, // This maps the name 'sorbet' to your darkTheme code
	darkTheme,         // This maps 'darkTheme' name too, just to be safe
	lightTheme,
	frostedGlass,
	obsidian,
	highContrast,
};

export function getThemes() {
	return themes;
}

// Keeping this so other scripts can still do: import { darkTheme } from "themes";
export { darkTheme };
