import Roact from "@rbxts/roact";
import Card from "components/Card";
import { useTheme } from "hooks/use-theme";
import { DashboardPage } from "store/models/dashboard.model";
import { px } from "utils/udim2";
import GistLoader from "./GistLoader";

function MiscPage() {
	const theme = useTheme("apps").players;

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

				<GistLoader />
			</scrollingframe>
		</Card>
	);
}

export default MiscPage;
