import { RunService, Players, Workspace } from "@rbxts/services";
import { Job } from "store/models/jobs.model";
import { getStore } from "./helpers/job-store"; // This is the secret sauce

const lp = Players.LocalPlayer;
const OFFSET_HEIGHT = 0.8;
const TELEPORT_DISTANCE = 1.9;

RunService.Stepped.Connect(() => {
	const store = getStore(); // Get the store safely from the helper
	if (!store) return;
    
	const state = store.getState();
	const facebangJob = state.jobs.facebang as Job | undefined;
	const isActive = facebangJob?.active;

	const char = lp.Character;
	if (!char) return;

	if (!isActive) {
		if (Workspace.Gravity === 0) Workspace.Gravity = 196.2;
		return;
	}

	const humanoid = char.FindFirstChildOfClass("Humanoid");
	if (humanoid) {
		humanoid.PlatformStand = true;
		humanoid.ChangeState(Enum.HumanoidStateType.Physics);
	}
	Workspace.Gravity = 0;

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
