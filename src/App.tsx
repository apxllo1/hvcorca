import Roact from "@rbxts/roact";
import { Stats } from "@rbxts/services";
import Dashboard from "./views/Dashboard";
import { startTimer, endTimer, logger, logPerformance } from "utils/debug";

const DISPLAY_ORDER = 7;

function App() {
	// We use useEffect to ensure this logic ONLY runs once when the UI first appears
	Roact.useEffect(() => {
		startTimer("Havoc_UI_Mount");
		logger.info("Havoc UI mounting sequence initiated...");

		// The "Pulse" check to ensure the script stays alive
		const thread = task.spawn(() => {
			while (task.wait(5)) {
				const mem = math.floor(Stats.GetTotalMemoryUsageMb());
				print(`[Havoc Pulse]: Main UI Active. Memory: ${mem}MB`);
			}
		});

		endTimer("Havoc_UI_Mount");
		logPerformance();

		// Cleanup: stops the pulse if the UI is ever destroyed
		return () => task.cancel(thread);
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
