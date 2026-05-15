declare const game: any;
declare function warn(message?: unknown): void;

declare global {
	interface Array<T> {
		push(...items: T[]): number;
		length: number;
	}

	interface Promise<T = any> {
		then<TResult1 = T, TResult2 = never>(
			onfulfilled?: ((value: T) => TResult1 | PromiseLike<TResult1>) | undefined | null,
			onrejected?: ((reason: any) => TResult2 | PromiseLike<TResult2>) | undefined | null,
		): Promise<TResult1 | TResult2>;
		catch<TResult = never>(
			onrejected?: ((reason: any) => TResult | PromiseLike<TResult>) | undefined | null,
		): Promise<T | TResult>;
	}

	interface PromiseConstructor {
		new <T = any>(
			executor: (
				resolve: (value?: T | PromiseLike<T>) => void,
				reject: (reason?: any) => void,
			) => void,
		): Promise<T>;
		resolve<T = void>(value?: T | PromiseLike<T>): Promise<T>;
		reject(reason?: any): Promise<never>;
	}

	interface PromiseLike<T> {
		then<TResult>(
			onfulfilled?: ((value: T) => TResult | PromiseLike<TResult>) | undefined | null,
		): PromiseLike<TResult>;
	}
}

declare const Promise: PromiseConstructor;

import { getStore, onJobChange } from "jobs/helpers/job-store";
import type { JobsAction } from "store/actions/jobs.action";

const Players = game.GetService("Players");
const Workspace = game.GetService("Workspace");
const player = Players.LocalPlayer;
const screenGuisWithResetOnSpawn: any[] = [];

let originalCharacter: any | undefined;
let ghostCharacter: any | undefined;
let lastPosition: any | undefined;

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
	screenGuisWithResetOnSpawn.length = 0;
}

async function main(): Promise<void> {
	await onJobChange("ghost", (job: any, state: any) => {
		if (state.jobs.refresh.active && job.active) {
			// Can't enable ghost while respawning
			deactivate();
		} else if (job.active) {
			// Enable ghost mode
			activateGhost().then(
				deactivateOnCharacterAdded,
				(err: unknown) => {
					warn(`[ghost-worker-active] ${err}`);
					deactivate();
				},
			);
		} else if (!state.jobs.refresh.active) {
			// Deactivate ghost if inactive & not respawning
			deactivateGhost().catch((err: unknown) => {
				warn(`[ghost-worker-inactive] ${err}`);
			});
		}
	});
}

async function deactivate(): Promise<void> {
	const store = await getStore();
	store.dispatch({
		type: "jobs/setJobActive",
		jobName: "ghost",
		active: false,
	} as JobsAction);
}

async function deactivateOnCharacterAdded(): Promise<void> {
	await new Promise<void>((resolve) => {
		const connection = player.CharacterAdded.Connect((character: any) => {
			if (character !== originalCharacter && character !== ghostCharacter) {
				connection.Disconnect();
				resolve();
			}
		});
	});
	await deactivate();
}

async function activateGhost(): Promise<void> {
	const character = player.Character;
	const humanoid = character?.FindFirstChildWhichIsA("Humanoid");
	if (!character || !humanoid) {
		throw "Character or Humanoid is null";
	}

	// Create fake character
	character.Archivable = true;
	ghostCharacter = character.Clone();
	character.Archivable = false;

	// Save position to restore later
	const rootPart = character.FindFirstChild("HumanoidRootPart");
	lastPosition = rootPart?.IsA("BasePart") ? rootPart.CFrame : undefined;
	originalCharacter = character;

	// Add ghost effect
	const ghostHumanoid = ghostCharacter.FindFirstChildWhichIsA("Humanoid");
	for (const child of ghostCharacter.GetDescendants()) {
		if (child.IsA("BasePart")) {
			child.Transparency = 1 - (1 - child.Transparency) * 0.5;
		}
	}
	if (ghostHumanoid) {
		ghostHumanoid.DisplayName = "👻";
	}

	// Set up animation
	ghostCharacter.FindFirstChild("Animate")?.Destroy();
	const animation = originalCharacter.FindFirstChild("Animate") as any | undefined;
	if (animation) {
		animation.Disabled = true;
		animation.Parent = ghostCharacter;
	}

	// Set up fake character
	disableResetOnSpawn();
	ghostCharacter.Parent = character.Parent;
	player.Character = ghostCharacter;
	Workspace.CurrentCamera!.CameraSubject = ghostHumanoid;
	enableResetOnSpawn();

	// Start animation
	if (animation) {
		animation.Disabled = false;
	}

	// Respawn on death
	const handle = humanoid.Died.Connect(() => {
		handle.Disconnect();
		deactivate().catch((err: unknown) => {
			warn(`[ghost-worker-died] ${err}`);
		});
	});
}

function deactivateGhost(): Promise<void> {
	if (!originalCharacter || !ghostCharacter) {
		return Promise.resolve();
	}

	// Store current position in ghost mode if possible
	const rootPart = originalCharacter.FindFirstChild("HumanoidRootPart");
	const ghostRootPart = ghostCharacter.FindFirstChild("HumanoidRootPart");
	const currentPosition = ghostRootPart?.IsA("BasePart") ? ghostRootPart.CFrame : undefined;

	// Save animation script
	const animation = ghostCharacter.FindFirstChild("Animate") as any | undefined;
	if (animation) {
		animation.Disabled = true;
		animation.Parent = undefined;
	}

	// Remove fake character
	ghostCharacter.Destroy();

	// Clear animations on original character
	const humanoid = originalCharacter.FindFirstChildWhichIsA("Humanoid");
	humanoid?.GetPlayingAnimationTracks().forEach((track: any) => track.Stop());

	// Restore original character
	const position = currentPosition ?? lastPosition;
	if (rootPart?.IsA("BasePart") && position) {
		rootPart.CFrame = position;
	}

	disableResetOnSpawn();
	player.Character = originalCharacter;
	Workspace.CurrentCamera!.CameraSubject = humanoid;
	enableResetOnSpawn();

	// Restore animation
	if (animation) {
		animation.Parent = originalCharacter;
		animation.Disabled = false;
	}

	originalCharacter = undefined;
	ghostCharacter = undefined;
	lastPosition = undefined;

	return Promise.resolve();
}

main().catch((err: unknown) => {
	warn(`[ghost-worker] ${err}`);
});
