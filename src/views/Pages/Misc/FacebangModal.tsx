import Roact from "@rbxts/roact";
import { hooked, useCallback, useState } from "@rbxts/roact-hooked";
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

const GREEN = Color3.fromRGB(80, 220, 140);
const BG_DARK = Color3.fromRGB(10, 10, 10);
const BG_ROW = Color3.fromRGB(20, 20, 20);
const BG_TRACK = Color3.fromRGB(15, 15, 15);

const Slider = hooked(({ label, displayValue, percent, onUpdate }: SliderProps) => {
	return (
		<frame Key={label} Size={new UDim2(1, 0, 0, 70)} BackgroundTransparency={1}>
			<textlabel
				Key="Label"
				Text={label}
				Size={new UDim2(0.5, 0, 0, 20)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(200, 200, 200)}
				Font={Enum.Font.GothamBold}
				TextSize={13}
				TextXAlignment={Enum.TextXAlignment.Left}
			/>
			<textlabel
				Key="Value"
				Text={displayValue}
				Size={new UDim2(0.5, 0, 0, 20)}
				Position={new UDim2(0.5, 0, 0, 0)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(160, 160, 160)}
				Font={Enum.Font.Gotham}
				TextSize={12}
				TextXAlignment={Enum.TextXAlignment.Right}
			/>
			<textbutton
				Key="Track"
				Text=""
				Size={new UDim2(1, 0, 0, 36)}
				Position={new UDim2(0, 0, 0, 26)}
				BackgroundColor3={BG_TRACK}
				AutoButtonColor={false}
				Event={{
					MouseButton1Down: (rbx) => {
						const mouse = Players.LocalPlayer.GetMouse();
						const moveConn = RunService.RenderStepped.Connect(() => {
							const relX = mouse.X - rbx.AbsolutePosition.X;
							onUpdate(math.clamp(relX / rbx.AbsoluteSize.X, 0, 1));
						});
						const upConn = UserInputService.InputEnded.Connect((inp) => {
							if (inp.UserInputType === Enum.UserInputType.MouseButton1) {
								moveConn.Disconnect();
								upConn.Disconnect();
							}
						});
					},
				}}
			>
				<uicorner CornerRadius={new UDim(0, 8)} />
				<frame
					Key="Fill"
					Size={new UDim2(percent, 0, 1, 0)}
					BackgroundColor3={GREEN}
					BorderSizePixel={0}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
					<frame
						Key="Thumb"
						Size={new UDim2(0, 4, 0, 18)}
						Position={new UDim2(1, -2, 0.5, -9)}
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
	const sliders = job?.sliders as { angle: number; distance: number; speed: number } | undefined;
	const [keybind, setKeybind] = useState("Z");
	const [listeningForKey, setListeningForKey] = useState(false);

	const handleToggleActive = useCallback(() => {
		if (job) dispatch(setJobActive("facebang", !job.active));
	}, [job]);

	const handleSpeedUpdate = useCallback(
		(p: number) => dispatch(setJobSlider("facebang", "speed", p * 10)),
		[],
	);
	const handleDistanceUpdate = useCallback(
		(p: number) => dispatch(setJobSlider("facebang", "distance", p * 15)),
		[],
	);

	if (!isVisible || !job || !sliders) return <></>;

	return (
		<frame
			Key="FacebangModal"
			Size={new UDim2(0, 380, 0, 480)}
			Position={new UDim2(0.5, -190, 0.5, -240)}
			BackgroundColor3={BG_DARK}
			BorderSizePixel={0}
			Active={true}
			ZIndex={11}
			Event={{
				InputBegan: (_, input) => {
					if (
						input.UserInputType === Enum.UserInputType.MouseButton1 ||
						input.UserInputType === Enum.UserInputType.Touch
					) {
						// block propagation
					}
				},
			}}
		>
			<uicorner CornerRadius={new UDim(0, 14)} />
			<uistroke Color={Color3.fromRGB(30, 30, 30)} Thickness={1} />

			{/* Header row */}
			<frame
				Key="Header"
				Size={new UDim2(1, -40, 0, 55)}
				Position={new UDim2(0, 20, 0, 15)}
				BackgroundTransparency={1}
			>
				<textlabel
					Key="Title"
					Text="Facebang"
					Size={new UDim2(0, 140, 0, 30)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(255, 255, 255)}
					Font={Enum.Font.GothamBold}
					TextSize={22}
					TextXAlignment={Enum.TextXAlignment.Left}
				/>
				<textlabel
					Key="Subtitle"
					Text={job.active ? "Running" : "Press keybind to start"}
					Size={new UDim2(1, -150, 0, 30)}
					Position={new UDim2(0, 150, 0, 0)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(130, 130, 130)}
					Font={Enum.Font.Gotham}
					TextSize={13}
					TextXAlignment={Enum.TextXAlignment.Right}
				/>
				<textlabel
					Key="FooterNote"
					Text="Keybind activates on nearest player"
					Size={new UDim2(1, 0, 0, 18)}
					Position={new UDim2(0, 0, 0, 32)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(90, 90, 90)}
					Font={Enum.Font.Gotham}
					TextSize={11}
					TextXAlignment={Enum.TextXAlignment.Left}
				/>
			</frame>

			{/* Divider */}
			<frame
				Key="Divider"
				Size={new UDim2(1, -40, 0, 1)}
				Position={new UDim2(0, 20, 0, 78)}
				BackgroundColor3={Color3.fromRGB(30, 30, 30)}
				BorderSizePixel={0}
			/>

			{/* START button */}
			<textbutton
				Key="StartButton"
				Text={job.active ? "STOP" : "START"}
				Size={new UDim2(1, -40, 0, 52)}
				Position={new UDim2(0, 20, 0, 92)}
				BackgroundColor3={GREEN}
				Font={Enum.Font.GothamBold}
				TextColor3={Color3.fromRGB(10, 10, 10)}
				TextSize={16}
				AutoButtonColor={false}
				Event={{ MouseButton1Click: handleToggleActive }}
			>
				<uicorner CornerRadius={new UDim(0, 10)} />
			</textbutton>

			{/* Divider 2 */}
			<frame
				Key="Divider2"
				Size={new UDim2(1, -40, 0, 1)}
				Position={new UDim2(0, 20, 0, 158)}
				BackgroundColor3={Color3.fromRGB(30, 30, 30)}
				BorderSizePixel={0}
			/>

			{/* Keybind row */}
			<frame
				Key="KeybindRow"
				Size={new UDim2(1, -40, 0, 44)}
				Position={new UDim2(0, 20, 0, 170)}
				BackgroundTransparency={1}
			>
				<textlabel
					Key="KeybindLabel"
					Text="Keybind"
					Size={new UDim2(0.5, 0, 1, 0)}
					BackgroundTransparency={1}
					TextColor3={Color3.fromRGB(200, 200, 200)}
					Font={Enum.Font.GothamBold}
					TextSize={13}
					TextXAlignment={Enum.TextXAlignment.Left}
				/>
				<textbutton
					Key="KeybindBox"
					Text={listeningForKey ? "..." : keybind}
					Size={new UDim2(0, 90, 0, 34)}
					Position={new UDim2(1, -90, 0.5, -17)}
					BackgroundColor3={BG_ROW}
					TextColor3={Color3.fromRGB(220, 220, 220)}
					Font={Enum.Font.GothamBold}
					TextSize={14}
					AutoButtonColor={false}
					Event={{
						MouseButton1Click: () => {
							setListeningForKey(true);
							const conn = UserInputService.InputBegan.Connect((inp, gp) => {
								if (!gp && inp.UserInputType === Enum.UserInputType.Keyboard) {
									setKeybind(inp.KeyCode.Name ?? "Z");
									setListeningForKey(false);
									conn.Disconnect();
								}
							});
						},
					}}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
					<uistroke Color={Color3.fromRGB(40, 40, 40)} Thickness={1} />
				</textbutton>
			</frame>

			{/* Sliders */}
			<frame
				Key="Sliders"
				Size={new UDim2(1, -40, 0, 160)}
				Position={new UDim2(0, 20, 0, 225)}
				BackgroundTransparency={1}
			>
				<uilistlayout Padding={new UDim(0, 6)} SortOrder={Enum.SortOrder.LayoutOrder} />

				<Slider
					Key="SpeedSlider"
					label="Speed"
					displayValue={`${math.round((sliders.speed ?? 5) * 10) / 10}x`}
					percent={(sliders.speed ?? 5) / 10}
					onUpdate={handleSpeedUpdate}
				/>

				<Slider
					Key="DistanceSlider"
					label="Distance"
					displayValue={`${math.round(sliders.distance * 10) / 10} studs`}
					percent={sliders.distance / 15}
					onUpdate={handleDistanceUpdate}
				/>
			</frame>

			{/* Footer bottom */}
			<textlabel
				Key="FooterBottom"
				Text="Keybind activates on nearest player"
				Size={new UDim2(1, -40, 0, 20)}
				Position={new UDim2(0, 20, 1, -30)}
				BackgroundTransparency={1}
				TextColor3={Color3.fromRGB(80, 80, 80)}
				Font={Enum.Font.Gotham}
				TextSize={11}
				TextXAlignment={Enum.TextXAlignment.Left}
			/>
		</frame>
	);
});

export default FacebangModal;
