import { HttpService, Players, TeleportService } from "@rbxts/services";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import { setJobActive } from "store/actions/jobs.action";
import * as http from "utils/http";
import { setTimeout } from "utils/timeout";
import type { Timeout } from "utils/timeout";

interface GameServer {
	id: string;
	maxPlayers: number;
	playing: number;
}

interface GameServersResponse {
	data: Array<GameServer>;
}

async function onServerHop(): Promise<void> {
	queueExecution();
	const serversResult = await http.get(
		`https://games.roblox.com/v1/games/${game.PlaceId}/servers/Public?sortOrder=Asc&limit=100`,
	);
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

function onRejoin(): void {
	queueExecution();
	if (Players.GetPlayers().size() === 1) {
		TeleportService.Teleport(game.PlaceId, Players.LocalPlayer);
	} else {
		TeleportService.TeleportToPlaceInstance(game.PlaceId, game.JobId);
	}
}

function queueExecution(): void {
	const code =
		'loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/apxllo1/hvcorca/master/public/latest.lua"))()';
	(syn?.queue_on_teleport ?? queue_on_teleport)?.(code);
}

async function main(): Promise<void> {
	const store = await getStore();
	let timeout: Timeout | undefined;

	function clearTimeout(): void {
		timeout?.clear();
		timeout = undefined;
	}

	onJobChange("rejoinServer", (job, state) => {
		clearTimeout();
		if (state.jobs.switchServer.active) {
			store.dispatch(setJobActive("switchServer", false));
		}
		if (job.active) {
			timeout = setTimeout(() => {
				try {
					onRejoin();
				} catch (err: unknown) {
					warn(`[server-worker-rejoin] ${String(err)}`);
					store.dispatch(setJobActive("rejoinServer", false));
				}
			}, 1000);
		}
	});

	onJobChange("switchServer", (job, state) => {
		clearTimeout();
		if (state.jobs.rejoinServer.active) {
			store.dispatch(setJobActive("rejoinServer", false));
		}
		if (job.active) {
			timeout = setTimeout(() => {
				void onServerHop().catch((err: unknown) => {
					warn(`[server-worker-switch] ${String(err)}`);
					store.dispatch(setJobActive("switchServer", false));
				});
			}, 1000);
		}
	});
}

main().catch((err: unknown) => {
	warn(`[server-worker] ${String(err)}`);
});
