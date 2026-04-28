import Roact from "@rbxts/roact";
import { useSelector, useDispatch } from "hooks/common/rodux-hooks";
import { setJobActive, setJobSlider } from "store/actions/jobs.action";
import { JobWithSliders } from "store/models/jobs.model";

interface FacebangProps {
	isVisible: boolean;
	onClose: () => void;
}

export function FacebangModal({ isVisible, onClose }: FacebangProps) {
	// Safety check: if Rodux isn't ready, this prevents the 'undefined' crash
	const job = useSelector((state) => state.jobs?.facebang) as JobWithSliders | undefined;
	const dispatch = useDispatch();

	if (!isVisible || !job) {
		return Roact.createElement("Frame", { Visible: false, Key: "Hidden" });
	}

	const renderSlider = (label: string, value: string, percent: number, onUpdate: (val: number) => void) => {
		return (
			<frame Key={label} Size={new UDim2(1, -40, 0, 65)} BackgroundTransparency={1}>
				<textlabel
					Text={label.upper()}
					Size={new UDim2(0, 100, 0, 20)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(180, 180, 180)}
					Font={Enum.Font.GothamBold}
					TextSize={11}
					TextXAlignment="Left"
				/>
				<textlabel
					Text={value}
					Size={new UDim2(0, 100, 0, 20)}
					Position={new UDim2(1, -100, 0, 0)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(235, 76, 105)}
					Font={Enum.Font.GothamBold}
					TextSize={13}
					TextXAlignment="Right"
				/>
				<textbutton
					Text=""
					Size={new UDim2(1, 0, 0, 32)}
					Position={new UDim2(0, 0, 0, 24)}
					BackgroundColor3={Color3.fromRGB(15, 15, 15)}
					AutoButtonColor={false}
					Event={{
						MouseButton1Click: (rbx) => {
							const mouse = game.GetService("Players").LocalPlayer.GetMouse();
							const relativeX = mouse.X - rbx.AbsolutePosition.X;
							const newPercent = math.clamp(relativeX / rbx.AbsoluteSize.X, 0, 1);
							onUpdate(newPercent);
						},
					}}
				>
					<uicorner CornerRadius={new UDim(0, 6)} />
					<uistroke Color={Color3.fromRGB(35, 35, 35)} Thickness={1} />

					{/* Background fill */}
					<frame
						Size={new UDim2(percent, 0, 1, 0)}
						BackgroundColor3={Color3.fromRGB(235, 76, 105)}
						BorderSizePixel={0}
					>
						<uicorner CornerRadius={new UDim(0, 6)} />

						{/* Professional Knob Handle */}
						<frame
							Size={new UDim2(0, 6, 0, 20)}
							Position={new UDim2(1, -3, 0.5, -10)}
							BackgroundColor3={Color3.fromRGB(255, 255, 255)}
							BorderSizePixel={0}
						>
							<uicorner CornerRadius={new UDim(1, 0)} />
							<uistroke Color={Color3.fromRGB(0, 0, 0)} Thickness={1} Transparency={0.5} />
						</frame>
					</frame>
				</textbutton>
			</frame>
		);
	};

	return (
		<frame
			Key="Main"
			Size={new UDim2(0, 360, 0, 480)}
			Position={new UDim2(0.5, -180, 0.5, -240)}
			BackgroundColor3={Color3.fromRGB(12, 12, 12)}
			BorderSizePixel={0}
			Active={true}
		>
			<uicorner CornerRadius={new UDim(0, 14)} />
			<uistroke Color={Color3.fromRGB(40, 40, 40)} Thickness={1.5} />

			{/* Title Section */}
			<textlabel
				Text="FACEBANG CONFIG"
				Size={new UDim2(1, -40, 0, 60)}
				Position={new UDim2(0, 20, 0, 0)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				Font={Enum.Font.GothamBold}
				TextSize={16}
				TextXAlignment="Left"
			/>

			<frame
				Size={new UDim2(1, -40, 0, 1)}
				Position={new UDim2(0, 20, 0, 55)}
				BackgroundColor3={Color3.fromRGB(235, 76, 105)}
				BackgroundTransparency={0.5}
				BorderSizePixel={0}
			/>

			<textbutton
				Text="✕"
				Size={new UDim2(0, 30, 0, 30)}
				Position={new UDim2(1, -45, 0, 15)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(150, 150, 150)}
				Font={Enum.Font.GothamBold}
				TextSize={16}
				Event={{ MouseButton1Click: onClose }}
			/>

			{/* Status & Toggle */}
			<frame Size={new UDim2(1, -40, 0, 80)} Position={new UDim2(0, 20, 0, 75)} BackgroundTransparency={1}>
				<textlabel
					Text={job.active ? "STATUS: ACTIVE" : "STATUS: STANDBY"}
					Size={new UDim2(1, 0, 0, 20)}
					BackgroundTransparency={1}
					TextColor3={job.active ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(100, 100, 100)}
					Font={Enum.Font.GothamBold}
					TextSize={10}
					TextXAlignment="Left"
				/>
				<textbutton
					Text={job.active ? "STOP EXECUTION" : "START MODULE"}
					Size={new UDim2(1, 0, 0, 45)}
					Position={new UDim2(0, 0, 0, 25)}
					BackgroundColor3={job.active ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(25, 25, 25)}
					Font={Enum.Font.GothamBold}
					TextColor3={Color3.fromRGB(255, 255, 255)}
					TextSize={13}
					Event={{
						MouseButton1Click: () => dispatch(setJobActive("facebang", !job.active)),
					}}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
				</textbutton>
			</frame>

			{/* Sliders Container */}
			<frame Size={new UDim2(1, 0, 0, 280)} Position={new UDim2(0, 20, 0, 175)} BackgroundTransparency={1}>
				<uilistlayout Padding={new UDim(0, 15)} SortOrder={Enum.SortOrder.LayoutOrder} />
				{renderSlider(
					"Interaction Distance",
					`${math.round(job.sliders.distance * 10) / 10} studs`,
					job.sliders.distance / 15,
					(p) => dispatch(setJobSlider("facebang", "distance", p * 15)),
				)}
				{renderSlider("Rotation Angle", `${math.round(job.sliders.angle)}°`, job.sliders.angle / 360, (p) =>
					dispatch(setJobSlider("facebang", "angle", p * 360)),
				)}
			</frame>
		</frame>
	);
}

export default FacebangModal;
