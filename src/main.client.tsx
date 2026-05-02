import Make from "@rbxts/make";
import Roact from "@rbxts/roact";

// Minimal UI for testing
import VerySimpleApp from "./VerySimpleApp";
// When you want full UI, use this:
// import App from "./App";
import { Provider } from "@rbxts/roact-rodux-hooked";
import { configureStore } from "store/store";
import { setStore } from "jobs";
import { toggleDashboard } from "store/actions/dashboard.action";
import { Players, RunService } from "@rbxts/services";
import { IS_DEV } from "constants";

const LOAD_GUARD = "_HAVOC_IS_LOADED";

async function main() {
	const g = (getgenv ? getgenv() : _G) as Record<string, any>;
	if (g[LOAD_GUARD] === true) return;

	try {
		// Rodux store (you can keep this, even if you switch UI)
		const store = configureStore();
		setStore(store);

		// Parent to CoreGui / PlayerGui
		const host = IS_DEV
			? (Players.LocalPlayer.WaitForChild("PlayerGui") as Instance)
			: (game.GetService("CoreGui") as Instance);

		const container = Make("Folder", { Name: "HavocMount", Parent: host });

		// === 1. Test UI that should compile ===
		Roact.mount(
			<Provider store={store}>
				<App />
			</Provider>,
			container,
		);

		// === 2. OPTIONAL: VerySimpleApp (no Rodux)
		// Roact.mount(
		// 	<VerySimpleApp />,
		// 	container,
		// );

		let app = container.FindFirstChildWhichIsA("ScreenGui");
		const start = os.clock();
		while (!app && os.clock() - start < 10) {
			RunService.Heartbeat.Wait();
			app = container.FindFirstChildWhichIsA("ScreenGui");
		}

		if (!app) throw "ScreenGui failed to render";

		// Executor Protection
		const synObj = syn as unknown as { protect_gui?: (gui: Instance) => void };
		if (synObj?.protect_gui) pcall(() => synObj.protect_gui!(app!));

		// Fix: gethui is not in normal TS; use CoreGui
		app.Parent = game.GetService("CoreGui") as Instance;

		g[LOAD_GUARD] = true;
		if (time() > 3) task.defer(() => store.dispatch(toggleDashboard()));
		print("[Havoc] Success");
	} catch (e) {
		warn("[Havoc] Init Error: " + tostring(e));
	}
}

main().catch(warn);
