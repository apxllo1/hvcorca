import { JobsState, InferJobValue } from "store/models/jobs.model";

export type JobsAction = 
	| { type: "setJobActive"; jobName: keyof JobsState; active: boolean }
	| { type: "setJobValue"; jobName: keyof JobsState; value: unknown }
	| { type: "setJobSlider"; jobName: keyof JobsState; slider: string; value: number };

export const setJobActive = (jobName: keyof JobsState, active: boolean): JobsAction => ({
	type: "setJobActive",
	jobName,
	active,
});

export const setJobValue = <K extends keyof JobsState>(jobName: K, value: InferJobValue<JobsState[K]>): JobsAction => ({
	type: "setJobValue",
	jobName,
	value,
});

export const setJobSlider = (jobName: keyof JobsState, slider: string, value: number): JobsAction => ({
	type: "setJobSlider",
	jobName,
	slider,
	value,
});
