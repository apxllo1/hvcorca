import Make from "@rbxts/make";
import Roact from "@rbxts/roact";
import { Provider } from "@rbxts/roact-rodux-hooked";
import { Players, RunService, CoreGui } from "@rbxts/services";
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
	// We use a folder to hold the mount so we can find the ScreenGui easily
	const container = Make("Folder", {
		Name: "HavocMount",
		Parent: IS_DEV ? (Players.LocalPlayer.WaitForChild("PlayerGui") as Instance) : (CoreGui as Instance),
	});

	Roact.mount(
		<Provider store={store}>
			<App />
		</Provider>,
		container,
	);

	// Poll until App.tsx renders the ScreenGui
	let appInstance = container.FindFirstChildWhichIsA("ScreenGui");
	const start = os.clock();

	while (!appInstance && os.clock() - start < MOUNT_TIMEOUT) {
		RunService.Heartbeat.Wait();
		appInstance = container.FindFirstChildWhichIsA("ScreenGui");
	}

	if (!appInstance) {
		container.Destroy();
		throw `[Havoc] Mount timed out. App failed to render ScreenGui.`;
	}

	return appInstance;
}

function render(app: ScreenGui): void {
	// DOUBLE-CAST: Resolves TS2352 strictly.
	const protect = (syn as unknown as { protect_gui?: (gui: Instance) => void })?.protect_gui;

	if (protect) {
		const [success, err] = pcall(() => protect(app));
		if (!success) warn(`[Havoc] Protection error: ${err}`);
	}

	if (IS_DEV) {
		app.Parent = Players.LocalPlayer.WaitForChild("PlayerGui") as Instance;
	} else {
		// Use gethui for modern executors (Wave, Solara, etc.), fallback to CoreGui
		const host = (gethui ? gethui() : CoreGui) as Instance;
		app.Parent = host;
	}
}

async function main(): Promise<void> {
	if (checkAlreadyLoaded()) return;

	try {
		// 1. Initialize Store
		const store = configureStore();
		setStore(store);

		// 2. Mount Roact tree
		const app = await mount(store);

		// 3. Protect and parent UI
		render(app);

		// 4. Auto-open if injected late
		if (time() > 2) {
			task.defer(() => store.dispatch(toggleDashboard()));
		}

		// 5. Set Global Guard
		const g = (getgenv ? getgenv() : _G) as Record<string, unknown>;
		g[LOAD_GUARD] = true;

		print("[Havoc] Successfully initialized.");
	} catch (err) {
		warn(`[Havoc] Init Error: ${tostring(err)}`);
	}
}

main().catch((err) => warn(`[Havoc] Fatal: ${tostring(err)}`));
