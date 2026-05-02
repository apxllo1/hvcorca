import Roact from "@rbxts/roact";
import { useEffect, useState } from "@rbxts/roact-hooked";
import { Stats } from "@rbxts/services";
import Dashboard from "./views/Dashboard";
import { startTimer, endTimer, logger, logPerformance } from "utils/debug";

const DISPLAY_ORDER = 7;

function App() {
	const [searchText] = useState("");
	const [searchFocused, setSearchFocused] = useState(false);

	useEffect(() => {
		startTimer("Havoc_UI_Mount");
		logger.info("Havoc UI mounting sequence initiated...");

		// The Pulse: keeps printing every 5s to prove the thread is alive
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

		// Cleanup
		return () => {
			isRunning = false;
		};
	}, []);

	const handleSearchChanged = (rbx: TextBox) => {
		// Just mirror the text
		// If you want, you can wire this to a search filter somewhere
		print("Search text:", rbx.Text);
	};

	const handleSearchFocus = () => {
		setSearchFocused(true);
	};

	const handleSearchBlur = () => {
		setSearchFocused(false);
	};

	return (
		<screengui
			IgnoreGuiInset
			ResetOnSpawn={false}
			ZIndexBehavior={Enum.ZIndexBehavior.Sibling}
			DisplayOrder={DISPLAY_ORDER}
		>
			{/* Simple search bar frame */}
			<frame
				Key="SearchBarFrame"
				Size={new UDim2(0.3, 0, 0.08, 0)}
				Position={new UDim2(0.05, 0, 0.05, 0)}
				BackgroundColor3={new Color3(0.15, 0.15, 0.15)}
				BackgroundTransparency={0}
				BorderColor3={new Color3(0.3, 0.3, 0.3)}
			>
				<uipadding
					PaddingLeft={new UDim(0, 8)}
					PaddingRight={new UDim(0, 8)}
					PaddingTop={new UDim(0, 4)}
					PaddingBottom={new UDim(0, 4)}
				/>

				<textbox
					Key="SearchBarInput"
					Text={searchText}
					Size={new UDim2(1, 0, 1, 0)}
					BackgroundTransparency={0}
					BackgroundColor3={new Color3(0.1, 0.1, 0.1)}
					TextColor3={new Color3(1, 1, 1)}
					Font={Enum.Font.Gotham}
					TextSize={14}
					ClearTextOnFocus={false}
					Change={{
						Text: handleSearchChanged,
					}}
					Event={{
						Focused: handleSearchFocus,
						FocusLost: handleSearchBlur,
					}}
				/>
			</frame>

			{/* Your main Dashboard UI */}
			<Dashboard />
		</screengui>
	);
}

export default App;
