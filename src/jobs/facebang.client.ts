import { RunService, Players, Workspace } from "@rbxts/services";
import store from "store/store"; // Fixed: Removed curly braces for default export
import { Job } from "store/models/jobs.model"; // Added: Import Job type for safety

const lp = Players.LocalPlayer;

// Exact values from your facebang.lua
const OFFSET_HEIGHT = 0.8;
const TELEPORT_DISTANCE = 1.9;

const disableActions = (char: Model) => {
	const animate = char.FindFirstChild("Animate") as LocalScript;
	if (animate) animate.Disabled = true;

	const humanoid = char.FindFirstChildOfClass("Humanoid");
	if (humanoid) {
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
	// Only reset gravity if it's currently 0 to avoid overriding other scripts
	if (Workspace.Gravity === 0) Workspace.Gravity = 196.2;
};

RunService.Stepped.Connect(() => {
	const state = store.getState();
	
	// Fixed: Cast to Job to prevent "Property active does not exist" error
	const facebangJob = state.jobs.facebang as Job | undefined;
	const isActive = facebangJob?.active;

	const char = lp.Character;
	if (!char) return;

	if (!isActive) {
		enableActions(char);
		return;
	}

	disableActions(char);

	const hrp = char.FindFirstChild("HumanoidRootPart") as Part;
	
	// Get the target player from the store
	const targetUserId = state.dashboard.apps.playerSelected;
	const target = Players.GetPlayerByUserId(tonumber(targetUserId) || 0);

	if (hrp && target && target.Character) {
		const targetHrp = target.Character.FindFirstChild("HumanoidRootPart") as Part;
		const targetHead = target.Character.FindFirstChild("Head") as Part;

		if (targetHrp && targetHead) {
			const targetPos = targetHead.Position.add(targetHrp.CFrame.LookVector.mul(TELEPORT_DISTANCE));
			
			hrp.CFrame = new CFrame(targetPos, targetHead.Position)
				.add(new Vector3(0, OFFSET_HEIGHT, 0))
				.mul(CFrame.Angles(0, math.rad(180), 0));
		}
	}
});
