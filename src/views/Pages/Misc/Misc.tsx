import Roact from "@rbxts/roact";
import { hooked, useState } from "@rbxts/roact-hooked";
import ActionButton from "components/ActionButton";
import { useTheme } from "hooks/use-theme";
import { JobsState } from "store/models/jobs.model";

function MiscPage() {
	const theme = useTheme("home").profile;
	const [searchText, setSearchText] = useState("");

	const commands = [
		{ 
			name: "Facebang", 
			action: "facebang", 
			hint: "Teleport to target's face", 
			icon: "rbxassetid://10734950309" 
		},
	];

	return (
		<frame Size={new UDim2(1, 0, 1, 0)} BackgroundTransparency={1}>
			<uipadding PaddingTop={new UDim(0, 20)} PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 20)} />
			<uilistlayout Padding={new UDim(0, 15)} SortOrder="LayoutOrder" HorizontalAlignment="Center" />

			{/* Search Bar */}
			<textbox
				Size={new UDim2(1, 0, 0, 40)}
				BackgroundColor3={theme.button.background}
				BackgroundTransparency={0.5}
				Text={searchText}
				PlaceholderText="Search commands..."
				PlaceholderColor3={Color3.fromRGB(200, 200, 200)}
				TextColor3={theme.button.foreground}
				Font={Enum.Font.Gotham}
				TextSize={14}
				Change={{
					Text: (rbx) => setSearchText(rbx.Text),
				}}
			>
				<uicorner CornerRadius={new UDim(0, 8)} />
				<uistroke Color={theme.button.background} Thickness={1} Transparency={0.8} />
			</textbox>

			{/* Scrolling List */}
			<scrollingframe
				Size={new UDim2(1, 0, 1, -60)}
				BackgroundTransparency={1}
				BorderSizePixel={0}
				ScrollBarThickness={0}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				AutomaticCanvasSize="Y"
			>
				<uilistlayout Padding={new UDim(0, 10)} SortOrder="LayoutOrder" />

				{commands
					.filter((cmd) => cmd.name.lower().find(searchText.lower()) !== undefined)
					.map((cmd) => (
						<frame
							Key={cmd.name}
							Size={new UDim2(1, 0, 0, 60)}
							BackgroundColor3={theme.button.background}
							BackgroundTransparency={0.7}
						>
							<uicorner CornerRadius={new UDim(0, 8)} />
							<uipadding PaddingLeft={new UDim(0, 10)} PaddingRight={new UDim(0, 10)} />
							<uilistlayout FillDirection="Horizontal" VerticalAlignment="Center" Padding={new UDim(0, 15)} />

							<ActionButton
								action={cmd.action as keyof JobsState}
								theme={theme}
								hint={cmd.hint}
								image={cmd.icon}
								position={new UDim2()}
								canDeactivate
							/>

							<textlabel
								Text={cmd.name.upper()}
								Size={new UDim2(0, 150, 1, 0)}
								BackgroundTransparency={1}
								TextColor3={theme.button.foreground}
								Font={Enum.Font.GothamBold}
								TextSize={14}
								TextXAlignment="Left"
							/>
						</frame>
					))}
			</scrollingframe>
		</frame>
	);
}

export default hooked(MiscPage);
