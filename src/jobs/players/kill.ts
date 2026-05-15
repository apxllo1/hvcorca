import { Players, Workspace } from "@rbxts/services";
import { getSelectedPlayer } from "jobs/helpers/get-selected-player";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import { setJobActive } from "store/actions/jobs.action";

const player = Players.LocalPlayer;

function attachToVictim(victim: Player): Promise<BasePart> {
	const backpack = player.FindFirstChildWhichIsA("Backpack");
	if (!backpack) {
		return Promise.reject("No inventory found");
	}

	const playerCharacter = player.Character;
	const victimCharacter = victim.Character;
	if (!playerCharacter || !victimCharacter) {
		return Promise.reject("Victim or local player has no character");
	}

	const playerHumanoid = playerCharacter.FindFirstChildWhichIsA("Humanoid");
	const playerRootPart = playerCharacter.FindFirstChild("HumanoidRootPart") as BasePart | undefined;
	const victimRootPart = victimCharacter.FindFirstChild("HumanoidRootPart") as BasePart | undefined;
	if (!playerHumanoid || !playerRootPart || !victimRootPart) {
		return Promise.reject("Victim or local player has no Humanoid or root part");
	}

	const tool = [...playerCharacter.GetChildren(), ...backpack.GetChildren()].find(
		(obj): obj is Tool => obj.IsA("Tool") && obj.FindFirstChild("Handle") !== undefined,
	);
	if (!tool) {
		return Promise.reject("A tool with a handle is required to kill this victim");
	}

	playerHumanoid.Name = "";

	const mockHumanoid = playerHumanoid.Clone();
	mockHumanoid.DisplayName = utf8.char(128298);
	mockHumanoid.Parent = playerCharacter;
	mockHumanoid.Name = "Humanoid";

	task.wait();
	playerHumanoid.Destroy();
	Workspace.CurrentCamera!.CameraSubject = mockHumanoid;

	tool.Parent = playerCharacter;

	return new Promise((resolve, reject) => {
		for (let count = 0; count < 250; count++) {
			if (victimRootPart.Parent !== victimCharacter || playerRootPart.Parent !== playerCharacter) {
				reject("Victim or local player has no root part; did a player respawn?");
				return;
			}
			if (tool.Parent !== playerCharacter) {
				resolve(playerRootPart);
				return;
			}
			playerRootPart.CFrame = victimRootPart.CFrame;
			task.wait(0.1);
		}
		reject("Failed to attach to victim");
	});
}

async function bringVictimToVoid(victim: Player) {
	const store = await getStore();

	const oldRootPart = player.Character?.FindFirstChild("HumanoidRootPart");
	const location = oldRootPart?.IsA("BasePart") ? oldRootPart.CFrame : undefined;

	store.dispatch(setJobActive("refresh", true));

	await Promise.fromEvent(
		player.CharacterAdded,
		(character) => character.WaitForChild("HumanoidRootPart", 5) !== undefined,
	);
	task.wait(0.3);

	const rootPart = await attachToVictim(victim);

	const [victimCharacter, playerCharacter] = [victim.Character!, player.Character!];
	do {
		task.wait(0.1);
		rootPart.CFrame = new CFrame(1000000, Workspace.FallenPartsDestroyHeight + 5, 1000000);
	} while (
		victimCharacter?.FindFirstChild("HumanoidRootPart") !== undefined &&
		playerCharacter?.FindFirstChild("HumanoidRootPart") !== undefined
	);

	const newCharacter = await Promise.fromEvent<Model & { HumanoidRootPart: BasePart }>(
		player.CharacterAdded,
		(character) => character.WaitForChild("HumanoidRootPart", 5) !== undefined,
	);

	if (location) {
		newCharacter.HumanoidRootPart.CFrame = location;
	}
}

async function main() {
	const store = await getStore();
	const playerSelected = await getSelectedPlayer();

	onJobChange("kill", (job) => {
		if (job.active) {
			if (!playerSelected.current) {
				store.dispatch(setJobActive("kill", false));
				return;
			}

			bringVictimToVoid(playerSelected.current)
				.catch((err: unknown) => warn(`[kill-worker] ${String(err)}`))
				.finally(() => store.dispatch(setJobActive("kill", false)));
		}
	}).catch((err: unknown) => warn(`[kill-worker] ${String(err)}`));
}

main().catch((err: unknown) => {
	warn(`[kill-worker] ${String(err)}`);
});
