import { RunService, Players } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";
import { JobWithSliders } from "store/models/jobs.model";

let connection: RBXScriptConnection | undefined;

onJobChange("facebang", (job, state) => {
	// 1. Clean up previous connection
	if (connection) {
		connection.Disconnect();
		connection = undefined;
	}

	const sliderJob = job as unknown as JobWithSliders;

	// 2. Safety check: If job is null or disabled, stop here
	if (!sliderJob || !sliderJob.active || !sliderJob.sliders) return;

	// 3. Identify the target
	const targetName = state.dashboard.apps.playerSelected;
	const targetPlayer = targetName !== undefined ? (Players.FindFirstChild(targetName) as Player) : undefined;

	if (!targetPlayer || targetPlayer === Players.LocalPlayer) return;

	// 4. Start the loop
	connection = RunService.Heartbeat.Connect(() => {
		const localChar = Players.LocalPlayer.Character;
		const targetChar = targetPlayer.Character;

		if (!localChar || !targetChar) return;

		const localRoot = localChar.FindFirstChild("HumanoidRootPart") as BasePart | undefined;
		const targetRoot = targetChar.FindFirstChild("HumanoidRootPart") as BasePart | undefined;
		const humanoid = localChar.FindFirstChildOfClass("Humanoid");

		if (localRoot && targetRoot && humanoid && humanoid.Health > 0) {
			const { angle, distance } = sliderJob.sliders;

			// Optimized CFrame math for TS
			const goalCFrame = targetRoot.CFrame.mul(new CFrame(0, 0, distance)).mul(
				CFrame.Angles(0, math.rad(angle), 0),
			);

			localRoot.CFrame = localRoot.CFrame.Lerp(goalCFrame, 0.5);
		}
	});
});
