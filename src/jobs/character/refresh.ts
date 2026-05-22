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
			deactivate();
		} else if (job.active) {
			respawn()
				.catch((err: unknown) => (warn as (s: string) => void)(`[refresh-worker-respawn] ${tostring(err)}`))
				.finally(() => deactivate());
		}
	}).catch((err: unknown) => (warn as (s: string) => void)(`[refresh-worker] ${tostring(err)}`));
}

async function respawn() {
	const character = player.Character;
	if (!character) {
		throw "Character is null";
	}

	const rootPart = character.FindFirstChild("HumanoidRootPart") as BasePart | undefined;
	const respawnLocation = rootPart?.CFrame;

	if (!respawnLocation) {
		return; // Nothing to respawn to
	}

	const humanoid = character.FindFirstChildWhichIsA("Humanoid");
	humanoid?.ChangeState(Enum.HumanoidStateType.Dead);
	character.ClearAllChildren();

	// Create mock to detach character
	// eslint-disable-next-line @typescript-eslint/no-unsafe-call
	const mockCharacter = new Instance("Model");
	mockCharacter.Parent = Workspace;

	try {
		// Force engine to recognize change
		player.Character = undefined as unknown as Model;
		player.Character = mockCharacter;

		// Wait a frame to let the engine process
		await Promise.delay(0.1);

		// Assign original character back (must be cloned or rebuilt)
		const clonedCharacter = character.Clone();
		clonedCharacter.Parent = Workspace;
		player.Character = clonedCharacter;

		// Wait for CharacterAdded (optional safety net)
		const newCharacter = await Promise.race([
			Promise.fromEvent(player.CharacterAdded).timeout(MAX_RESPAWN_TIME, "Respawn timeout"),
			Promise.resolve(clonedCharacter),
		]);

		// Wait for root part and humanoid
		const newRoot = newCharacter.WaitForChild("HumanoidRootPart", 5) as BasePart | undefined;
		if (newRoot !== undefined && newRoot.IsA("BasePart")) {
			task.delay(0.1, () => {
				if (newRoot.Parent) {
					newRoot.CFrame = respawnLocation;
				}
			});
		}

		// Ensure Humanoid exists
		if (newCharacter.FindFirstChildWhichIsA("Humanoid") === undefined) {
			// eslint-disable-next-line @typescript-eslint/no-unsafe-call
			const newHumanoid = new Instance("Humanoid");
			newHumanoid.Parent = newCharacter;
		}
	} finally {
		// Clean up mock safely
		if (mockCharacter.Parent === Workspace) {
			mockCharacter.Destroy();
		}
	}
}

main().catch((err: unknown) => {
	(warn as (s: string) => void)(`[refresh-worker] ${tostring(err)}`);
});
