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

/**
 * Checks the global environment to prevent multiple instances of the script.
 */
function checkAlreadyLoaded(): boolean {
	const g = (getgenv ? getgenv() : _G) as Record<string, unknown>;
	if (g[LOAD_GUARD] === true) {
		warn("[Havoc] Already loaded — skipping.");
		return true;
	}
	return false;
}

/**
 * Mounts the Roact tree into a container and polls for the ScreenGui.
 */
async function mount(store: ReturnType<typeof configureStore>): Promise<ScreenGui> {
	// Create a temporary container for mounting
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

	// Poll for the ScreenGui created by App.tsx
	let appInstance = container.FindFirstChildWhichIsA("ScreenGui");
	if (!appInstance) {
		const start = os.clock();
		while (!appInstance && os.clock() - start < MOUNT_TIMEOUT) {
			appInstance = container.FindFirstChildWhichIsA("ScreenGui");
			RunService.Heartbeat.Wait();
		}
	}

	if (!appInstance) {
		throw `[Havoc] Mount timed out after ${MOUNT_TIMEOUT}s. ScreenGui not found.`;
	}

	return appInstance;
}

/**
 * Protects the UI from detection and moves it to the final destination.
 */
function render(app: ScreenGui): void {
	// DOUBLE-CAST FIX: Bypasses TS2352 overlap error between ScreenGui and Instance
	const protect = (syn as unknown as { protect_gui?: (gui: Instance) => void })?.protect_gui;

	if (protect) {
		const [success, err] = pcall(() => protect(app));
		if (!success) warn(`[Havoc] protect_gui failed: ${err}`);
	}

	if (IS_DEV) {
		app.Parent = Players.LocalPlayer.WaitForChild("PlayerGui") as Instance;
	} else {
		// Use gethui for modern executors, fallback to CoreGui
		const host = (gethui ? gethui() : game.GetService("CoreGui")) as Instance;
		app.Parent = host;
	}
}

/**
 * Initialization entry point.
 */
async function main(): Promise<void> {
	if (checkAlreadyLoaded()) return;

	try {
		const store = configureStore();
		setStore(store);

		const app = await mount(store);
		render(app);

		// Auto-open UI if injected into an active game session
		if (time() > 3) {
			task.defer(() => store.dispatch(toggleDashboard()));
		}

		// Set the guard to prevent re-loads
		const g = (getgenv ? getgenv() : _G) as Record<string, unknown>;
		g[LOAD_GUARD] = true;

		print("[Havoc] Loaded successfully.");
	} catch (err) {
		warn(`[Havoc] Init Error: ${tostring(err)}`);
	}
}

main().catch((err) => {
	warn(`[Havoc] Fatal startup error: ${tostring(err)}`);
});
