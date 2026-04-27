export interface Job {
	readonly active: boolean;
}

export interface JobWithValue<T> extends Job {
	readonly value: T;
}

export interface JobWithSliders extends Job {
	readonly sliders: {
		angle: number;
		distance: number;
	};
}

export type InferJobValue<T> = T extends JobWithValue<infer V> ? V : never;

export interface JobsState {
	readonly flight: JobWithValue<number>;
	readonly walkSpeed: JobWithValue<number>;
	readonly jumpHeight: JobWithValue<number>;
	readonly refresh: Job;
	readonly ghost: Job;
	readonly godmode: Job;
	readonly freecam: Job;
	readonly teleport: Job;
	readonly hide: Job;
	readonly kill: Job;
	readonly spectate: Job;
	readonly facebang: JobWithSliders;
	readonly rejoinServer: Job;
	readonly switchServer: Job;
}

export type JobsWithValue<T> = {
	[K in keyof JobsState]: JobsState[K] extends JobWithValue<T> ? K : never;
}[keyof JobsState];
