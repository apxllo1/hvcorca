import Make from "@rbxts/make";
import Roact from "@rbxts/roact";
import { withHookDetection } from "@rbxts/roact-hooked";
import { StoreProvider } from "@rbxts/roact-rodux-hooked";
import { Players } from "@rbxts/services";
import { IS_DEV, LOAD_GUARD } from "constants";
import { setStore } from "jobs";
import { toggleDashboard } from "store/actions/dashboard.action";
import { configureStore } from "store/store";
import App from "./App";

withHookDetection(Roact);

const store = configureStore();
setStore(store);

function mount() {
	const container = Make("Folder", {});
	Roact.mount(
		<StoreProvider store={store}>
			<App />
		</StoreProvider>,
		container,
	);
	return container.WaitForChild(1) as ScreenGui;
}

function render(app: ScreenGui) {
	const protect = syn ? syn.protect_gui : protect_gui;
	if (protect) {
		protect(app);
	}
	if (IS_DEV) {
		app.Parent = Players.LocalPlayer.WaitForChild("PlayerGui");
	} else if (gethui) {
		app.Parent = gethui();
	} else {
		app.Parent = game.GetService("CoreGui");
	}
}

async function main() {
	const g = getgenv ? getgenv() : _G;
	if (g[LOAD_GUARD] === true) {
		throw "Havoc is already loaded!";
	}
	const app = await mount();
	render(app);
	if (time() > 3) {
		task.defer(() => store.dispatch(toggleDashboard()));
	}
	if (getgenv) {
		getgenv()[LOAD_GUARD] = true;
	}
	print("[Havoc] Loaded successfully");
}

main().catch((err) => {
	warn(`[Havoc] Failed to load: ${err}`);
});
