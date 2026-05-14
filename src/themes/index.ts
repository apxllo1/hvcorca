import { crimson } from "./crimson";
import { darkTheme } from "./sorbet";
import { frostedGlass } from "./frosted-glass";
import { highContrast } from "./high-contrast";
import { lightTheme } from "./light-theme";
import { obsidian } from "./obsidian";

import type { Theme } from "./theme.interface";

const themeList: Theme[] = [crimson, darkTheme, lightTheme, frostedGlass, obsidian, highContrast].filter(
	(t): t is Theme => t !== undefined,
);

const themeMap = new Map<string, Theme>();

themeList.forEach((theme) => {
	themeMap.set(theme.name, theme);
});

export function getThemes(): Theme[] {
	return themeList;
}

export function getThemeByName(name: string): Theme {
	return themeMap.get(name) ?? darkTheme;
}

export { darkTheme };
