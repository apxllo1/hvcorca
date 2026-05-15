import { Players, Workspace } from "@rbxts/services";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import type { JobsAction } from "store/actions/jobs.action";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const safeWarn = warn as unknown as (msg: string) => void;

const player = Players.LocalPlayer;
const screenGuisWithResetOnSpawn = new Array<ScreenGui>();
let originalCharacter: Model | undefined;
let ghostCharacter: Model | undefined;
let lastPosition: CFrame | undefined;

function disableResetOnSpawn() {
	const playerGui = player.FindFirstChildWhichIsA("PlayerGui");
	if (playerGui) {
		for (const object of playerGui.GetChildren()) {
			if (object.IsA("ScreenGui") && object.ResetOnSpawn) {
				screenGuisWithResetOnSpawn.push(object);
				object.ResetOnSpawn = false;
			}
		}
	}
}

function enableResetOnSpawn() {
	for (const screenGui of screenGuisWithResetOnSpawn) {
		screenGui.ResetOnSpawn = true;
	}
	screenGuisWithResetOnSpawn.clear();
}

function main(): void {
	onJobChange("ghost", (job, state): void => {
		if (state.jobs.refresh.active && job.active) {
			deactivate().catch((err: unknown) => {
				safeWarn(`[ghost-worker-deactivate] ${String(err)}`);
			});
		} else if (job.active) {
			activateGhost()
				.then(deactivateOnCharacterAdded)
				.catch((err: unknown) => {
					safeWarn(`[ghost-worker-active] ${String(err)}`);
					deactivate().catch((e: unknown) => {
						safeWarn(`[ghost-worker-deactivate] ${String(e)}`);
					});
				});
		} else if (!state.jobs.refresh.active) {
			deactivateGhost().catch((err: unknown) => {
				safeWarn(`[ghost-worker-inactive] ${String(err)}`);
			});
		}
	});
}

async function deactivate() {
	const store = await getStore();
	store.dispatch({
		type: "jobs/setJobActive",
		jobName: "ghost",
		active: false,
	} as JobsAction);
}

async function deactivateOnCharacterAdded() {
	await Promise.fromEvent(
		player.CharacterAdded,
		(character) => character !== originalCharacter && character !== ghostCharacter,
	);
	await deactivate();
}

function activateGhost(): Promise<void> {
	const character = player.Character;
	const humanoid = character?.FindFirstChildWhichIsA("Humanoid");
	if (!character || !humanoid) {
		return Promise.reject("Character or Humanoid is null");
	}

	character.Archivable = true;
	ghostCharacter = character.Clone();
	character.Archivable = false;

	const rootPart = character.FindFirstChild("HumanoidRootPart");
	lastPosition = rootPart?.IsA("BasePart") ? rootPart.CFrame : undefined;
	originalCharacter = character;

	const ghostHumanoid = ghostCharacter.FindFirstChildWhichIsA("Humanoid");
	for (const child of ghostCharacter.GetDescendants()) {
		if (child.IsA("BasePart")) {
			child.Transparency = 1 - (1 - child.Transparency) * 0.5;
		}
	}

	if (ghostHumanoid) {
		ghostHumanoid.DisplayName = utf8.char(128123);
	}

	ghostCharacter.FindFirstChild("Animate")?.Destroy();
	const animation = originalCharacter.FindFirstChild("Animate") as LocalScript | undefined;
	if (animation) {
		animation.Disabled = true;
		animation.Parent = ghostCharacter;
	}

	disableResetOnSpawn();
	ghostCharacter.Parent = character.Parent;
	player.Character = ghostCharacter;
	Workspace.CurrentCamera!.CameraSubject = ghostHumanoid;
	enableResetOnSpawn();

	if (animation) {
		animation.Disabled = false;
	}

	const handle = humanoid.Died.Connect(() => {
		handle.Disconnect();
		deactivate().catch((err: unknown) => {
			safeWarn(`[ghost-worker-died] ${String(err)}`);
		});
	});

	return Promise.resolve();
}

function deactivateGhost(): Promise<void> {
	if (!originalCharacter || !ghostCharacter) {
		return Promise.resolve();
	}

	const rootPart = originalCharacter.FindFirstChild("HumanoidRootPart");
	const ghostRootPart = ghostCharacter.FindFirstChild("HumanoidRootPart");
	const currentPosition = ghostRootPart?.IsA("BasePart") ? ghostRootPart.CFrame : undefined;

	const animation = ghostCharacter.FindFirstChild("Animate") as LocalScript | undefined;
	if (animation) {
		animation.Disabled = true;
		animation.Parent = undefined;
	}

	ghostCharacter.Destroy();

	const humanoid = originalCharacter.FindFirstChildWhichIsA("Humanoid");
	humanoid?.GetPlayingAnimationTracks().forEach((track) => track.Stop());

	const position = currentPosition ?? lastPosition;
	if (rootPart?.IsA("BasePart") && position) {
		rootPart.CFrame = position;
	}

	disableResetOnSpawn();
	player.Character = originalCharacter;
	Workspace.CurrentCamera!.CameraSubject = humanoid;
	enableResetOnSpawn();

	if (animation) {
		animation.Parent = originalCharacter;
		animation.Disabled = false;
	}

	originalCharacter = undefined;
	ghostCharacter = undefined;
	lastPosition = undefined;

	return Promise.resolve();
}

main();
