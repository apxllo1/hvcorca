import { Players } from "@rbxts/services";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import type { JobWithValue } from "store/models/jobs.model";

const JUMP_POWER_CONSTANT = 349.24;
const player = Players.LocalPlayer;
const defaults = {
	walkSpeed: 16,
	jumpHeight: 7.2,
};
let humanoid: Humanoid | undefined;
let walkSpeedJob: JobWithValue<number>;
let jumpHeightJob: JobWithValue<number>;

async function main() {
	const store = await getStore();
	const state = store.getState();
	walkSpeedJob = state.jobs.walkSpeed;
	jumpHeightJob = state.jobs.jumpHeight;

	// Initial setup
	humanoid = player.Character?.FindFirstChildWhichIsA("Humanoid");
	setDefaultWalkSpeed(humanoid);
	setDefaultJumpHeight(humanoid);

	onJobChange("walkSpeed", (job) => {
		walkSpeedJob = job;
		updateWalkSpeed(humanoid, job);
	});

	onJobChange("jumpHeight", (job) => {
		jumpHeightJob = job;
		updateJumpHeight(humanoid, job);
	});

	// Handle respawn
	player.CharacterAdded.Connect((character) => {
		const newHumanoid = character.WaitForChild("Humanoid", 5) as Humanoid | undefined;
		if (newHumanoid?.IsA("Humanoid")) {
			humanoid = newHumanoid;
			setDefaultWalkSpeed(newHumanoid);
			setDefaultJumpHeight(newHumanoid);
			if (walkSpeedJob.active) updateWalkSpeed(newHumanoid, walkSpeedJob);
			if (jumpHeightJob.active) updateJumpHeight(newHumanoid, jumpHeightJob);
		}
	});
}

function setDefaultWalkSpeed(humanoid: Humanoid | undefined) {
	if (humanoid) {
		defaults.walkSpeed = humanoid.WalkSpeed;
	}
}

function setDefaultJumpHeight(humanoid: Humanoid | undefined) {
	if (humanoid) {
		defaults.jumpHeight = humanoid.JumpHeight;
	}
}

function updateWalkSpeed(humanoid: Humanoid | undefined, job: JobWithValue<number>) {
	if (!humanoid) return;
	humanoid.WalkSpeed = job.active ? job.value : defaults.walkSpeed;
}

function updateJumpHeight(humanoid: Humanoid | undefined, job: JobWithValue<number>) {
	if (!humanoid) return;
	if (job.active) {
		humanoid.JumpHeight = job.value;
		if (humanoid.UseJumpPower) {
			humanoid.JumpPower = math.sqrt(JUMP_POWER_CONSTANT * job.value);
		}
	} else {
		humanoid.JumpHeight = defaults.jumpHeight;
		if (humanoid.UseJumpPower) {
			humanoid.JumpPower = math.sqrt(JUMP_POWER_CONSTANT * defaults.jumpHeight);
		}
	}
}

main().catch((err) => {
	warn(`[humanoid-worker] ${err}`);
});
