import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";
import { JobWithSliders } from "store/models/jobs.model";

const HEIGHT_OFFSET = 0.8;
const DEPTH_OFFSET = -0.7;
const DEFAULT_GRAVITY = 192.2;

let isRunning = false;

const disablePhysics = (char: Model) => {
	const hum = char.FindFirstChildOfClass("Humanoid");
	if (hum) {
		hum.PlatformStand = true;
		hum.AutoRotate = false;
	}
	Workspace.Gravity = 0;
};

const enablePhysics = (char: Model) => {
	const hum = char.FindFirstChildOfClass("Humanoid");
	if (hum) {
		hum.PlatformStand = false;
		hum.AutoRotate = true;
	}
	Workspace.Gravity = DEFAULT_GRAVITY;
};

const ease = (t: number) => -(math.cos(math.pi * t) - 1) / 2;

onJobChange("facebang", (job, state) => {
	const sliderJob = job as unknown as JobWithSliders;
	const localChar = Players.LocalPlayer.Character;

	// 1. Check if we should stop
	if (!sliderJob?.active || !localChar) {
		isRunning = false;
		if (localChar) enablePhysics(localChar);
		return;
	}

	// 2. Prevent duplicate loops
	if (isRunning) return;

	const targetName = state.dashboard.apps.playerSelected;
	const targetPlayer = targetName !== undefined ? (Players.FindFirstChild(targetName) as Player) : undefined;

	if (!targetPlayer?.Character || targetPlayer === Players.LocalPlayer) return;

	isRunning = true;

	task.spawn(() => {
		const localRoot = localChar.WaitForChild("HumanoidRootPart") as BasePart;

		while (isRunning) {
			// CRITICAL: Pull current slider values from state every cycle for "Live" updates
			const currentJob = (state.jobs as any).facebang as JobWithSliders;
			if (!currentJob || !currentJob.active) break;

			const targetHead = targetPlayer.Character?.FindFirstChild("Head") as BasePart | undefined;
			if (!targetHead) {
				task.wait(1);
				continue;
			}

			disablePhysics(localChar);

			// Map UI sliders to internal variables
			const td = currentJob.sliders.distance ?? 1.9;
			const angle = currentJob.sliders.angle ?? 180;
			const speed = 0.1; 

			const basePos = targetHead.CFrame
				.mul(new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET))
				.mul(CFrame.Angles(0, math.rad(angle), 0));

			const targetPos = targetHead.CFrame
				.mul(new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET - td))
				.mul(CFrame.Angles(0, math.rad(angle), 0));

			// Thrust Forward
			let start = tick();
			while (isRunning && (tick() - start) < speed) {
				const alpha = math.min((tick() - start) / speed, 1);
				localRoot.CFrame = basePos.Lerp(targetPos, ease(alpha));
				RunService.RenderStepped.Wait();
			}

			// Pull Back
			start = tick();
			while (isRunning && (tick() - start) < speed) {
				const alpha = math.min((tick() - start) / speed, 1);
				localRoot.CFrame = targetPos.Lerp(basePos, ease(alpha));
				RunService.RenderStepped.Wait();
			}
		}

		isRunning = false;
		if (localChar) enablePhysics(localChar);
	});
});
