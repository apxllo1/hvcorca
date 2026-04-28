import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";
import { JobWithSliders } from "store/models/jobs.model";

const HEIGHT_OFFSET = 0.8;
const DEPTH_OFFSET = -0.7;
const DEFAULT_GRAVITY = 192.2;

let isRunning = false;

// Helper to safely toggle character physics
const setPhysicsEnabled = (char: Model, enabled: boolean) => {
	const hum = char.FindFirstChildOfClass("Humanoid");
	if (hum) {
		hum.PlatformStand = !enabled;
		hum.AutoRotate = enabled;
	}
	Workspace.Gravity = enabled ? DEFAULT_GRAVITY : 0;
};

const ease = (t: number) => -(math.cos(math.pi * t) - 1) / 2;

onJobChange("facebang", (job, state) => {
	const sliderJob = job as unknown as JobWithSliders;
	const localPlayer = Players.LocalPlayer;
	const localChar = localPlayer.Character;

	// 1. Cleanup and Exit
	if (!sliderJob?.active || !localChar) {
		isRunning = false;
		if (localChar) setPhysicsEnabled(localChar, true);
		return;
	}

	// 2. Singleton Guard
	if (isRunning) return;

	// 3. Target Validation
	const targetName = state.dashboard.apps.playerSelected;
	const targetPlayer = targetName !== undefined ? (Players.FindFirstChild(targetName) as Player) : undefined;

	if (!targetPlayer || targetPlayer === localPlayer) return;

	isRunning = true;

	task.spawn(() => {
		const localRoot = localChar.WaitForChild("HumanoidRootPart") as BasePart;

		// Use a local reference to the job data that we can update
		while (isRunning) {
			const targetChar = targetPlayer.Character;
			const targetHead = targetChar?.FindFirstChild("Head") as BasePart | undefined;

			// If target leaves or dies, wait or exit
			if (!targetHead || !targetChar) {
				task.wait(0.5);
				continue;
			}

			setPhysicsEnabled(localChar, false);

			// Logic variables pulled from the latest state in the loop
			// Use 'any' cast specifically to avoid the "index signature" compile error
			const currentJob = (state.jobs as any).facebang as JobWithSliders;
			const dist = currentJob?.sliders?.distance ?? 1.9;
			const angle = currentJob?.sliders?.angle ?? 180;
			const speed = 0.1; // Hardcoded or pull from a slider if you add one

			// Pre-calculate rotations to save CPU cycles
			const rotation = CFrame.Angles(0, math.rad(angle), 0);
			const offset = new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET);

			const baseCFrame = targetHead.CFrame.mul(offset).mul(rotation);
			const peakCFrame = baseCFrame.mul(new CFrame(0, 0, -dist));

			// Sub-loop: Forward & Back (The "Bang")
			// We split the alpha (0 to 1) to handle the full stroke in one timer
			const startTime = tick();
			while (isRunning && tick() - startTime < speed * 2) {
				const elapsed = tick() - startTime;
				const isPushing = elapsed < speed;

				// Calculate alpha for the current half-stroke
				const alpha = isPushing ? elapsed / speed : 1 - (elapsed - speed) / speed;
				const smoothAlpha = ease(math.clamp(alpha, 0, 1));

				// Check if character still exists before applying CFrame
				if (localRoot && targetHead.Parent) {
					localRoot.CFrame = baseCFrame.Lerp(peakCFrame, smoothAlpha);
				}

				RunService.RenderStepped.Wait();
			}
		}

		isRunning = false;
		if (localPlayer.Character) setPhysicsEnabled(localPlayer.Character, true);
	});
});
