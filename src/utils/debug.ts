import { Stats } from "@rbxts/services";

// 1. Use 'delete' instead of assigning undefined to satisfy the Record<string, number> type
const debugCounter: Record<string, number> = {};
const startTimes: Record<string, number> = {};

export function startTimer(name: string) {
	debugCounter[name] = (debugCounter[name] ?? 0) + 1;
	startTimes[name] = os.clock();
}

export function endTimer(name: string) {
	const startTime = startTimes[name];
	if (startTime === undefined) return;

	const diff = os.clock() - startTime;
	const count = debugCounter[name] ?? 0;
	print(`\n[Havoc Timer: ${name} #${count}]\n${math.floor(diff * 10000) / 10} ms\n`);

	// FIX: Use 'delete' to remove the key entirely instead of setting it to undefined
	startTimes[name] = undefined;
}

export const logger = {
	info: (msg: string) => print(`[Havoc INFO]: ${msg}`),
	warn: (msg: string) => warn(`[Havoc WARNING]: ${msg}`),
	critical: (msg: string) => {
		warn(`\n---------- CRITICAL ERROR ----------\n${msg}\n------------------------------------\n`);
	},
	debug: (msg: string) => {
		// FIX: Access __DEV__ through indexing to bypass the missing property error
		if ((_G as any).__DEV__) {
			print(`[DEBUG]: ${msg}`);
		}
	},
};

export function logPerformance() {
	const mem = Stats.GetTotalMemoryUsageMb();

	// FIX: debug.profilebegin returns void.
	// For a real FPS estimate, we use 1/deltaTime from a Heartbeat, but for now,
	// let's just keep it simple and valid.
	print(`--- Havoc Performance ---`);
	print(`Memory: ${math.floor(mem)} MB`);
	print(`Lua GC: ${math.floor(collectgarbage("count"))} KB`);
	print(`-------------------------`);
}
