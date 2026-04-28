import Roact from "@rbxts/roact";
import { hooked, useCallback } from "@rbxts/roact-hooked";
import { useSelector, useDispatch } from "hooks/common/rodux-hooks";
import { setJobActive, setJobSlider } from "store/actions/jobs.action";
import { JobWithSliders } from "store/models/jobs.model";
import { RunService, UserInputService, Players } from "@rbxts/services";

interface FacebangProps {
	isVisible: boolean;
	onClose: () => void;
}

interface SliderProps {
	label: string;
	displayValue: string;
	percent: number;
	onUpdate: (value: number) => void;
}

// Extracted as a named hooked component so Roact can diff it properly
const Slider = hooked(({ label, displayValue, percent, onUpdate }: SliderProps) => {
	return (
		<frame Key={label} Size={new UDim2(1, -40, 0, 65)} BackgroundTransparency={1} LayoutOrder={0}>
			{/* Label */}
			<textlabel
				Key="SliderLabel"
				Text={label.upper()}
				Size={new UDim2(0, 160, 0, 20)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(180, 180, 180)}
				Font={Enum.Font.GothamBold}
				TextSize={12}
				TextXAlignment={Enum.TextXAlignment.Left}
			/>

			{/* Current value display */}
			<textlabel
				Key="SliderValue"
				Text={displayValue}
				Size={new UDim2(0, 100, 0, 20)}
				Position={new UDim2(1, -100, 0, 0)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(235, 76, 105)}
				Font={Enum.Font.GothamBold}
				TextSize={13}
				TextXAlignment={Enum.TextXAlignment.Right}
			/>

			{/* Draggable track */}
			<textbutton
				Key="SliderTrack"
				Text=""
				Size={new UDim2(1, 0, 0, 32)}
				Position={new UDim2(0, 0, 0, 24)}
				BackgroundColor3={Color3.fromRGB(15, 15, 15)}
				AutoButtonColor={false}
				Event={{
					MouseButton1Down: (rbx) => {
						const mouse = Players.LocalPlayer.GetMouse();

						const moveConn = RunService.RenderStepped.Connect(() => {
							const relativeX = mouse.X - rbx.AbsolutePosition.X;
							const newPercent = math.clamp(relativeX / rbx.AbsoluteSize.X, 0, 1);
							onUpdate(newPercent);
						});

						const releaseConn = UserInputService.InputEnded.Connect((input) => {
							if (input.UserInputType === Enum.UserInputType.MouseButton1) {
								moveConn.Disconnect();
								releaseConn.Disconnect();
							}
						});
					},
				}}
			>
				<uicorner CornerRadius={new UDim(0, 6)} />
				<uistroke Color={Color3.fromRGB(30, 30, 30)} Thickness={1} />

				{/* Fill bar */}
				<frame
					Key="Fill"
					Size={new UDim2(percent, 0, 1, 0)}
					BackgroundColor3={Color3.fromRGB(235, 76, 105)}
					BorderSizePixel={0}
				>
					<uicorner CornerRadius={new UDim(0, 6)} />

					{/* Thumb handle */}
					<frame
						Key="Thumb"
						Size={new UDim2(0, 4, 0, 16)}
						Position={new UDim2(1, -2, 0.5, -8)}
						BackgroundColor3={Color3.fromRGB(255, 255, 255)}
						BorderSizePixel={0}
					>
						<uicorner CornerRadius={new UDim(1, 0)} />
					</frame>
				</frame>
			</textbutton>
		</frame>
	);
});

