import { HttpService, Players } from "@rbxts/services";
import { getStore } from "../jobs/helpers/job-store";
import type { RootState } from "./store";
import { setInterval } from "../utils/timeout";

const warnLog = warn as (msg: string) => void;

if (typeIs(makefolder, "function") && !isfolder("_orca")) {
	makefolder("_orca");
}

function read(file: string): string | undefined {
	if (typeIs(readfile, "function") && isfile(file)) {
		return readfile(file);
	}
	return undefined;
}

function write(file: string, content: string): void {
	if (typeIs(writefile, "function")) {
		writefile(file, content);
	}
}

export function persistentState<T extends object>(name: string, selector: (state: RootState) => T, defaultValue: T): T {
	try {
		const serializedState = read(`_orca/${name}.json`);
		if (serializedState === undefined) {
			write(`_orca/${name}.json`, HttpService.JSONEncode(defaultValue));
			autosave(name, selector).catch((err: unknown) => warnLog(`[PersistentState] ${tostring(err)}`));
			return defaultValue;
		}
		const value = HttpService.JSONDecode(serializedState) as T;
		autosave(name, selector).catch((err: unknown) => warnLog(`[PersistentState] ${tostring(err)}`));
		return value;
	} catch (err: unknown) {
		warnLog(`[PersistentState] Load failed for ${name}: ${tostring(err)}`);
		return defaultValue;
	}
}

async function autosave(name: string, selector: (state: RootState) => object) {
	const store = await getStore();
	const save = () => {
		try {
			const state = selector(store.getState());
			write(`_orca/${name}.json`, HttpService.JSONEncode(state));
		} catch (err: unknown) {
			warnLog(`[PersistentState] Autosave failed for ${name}: ${tostring(err)}`);
		}
	};
	setInterval(save, 60000);
	Players.PlayerRemoving.Connect((player) => {
		if (player === Players.LocalPlayer) {
			save();
		}
	});
}
