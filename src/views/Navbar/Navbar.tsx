import Roact from "@rbxts/roact";
import { hooked } from "@rbxts/roact-hooked";
import Acrylic from "components/Acrylic";
import Border from "components/Border";
import Canvas from "components/Canvas";
import Fill from "components/Fill";
import Glow, { GlowRadius } from "components/Glow";
import { useAppSelector } from "hooks/common/rodux-hooks";
import { useSpring } from "hooks/common/use-spring";
import { useCurrentPage } from "hooks/use-current-page";
import { useTheme } from "hooks/use-theme";
import { DashboardPage, PAGE_TO_INDEX } from "store/models/dashboard.model";
import { getColorInSequence, hex } from "utils/color3";
import { px, scale } from "utils/udim2";
import NavbarTab from "./NavbarTab";

// 500px wide allows each of the 5 tabs to be exactly 100px wide
const NAVBAR_SIZE = px(500, 56);

function Navbar() {
	const theme = useTheme("navbar");
	const page = useCurrentPage();
	const isOpen = useAppSelector((state) => state.dashboard.isOpen);

	/**
	 * MATH FIX: PAGE_TO_INDEX[page] / 4
	 * With 5 tabs (0, 1, 2, 3, 4), dividing by 4 ensures that:
	 * Index 0 = 0.0 (First Tab)
	 * Index 4 = 1.0 (Last Tab)
	 */
	const alpha = useSpring(PAGE_TO_INDEX[page] / 4, { frequency: 3.9, dampingRatio: 0.76 });

	return (
		<frame
			Size={NAVBAR_SIZE}
			Position={useSpring(isOpen ? new UDim2(0.5, 0, 1, -20) : new UDim2(0.5, 0, 1, 100), {})}
			AnchorPoint={new Vector2(0.5, 1)}
			BackgroundTransparency={1}
		>
			{/* Shadows */}
			<Glow
				radius={GlowRadius.Size146}
				size={new UDim2(1, 80, 0, 146)}
				position={px(-40, -20)}
				color={theme.dropshadow}
				gradient={theme.dropshadowGradient}
				transparency={theme.transparency}
			/>

			{/* Underglow - Centered purely by alpha now */}
			<Underglow
				transparency={theme.glowTransparency}
				position={alpha}
				sequenceColor={alpha.map((a) => getColorInSequence(theme.accentGradient.color, a))}
			/>

			{/* Body Background */}
			<Fill
				color={theme.background}
				gradient={theme.backgroundGradient}
				radius={8}
				transparency={theme.transparency}
			/>

			{/* Sliding Accent Light */}
			<Canvas
				size={px(100, 56)}
				position={alpha.map((a) => scale(a, 0))}
				clipsDescendants
			>
				<frame
					Size={NAVBAR_SIZE}
					Position={alpha.map((a) => scale(-a, 0))}
					BackgroundColor3={hex("#FFFFFF")}
					BorderSizePixel={0}
				>
					<uigradient
						Color={theme.accentGradient.color}
						Transparency={theme.accentGradient.transparency}
						Rotation={theme.accentGradient.rotation}
					/>
					<uicorner CornerRadius={new UDim(0, 8)} />
				</frame>
			</Canvas>

			{/* Border Layer */}
			{theme.outlined && <Border Key="border" color={theme.foreground} radius={8} transparency={0.8} />}

			{/* The 5 Navigation Tabs */}
			<NavbarTab page={DashboardPage.Home} />
			<NavbarTab page={DashboardPage.Apps} />
			<NavbarTab page={DashboardPage.Scripts} />
			<NavbarTab page={DashboardPage.Options} />
			<NavbarTab page={DashboardPage.Misc} />

			{/* Acrylic Blur Effect */}
			{theme.acrylic && <Acrylic />}
		</frame>
	);
}

export default hooked(Navbar);

function Underglow(props: {
	sequenceColor: Roact.Binding<Color3>;
	position: Roact.Binding<number>;
	transparency: number;
}) {
	return (
		<imagelabel
			Image="rbxassetid://8992238178"
			ImageColor3={props.sequenceColor}
			ImageTransparency={props.transparency}
			Size={px(148, 104)}
			Position={props.position.map((a) => new UDim2(a, 0, 0, -18))}
			AnchorPoint={new Vector2(0.5, 0)}
			BackgroundTransparency={1}
		/>
	);
}
