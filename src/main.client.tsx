import Make from "@rbxts/make";
import Roact from "@rbxts/roact";
import { Provider } from "@rbxts/roact-rodux-hooked";
import { Players } from "@rbxts/services";
import { IS_DEV } from "constants";
import { setStore } from "jobs";
import { toggleDashboard } from "store/actions/dashboard.action";
import { configureStore } from "store/store";
import App from "./App";

const LOAD_GUARD = "_HAVOC_IS_LOADED";
const MOUNT_TIMEOUT = 10;

/**
 * Prevents double-loading in auto-execution environments.
 */
function checkAlreadyLoaded(): boolean {
	if (getgenv && LOAD_GUARD in getgenv()) {
		warn("[Havoc] Already loaded — skipping.");
		return true;
	}
	return false;
}

/**
 * Mounts the Roact tree and waits for the ScreenGui to appear.
 */
async function mount(store: ReturnType<typeof configureStore>): Promise<ScreenGui> {
	const container = Make("Folder", {});
	Roact.mount(
		<Provider store={store}>
			<App />
		</Provider>,
		container,
	);
	const app = container.WaitForChild(MOUNT_TIMEOUT) as ScreenGui | undefined;
	if (!app) {
		throw `[Havoc] Mount timed out after ${MOUNT_TIMEOUT}s — ScreenGui never appeared.`;
	}
	return app as ScreenGui;
}

/**
 * Parents the ScreenGui to the correct container.
 * Prefers syn.protect_gui, then gethui, then CoreGui, then PlayerGui in dev.
 */
function render(app: ScreenGui): void {
	const protect = syn?.protect_gui ?? protect_gui;
	if (protect) {
		pcall(() => protect(app));
	}

	if (IS_DEV) {
		app.Parent = Players.LocalPlayer.WaitForChild("PlayerGui") as Instance;
	} else if (gethui) {
		app.Parent = gethui();
	} else {
		app.Parent = game.GetService("CoreGui");
	}
}

/**
 * Entry point.
 */
async function main(): Promise<void> {
	if (checkAlreadyLoaded()) return;

	const store = configureStore();
	setStore(store);

	const app = await mount(store);
	render(app);

	// Auto-open dashboard if the game has been running for more than 3 seconds
	if (time() > 3) {
		task.defer(() => store.dispatch(toggleDashboard()));
	}

	if (getgenv) {
		getgenv()[LOAD_GUARD] = true;
	}
}

main().catch((err: unknown) => {
	warn(`[Havoc] Failed to load: ${tostring(err)}`);
});
