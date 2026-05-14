export const UI_COLORS = {
	// Primary Brand Colors
	Accent: Color3.fromRGB(235, 76, 105),
	AccentDark: Color3.fromRGB(150, 40, 60),

	// Backgrounds
	MainBG: Color3.fromRGB(10, 10, 10),
	SectionBG: Color3.fromRGB(15, 15, 15),
	ElementBG: Color3.fromRGB(20, 20, 20),

	// Borders & Strokes
	Border: Color3.fromRGB(35, 35, 35),
	Hover: Color3.fromRGB(45, 45, 45),

	// Text
	TextMain: Color3.fromRGB(255, 255, 255),
	TextDim: Color3.fromRGB(180, 180, 180),
	TextDark: Color3.fromRGB(120, 120, 120),
} as const;

export const UI_ANIMATION = {
	SpringDamping: 0.8,
	SpringFrequency: 2.5,
	FastSpeed: 0.1,
	DefaultSpeed: 0.25,
} as const;

export const UI_LAYOUT = {
	Padding: new UDim(0, 20),
	Spacing: new UDim(0, 10),
	CornerRadius: new UDim(0, 8),
	HeaderHeight: 60,
} as const;
