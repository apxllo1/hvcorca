import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange, getStore } from "./helpers/job-store";

const lp = Players.LocalPlayer;
let isActive = false;

onJobChange("facebang", (job) => {
	isActive = job.active;
	print(`[Facebang] State changed: ${isActive}`);
});

RunService.Stepped.Connect(async () => {
	if (!isActive) return;

	const store = await getStore();
	const state = store.getState();
	const targetUserId = state.dashboard.apps.playerSelected;

	// DEBUG: Is a player actually selected?
	if (targetUserId === undefined || targetUserId === "") {
		warn("[Facebang] Error: No player selected in UI");
		return;
	}

	const char = lp.Character;
	if (!char) {
		warn("[Facebang] Waiting for your character...");
		return;
	}

	const target = Players.GetPlayerByUserId(tonumber(targetUserId) || 0);
	if (!target || !target.Character) {
		warn(`[Facebang] Target player ${targetUserId} character not found`);
		return;
	}

	const hrp = char.FindFirstChild("HumanoidRootPart") as Part;
	const targetHrp = target.Character.FindFirstChild("HumanoidRootPart") as Part;
	const targetHead = target.Character.FindFirstChild("Head") as Part;

	if (hrp && targetHrp && targetHead) {
		// Logic is running
		const targetPos = targetHead.Position.add(targetHrp.CFrame.LookVector.mul(1.9));
		hrp.CFrame = new CFrame(targetPos, targetHead.Position)
			.add(new Vector3(0, 0.8, 0))
			.mul(CFrame.Angles(0, math.rad(180), 0));
		
		Workspace.Gravity = 0;
	} else {
		warn("[Facebang] Missing Body Parts (HRP or Head)");
	}
});
