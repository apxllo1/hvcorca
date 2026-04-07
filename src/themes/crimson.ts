import { darkTheme } from "themes/dark-theme";
import { Theme, ViewTheme } from "themes/theme.interface";
import { hex } from "utils/color3";

const redAccent = hex("#FF2222");
const white = hex("#ffffff");
const black = hex("#0a0a0a");

const accentSequence = new ColorSequence([
	new ColorSequenceKeypoint(0, hex("#FF4444")),
	new ColorSequenceKeypoint(0.5, hex("#CC0000")),
	new ColorSequenceKeypoint(1, hex("#880000")),
]);

const background = hex("#111111");
const backgroundDark = hex("#0a0a0a");

const view: ViewTheme = {
	acrylic: false,
	outlined: true,
	foreground: white,
	background: background,
	backgroundGradient: undefined,
	transparency: 0,
	dropshadow: background,
	dropshadowTransparency: 0.3,
};

export const crimson: Theme = {
	...darkTheme,

	name: "Crimson",

	preview: {
		foreground: {
			color: new ColorSequence(white),
		},
		background: {
			color: new ColorSequence(background),
		},
		accent: {
			color: accentSequence,
			rotation: 25,
		},
	},

	navbar: {
		...darkTheme.navbar,
		outlined: true,
		background: background,
		dropshadow: background,
		foreground: white,
		accentGradient: {
			color: accentSequence,
		},
	},

	clock: {
		...darkTheme.clock,
		outlined: true,
		background: background,
		dropshadow: background,
		foreground: white,
	},

	home: {
		title: {
			...view,
			background: white,
			backgroundGradient: {
				color: accentSequence,
				rotation: 25,
			},
			dropshadow: white,
			dropshadowGradient: {
				color: accentSequence,
				rotation: 25,
			},
		},
		profile: {
			...view,
			avatar: {
				...darkTheme.home.profile.avatar,
				background: backgroundDark,
				transparency: 0,
				gradient: {
					color: accentSequence,
					rotation: 25,
				},
			},
			highlight: {
				flight: redAccent,
				walkSpeed: hex("#FF4444"),
				jumpHeight: hex("#FF6666"),
				refresh: redAccent,
				ghost: hex("#FF4444"),
				godmode: hex("#FF0000"),
				freecam: hex("#FF6666"),
			},
			slider: {
				...darkTheme.home.profile.slider,
				outlined: true,
				foreground: white,
				background: backgroundDark,
			},
			button: {
				...darkTheme.home.profile.button,
				outlined: true,
				foreground: white,
				background: backgroundDark,
			},
		},
		server: {
			...view,
			background: hex("#CC0000"),
			dropshadow: hex("#CC0000"),
			rejoinButton: {
				...darkTheme.home.server.rejoinButton,
				outlined: true,
				foreground: white,
				background: hex("#CC0000"),
				foregroundTransparency: 0,
				accent: black,
			},
			switchButton: {
				...darkTheme.home.server.switchButton,
				outlined: true,
				foreground: white,
				background: hex("#CC0000"),
				foregroundTransparency: 0,
				accent: black,
			},
		},
		friendActivity: {
			...view,
			friendButton: {
				...darkTheme.home.friendActivity.friendButton,
				outlined: true,
				foreground: white,
				background: backgroundDark,
				accent: redAccent,
			},
		},
	},

	apps: {
		players: {
			...view,
			highlight: {
				teleport: hex("#FF4444"),
				hide: hex("#FF2222"),
				kill: hex("#CC0000"),
				spectate: hex("#FF6666"),
			},
			avatar: {
				...darkTheme.apps.players.avatar,
				background: backgroundDark,
				transparency: 0,
				gradient: {
					color: accentSequence,
					rotation: 25,
				},
			},
			button: {
				...darkTheme.apps.players.button,
				outlined: true,
				foreground: white,
				background: backgroundDark,
			},
			playerButton: {
				...darkTheme.apps.players.playerButton,
				outlined: true,
				foreground: white,
				background: backgroundDark,
				dropshadow: backgroundDark,
				accent: redAccent,
			},
		},
	},

	options: {
		config: {
			...view,
			configButton: {
				...darkTheme.options.config.configButton,
				outlined: true,
				foreground: white,
				background: backgroundDark,
				dropshadow: backgroundDark,
				accent: redAccent,
			},
		},
		shortcuts: {
			...view,
			shortcutButton: {
				...darkTheme.options.shortcuts.shortcutButton,
				outlined: true,
				foreground: white,
				background: backgroundDark,
				dropshadow: backgroundDark,
				accent: redAccent,
			},
		},
		themes: {
			...view,
			themeButton: {
				...darkTheme.options.themes.themeButton,
				outlined: true,
				foreground: white,
				background: backgroundDark,
				dropshadow: backgroundDark,
				accent: redAccent,
			},
		},
	},
};
