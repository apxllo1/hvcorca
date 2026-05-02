import Roact from "@rbxts/roact";

function VerySimpleApp() {
	return (
		<screengui ResetOnSpawn={false} ZIndexBehavior={Enum.ZIndexBehavior.Sibling}>
			<frame
				Size={new UDim2(0.3, 0, 0.3, 0)}
				Position={new UDim2(0.5, 0, 0.5, 0)}
				AnchorPoint={new Vector2(0.5, 0.5)}
				BackgroundColor3={new Color3(0.2, 0.2, 0.2)}
				BorderSizePixel={1}
			>
				<textlabel
					Text="Havoc UI is working"
					TextColor3={new Color3(1, 1, 1)}
					Font={Enum.Font.Gotham}
					TextSize={14}
					Size={new UDim2(1, 0, 1, 0)}
				/>
			</frame>
		</screengui>
	);
}

export default VerySimpleApp;
