import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";
import { JobWithSliders } from "store/models/jobs.model";

// --- Constants from your Lua File  ---
const DEPTH_OFFSET = -0.7; // fd
const HEIGHT_OFFSET = 0.8; // ho
const THRUST_DISTANCE = 1.9; // td
const DEFAULT_GRAVITY = 192.2;

let isRunning = false; // Our "Bypass" for task.cancel

const disablePhysics = (char: Model) => {
	const hum = char.FindFirstChildOfClass("Humanoid");
	const anim = char.FindFirstChild("Animate") as LocalScript | undefined;
	if (anim) anim.Disabled = true;
	if (hum) {
		hum.PlatformStand = true; // [cite: 3]
		hum.AutoRotate = false; // [cite: 3]
		hum.ChangeState(Enum.HumanoidStateType.Physics); // [cite: 3]
	}
	Workspace.Gravity = 0; // [cite: 3]
};

const enablePhysics = (char: Model) => {
	const hum = char.FindFirstChildOfClass("Humanoid");
	const anim = char.FindFirstChild("Animate") as LocalScript | undefined;
	if (anim) anim.Disabled = false;
	if (hum) {
		hum.PlatformStand = false; // [cite: 4]
		hum.AutoRotate = true; // [cite: 4]
		hum.ChangeState(Enum.HumanoidStateType.GettingUp); // [cite: 4]
	}
	Workspace.Gravity = DEFAULT_GRAVITY; // [cite: 4]
};

// Easing function from your Lua file [cite: 9]
const ease = (t: number) => -(math.cos(math.pi * t) - 1) / 2;

onJobChange("facebang", (job, state) => {
	const sliderJob = job as unknown as JobWithSliders;
	const localChar = Players.LocalPlayer.Character;

	// 1. If job is turned off, flip the flag to break the while loop
	if (!sliderJob?.active || !sliderJob.sliders || !localChar) {
		isRunning = false;
		if (localChar) enablePhysics(localChar);
		return;
	}

	const targetName = state.dashboard.apps.playerSelected;
	const targetPlayer = targetName !== undefined ? (Players.FindFirstChild(targetName) as Player) : undefined;

	if (!targetPlayer?.Character || targetPlayer === Players.LocalPlayer) return;

	// 2. Start the Loop
	isRunning = true;

	// We use coroutine.create to avoid the 'void' return type error on task.spawn
	const thread = coroutine.create(() => {
		const localRoot = localChar.WaitForChild("HumanoidRootPart") as BasePart;

		while (isRunning && sliderJob.active) {
			const targetHead = targetPlayer.Character?.FindFirstChild("Head") as BasePart | undefined;
			if (!targetHead) {
				task.wait(1);
				continue;
			}

			disablePhysics(localChar);

			// Sliders: Distance = td (1.9), Speed = ft/bt (0.1)
			const td = sliderJob.sliders.distance || THRUST_DISTANCE;
			const speed = 0.1; // Matches Lua 'ft' and 'bt'

			// PRE-CALCULATE CFRAMES [cite: 12, 13]
			const basePos = targetHead.CFrame.mul(new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET)).mul(
				CFrame.Angles(0, math.rad(180), 0),
			);

			const targetPos = targetHead.CFrame.mul(new CFrame(0, HEIGHT_OFFSET, DEPTH_OFFSET - td)).mul(
				CFrame.Angles(0, math.rad(180), 0),
			);

			// --- Phase 1: Forward Thrust [cite: 13] ---
			let start = tick();
			while (isRunning && tick() - start < speed) {
				const alpha = math.min((tick() - start) / speed, 1);
				localRoot.CFrame = basePos.Lerp(targetPos, ease(alpha));
				RunService.RenderStepped.Wait();
			}

			// --- Phase 2: Pull Back [cite: 15] ---
			start = tick();
			while (isRunning && tick() - start < speed) {
				const alpha = math.min((tick() - start) / speed, 1);
				localRoot.CFrame = targetPos.Lerp(basePos, ease(alpha));
				RunService.RenderStepped.Wait();
			}
		}

		if (localChar) enablePhysics(localChar);
	});

	task.spawn(thread);
});
