import { RunService, Players } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";
import { JobWithSliders } from "store/models/jobs.model";

let connection: RBXScriptConnection | undefined;

onJobChange("facebang", (job, state) => {
	// 1. Clean up previous connection to prevent "Ghost" movement
	if (connection) {
		connection.Disconnect();
		connection = undefined;
	}

	const sliderJob = job as unknown as JobWithSliders;
	
	// Safety: Ensure job and sliders exist before proceeding
	if (!sliderJob || !sliderJob.active || !sliderJob.sliders) return;

	// 2. Identify the target from the state
	const targetName = state.dashboard.apps.playerSelected;
	const targetPlayer = targetName ? Players.FindFirstChild(targetName) : undefined;

	if (!targetPlayer || targetPlayer === Players.LocalPlayer) return;

	// 3. High-performance Heartbeat loop
	connection = RunService.Heartbeat.Connect(() => {
		const localChar = Players.LocalPlayer.Character;
		const targetChar = (targetPlayer as Player).Character;

		if (!localChar || !targetChar) return;

		const localRoot = localChar.FindFirstChild("HumanoidRootPart") as BasePart | undefined;
		const targetRoot = targetChar.FindFirstChild("HumanoidRootPart") as BasePart | undefined;
		const humanoid = localChar.FindFirstChildOfClass("Humanoid");

		// Guard against dying or missing parts
		if (localRoot && targetRoot && humanoid && humanoid.Health > 0) {
			const { angle, distance } = sliderJob.sliders;
			
			// MAXIMIZED CALCULATION:
			// We calculate the position behind the target and apply the custom rotation angle
			const offset = new CFrame(0, 0, distance); 
			const rotation = CFrame.Angles(0, math.rad(angle), 0);
			const goalCFrame = targetRoot.CFrame.ToWorldSpace(offset).mul(rotation);

			// Use a fast Lerp (0.5) for "snappy" but non-glitchy following
			localRoot.CFrame = localRoot.CFrame.Lerp(goalCFrame, 0.5);
		}
	});
});
