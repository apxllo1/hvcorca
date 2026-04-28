import Roact from "@rbxts/roact";
import { hooked, useState, useCallback } from "@rbxts/roact-hooked";
import { useTheme } from "hooks/use-theme";
import FacebangModal from "./FacebangModal";

function MiscPage() {
	const themeData = useTheme("home");
	const theme = themeData?.profile;
	
	const [modalVisible, setModalVisible] = useState(false);
	const [isHovered, setHovered] = useState(false);

	const toggleModal = useCallback(() => setModalVisible((prev) => !prev), []);

	// Safety check for theme initialization
	if (!theme) return <frame Key="Loading" BackgroundTransparency={1} Size={new UDim2(1, 0, 1, 0)} />;

	return (
		<frame Key="MiscPage" Size={new UDim2(1, 0, 1, 0)} BackgroundTransparency={1}>
			<uipadding 
				PaddingTop={new UDim(0, 20)} 
				PaddingLeft={new UDim(0, 20)} 
				PaddingRight={new UDim(0, 20)} 
			/>

			<scrollingframe
				Key="ContentScroll"
				Size={new UDim2(1, 0, 1, 0)}
				BackgroundTransparency={1}
				ScrollBarThickness={2}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				AutomaticCanvasSize={Enum.AutomaticSize.Y}
				ClipsDescendants={true}
				ZIndex={1}
			>
				<uilistlayout 
					Padding={new UDim(0, 12)} 
					SortOrder={Enum.SortOrder.LayoutOrder} 
					HorizontalAlignment={Enum.HorizontalAlignment.Center}
				/>

				<textbutton
					Key="FacebangButton"
					Text="Facebang Settings"
					Size={new UDim2(1, 0, 0, 55)}
					BackgroundColor3={
						isHovered ? theme.button.background.Lerp(new Color3(1, 1, 1), 0.05) : theme.button.background
					}
					TextColor3={theme.button.foreground}
					Font={Enum.Font.GothamBold}
					TextSize={16}
					AutoButtonColor={false}
					LayoutOrder={1}
					Event={{
						Activated: toggleModal,
						MouseEnter: () => setHovered(true),
						MouseLeave: () => setHovered(false),
					}}
				>
					<uicorner CornerRadius={new UDim(0, 10)} />
					<uistroke
						Thickness={2}
						Color={theme.button.background.Lerp(new Color3(1, 1, 1), 0.15)}
						Transparency={isHovered ? 0.2 : 0.6}
					/>
					{/* Keeps the button from getting too tall on massive resolutions */}
					<uiaspectratioconstraint AspectRatio={8} DominantAxis={Enum.DominantAxis.Width} />
				</textbutton>
			</scrollingframe>

			{/* Modal Layer with CanvasGroup for better rendering/transparency control */}
			{modalVisible && (
				<canvasgroup
					Key="ModalOverlay"
					Size={new UDim2(1, 40, 1, 40)}
					Position={new UDim2(0, -20, 0, -20)}
					BackgroundColor3={new Color3(0, 0, 0)}
					BackgroundTransparency={0.4}
					ZIndex={10}
					GroupTransparency={0}
					Event={{
						InputBegan: (_, input) => {
							if (input.UserInputType === Enum.UserInputType.MouseButton1) setModalVisible(false);
						},
					}}
				>
					<FacebangModal isVisible={modalVisible} onClose={() => setModalVisible(false)} />
				</canvasgroup>
			)}
		</frame>
	);
}

export default hooked(MiscPage);
