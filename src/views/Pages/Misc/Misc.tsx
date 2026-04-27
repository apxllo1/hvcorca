import Roact from "@rbxts/roact";
import { hooked } from "@rbxts/roact-hooked";
import ActionButton from "components/ActionButton";
import { useTheme } from "hooks/use-theme";

function MiscPage() {
	const theme = useTheme("home").profile;

	return (
		<frame
			Size={new UDim2(1, -40, 1, -40)}
			Position={new UDim2(0, 20, 0, 20)}
			BackgroundTransparency={1}
		>
			<ActionButton 
				action="facebang" 
				theme={theme} 
				hint="Teleport to and 'facebang' the selected target"
				image="rbxassetid://10734950309" // A decent default icon
				position={new UDim2(0, 0, 0, 0)}
				canDeactivate 
			/>
		</frame>
	);
}

export default hooked(MiscPage);
