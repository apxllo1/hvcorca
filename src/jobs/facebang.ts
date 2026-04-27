import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange, getStore } from "./helpers/job-store";

const lp = Players.LocalPlayer;
let isActive = false;
const originalGravity = Workspace.Gravity;

async function initFacebang() {
	// 1. Get the store once at the start to prevent lag
	const store = await getStore();
	print("[Facebang] Successfully linked to Store");

	// 2. Listen for the toggle change
	onJobChange("facebang", (job) => {
		isActive = job.active;
		
		// Reset gravity when turned off
		if (!isActive) {
			Workspace.Gravity = originalGravity;
		}
		
		print(`[Facebang] Active: ${isActive}`);
	});

	// 3. The high-speed loop
	RunService.Stepped.Connect(() => {
		if (!isActive) return;

		const state = store.getState();
		const targetIdentifier = state.dashboard.apps.playerSelected;

		// Validation: Check if a player is selected
		if (targetIdentifier === undefined || targetIdentifier === "") return;

		const char = lp.Character;
		if (!char) return;

		// Find target by Name or UserId (Handling both string/number cases)
		const target = Players.FindFirstChild(tostring(targetIdentifier)) as Player;
		
		if (!target || !target.Character) return;

		const hrp = char.FindFirstChild("HumanoidRootPart") as Part;
		const targetHrp = target.Character.FindFirstChild("HumanoidRootPart") as Part;
		const targetHead = target.Character.FindFirstChild("Head") as Part;

		if (hrp && targetHrp && targetHead) {
			// Calculate position: 1.9 studs in front of their face
			const targetPos = targetHead.Position.add(targetHrp.CFrame.LookVector.mul(1.9));
			
			// Set CFrame: Look at their head, flip 180 degrees to face them
			hrp.CFrame = new CFrame(targetPos, targetHead.Position)
				.add(new Vector3(0, 0.8, 0))
				.mul(CFrame.Angles(0, math.rad(180), 0));
			
			// Float in place
			Workspace.Gravity = 0;
		}
	});
}

// Start the job
initFacebang().catch((err) => warn(`[Facebang] Initialization Error: ${err}`));
