import Roact from "@rbxts/roact";
import { hooked } from "@rbxts/roact-hooked";
import { Players } from "@rbxts/services";
import { useAppDispatch, useAppSelector } from "hooks/common/rodux-hooks";
import { setJobActive, setJobSlider } from "store/actions/jobs.action";
import { RootState } from "store/store";
import { JobWithSliders } from "store/models/jobs.model";
import BrightSlider from "components/BrightSlider"; 

interface Props {
	isVisible: boolean;
	onClose: () => void;
}

const FacebangModal = hooked((props: Props) => {
	const dispatch = useAppDispatch();
	
	const localPlayer = Players.LocalPlayer;
	const avatarUrl = `https://www.roblox.com/headshot-thumbnail/image?userId=${localPlayer.UserId}&width=420&height=420&format=png`;

	const job = useAppSelector((state: RootState) => {
		const facebang = state.jobs.facebang as unknown;
		return facebang as JobWithSliders;
	});

	if (!props.isVisible) return <frame Visible={false} />;

	return (
		<frame
			Key="FacebangContainer"
			Size={new UDim2(0, 320, 0, 300)}
			Position={new UDim2(0.5, 0, 0.5, 0)}
			AnchorPoint={new Vector2(0.5, 0.5)}
			BackgroundColor3={Color3.fromRGB(12, 12, 12)}
			BorderSizePixel={0}
		>
			<uicorner CornerRadius={new UDim(0, 12)} />
			<uistroke Color={Color3.fromRGB(35, 35, 35)} Thickness={1} />
			
			<frame
				Size={new UDim2(1, 0, 0, 3)}
				BackgroundColor3={Color3.fromRGB(235, 76, 105)}
				BorderSizePixel={0}
			>
				<uicorner CornerRadius={new UDim(0, 12)} />
				<frame Size={new UDim2(1, 0, 0.5, 0)} Position={new UDim2(0, 0, 0.5, 0)} BackgroundColor3={Color3.fromRGB(235, 76, 105)} BorderSizePixel={0} />
			</frame>

			<uipadding PaddingTop={new UDim(0, 25)} PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 20)} PaddingBottom={new UDim(0, 20)} />
			<uilistlayout Padding={new UDim(0, 18)} SortOrder="LayoutOrder" />

			<frame Size={new UDim2(1, 0, 0, 50)} BackgroundTransparency={1} LayoutOrder={1}>
				<imagelabel
					Key="AvatarCircle"
					Image={avatarUrl}
					Size={new UDim2(0, 50, 0, 50)}
					BackgroundColor3={Color3.fromRGB(25, 25, 25)}
				>
					<uicorner CornerRadius={new UDim(1, 0)} />
					<uistroke Color={Color3.fromRGB(235, 76, 105)} Thickness={2} />
				</imagelabel>

				<textlabel
					Text="Facebang"
					Position={new UDim2(0, 60, 0, 5)}
					Size={new UDim2(1, -65, 0, 20)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(255, 255, 255)}
					Font={Enum.Font.GothamBold}
					TextSize={18}
					TextXAlignment="Left"
				/>
				
				<textlabel
					Text="Active Target: LocalUser"
					Position={new UDim2(0, 60, 0, 25)}
					Size={new UDim2(1, -65, 0, 15)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(150, 150, 150)}
					Font={Enum.Font.Gotham} // FIXED: Changed from GothamMedium
					TextSize={12}
					TextXAlignment="Left"
				/>
			</frame>

			<textbutton
				Key="StateToggle"
				LayoutOrder={2}
				Text={job.active ? "STOP MODULE" : "START MODULE"}
				Size={new UDim2(1, 0, 0, 35)}
				BackgroundColor3={job.active ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(30, 30, 30)}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				Font={Enum.Font.GothamBold}
				TextSize={13}
				Event={{ Activated: () => dispatch(setJobActive("facebang", !job.active)) }}
			>
				<uicorner CornerRadius={new UDim(0, 6)} />
			</textbutton>

			<frame Size={new UDim2(1, 0, 0, 100)} BackgroundTransparency={1} LayoutOrder={3}>
				<uilistlayout Padding={new UDim(0, 12)} />
				
				<frame Size={new UDim2(1, 0, 0, 40)} BackgroundTransparency={1}>
					<textlabel Text="Angle Offset" Size={new UDim2(0.5, 0, 0, 15)} BackgroundTransparency={1} TextColor3={Color3.fromRGB(200, 200, 200)} Font={Enum.Font.Gotham} TextSize={12} TextXAlignment="Left" />
					<textlabel Text={`${math.round(job.sliders.angle)}°`} Size={new UDim2(0.5, 0, 0, 15)} Position={new UDim2(1, 0, 0, 0)} AnchorPoint={new Vector2(1, 0)} BackgroundTransparency={1} TextColor3={Color3.fromRGB(235, 76, 105)} Font={Enum.Font.GothamBold} TextSize={12} TextXAlignment="Right" />
					<BrightSlider
						size={new UDim2(1, 0, 0, 20)}
						position={new UDim2(0, 0, 1, 0)}
						// FIXED: Removed AnchorPoint because BrightSlider doesn't support it
						min={0} max={360} initialValue={job.sliders.angle}
						onRelease={(v) => dispatch(setJobSlider("facebang", "angle", v))}
						accentColor={Color3.fromRGB(235, 76, 105)}
					/>
				</frame>

				<frame Size={new UDim2(1, 0, 0, 40)} BackgroundTransparency={1}>
					<textlabel Text="Distance" Size={new UDim2(0.5, 0, 0, 15)} BackgroundTransparency={1} TextColor3={Color3.fromRGB(200, 200, 200)} Font={Enum.Font.Gotham} TextSize={12} TextXAlignment="Left" />
					<textlabel Text={`${math.round(job.sliders.distance * 10) / 10}s`} Size={new UDim2(0.5, 0, 0, 15)} Position={new UDim2(1, 0, 0, 0)} AnchorPoint={new Vector2(1, 0)} BackgroundTransparency={1} TextColor3={Color3.fromRGB(235, 76, 105)} Font={Enum.Font.GothamBold} TextSize={12} TextXAlignment="Right" />
					<BrightSlider
						size={new UDim2(1, 0, 0, 20)}
						position={new UDim2(0, 0, 1, 0)}
						// FIXED: Removed AnchorPoint
						min={1} max={15} initialValue={job.sliders.distance}
						onRelease={(v) => dispatch(setJobSlider("facebang", "distance", v))}
						accentColor={Color3.fromRGB(235, 76, 105)}
					/>
				</frame>
			</frame>

			<textbutton
				Text="CLOSE SETTINGS"
				Size={new UDim2(1, 0, 0, 30)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(100, 100, 100)}
				Font={Enum.Font.GothamBold}
				TextSize={11}
				LayoutOrder={4}
				Event={{ Activated: props.onClose }}
			/>
		</frame>
	);
});

export default FacebangModal;
