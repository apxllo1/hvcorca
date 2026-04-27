import Roact from "@rbxts/roact";
import { hooked, useState } from "@rbxts/roact-hooked";
import { useDispatch, useSelector } from "hooks/common/rodux-hooks";
import { setJobActive } from "store/actions/jobs.action";
import { JobsState } from "store/models/jobs.model";

interface Props {
	isVisible: boolean;
	onClose: () => void;
}

const FacebangModal = hooked((props: Props) => {
	const dispatch = useDispatch();
	const isEnabled = useSelector((state: { jobs: JobsState }) => state.jobs.facebang.active);

	if (!props.isVisible) return <frame Visible={false} />;

	return (
		<frame
			Key="FacebangPopOut"
			Size={new UDim2(0.4, 0, 0.6, 0)}
			Position={new UDim2(0.5, 0, 0.5, 0)}
			AnchorPoint={new Vector2(0.5, 0.5)}
			BackgroundColor3={Color3.fromRGB(10, 10, 10)}
			ZIndex={10}
		>
			<uicorner CornerRadius={new UDim(0, 15)} />
			<uiaspectratioconstraint AspectRatio={350 / 550} AspectType="ScaleWithParentSize" />
			<uisizeconstraint MaxSize={new Vector2(400, 600)} MinSize={new Vector2(280, 450)} />

			<uipadding PaddingTop={new UDim(0.05, 0)} PaddingLeft={new UDim(0.05, 0)} PaddingRight={new UDim(0.05, 0)} />

			<textlabel
				Text="Facebang"
				Size={new UDim2(0.6, 0, 0.08, 0)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				Font={Enum.Font.GothamBold}
				TextSize={22}
				TextXAlignment="Left"
			/>

			{/* Status Label */}
			<textlabel
				Text={isEnabled ? "• Active" : "• Idle"}
				Size={new UDim2(0.3, 0, 0.08, 0)}
				Position={new UDim2(1, 0, 0, 0)}
				AnchorPoint={new Vector2(1, 0)}
				BackgroundTransparency={1}
				TextColor3={isEnabled ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(150, 150, 150)}
				Font={Enum.Font.GothamMedium}
				TextSize={14}
				TextXAlignment="Right"
			/>

			{/* Start Button */}
			<textbutton
				Text={isEnabled ? "STOP" : "START"}
				Size={new UDim2(1, 0, 0.12, 0)}
				Position={new UDim2(0, 0, 0.12, 0)}
				BackgroundColor3={isEnabled ? Color3.fromRGB(40, 40, 40) : Color3.fromRGB(235, 76, 105)}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				Font={Enum.Font.GothamBold}
				TextSize={18}
				Event={{ Activated: () => dispatch(setJobActive("facebang", !isEnabled)) }}
			>
				<uicorner CornerRadius={new UDim(0, 8)} />
			</textbutton>

			{/* Close Button at the bottom */}
			<textbutton
				Text="CLOSE"
				Size={new UDim2(1, 0, 0.08, 0)}
				Position={new UDim2(0, 0, 1, 0)}
				AnchorPoint={new Vector2(0, 1)}
				BackgroundColor3={Color3.fromRGB(25, 25, 25)}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				Font={Enum.Font.GothamBold}
				TextSize={14}
				Event={{ Activated: props.onClose }}
			>
				<uicorner CornerRadius={new UDim(0, 8)} />
			</textbutton>
		</frame>
	);
});

export default FacebangModal;
