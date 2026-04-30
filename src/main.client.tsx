import Make from "@rbxts/make";
import Roact from "@rbxts/roact";
import { Provider } from "@rbxts/roact-rodux-hooked";
import { Players, RunService } from "@rbxts/services";
import { IS_DEV } from "constants";
import { setStore } from "jobs";
import { toggleDashboard } from "store/actions/dashboard.action";
import { configureStore } from "store/store";
import App from "./App";

const LOAD_GUARD = "_HAVOC_IS_LOADED";

async function main() {
	const g = (getgenv ? getgenv() : _G) as Record<string, any>;
	if (g[LOAD_GUARD] === true) return;

	try {
		const store = configureStore();
		setStore(store);

		// Parent to CoreGui via GetService to pass TS compiler
		const host = IS_DEV
			? (Players.LocalPlayer.WaitForChild("PlayerGui") as Instance)
			: (game.GetService("CoreGui") as Instance);

		const container = Make("Folder", { Name: "HavocMount", Parent: host });

		Roact.mount(
			<Provider store={store}>
				<App />
			</Provider>,
			container,
		);

		// Wait for Roact to actually create the ScreenGui
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

		if (!IS_DEV) {
			app.Parent = (gethui ? gethui() : game.GetService("CoreGui")) as Instance;
		}

		g[LOAD_GUARD] = true;
		if (time() > 3) task.defer(() => store.dispatch(toggleDashboard()));
		print("[Havoc] Success");
	} catch (e) {
		warn("[Havoc] Init Error: " + tostring(e));
	}
}

main().catch(warn);
