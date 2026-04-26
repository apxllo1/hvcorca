import { RunService, Players, Workspace } from "@rbxts/services";
import { store } from "store/store";

const lp = Players.LocalPlayer;

// Exact values from your facebang.lua
const OFFSET_FORWARD = -0.7;
const OFFSET_HEIGHT = 0.8;
const TELEPORT_DISTANCE = 1.9;

const disableActions = (char: Model) => {
	const animate = char.FindFirstChild("Animate") as LocalScript;
	if (animate) animate.Disabled = true;

	const humanoid = char.FindFirstChildOfClass("Humanoid");
	if (humanoid) {
		// Stops all playing animations exactly like your Lua script
		humanoid.GetPlayingAnimationTracks().forEach((track) => {
			track.Stop();
		});
		humanoid.PlatformStand = true;
		humanoid.AutoRotate = false;
		humanoid.ChangeState(Enum.HumanoidStateType.Physics);
	}
	Workspace.Gravity = 0;
};

const enableActions = (char: Model) => {
	const animate = char.FindFirstChild("Animate") as LocalScript;
	if (animate) animate.Disabled = false;

	const humanoid = char.FindFirstChildOfClass("Humanoid");
	if (humanoid) {
		humanoid.PlatformStand = false;
		humanoid.AutoRotate = true;
		humanoid.ChangeState(Enum.HumanoidStateType.GettingUp);
	}
	Workspace.Gravity = 196.2; // Default Roblox gravity
};

RunService.Stepped.Connect(() => {
	const state = store.getState();
	const isActive = state.jobs.facebang?.active;

	const char = lp.Character;
	if (!char) return;

	if (!isActive) {
		enableActions(char);
		return;
	}

	// If active, apply the "facebang" state
	disableActions(char);

	const hrp = char.FindFirstChild("HumanoidRootPart") as Part;
	const target = state.dashboard.selectedPlayer; // This uses the player you selected in the UI

	if (hrp && target && target.Character) {
		const targetHrp = target.Character.FindFirstChild("HumanoidRootPart") as Part;
		const targetHead = target.Character.FindFirstChild("Head") as Part;

		if (targetHrp && targetHead) {
			// MATH CONVERSION: 
			// 1. Calculate position in front of target head
			const targetPos = targetHead.Position.add(targetHrp.CFrame.LookVector.mul(TELEPORT_DISTANCE));
			
			// 2. Set CFrame to look at head, add height offset, and rotate 180 degrees
			hrp.CFrame = new CFrame(targetPos, targetHead.Position)
				.add(new Vector3(0, OFFSET_HEIGHT, 0))
				.mul(CFrame.Angles(0, math.rad(180), 0));
		}
	}
});
