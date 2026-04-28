import Roact from "@rbxts/roact";
import { useEffect } from "@rbxts/roact-hooked"; // Standalone hook import
import { Stats } from "@rbxts/services";
import Dashboard from "./views/Dashboard";
import { startTimer, endTimer, logger, logPerformance } from "utils/debug";

const DISPLAY_ORDER = 7;

function App() {
	// Logic inside useEffect only runs ONCE on mount
	useEffect(() => {
		startTimer("Havoc_UI_Mount");
		logger.info("Havoc UI mounting sequence initiated...");

		// The Pulse: Keeps printing every 5s to prove the thread is alive
		let isRunning = true;
		task.spawn(() => {
			while (isRunning) {
				const mem = math.floor(Stats.GetTotalMemoryUsageMb());
				print(`[Havoc Pulse]: Main UI Active. Memory: ${mem}MB`);
				task.wait(5);
			}
		});

		endTimer("Havoc_UI_Mount");
		logPerformance();

		// Cleanup function: Triggered when the UI is closed/destroyed
		return () => {
			isRunning = false;
		};
	}, []);

	return (
		<screengui
			IgnoreGuiInset
			ResetOnSpawn={false}
			ZIndexBehavior={Enum.ZIndexBehavior.Sibling}
			DisplayOrder={DISPLAY_ORDER}
		>
			<Dashboard />
		</screengui>
	);
}

export default App;
