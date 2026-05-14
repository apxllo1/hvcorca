import { Players, Workspace } from "@rbxts/services";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import type { JobsAction } from "store/actions/jobs.action";

const MAX_RESPAWN_TIME = 10;
const player = Players.LocalPlayer;

async function main() {
	const store = await getStore();

	function deactivate() {
		store.dispatch({
			type: "jobs/setJobActive",
			jobName: "refresh",
			active: false,
		} as JobsAction);
	}

	onJobChange("refresh", (job, state) => {
		if (state.jobs.ghost.active && job.active) {
			// Can't refresh while ghost is active
			deactivate();
		} else if (job.active) {
			void respawn()
				.catch((err) => warn(`[refresh-worker-respawn] ${err}`))
				.finally(() => deactivate());
		}
	});
}

// https://github.com/EdgeIY/infiniteyield/blob/master/source#L4871
async function respawn() {
	const character = player.Character;
	if (!character) {
		throw "Character is null";
	}

	// Save current location
	const rootPart = character.FindFirstChild("HumanoidRootPart") as BasePart | undefined;
	const respawnLocation = rootPart?.CFrame;

	const humanoid = character.FindFirstChildWhichIsA("Humanoid");
	humanoid?.ChangeState(Enum.HumanoidStateType.Dead);

	// Clear character
	character.ClearAllChildren();

	// Force respawn
	const mockCharacter = new Instance("Model", Workspace);
	player.Character = mockCharacter;
	player.Character = character;
	mockCharacter.Destroy();

	if (!respawnLocation) {
		return;
	}

	// Wait for new character
	const newCharacter = await Promise.fromEvent(player.CharacterAdded).timeout(
		MAX_RESPAWN_TIME,
		"CharacterAdded event timed out",
	);

	const newRoot = newCharacter.WaitForChild("HumanoidRootPart", 5);
	if (newRoot && newRoot.IsA("BasePart")) {
		task.delay(0.1, () => {
			newRoot.CFrame = respawnLocation;
		});
	}
}

main().catch((err) => {
	warn(`[refresh-worker] ${err}`);
});
