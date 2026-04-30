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
 * Checks if Havoc is already running in the current session.
 */
function checkAlreadyLoaded(): boolean {
	const g = (getgenv ? getgenv() : _G) as Record<string, any>;
	if (g[LOAD_GUARD] === true) {
		warn("[Havoc] Already loaded — skipping execution.");
		return true;
	}
	return false;
}

/**
 * Mounts the Roact tree into a temporary folder and waits for the ScreenGui to appear.
 */
async function mount(store: ReturnType<typeof configureStore>): Promise<ScreenGui> {
	// Use CoreGui via GetService to satisfy roblox-ts compiler permissions
	const host = IS_DEV
		? (Players.LocalPlayer.WaitForChild("PlayerGui") as Instance)
		: (game.GetService("CoreGui") as Instance);

	const container = Make("Folder", {
		Name: "HavocMount",
		Parent: host,
	});

	Roact.mount(
		<Provider store={store}>
			<App />
		</Provider>,
		container,
	);

	// In modular builds, the ScreenGui might not exist the exact millisecond mount() is called
	let appInstance = container.FindFirstChildWhichIsA("ScreenGui");
	const start = os.clock();

	while (!appInstance && os.clock() - start < MOUNT_TIMEOUT) {
		RunService.Heartbeat.Wait();
		appInstance = container.FindFirstChildWhichIsA("ScreenGui");
	}

	if (!appInstance) {
		container.Destroy();
		throw `[Havoc] Mount Failure: App rendered but no ScreenGui was found within ${MOUNT_TIMEOUT}s.`;
	}

	return appInstance;
}

/**
 * Handles UI protection for executors and final parenting.
 */
function render(app: ScreenGui): void {
	// Bypasses TS error for custom executor globals
	const syn_obj = syn as unknown as { protect_gui?: (gui: Instance) => void };
	const protect = syn_obj?.protect_gui;

	if (protect) {
		pcall(() => protect(app));
	}

	if (IS_DEV) {
		app.Parent = Players.LocalPlayer.WaitForChild("PlayerGui") as Instance;
	} else {
		// Use gethui() if available (Wave/Solara/etc), otherwise fallback to CoreGui
		const host = (gethui ? gethui() : game.GetService("CoreGui")) as Instance;
		app.Parent = host;
	}
}

/**
 * Entry point for the client script.
 */
async function main(): Promise<void> {
	if (checkAlreadyLoaded()) return;

	try {
		// 1. Initialize Redux Store
		const store = configureStore();
		setStore(store);

		// 2. Mount Roact Tree
		const app = await mount(store);

		// 3. Move and Protect UI
		render(app);

		// 4. Set Global Guard to prevent re-execution
		const g = (getgenv ? getgenv() : _G) as Record<string, any>;
		g[LOAD_GUARD] = true;

		// 5. If injected late, toggle the dashboard open automatically
		if (time() > 3) {
			task.defer(() => store.dispatch(toggleDashboard()));
		}

		print("[Havoc] Client initialized successfully.");
	} catch (err) {
		warn(`[Havoc] Initialization Error: ${tostring(err)}`);
	}
}

// Start execution
main().catch((err) => {
	warn(`[Havoc] Fatal Runtime Error: ${tostring(err)}`);
});
