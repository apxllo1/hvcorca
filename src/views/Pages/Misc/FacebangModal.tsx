import Roact from "@rbxts/roact";
import { useSelector, useDispatch } from "hooks/common/rodux-hooks";
import { setJobActive, setJobSlider } from "store/actions/jobs.action";
import { JobWithSliders } from "store/models/jobs.model";

interface FacebangProps {
	isVisible: boolean;
	onClose: () => void;
}

export function FacebangModal({ isVisible, onClose }: FacebangProps) {
	const job = useSelector((state) => state.jobs.facebang) as JobWithSliders | undefined;
	const dispatch = useDispatch();

	// 1. Fixed the Overload error by removing 'Key' from the props table
	// 2. Added safety check for 'job'
	if (!isVisible || !job) {
		return Roact.createElement("Frame", {
			Visible: false,
		});
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
					TextSize={12}
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
					<uistroke Color={Color3.fromRGB(30, 30, 30)} Thickness={1} />
					<frame
						Size={new UDim2(percent, 0, 1, 0)}
						BackgroundColor3={Color3.fromRGB(235, 76, 105)}
						BorderSizePixel={0}
					>
						<uicorner CornerRadius={new UDim(0, 6)} />
						<frame
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
	};

	return (
		<frame
			Key="Main"
			Size={new UDim2(0, 350, 0, 500)}
			Position={new UDim2(0.5, -175, 0.5, -250)}
			BackgroundColor3={Color3.fromRGB(10, 10, 10)}
			BorderSizePixel={0}
			Active={true}
		>
			<uicorner CornerRadius={new UDim(0, 12)} />
			<uistroke Color={Color3.fromRGB(35, 35, 35)} Thickness={1} />

			<textlabel
				Text="FACEBANG CONFIG"
				Size={new UDim2(0, 200, 0, 60)}
				Position={new UDim2(0, 20, 0, 0)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(255, 255, 255)}
				Font={Enum.Font.GothamBold}
				TextSize={18}
				TextXAlignment="Left"
			/>

			<frame
				Size={new UDim2(1, -40, 0, 1)}
				Position={new UDim2(0, 20, 0, 55)}
				BackgroundColor3={Color3.fromRGB(235, 76, 105)}
				BackgroundTransparency={0.6}
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

			<frame Size={new UDim2(1, -40, 0, 80)} Position={new UDim2(0, 20, 0, 75)} BackgroundTransparency={1}>
				<textlabel
					Text={job.active ? "STATUS: RUNNING" : "STATUS: READY"}
					Size={new UDim2(1, 0, 0, 20)}
					BackgroundTransparency={1}
					TextColor3={job.active ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(120, 120, 120)}
					Font={Enum.Font.GothamBold}
					TextSize={11}
					TextXAlignment="Left"
				/>
				<textbutton
					Text={job.active ? "TERMINATE" : "ACTIVATE"}
					Size={new UDim2(1, 0, 0, 45)}
					Position={new UDim2(0, 0, 0, 25)}
					BackgroundColor3={job.active ? Color3.fromRGB(235, 76, 105) : Color3.fromRGB(20, 20, 20)}
					Font={Enum.Font.GothamBold}
					TextColor3={Color3.fromRGB(255, 255, 255)}
					TextSize={14}
					Event={{
						MouseButton1Click: () => dispatch(setJobActive("facebang", !job.active)),
					}}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
					<uistroke
						Color={job.active ? Color3.fromRGB(255, 255, 255) : Color3.fromRGB(40, 40, 40)}
						Transparency={0.8}
					/>
				</textbutton>
			</frame>

			<frame Size={new UDim2(1, 0, 0, 300)} Position={new UDim2(0, 20, 0, 175)} BackgroundTransparency={1}>
				<uilistlayout Padding={new UDim(0, 10)} SortOrder={Enum.SortOrder.LayoutOrder} />
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
