import { RunService, Players, Workspace } from "@rbxts/services";
import * as StoreModule from "store/store"; // Force-grab everything from the store file
import { Job } from "store/models/jobs.model";

const lp = Players.LocalPlayer;
const store = StoreModule.store; // Pick the store variable out manually

const OFFSET_HEIGHT = 0.8;
const TELEPORT_DISTANCE = 1.9;

const disableActions = (char: Model) => {
	const animate = char.FindFirstChild("Animate") as LocalScript;
	if (animate) animate.Disabled = true;

	const humanoid = char.FindFirstChildOfClass("Humanoid");
	if (humanoid) {
		humanoid.GetPlayingAnimationTracks().forEach((track) => track.Stop());
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
	const facebangJob = state.jobs.facebang as Job | undefined;
	const isActive = facebangJob?.active;

	const char = lp.Character;
	if (!char || !isActive) {
		if (char) enableActions(char);
		return;
	}

	disableActions(char);

	const hrp = char.FindFirstChild("HumanoidRootPart") as Part;
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
