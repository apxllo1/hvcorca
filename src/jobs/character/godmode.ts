import { Players, RunService } from "@rbxts/services";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import type { JobsAction } from "store/actions/jobs.action";

const player = Players.LocalPlayer;

let healthConnection: RBXScriptConnection | undefined;

function errorHandler(err: unknown) {
	warn(`[godmode-worker] ${err}`);
	void deactivate();
}

async function main() {
	onJobChange("godmode", (job, state) => {
		if (state.jobs.ghost.active && job.active) {
			// Conflict with ghost
			void deactivate();
		} else if (job.active) {
			void activateGodmode().catch(errorHandler);
		} else {
			void deactivate();
		}
	});
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

async function activateGodmode() {
	const character = player.Character;
	if (!character) throw "No character found";

	const humanoid = character.FindFirstChildWhichIsA("Humanoid");
	if (!humanoid) throw "No humanoid found";

	// Main godmode: keep health at maximum
	healthConnection = humanoid.HealthChanged.Connect(() => {
		if (humanoid.Health < humanoid.MaxHealth) {
			humanoid.Health = humanoid.MaxHealth;
		}
	});

	// Force max health immediately
	humanoid.MaxHealth = math.huge;
	humanoid.Health = humanoid.MaxHealth;

	// Optional: Prevent some death states
	humanoid.SetStateEnabled(Enum.HumanoidStateType.Dead, false);
	humanoid.BreakJointsOnDeath = false;

	print("[Godmode] Activated - Health locked at maximum");

	// Backup loop (in case HealthChanged is blocked in some games)
	const backupLoop = RunService.Heartbeat.Connect(() => {
		if (humanoid && humanoid.Health < humanoid.MaxHealth) {
			humanoid.Health = humanoid.MaxHealth;
		}
	});

	// Clean up backup when godmode ends
	healthConnection = healthConnection; // keep reference
	task.delay(0, () => {
		if (!healthConnection) backupLoop.Disconnect();
	});
}

main().catch((err) => {
	warn(`[godmode-worker] ${err}`);
});
