import Make from "@rbxts/make";
import Roact from "@rbxts/roact";
import { StoreProvider } from "@rbxts/roact-rodux-hooked";
import { configureStore } from "store/store";
import { setStore } from "jobs";
import { toggleDashboard } from "store/actions/dashboard.action";
import { Players, RunService } from "@rbxts/services";
import { IS_DEV, LOAD_GUARD } from "constants";
import App from "./App";

async function main(): Promise<void> {
	const g = (getgenv !== undefined ? getgenv() : _G) as Record<string, any>;

	if (g[LOAD_GUARD] === true) return;

	try {
		const store = configureStore();
		setStore(store);

		const host = (IS_DEV ? Players.LocalPlayer.WaitForChild("PlayerGui") : game.GetService("CoreGui")) as Instance;

		const container = Make("Folder", {
			Name: "HavocMount",
			Parent: host,
		});

		Roact.mount(
			<StoreProvider store={store}>
				<App />
			</StoreProvider>,
			container,
		);

		let app: ScreenGui | undefined = container.FindFirstChildWhichIsA("ScreenGui");
		const start = os.clock();
		while (!app && os.clock() - start < 10) {
			RunService.Heartbeat.Wait();
			app = container.FindFirstChildWhichIsA("ScreenGui");
		}

		if (!app) throw "ScreenGui failed to render";

		// Use typeIs/type to comply with roblox-ts requirements
		if (syn !== undefined && typeIs(syn.protect_gui, "function")) {
			syn.protect_gui(app as unknown as GuiObject);
		}

		app.Parent = game.GetService("CoreGui");

		g[LOAD_GUARD] = true;
		if (time() > 3) task.defer(() => store.dispatch(toggleDashboard()));
		print("[Havoc] Success");
	} catch (e: unknown) {
		warn("[Havoc] Init Error: " + tostring(e));
	}
}

main().catch((err: unknown) => warn("[Havoc] Fatal: " + tostring(err)));
