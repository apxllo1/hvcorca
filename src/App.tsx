import Roact from "@rbxts/roact";
import Dashboard from "./views/Dashboard";
import { startTimer, endTimer, logger, logPerformance } from "utils/debug";

// Above topbar, below prompts
const DISPLAY_ORDER = 7;

function App() {
	// 1. Start the Timer right when the UI component begins to mount
	startTimer("Havoc_UI_Mount");
	logger.info("Havoc UI is mounting...");

	const element = (
		<screengui IgnoreGuiInset ResetOnSpawn={false} ZIndexBehavior="Sibling" DisplayOrder={DISPLAY_ORDER}>
			<Dashboard />
		</screengui>
	);

	// 2. End the timer and log performance
	endTimer("Havoc_UI_Mount");
	logPerformance();

	return element;
}

export default App;
