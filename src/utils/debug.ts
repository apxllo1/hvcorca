import { Stats } from "@rbxts/services";

const debugCounter: Record<string, number> = {};
const startTimes: Record<string, number> = {};

/**
 * Starts a named timer to profile execution speed.
 */
export function startTimer(name: string) {
	debugCounter[name] = (debugCounter[name] ?? 0) + 1;
	startTimes[name] = os.clock();
}

/**
 * Ends a timer and prints the elapsed time in milliseconds.
 */
export function endTimer(name: string) {
	const startTime = startTimes[name];
	if (startTime === undefined) return;

	const diff = os.clock() - startTime;
	const count = debugCounter[name] ?? 0;
	
	print(`\n[Havoc Timer: ${name} #${count}]\nExecution: ${math.floor(diff * 10000) / 10} ms\n`);
	
	delete (startTimes as any)[name];
}

/**
 * Professional logger for console filtering.
 */
export const logger = {
	info: (msg: string) => print(`[Havoc INFO]: ${msg}`),
	warn: (msg: string) => warn(`[Havoc WARNING]: ${msg}`),
	critical: (msg: string) => {
		warn(`\n---------- CRITICAL ERROR ----------\n${msg}\n------------------------------------\n`);
	},
	debug: (msg: string) => {
		if ((_G as any)["__DEV__"]) { 
			print(`[DEBUG]: ${msg}`);
		}
	}
};

/**
 * Logs current script memory usage.
 */
export function logPerformance() {
	const mem = Stats.GetTotalMemoryUsageMb();
	
	print(`\n--- Havoc Performance ---`);
	print(`Memory: ${math.floor(mem)} MB`);
	print(`Lua GC: ${math.floor(collectgarbage("count"))} KB`);
	print(`-------------------------\n`);
}
