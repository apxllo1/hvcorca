import { Players, RunService } from "@rbxts/services";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import type { JobsAction } from "store/actions/jobs.action";

const player = Players.LocalPlayer;
let healthConnection: RBXScriptConnection | undefined;

function errorHandler(err: unknown) {
	(warn as (msg: string) => void)(`[godmode-worker] ${String(err)}`);
	deactivate().catch(() => {});
}

function main() {
	onJobChange("godmode", (job, state) => {
		if (state.jobs.ghost.active && job.active) {
			deactivate().catch((err) => (warn as (msg: string) => void)(`[godmode-worker] ${String(err)}`));
		} else if (job.active) {
			activateGodmode().catch(errorHandler);
		} else {
			deactivate().catch((err) => (warn as (msg: string) => void)(`[godmode-worker] ${String(err)}`));
		}
	}).catch((err) => (warn as (msg: string) => void)(`[godmode-worker] ${String(err)}`));
}

async function deactivate() {
	if (healthConnection) {
		healthConnection.Disconnect();
		healthConnection = undefined;
	}
	const store = await getStore();
	store.dispatch({
		type: "jobs/setJobActive",
		jobName: "godmode",
		active: false,
	} as JobsAction);
	print("[Godmode] Deactivated");
}

function activateGodmode(): Promise<void> {
	const character = player.Character;
	if (!character) return Promise.reject("No character found");
	const humanoid = character.FindFirstChildWhichIsA("Humanoid");
	if (!humanoid) return Promise.reject("No humanoid found");

	healthConnection = humanoid.HealthChanged.Connect(() => {
		if (humanoid.Health < humanoid.MaxHealth) {
			humanoid.Health = humanoid.MaxHealth;
		}
	});

	humanoid.MaxHealth = math.huge;
	humanoid.Health = humanoid.MaxHealth;

	humanoid.SetStateEnabled(Enum.HumanoidStateType.Dead, false);
	humanoid.BreakJointsOnDeath = false;

	print("[Godmode] Activated - Health locked at maximum");

	const backupLoop = RunService.Heartbeat.Connect(() => {
		if (humanoid && humanoid.Health < humanoid.MaxHealth) {
			humanoid.Health = humanoid.MaxHealth;
		}
	});

	const savedConnection = healthConnection;
	task.delay(0, () => {
		if (!savedConnection) backupLoop.Disconnect();
	});

	return Promise.resolve();
}

main();
