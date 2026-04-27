export interface Job {
	active: boolean;
}

export interface JobWithValue<T> extends Job {
	value: T;
}

// New interface to support multiple sliders (Angle, Distance, etc.)
export interface JobWithSliders extends Job {
	sliders: Record<string, number>;
}

export type InferJobValue<T> = T extends JobWithValue<infer V> ? V : never;

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
	
	// FIXED: Now supports sliders so the UI won't crash
	facebang: JobWithSliders;

	rejoinServer: Job;
	switchServer: Job;
};

export const __FIX_JOBS = true;