const FacebangModal = hooked(({ isVisible, onClose }: FacebangProps) => {
	const job = useSelector((state) => state.jobs.facebang) as JobWithSliders | undefined;
	const dispatch = useDispatch();

	const handleToggleActive = useCallback(() => {
		if (job) dispatch(setJobActive("facebang", !job.active));
	}, [job]);

	const handleDistanceUpdate = useCallback((p: number) => dispatch(setJobSlider("facebang", "distance", p * 15)), []);

	const handleAngleUpdate = useCallback((p: number) => dispatch(setJobSlider("facebang", "angle", p * 360)), []);

	if (!isVisible || !job) return <></>;

	return (
		<frame
			Key="FacebangModal"
			Size={new UDim2(0, 350, 0, 420)}
			Position={new UDim2(0.5, -175, 0.5, -210)}
			BackgroundColor3={Color3.fromRGB(10, 10, 10)}
			BorderSizePixel={0}
			Active={true}
			ZIndex={11}
			Event={{
				// Swallow clicks so they don't bubble to the overlay and close the modal
				InputBegan: (_, input) => {
					if (
						input.UserInputType === Enum.UserInputType.MouseButton1 ||
						input.UserInputType === Enum.UserInputType.Touch
					) {
						// Intentional no-op: block propagation to overlay
					}
				},
			}}
		>
			<uicorner CornerRadius={new UDim(0, 12)} />
			<uistroke Color={Color3.fromRGB(35, 35, 35)} Thickness={1} />

			{/* Header */}
			<textlabel
				Key="Title"
				Text="FACEBANG CONFIG"
				Size={new UDim2(1, -60, 0, 60)}
				Position={new UDim2(0, 20, 0, 0)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				Font={Enum.Font.GothamBold}
				TextSize={18}
				TextXAlignment={Enum.TextXAlignment.Left}
			/>

			<textbutton
				Key="CloseButton"
				Text="✕"
				Size={new UDim2(0, 30, 0, 30)}
				Position={new UDim2(1, -40, 0, 15)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(150, 150, 150)}
				Font={Enum.Font.GothamBold}
				TextSize={16}
				Event={{ MouseButton1Click: onClose }}
			/>

			{/* Status + activate/terminate */}
			<frame
				Key="StatusSection"
				Size={new UDim2(1, -40, 0, 80)}
				Position={new UDim2(0, 20, 0, 75)}
				BackgroundTransparency={1}
			>
				<textlabel
					Key="StatusLabel"
					Text={job.active ? "STATUS: RUNNING" : "STATUS: READY"}
					Size={new UDim2(1, 0, 0, 20)}
					BackgroundTransparency={1}
					TextColor3={job.active ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(120, 120, 120)}
					Font={Enum.Font.GothamBold}
					TextSize={11}
					TextXAlignment={Enum.TextXAlignment.Left}
				/>

				<textbutton
					Key="ActivateButton"
					Text={job.active ? "TERMINATE" : "ACTIVATE"}
					Size={new UDim2(1, 0, 0, 45)}
					Position={new UDim2(0, 0, 0, 25)}
					BackgroundColor3={job.active ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(20, 20, 20)}
					Font={Enum.Font.GothamBold}
					TextColor3={Color3.fromRGB(255, 255, 255)}
					TextSize={14}
					AutoButtonColor={false}
					Event={{
						MouseButton1Click: handleToggleActive,
					}}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
				</textbutton>
			</frame>

			{/* Sliders */}
			<frame
				Key="SlidersSection"
				Size={new UDim2(1, -40, 0, 200)}
				Position={new UDim2(0, 20, 0, 175)}
				BackgroundTransparency={1}
			>
				<uilistlayout Padding={new UDim(0, 10)} SortOrder={Enum.SortOrder.LayoutOrder} />

				<Slider
					Key="DistanceSlider"
					label="Interaction Distance"
					displayValue={`${math.round(job.sliders.distance * 10) / 10} studs`}
					percent={job.sliders.distance / 15}
					onUpdate={handleDistanceUpdate}
				/>

				<Slider
					Key="AngleSlider"
					label="Rotation Angle"
					displayValue={`${math.round(job.sliders.angle)}°`}
					percent={job.sliders.angle / 360}
					onUpdate={handleAngleUpdate}
				/>
			</frame>
		</frame>
	);
});

export default FacebangModal;
