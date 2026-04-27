import { RunService, Players, Workspace } from "@rbxts/services";
import { store } from "store/store"; // Added back the curly braces
import { Job } from "store/models/jobs.model"; // Import the type for casting

const lp = Players.LocalPlayer;

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
	if (Workspace.Gravity === 0) Workspace.Gravity = 196.2;
};

RunService.Stepped.Connect(() => {
	const state = store.getState();
	
	// FIX: Use 'as Job' to tell TypeScript that facebang has an 'active' property
	const job = state.jobs.facebang as Job | undefined;
	const isActive = job?.active;

	const char = lp.Character;
	if (!char) return;

	if (!isActive) {
		enableActions(char);
		return;
	}

	disableActions(char);

	const hrp = char.FindFirstChild("HumanoidRootPart") as Part;
	
	// FIX: Pulling the target ID from the correct state location
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
