import Roact from "@rbxts/roact";
import { useSelector, useDispatch } from "hooks/common/rodux-hooks";
import { setJobActive, setJobSlider } from "store/actions/jobs.action";
import { JobWithSliders } from "store/models/jobs.model";

export default function FacebangModal() {
	const job = useSelector((state) => state.jobs.facebang) as JobWithSliders;
	const dispatch = useDispatch();

	// Helper to create the specific slider style from your reference
	const renderSlider = (label: string, value: string, percent: number, onUpdate: (val: number) => void) => {
		return (
			<frame Key={label} Size={new UDim2(1, -40, 0, 60)} BackgroundTransparency={1}>
				<textlabel
					Text={label}
					Size={new UDim2(0, 100, 0, 20)}
					Position={new UDim2(0, 0, 0, 0)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(255, 255, 255)}
					Font={Enum.Font.GothamBold}
					TextSize={14}
					TextXAlignment="Left"
				/>
				<textlabel
					Text={value}
					Size={new UDim2(0, 100, 0, 20)}
					Position={new UDim2(1, -100, 0, 0)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(235, 76, 105)}
					Font={Enum.Font.GothamBold}
					TextSize={14}
					TextXAlignment="Right"
				/>
				<textbutton
					Text=""
					Size={new UDim2(1, 0, 0, 35)}
					Position={new UDim2(0, 0, 0, 20)}
					BackgroundColor3={Color3.fromRGB(20, 20, 20)}
					Event={{
						MouseButton1Click: (rbx) => {
							// Simple calculation for the slider click
							const mouse = game.GetService("Players").LocalPlayer.GetMouse();
							const relativeX = mouse.X - rbx.AbsolutePosition.X;
							const newPercent = math.clamp(relativeX / rbx.AbsoluteSize.X, 0, 1);
							onUpdate(newPercent);
						},
					}}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
					<frame
						Key="SliderFill"
						Size={new UDim2(percent, 0, 1, 0)}
						BackgroundColor3={Color3.fromRGB(235, 76, 105)}
						BorderSizePixel={0}
					>
						<uicorner CornerRadius={new UDim(0, 8)} />
					</frame>
				</textbutton>
			</frame>
		);
	};

	return (
		<frame
			Key="Main"
			Size={new UDim2(0, 350, 0, 550)}
			Position={new UDim2(0.5, -175, 0.5, -275)}
			BackgroundColor3={Color3.fromRGB(10, 10, 10)}
			BorderSizePixel={0}
			Active={true}
		>
			<uicorner CornerRadius={new UDim(0, 15)} />

			{/* Title Section */}
			<textlabel
				Text="Facebang"
				Size={new UDim2(0, 200, 0, 50)}
				Position={new UDim2(0, 20, 0, 5)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				Font={Enum.Font.GothamBold}
				TextSize={22}
				TextXAlignment="Left"
			/>

			{/* Status Label */}
			<textlabel
				Text={job.active ? "• Active" : "• Idle"}
				Size={new UDim2(0, 100, 0, 50)}
				Position={new UDim2(1, -120, 0, 5)}
				BackgroundTransparency={1}
				TextColor3={job.active ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(150, 150, 150)}
				Font={Enum.Font.GothamMedium}
				TextSize={14}
				TextXAlignment="Right"
			/>

			{/* Main Toggle Button */}
			<textbutton
				Text={job.active ? "Stop Facebang" : "Start Facebang"}
				Size={new UDim2(1, -40, 0, 50)}
				Position={new UDim2(0, 20, 0, 60)}
				BackgroundColor3={Color3.fromRGB(235, 76, 105)}
				Font={Enum.Font.GothamBold}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				TextSize={16}
				Event={{
					MouseButton1Click: () => dispatch(setJobActive("facebang", !job.active)),
				}}
			>
				<uicorner CornerRadius={new UDim(0, 8)} />
			</textbutton>

			{/* Decorative Tabs (Matching your ref style) */}
			<frame Size={new UDim2(1, -40, 0, 35)} Position={new UDim2(0, 20, 0, 120)} BackgroundTransparency={1}>
				<uilistlayout FillDirection="Horizontal" Padding={new UDim(0, 8)} />
				{["Settings", "Targets", "Presets"].map((name, i) => (
					<textbutton
						Text={name}
						Size={new UDim2(0.33, -5, 1, 0)}
						BackgroundColor3={i === 0 ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(25, 25, 25)}
						TextColor3={Color3.fromRGB(255, 255, 255)}
						Font={Enum.Font.GothamBold}
						TextSize={12}
					>
						<uicorner CornerRadius={new UDim(0, 6)} />
					</textbutton>
				))}
			</frame>

			{/* Slider Section Container */}
			<frame Size={new UDim2(1, 0, 0, 300)} Position={new UDim2(0, 20, 0, 170)} BackgroundTransparency={1}>
				<uilistlayout Padding={new UDim(0, 15)} />
				
				{/* Distance Slider */}
				{renderSlider(
					"Distance", 
					`${math.round(job.sliders.distance * 10) / 10} studs`, 
					job.sliders.distance / 15, // Percent based on max 15
					(p) => dispatch(setJobSlider("facebang", "distance", p * 15))
				)}

				{/* Angle Slider */}
				{renderSlider(
					"Angle Offset", 
					`${math.round(job.sliders.angle)}°`, 
					job.sliders.angle / 360, 
					(p) => dispatch(setJobSlider("facebang", "angle", p * 360))
				)}
			</frame>
		</frame>
	);
}
