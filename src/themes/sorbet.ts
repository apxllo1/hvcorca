import { Theme, ViewTheme } from "./theme.interface";
import { hex } from "../utils/color3";

const redAccent = hex("#C6428E");
const blueAccent = hex("#484fd7");
const mixedAccent = hex("#9a3fe5");
const accentSequence = new ColorSequence([
	new ColorSequenceKeypoint(0, redAccent),
	new ColorSequenceKeypoint(0.5, mixedAccent),
	new ColorSequenceKeypoint(1, blueAccent),
]);

const background = hex("#181818");
const backgroundDark = hex("#242424");

const view: ViewTheme = {
	acrylic: false,
	outlined: false,
	foreground: hex("#ffffff"),
	background: background,
	transparency: 0,
	dropshadow: background,
	dropshadowTransparency: 0.3,
};

export const darkTheme: Theme = {
	name: "Sorbet",

	preview: {
		foreground: {
			color: new ColorSequence(hex("#ffffff")),
		},
		background: {
			color: new ColorSequence(background),
		},
		accent: {
			color: accentSequence,
		},
	},

	navbar: {
		outlined: false,
		acrylic: false,
		foreground: hex("#ffffff"),
		background: background,
		transparency: 0,
		accentGradient: {
			color: accentSequence,
		},
		dropshadow: background,
		dropshadowTransparency: 0.3,
		glowTransparency: 0,
	},

	clock: {
		outlined: false,
		acrylic: false,
		foreground: hex("#ffffff"),
		background: background,
		transparency: 0,
		dropshadow: background,
		dropshadowTransparency: 0.3,
	},

	home: {
		title: {
			...view,
			background: hex("#ffffff"),
			backgroundGradient: {
				color: accentSequence,
				rotation: 30,
			},
			dropshadow: hex("#ffffff"),
			dropshadowGradient: {
				color: accentSequence,
				rotation: 30,
			},
			dropshadowTransparency: 0.3,
		},
		profile: {
			...view,
			avatar: {
				background: backgroundDark,
				transparency: 0,
				gradient: {
					color: accentSequence,
					rotation: 45,
				},
			},
			highlight: {
				flight: redAccent,
				walkSpeed: mixedAccent,
				jumpHeight: blueAccent,
				refresh: redAccent,
				ghost: blueAccent,
				godmode: redAccent,
				freecam: blueAccent,
			},
			slider: {
				outlined: false,
				foreground: hex("#ffffff"),
				foregroundTransparency: 0,
				background: backgroundDark,
				backgroundTransparency: 0,
			},
			button: {
				outlined: false,
				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,
				background: backgroundDark,
				backgroundTransparency: 0,
			},
		},
		server: {
			...view,
			rejoinButton: {
				outlined: false,
				foreground: hex("#ffffff"),
				background: backgroundDark,
				foregroundTransparency: 0.5,
				backgroundTransparency: 0,
				accent: redAccent,
			},
			switchButton: {
				outlined: false,
				foreground: hex("#ffffff"),
				background: backgroundDark,
				foregroundTransparency: 0.5,
				backgroundTransparency: 0,
				accent: blueAccent,
			},
		},
		friendActivity: {
			...view,
			friendButton: {
				outlined: false,
				foreground: hex("#ffffff"),
				background: backgroundDark,
				foregroundTransparency: 0,
				backgroundTransparency: 0,
				dropshadow: backgroundDark,
				dropshadowTransparency: 0.4,
				glowTransparency: 0.6,
				accent: mixedAccent,
			},
		},
	},

	apps: {
		players: {
			...view,
			highlight: {
				teleport: redAccent,
				hide: blueAccent,
				kill: redAccent,
				spectate: blueAccent,
			},
			avatar: {
				background: backgroundDark,
				transparency: 0,
				gradient: {
					color: accentSequence,
					rotation: 45,
				},
			},
			button: {
				outlined: false,
				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,
				background: backgroundDark,
				backgroundTransparency: 0,
			},
			playerButton: {
				outlined: false,
				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,
				background: backgroundDark,
				backgroundTransparency: 0,
				dropshadow: backgroundDark,
				dropshadowTransparency: 0.5,
				glowTransparency: 0.2,
				accent: blueAccent,
			},
		},
	},

	options: {
		themes: {
			...view,
			themeButton: {
				outlined: false,
				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,
				background: backgroundDark,
				backgroundTransparency: 0,
				dropshadow: backgroundDark,
				dropshadowTransparency: 0.5,
				glowTransparency: 0.2,
				accent: blueAccent,
			},
		},
		shortcuts: {
			...view,
			shortcutButton: {
				outlined: false,
				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,
				background: backgroundDark,
				backgroundTransparency: 0,
				dropshadow: backgroundDark,
				dropshadowTransparency: 0.5,
				glowTransparency: 0.2,
				accent: mixedAccent,
			},
		},
		config: {
			...view,
			configButton: {
				outlined: false,
				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,
				background: backgroundDark,
				backgroundTransparency: 0,
				dropshadow: backgroundDark,
				dropshadowTransparency: 0.5,
				glowTransparency: 0.2,
				accent: redAccent,
			},
		},
	},
};
