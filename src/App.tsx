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
	
	// FIX: Use delete to satisfy the compiler
	delete (startTimes as any)[name];
}

// ... keep the rest of your logger and performance code the same
