import { useAppSelector } from "hooks/common/rodux-hooks";
import { getThemes } from "themes";
import { darkTheme } from "themes/sorbet";
import { Theme } from "themes/theme.interface";

const THEME_MAP = new Map(getThemes().map((t) => [t.name, t]));

export function useTheme<K extends keyof Theme>(key: K): Theme[K] {
	return useAppSelector((state) => {
		const themeName = state.options.currentTheme;
		const theme = THEME_MAP.get(themeName) ?? darkTheme;

		return theme[key];
	});
}
