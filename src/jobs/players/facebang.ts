import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";
import { JobWithSliders } from "store/models/jobs.model";

const HEIGHT_OFFSET = 0.8;
const DEPTH_OFFSET = -0.7;
const DEFAULT_GRAVITY = 192.2;

let isRunning = false;

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

// Maps speed slider (0-10) to a duration value
// Higher speed = lower duration = faster strokes
const speedToDuration = (speed: number) => {
	const clamped = math.clamp(speed, 0.1, 10);
	// At speed 5 (default) => 0.16s, at 10 => 0.05s, at 0.1 => ~0.8s
	return 0.5 / clamped;
};

onJobChange("facebang", (job, state) => {
	const sliderJob = job as unknown as JobWithSliders;
	const sliders = sliderJob?.sliders as { distance: number; speed: number; angle?: number } | undefined;

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
				task.wait(0.1);
				continue;
			}

			setPhysicsEnabled(localChar, false);

			// Pull latest slider values each stroke
			const currentJob = (state.jobs as unknown as Record<string, JobWithSliders>).facebang;
			const currentSliders = currentJob?.sliders as
				| { distance: number; speed: number; angle?: number }
				| undefined;

			const dist = currentSliders?.distance ?? 1.9;
			const speed = currentSliders?.speed ?? 5;
			const angle = math.rad(currentSliders?.angle ?? 180);
			const duration = speedToDuration(speed);

			const angleRotation = CFrame.Angles(0, angle, 0);
			const relativeBase = CF_HEIGHT.mul(angleRotation);
			const relativePeak = relativeBase.mul(new CFrame(0, 0, -dist));

			const startTime = tick();

			// Render loop for one stroke
			while (isRunning && tick() - startTime < duration) {
				const elapsed = tick() - startTime;
				const rawAlpha = elapsed / duration;
				const pingPongAlpha = 1 - math.abs(1 - rawAlpha * 2);
				const smoothAlpha = ease(math.clamp(pingPongAlpha, 0, 1));

				if (targetHead.Parent && localRoot.Parent) {
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
