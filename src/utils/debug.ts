import { Stats } from "@rbxts/services";

// --- Timer Logic ---
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

	startTimes[name] = undefined;
}

// --- NEW: Logger Logic ---
// Use these to make your console output easy to read/filter
export const logger = {
	info: (msg: string) => print(`[Havoc INFO]: ${msg}`),
	warn: (msg: string) => warn(`[Havoc WARNING]: ${msg}`),
	critical: (msg: string) => {
		warn(`\n---------- CRITICAL ERROR ----------\n${msg}\n------------------------------------\n`);
	},
	// This helps you track state changes in the background
	debug: (msg: string) => {
		if (_G.__DEV__) {
			// Only prints if you have a dev flag enabled
			print(`[DEBUG]: ${msg}`);
		}
	},
};

// --- NEW: Memory & Performance Tracker ---
/**
 * Prints the current memory usage of the script environment.
 * Use this to check if your 18k line bundle is bloating.
 */
export function logPerformance() {
	const mem = Stats.GetTotalMemoryUsageMb();
	const heartbeat = 1 / (debug.profilebegin("Heartbeat") || 0.016); // Rough FPS estimate

	print(`--- Havoc Performance ---`);
	print(`Memory: ${math.floor(mem)} MB`);
	print(`Lua GC: ${math.floor(collectgarbage("count"))} KB`);
	print(`-------------------------`);
}
