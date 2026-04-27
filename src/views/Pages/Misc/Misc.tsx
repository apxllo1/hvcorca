import Roact from "@rbxts/roact";
import { hooked, useState } from "@rbxts/roact-hooked";
import { useTheme } from "hooks/use-theme";
import FacebangModal from "./FacebangModal";

function MiscPage() {
	const theme = useTheme("home").profile;
	const [modalVisible, setModalVisible] = useState(false);

	return (
		<frame Size={new UDim2(1, 0, 1, 0)} BackgroundTransparency={1}>
			<uipadding PaddingTop={new UDim(0, 20)} PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 20)} />
			<scrollingframe Size={new UDim2(1, 0, 1, 0)} BackgroundTransparency={1} ScrollBarThickness={2}>
				<uilistlayout Padding={new UDim(0, 10)} SortOrder="LayoutOrder" />
				<textbutton
					Text="Facebang Settings"
					Size={new UDim2(1, 0, 0, 50)}
					BackgroundColor3={theme.button.background}
					TextColor3={theme.button.foreground}
					Font={Enum.Font.GothamBold}
					TextSize={16}
					Event={{ Activated: () => setModalVisible(true) }}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
				</textbutton>
			</scrollingframe>

			<FacebangModal isVisible={modalVisible} onClose={() => setModalVisible(false)} />
		</frame>
	);
}

export default hooked(MiscPage);
