import Roact from "@rbxts/roact";
import { hooked, useState, useCallback } from "@rbxts/roact-hooked";
import { useTheme } from "hooks/use-theme";
import FacebangModal from "./FacebangModal";

function MiscPage() {
	const theme = useTheme("home").profile;
	const [modalVisible, setModalVisible] = useState(false);
	const [isHovered, setHovered] = useState(false);

	const toggleModal = useCallback(() => setModalVisible((prev) => !prev), []);

	return (
		<frame Size={new UDim2(1, 0, 1, 0)} BackgroundTransparency={1}>
			<uipadding PaddingTop={new UDim(0, 20)} PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 20)} />

			<scrollingframe
				Size={new UDim2(1, 0, 1, 0)}
				BackgroundTransparency={1}
				ScrollBarThickness={2}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				AutomaticCanvasSize={Enum.AutomaticSize.Y}
				ClipsDescendants={true}
				ZIndex={1}
			>
				<uilistlayout Padding={new UDim(0, 10)} SortOrder={Enum.SortOrder.LayoutOrder} />

				<textbutton
					Text="Facebang Settings"
					Size={new UDim2(1, 0, 0, 50)}
					BackgroundColor3={isHovered ? theme.button.background.Lerp(new Color3(1, 1, 1), 0.1) : theme.button.background}
					TextColor3={theme.button.foreground}
					Font={Enum.Font.GothamBold}
					TextSize={16}
					AutoButtonColor={false}
					Event={{
						Activated: toggleModal,
						MouseEnter: () => setHovered(true),
						MouseLeave: () => setHovered(false),
					}}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
					<uistroke
						Thickness={1.5}
						Color={theme.button.background.Lerp(new Color3(1, 1, 1), 0.2)}
						Transparency={isHovered ? 0 : 0.5}
					/>
				</textbutton>
			</scrollingframe>

			{/* Modal Overlay / Trigger Container */}
			{modalVisible && (
				<frame
					Key="ModalOverlay"
					Size={new UDim2(1, 40, 1, 40)} 
					Position={new UDim2(0, -20, 0, -20)}
					BackgroundColor3={new Color3(0, 0, 0)}
					BackgroundTransparency={0.5}
					ZIndex={10}
					Event={{
						InputBegan: (_, input) => {
							if (input.UserInputType === Enum.UserInputType.MouseButton1) setModalVisible(false);
						}
					}}
				>
					<FacebangModal isVisible={modalVisible} onClose={() => setModalVisible(false)} />
				</frame>
			)}
		</frame>
	);
}

export default hooked(MiscPage);
