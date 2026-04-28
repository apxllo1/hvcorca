import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";
import { JobWithSliders } from "store/models/jobs.model";

const HEIGHT_OFFSET = 0.8;
const DEPTH_OFFSET = -0.7;
const DEFAULT_GRAVITY = 192.2;

let isRunning = false;

// Pre-define common CFrames to save memory allocation
const CF_IDENTITY = new CFrame();
const CF_HEIGHT = new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET);

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

	if (!sliderJob?.active || !localChar) {
		isRunning = false;
		if (localChar) setPhysicsEnabled(localChar, true);
		return;
	}

	if (isRunning) return;

	const targetName = state.dashboard.apps.playerSelected;
	const targetPlayer = targetName !== undefined ? (Players.FindFirstChild(targetName) as Player) : undefined;

	if (!targetPlayer || targetPlayer === localPlayer) return;

	isRunning = true;

	task.spawn(() => {
		const localRoot = localChar.WaitForChild("HumanoidRootPart") as BasePart;
		
		while (isRunning) {
			const targetChar = targetPlayer.Character;
			const targetHead = targetChar?.FindFirstChild("Head") as BasePart | undefined;
			
			if (!targetHead) {
				task.wait(0.1); // Reduced wait for snappier target re-acquisition
				continue; 
			}

			setPhysicsEnabled(localChar, false);

			// Optimization: Fetch sliders once per 'stroke' instead of every frame
			const currentJob = (state.jobs as any).facebang as JobWithSliders;
			const dist = currentJob?.sliders?.distance ?? 1.9;
			const angle = math.rad(currentJob?.sliders?.angle ?? 180);
			const speed = 0.08; // Slightly faster for better "impact" feel

			// Pre-calculate the Angle CFrame
			const angleRotation = CFrame.Angles(0, angle, 0);
			
			// We define the relative offsets once
			const relativeBase = CF_HEIGHT.mul(angleRotation);
			const relativePeak = relativeBase.mul(new CFrame(0, 0, -dist));

			const startTime = tick();
			const duration = speed * 2;

			// THE RENDER LOOP
			while (isRunning && tick() - startTime < duration) {
				const elapsed = tick() - startTime;
				
				// Calculate a 0 -> 1 -> 0 alpha in a single math operation
				// This creates the "bounce" effect without nested while loops
				const rawAlpha = elapsed / duration;
				const pingPongAlpha = 1 - math.abs(1 - (rawAlpha * 2)); 
				const smoothAlpha = ease(math.clamp(pingPongAlpha, 0, 1));

				if (targetHead.Parent && localRoot.Parent) {
					// Optimization: One single CFrame multiplication chain
					const targetCF = targetHead.CFrame;
					localRoot.CFrame = targetCF.mul(relativeBase.Lerp(relativePeak, smoothAlpha));
				}

				RunService.RenderStepped.Wait();
			}
		}

		isRunning = false;
		if (localPlayer.Character) setPhysicsEnabled(localPlayer.Character, true);
	});
});
