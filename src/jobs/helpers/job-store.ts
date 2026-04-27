import type { JobsState } from "store/models/jobs.model";
import type { RootState, RootStore } from "store/store";
import { setInterval } from "utils/timeout";

const store: { current?: RootStore } = {};

export function setStore(newStore: RootStore) {
	if (store.current) {
		throw "Store has already been set";
	}
	store.current = newStore;
}

export async function getStore() {
	if (store.current) {
		return store.current;
	}
	return new Promise<RootStore>((resolve, _, onCancel) => {
		const interval = setInterval(() => {
			if (store.current) {
				resolve(store.current);
				interval.clear();
			}
		}, 100);
		onCancel(() => {
			interval.clear();
		});
	});
}

export async function onJobChange<K extends keyof JobsState>(
	jobName: K,
	callback: (job: JobsState[K], state: RootState) => void,
) {
	const store = await getStore();
	let lastJob = store.getState().jobs[jobName];

	return store.changed.connect((newState) => {
		const job = newState.jobs[jobName];
		
		// FIX: Check that both exist and cast to object for shallowEqual
		if (job !== undefined && lastJob !== undefined && !shallowEqual(job as object, lastJob as object)) {
			lastJob = job;
			task.defer(callback, job, newState);
		}
	});
}

// FIX: Added explicit types and handled the key indexing properly for roblox-ts
function shallowEqual(a: Record<string, unknown>, b: Record<string, unknown>) {
	if (a === b) return true;

	for (const [key, value] of pairs(a)) {
		if (value !== b[key as string]) {
			return false;
		}
	}
	for (const [key, value] of pairs(b)) {
		if (value !== a[key as string]) {
			return false;
		}
	}
	return true;
}
