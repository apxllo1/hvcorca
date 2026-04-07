import { Theme } from "themes/theme.interface";
import { hex } from "utils/color3";

export const darkTheme: Theme = {
	name: "Havoc",

	preview: {
		foreground: {
			color: new ColorSequence(hex("#ffffff")),
		},
		background: {
			color: new ColorSequence(hex("#0f0f0f")),
		},
		accent: {
			color: new ColorSequence([
				new ColorSequenceKeypoint(0, hex("#FF2222")),
				new ColorSequenceKeypoint(0.5, hex("#CC0000")),
				new ColorSequenceKeypoint(1, hex("#880000")),
			]),
			rotation: 25,
		},
	},

	navbar: {
		outlined: true,
		acrylic: false,

		foreground: hex("#ffffff"),
		background: hex("#0f0f0f"),
		transparency: 0,

		accentGradient: {
			color: new ColorSequence([
				new ColorSequenceKeypoint(0, hex("#FF4444")),
				new ColorSequenceKeypoint(0.25, hex("#FF2222")),
				new ColorSequenceKeypoint(0.5, hex("#CC0000")),
				new ColorSequenceKeypoint(0.75, hex("#990000")),
				new ColorSequenceKeypoint(1, hex("#FF4444")),
			]),
		},
		dropshadow: hex("#0f0f0f"),
		dropshadowTransparency: 0.3,
		glowTransparency: 0,
	},

	clock: {
		outlined: true,
		acrylic: false,

		foreground: hex("#ffffff"),
		background: hex("#0f0f0f"),
		transparency: 0,

		dropshadow: hex("#0f0f0f"),
		dropshadowTransparency: 0.3,
	},

	home: {
		title: {
			outlined: true,
			acrylic: false,

			foreground: hex("#ffffff"),
			background: hex("#ffffff"),
			backgroundGradient: {
				color: new ColorSequence([
					new ColorSequenceKeypoint(0, hex("#FF4444")),
					new ColorSequenceKeypoint(0.5, hex("#CC0000")),
					new ColorSequenceKeypoint(1, hex("#880000")),
				]),
				rotation: 25,
			},
			transparency: 0,

			dropshadow: hex("#ffffff"),
			dropshadowGradient: {
				color: new ColorSequence([
					new ColorSequenceKeypoint(0, hex("#FF4444")),
					new ColorSequenceKeypoint(0.5, hex("#CC0000")),
					new ColorSequenceKeypoint(1, hex("#880000")),
				]),
				rotation: 25,
			},
			dropshadowTransparency: 0.3,
		},

		profile: {
			outlined: true,
			acrylic: false,

			foreground: hex("#ffffff"),
			background: hex("#141414"),
			transparency: 0,

			dropshadow: hex("#141414"),
			dropshadowTransparency: 0.3,

			avatar: {
				background: hex("#0a0a0a"),
				gradient: {
					color: new ColorSequence([
						new ColorSequenceKeypoint(0, hex("#FF4444")),
						new ColorSequenceKeypoint(0.5, hex("#CC0000")),
						new ColorSequenceKeypoint(1, hex("#880000")),
					]),
					rotation: 25,
				},
				transparency: 0,
			},

			button: {
				outlined: true,

				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,

				background: hex("#0a0a0a"),
				backgroundTransparency: 0,
			},

			slider: {
				outlined: true,

				foreground: hex("#ffffff"),
				foregroundTransparency: 0,

				background: hex("#0a0a0a"),
				backgroundTransparency: 0,
			},

			highlight: {
				flight: hex("#CC0000"),
				walkSpeed: hex("#FF2222"),
				jumpHeight: hex("#FF6666"),
				refresh: hex("#CC0000"),
				ghost: hex("#FF4444"),
				godmode: hex("#FF0000"),
				freecam: hex("#FF6666"),
			},
		},

		server: {
			outlined: true,
			acrylic: false,

			foreground: hex("#ffffff"),
			background: hex("#CC0000"),
			transparency: 0,

			dropshadow: hex("#CC0000"),
			dropshadowTransparency: 0.3,

			rejoinButton: {
				outlined: true,
				foreground: hex("#ffffff"),
				background: hex("#CC0000"),
				accent: hex("#0f0f0f"),
				foregroundTransparency: 0,
				backgroundTransparency: 0,
			},

			switchButton: {
				outlined: true,
				foreground: hex("#ffffff"),
				background: hex("#CC0000"),
				accent: hex("#0f0f0f"),
				foregroundTransparency: 0,
				backgroundTransparency: 0,
			},
		},

		friendActivity: {
			outlined: true,
			acrylic: false,

			foreground: hex("#ffffff"),
			background: hex("#141414"),
			transparency: 0,

			dropshadow: hex("#141414"),
			dropshadowTransparency: 0.3,

			friendButton: {
				outlined: true,

				accent: hex("#CC0000"),

				foreground: hex("#ffffff"),
				foregroundTransparency: 0,

				background: hex("#0a0a0a"),
				backgroundTransparency: 0,

				dropshadow: hex("#000000"),
				dropshadowTransparency: 0.4,
				glowTransparency: 0.6,
			},
		},
	},

	apps: {
		players: {
			outlined: true,
			acrylic: false,

			foreground: hex("#ffffff"),
			background: hex("#141414"),
			transparency: 0,

			dropshadow: hex("#141414"),
			dropshadowTransparency: 0.3,

			avatar: {
				background: hex("#0a0a0a"),
				gradient: {
					color: new ColorSequence([
						new ColorSequenceKeypoint(0, hex("#CC0000")),
						new ColorSequenceKeypoint(1, hex("#CC0000")),
					]),
					rotation: 25,
				},
				transparency: 0,
			},

			button: {
				outlined: true,

				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,

				background: hex("#0a0a0a"),
				backgroundTransparency: 0,
			},

			highlight: {
				teleport: hex("#FF4444"),
				hide: hex("#FF2222"),
				kill: hex("#CC0000"),
				spectate: hex("#FF6666"),
			},

			playerButton: {
				outlined: true,

				accent: hex("#CC0000"),

				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,

				background: hex("#0a0a0a"),
				backgroundTransparency: 0,

				dropshadow: hex("#000000"),
				dropshadowTransparency: 0.5,
				glowTransparency: 0.2,
			},
		},
	},

	options: {
		themes: {
			outlined: true,
			acrylic: false,

			foreground: hex("#ffffff"),
			background: hex("#141414"),
			transparency: 0,

			dropshadow: hex("#141414"),
			dropshadowTransparency: 0.3,

			themeButton: {
				outlined: true,

				accent: hex("#FF2222"),

				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,

				background: hex("#0a0a0a"),
				backgroundTransparency: 0,

				dropshadow: hex("#000000"),
				dropshadowTransparency: 0.5,
				glowTransparency: 0.2,
			},
		},

		shortcuts: {
			outlined: true,
			acrylic: false,

			foreground: hex("#ffffff"),
			background: hex("#141414"),
			transparency: 0,

			dropshadow: hex("#141414"),
			dropshadowTransparency: 0.3,

			shortcutButton: {
				outlined: true,

				accent: hex("#CC0000"),

				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,

				background: hex("#0a0a0a"),
				backgroundTransparency: 0,

				dropshadow: hex("#000000"),
				dropshadowTransparency: 0.5,
				glowTransparency: 0.2,
			},
		},

		config: {
			outlined: true,
			acrylic: false,

			foreground: hex("#ffffff"),
			background: hex("#141414"),
			transparency: 0,

			dropshadow: hex("#141414"),
			dropshadowTransparency: 0.3,

			configButton: {
				outlined: true,

				accent: hex("#CC0000"),

				foreground: hex("#ffffff"),
				foregroundTransparency: 0.5,

				background: hex("#0a0a0a"),
				backgroundTransparency: 0,

				dropshadow: hex("#000000"),
				dropshadowTransparency: 0.5,
				glowTransparency: 0.2,
			},
		},
	},
};
