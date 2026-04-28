import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";
import { JobWithSliders } from "store/models/jobs.model";

// Constants from your Lua file
const DEFAULT_GRAVITY = 192.2;
const HEIGHT_OFFSET = 0.8;
const DEPTH_OFFSET = -0.7;

let activeThread: thread | undefined;

/**
 * Disables character physics and animations to prevent interference
 */
const disablePhysics = (char: Model) => {
	const humanoid = char.FindFirstChildOfClass("Humanoid");
	const animate = char.FindFirstChild("Animate") as LocalScript | undefined;

	if (animate) animate.Disabled = true;
	if (humanoid) {
		humanoid.PlatformStand = true;
		humanoid.AutoRotate = false;
		humanoid.ChangeState(Enum.HumanoidStateType.Physics);
	}
	Workspace.Gravity = 0;
};

/**
 * Re-enables character physics and animations
 */
const enablePhysics = (char: Model) => {
	const humanoid = char.FindFirstChildOfClass("Humanoid");
	const animate = char.FindFirstChild("Animate") as LocalScript | undefined;

	if (animate) animate.Disabled = false;
	if (humanoid) {
		humanoid.PlatformStand = false;
		humanoid.AutoRotate = true;
		humanoid.ChangeState(Enum.HumanoidStateType.GettingUp);
	}
	Workspace.Gravity = DEFAULT_GRAVITY;
};

/**
 * Standard InOutSine easing function from your Lua file
 */
const ease = (t: number) => -(math.cos(math.pi * t) - 1) / 2;

onJobChange("facebang", (job, state) => {
	// 1. Cleanup: Stop any existing movement threads
	if (activeThread) {
		task.cancel(activeThread);
		activeThread = undefined;
	}

	const sliderJob = job as unknown as JobWithSliders;
	const localChar = Players.LocalPlayer.Character;

	// 2. Safety Check
	if (!sliderJob?.active || !sliderJob.sliders || !localChar) {
		if (localChar) enablePhysics(localChar);
		return;
	}

	const targetName = state.dashboard.apps.playerSelected;
	const targetPlayer = targetName !== undefined ? (Players.FindFirstChild(targetName) as Player) : undefined;

	if (!targetPlayer?.Character || targetPlayer === Players.LocalPlayer) return;

	// 3. Start the Movement Loop
	activeThread = task.spawn(() => {
		const localRoot = localChar.WaitForChild("HumanoidRootPart") as BasePart;

		while (sliderJob.active) {
			const targetChar = targetPlayer.Character;
			if (!targetChar) {
				task.wait(1);
				continue;
			}

			const targetHead = targetChar.FindFirstChild("Head") as BasePart;
			if (!targetHead) {
				task.wait(1);
				continue;
			}

			disablePhysics(localChar);

			const { angle, distance } = sliderJob.sliders; // Note: 'distance' in sliders = 'td' in Lua
			const speed = 0.1; // Matches 'ft' and 'bt' in Lua

			// --- Phase 1: Forward Thrust ---
			let startTick = tick();
			while (tick() - startTick < speed) {
				const alpha = math.min((tick() - startTick) / speed, 1);
				const easedAlpha = ease(alpha);

				const baseCFrame = targetHead.CFrame.mul(new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET)).mul(
					CFrame.Angles(0, math.rad(180), 0),
				);

				const thrustCFrame = targetHead.CFrame.mul(new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET - distance)).mul(
					CFrame.Angles(0, math.rad(180), 0),
				);

				localRoot.CFrame = baseCFrame.Lerp(thrustCFrame, easedAlpha);
				RunService.RenderStepped.Wait();
			}

			// --- Phase 2: Pull Back ---
			startTick = tick();
			while (tick() - startTick < speed) {
				const alpha = math.min((tick() - startTick) / speed, 1);
				const easedAlpha = ease(alpha);

				const baseCFrame = targetHead.CFrame.mul(new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET)).mul(
					CFrame.Angles(0, math.rad(180), 0),
				);

				const thrustCFrame = targetHead.CFrame.mul(new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET - distance)).mul(
					CFrame.Angles(0, math.rad(180), 0),
				);

				localRoot.CFrame = thrustCFrame.Lerp(baseCFrame, easedAlpha);
				RunService.RenderStepped.Wait();
			}
		}

		enablePhysics(localChar);
	});
});
