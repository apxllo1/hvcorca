import Roact from "@rbxts/roact";
import { hooked } from "@rbxts/roact-hooked";
import ActionButton from "components/ActionButton";
import { useTheme } from "hooks/use-theme";

function MiscPage() {
	const theme = useTheme("home").profile;

	return (
		<scrollingframe
			Size={new UDim2(1, -40, 1, -40)}
			Position={new UDim2(0, 20, 0, 20)}
			BackgroundTransparency={1}
			BorderSizePixel={0}
			ScrollBarThickness={2}
		>
			<uilistlayout Padding={new UDim(0, 10)} SortOrder="LayoutOrder" />
			
			<ActionButton 
				action="facebang" 
				theme={theme} 
				hint="Facebang the selected player"
				image="rbxassetid://10734950309"
				position={new UDim2(0, 0, 0, 0)}
				canDeactivate 
			/>
		</scrollingframe>
	);
}

export default hooked(MiscPage);
