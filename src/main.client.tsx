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
const MOUNT_TIMEOUT = 10;

function checkAlreadyLoaded(): boolean {
	const g = (getgenv ? getgenv() : _G) as Record<string, unknown>;
	if (g[LOAD_GUARD] === true) {
		warn("[Havoc] Already loaded — skipping.");
		return true;
	}
	return false;
}

async function mount(store: ReturnType<typeof configureStore>): Promise<ScreenGui> {
	const container = Make("Folder", {
		Name: "HavocMountContainer",
		Parent: IS_DEV
			? (Players.LocalPlayer.WaitForChild("PlayerGui") as Instance)
			: (game.GetService("CoreGui") as Instance),
	});

	Roact.mount(
		<Provider store={store}>
			<App />
		</Provider>,
		container,
	);

	let appInstance = container.FindFirstChildWhichIsA("ScreenGui");
	if (!appInstance) {
		const start = os.clock();
		while (!appInstance && os.clock() - start < MOUNT_TIMEOUT) {
			appInstance = container.FindFirstChildWhichIsA("ScreenGui");
			RunService.Heartbeat.Wait();
		}
	}

	if (!appInstance) throw `[Havoc] Mount timed out.`;
	return appInstance;
}

function render(app: ScreenGui): void {
	// FIX: Use 'as unknown' to bypass the TS2352 overlap error
	const protect = (syn as unknown as { protect_gui?: (gui: Instance) => void })?.protect_gui;

	if (protect) {
		pcall(() => protect(app));
	}

	if (IS_DEV) {
		app.Parent = Players.LocalPlayer.WaitForChild("PlayerGui") as Instance;
	} else {
		app.Parent = (gethui ? gethui() : game.GetService("CoreGui")) as Instance;
	}
}

async function main(): Promise<void> {
	if (checkAlreadyLoaded()) return;

	try {
		const store = configureStore();
		setStore(store);
		const app = await mount(store);
		render(app);

		if (time() > 3) {
			task.defer(() => store.dispatch(toggleDashboard()));
		}

		const g = (getgenv ? getgenv() : _G) as Record<string, unknown>;
		g[LOAD_GUARD] = true;
	} catch (err) {
		warn(`[Havoc] Init Error: ${err}`);
	}
}

main().catch(warn);
