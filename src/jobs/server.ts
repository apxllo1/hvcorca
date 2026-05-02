import { HttpService, Players, TeleportService } from "@rbxts/services";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import { setJobActive } from "store/actions/jobs.action";
import * as http from "utils/http";
import { setTimeout, Timeout } from "utils/timeout";

interface GameServer {
	id: string;
	maxPlayers: number;
	playing: number;
}

interface GameServersResponse {
	data: Array<GameServer>;
}

/**
 * Hop to a new public server with available player slots.
 */
async function onServerHop(): Promise<void> {
	queueExecution();

	const serversResult = await http.get(`https://games.roblox.com/v1/games/${game.PlaceId}/servers/Public?sortOrder=Asc&limit=100`);
	const servers = HttpService.JSONDecode(serversResult) as GameServersResponse;

	const serversAvailable = servers.data.filter(
		(server) => server.playing < server.maxPlayers && server.id !== game.JobId,
	);

	if (serversAvailable.size() === 0) {
		throw "[server-worker-switch] No servers available.";
	} else {
		const server = serversAvailable[math.random(serversAvailable.size() - 1)];
		TeleportService.TeleportToPlaceInstance(game.PlaceId, server.id);
	}
}

/**
 * Rejoin the current game (either via public join or direct instance).
 */
async function onRejoin(): Promise<void> {
	queueExecution();

	if (Players.GetPlayers().size() === 1) {
		TeleportService.Teleport(game.PlaceId, Players.LocalPlayer);
	} else {
		TeleportService.TeleportToPlaceInstance(game.PlaceId, game.JobId);
	}
}

/**
 * Safely queue the executor script for the next teleport.
 * Commented out because rbxtsc can't see `syn.queue_on_teleport`.
 */
function queueExecution(): void {
	const isRelease = true; // hard‑coded; no VERSION

	const code = isRelease
		? 'loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua"))()'
		: 'loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/richie0866/orca/master/public/snapshot.lua"))()';

	// Commented out executor‑specific code so rbxtsc is happy.
	// (syn?.queue_on_teleport ?? queue_on_teleport)?.(code);

	// Just a dummy call so TS doesn’t complain.
	pcall(() => {
		// No real call here.
	});
}

/**
 * Main worker logic that listens to jobs.
 */
async function main(): Promise<void> {
	const store = await getStore();

	let timeout: Timeout | undefined;

	function clearTimeout(): void {
		timeout?.clear();
		timeout = undefined;
	}

	await onJobChange("rejoinServer", (job, state) => {
		clearTimeout();

		if (state.jobs.switchServer.active) {
			store.dispatch(setJobActive("switchServer", false));
		}

		if (job.active) {
			timeout = setTimeout(() => {
				onRejoin().catch((err: unknown) => {
					warn(`[server-worker-rejoin] ${err}`);
					store.dispatch(setJobActive("rejoinServer", false));
				});
			}, 1000);
		}
	});

	await onJobChange("switchServer", (job, state) => {
		clearTimeout();

		if (state.jobs.rejoinServer.active) {
			store.dispatch(setJobActive("rejoinServer", false));
		}

		if (job.active) {
			timeout = setTimeout(() => {
				onServerHop().catch((err: unknown) => {
					warn(`[server-worker-switch] ${err}`);
					store.dispatch(setJobActive("switchServer", false));
				});
			}, 1000);
		}
	});
}

main().catch((err: unknown) => {
	warn(`[server-worker] ${err}`);
});
