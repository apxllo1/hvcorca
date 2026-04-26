import { darkTheme } from "themes/sorbet";
import { frostedGlass } from "themes/frosted-glass";
import { highContrast } from "themes/high-contrast";
import { lightTheme } from "themes/light-theme";
import { obsidian } from "themes/obsidian";
import { crimson } from "themes/crimson";
import { Theme } from "themes/theme.interface";

const themes: Theme[] = [crimson, darkTheme, lightTheme, frostedGlass, obsidian, highContrast];

export function getThemes() {
	return themes;
}
