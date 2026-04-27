export interface Job {
	readonly active: boolean;
}

export interface JobWithValue<T> extends Job {
	readonly value: T;
}

export interface JobWithSliders extends Job {
	readonly sliders: Record<string, number>;
}

export type InferJobValue<T> = T extends JobWithValue<infer V> ? V : never;

// This fixes the 'no exported member' error in Sliders.tsx
export type JobsWithValue<T> = {
	[K in keyof JobsState]: JobsState[K] extends JobWithValue<T> ? JobsState[K] : never;
};

export interface JobsState {
	flight: JobWithValue<number>;
	walkSpeed: JobWithValue<number>;
	jumpHeight: JobWithValue<number>;

	refresh: Job;
	ghost: Job;
	godmode: Job;
	freecam: Job;

	teleport: Job;
	hide: Job;
	kill: Job;
	spectate: Job;
	
	facebang: JobWithSliders;

	rejoinServer: Job;
	switchServer: Job;

	/** Index signature to allow dynamic access without 'any' */
	[key: string]: Job | JobWithValue<number> | JobWithSliders | undefined;
}

export const __FIX_JOBS = true;
