import Roact from "@rbxts/roact";
import { useSelector, useDispatch } from "hooks/common/rodux-hooks";
import { setJobActive, setJobSlider } from "store/actions/jobs.action";
import { JobWithSliders } from "store/models/jobs.model";

// This interface tells TypeScript exactly what "props" this component takes
interface FacebangProps {
	isVisible: boolean;
	onClose: () => void;
}

export default function FacebangModal({ isVisible, onClose }: FacebangProps) {
	const job = useSelector((state) => state.jobs.facebang) as JobWithSliders;
	const dispatch = useDispatch();

	// If the UI isn't supposed to be visible, return nothing
	if (!isVisible) return <></>;

	const renderSlider = (label: string, value: string, percent: number, onUpdate: (val: number) => void) => {
		return (
			<frame Key={label} Size={new UDim2(1, -40, 0, 60)} BackgroundTransparency={1}>
				<textlabel
					Text={label}
					Size={new UDim2(0, 100, 0, 20)}
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
					Position={new UDim2(0, 0, 0, 25)}
					BackgroundColor3={Color3.fromRGB(20, 20, 20)}
					Event={{
						MouseButton1Click: (rbx) => {
							const mouse = game.GetService("Players").LocalPlayer.GetMouse();
							const relativeX = mouse.X - rbx.AbsolutePosition.X;
							const newPercent = math.clamp(relativeX / rbx.AbsoluteSize.X, 0, 1);
							onUpdate(newPercent);
						},
					}}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
					<frame
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

			{/* Use onClose to handle the exit button if you add one later */}
			<textbutton
				Text="X"
				Size={new UDim2(0, 30, 0, 30)}
				Position={new UDim2(1, -40, 0, 10)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				Font={Enum.Font.GothamBold}
				TextSize={18}
				Event={{ MouseButton1Click: onClose }}
			/>

			<textlabel
				Text={job.active ? "• Active" : "• Idle"}
				Size={new UDim2(0, 100, 0, 50)}
				Position={new UDim2(1, -120, 0, 5)}
				BackgroundTransparency={1}
				TextColor3={job.active ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(150, 150, 150)}
				Font={Enum.Font.Gotham} // Fixed GothamMedium error here
				TextSize={14}
				TextXAlignment="Right"
			/>

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

			<frame Size={new UDim2(1, 0, 0, 300)} Position={new UDim2(0, 20, 0, 130)} BackgroundTransparency={1}>
				<uilistlayout Padding={new UDim(0, 15)} />
				{renderSlider(
					"Distance", 
					`${math.round(job.sliders.distance * 10) / 10} studs`, 
					job.sliders.distance / 15, 
					(p) => dispatch(setJobSlider("facebang", "distance", p * 15))
				)}
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
