import Roact from "@rbxts/roact";
import { hooked, useState, useCallback } from "@rbxts/roact-hooked";
import Card from "components/Card";
import { useTheme } from "hooks/use-theme";
import { DashboardPage } from "store/models/dashboard.model";
import { px } from "utils/udim2";
import FacebangModal from "./FacebangModal";

function MiscPage() {
	const theme = useTheme("apps").players;

	const [modalVisible, setModalVisible] = useState(false);
	const [isHovered, setHovered] = useState(false);

	const openModal = useCallback(() => setModalVisible(true), []);
	const closeModal = useCallback(() => setModalVisible(false), []);

	return (
		<Card index={2} page={DashboardPage.Apps} theme={theme} size={px(326, 648)} position={new UDim2(0, 0, 1, 0)}>
			<uipadding PaddingTop={new UDim(0, 20)} PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 20)} />

			<scrollingframe
				Key="ContentScroll"
				Size={new UDim2(1, 0, 1, 0)}
				BackgroundTransparency={1}
				ScrollBarThickness={2}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				AutomaticCanvasSize={Enum.AutomaticSize.Y}
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
					ZIndex={1}
					Event={{
						Activated: openModal,
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
				</textbutton>
			</scrollingframe>

			{modalVisible && (
				<textbutton
					Key="ModalOverlay"
					Text=""
					Size={new UDim2(1, 40, 1, 40)}
					Position={new UDim2(0, -20, 0, -20)}
					BackgroundColor3={new Color3(0, 0, 0)}
					BackgroundTransparency={0.4}
					AutoButtonColor={false}
					ZIndex={10}
					Event={{
						Activated: closeModal,
					}}
				>
					<FacebangModal isVisible={modalVisible} onClose={closeModal} />
				</textbutton>
			)}
		</Card>
	);
}

export default hooked(MiscPage);
