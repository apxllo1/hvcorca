import Roact from "@rbxts/roact";
import Dashboard from "./views/Dashboard";

const DISPLAY_ORDER = 7;

function App() {
	return (
		<screengui IgnoreGuiInset ResetOnSpawn={false} ZIndexBehavior="Sibling" DisplayOrder={DISPLAY_ORDER}>
			<Dashboard />
		</screengui>
	);
}

export default App;
