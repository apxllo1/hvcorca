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
 * Prevents multiple instances by checking the global environment.
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
 * Mounts the Roact app and polls for the resulting ScreenGui.
 */
async function mount(store: ReturnType<typeof configureStore>): Promise<ScreenGui> {
	// Identify the target host for the temporary container
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

	// Poll for the ScreenGui (Modular Roact apps take a few frames to mount)
	let appInstance = container.FindFirstChildWhichIsA("ScreenGui");
	const start = os.clock();

	while (!appInstance && os.clock() - start < MOUNT_TIMEOUT) {
		RunService.Heartbeat.Wait();
		appInstance = container.FindFirstChildWhichIsA("ScreenGui");
	}

	if (!appInstance) {
		container.Destroy();
		throw `Mount timed out: ScreenGui not found in App tree.`;
	}

	return appInstance;
}

/**
 * Protects and finalizes the UI location.
 */
function render(app: ScreenGui): void {
	// Bypasses TS2352 strictly to allow protection on the ScreenGui
	const protect = (syn as unknown as { protect_gui?: (gui: Instance) => void })?.protect_gui;
	if (protect) {
		pcall(() => protect(app));
	}

	if (IS_DEV) {
		app.Parent = Players.LocalPlayer.WaitForChild("PlayerGui") as Instance;
	} else {
		// Use gethui for modern executors (Wave/Solara), fallback to CoreGui
		const host = (gethui ? gethui() : game.GetService("CoreGui")) as Instance;
		app.Parent = host;
	}
}

async function main(): Promise<void> {
	if (checkAlreadyLoaded()) return;

	try {
		// 1. Setup Store
		const store = configureStore();
		setStore(store);

		// 2. Mount & Find UI
		const app = await mount(store);

		// 3. Move to final destination & Protect
		render(app);

		// 4. Set persistent guard
		const g = (getgenv ? getgenv() : _G) as Record<string, unknown>;
		g[LOAD_GUARD] = true;

		// 5. Open UI if injected into an active game
		if (time() > 2) {
			task.defer(() => store.dispatch(toggleDashboard()));
		}

		print("[Havoc] Successfully initialized.");
	} catch (err) {
		warn(`[Havoc] Init Error: ${tostring(err)}`);
	}
}

main().catch((err) => warn(`[Havoc] Fatal: ${tostring(err)}`));
