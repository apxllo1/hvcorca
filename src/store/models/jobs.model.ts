export interface Job {
	active: boolean;
}

export interface JobWithValue<T> extends Job {
	value: T;
}

export interface JobWithSliders extends Job {
	sliders: Record<string, number>;
}

export type InferJobValue<T> = T extends JobWithValue<infer V> ? V : never;

// This fixes the error in Sliders.tsx
export type JobsWithValue<T> = {
	[K in keyof JobsState]: JobsState[K] extends JobWithValue<T> ? JobsState[K] : never;
};

export type JobsState = {
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
} & { [key: string]: any }; // This allows indexing by string (fixing the Sliders.tsx error)

export const __FIX_JOBS = true;
