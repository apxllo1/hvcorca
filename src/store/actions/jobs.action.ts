import { JobsState, InferJobValue } from "store/models/jobs.model";

export type JobsAction =
	| { type: "jobs/setJobActive"; jobName: keyof JobsState; active: boolean }
	| { type: "jobs/setJobValue"; jobName: keyof JobsState; value: unknown }
	| { type: "jobs/setJobSlider"; jobName: keyof JobsState; slider: string; value: number };

export const setJobActive = (jobName: keyof JobsState, active: boolean): JobsAction => ({
	type: "jobs/setJobActive",
	jobName,
	active,
});

export const setJobValue = (jobName: keyof JobsState, value: unknown): JobsAction => ({
	type: "jobs/setJobValue",
	jobName,
	value,
});

export const setJobSlider = (jobName: keyof JobsState, slider: string, value: number): JobsAction => ({
	type: "jobs/setJobSlider",
	jobName,
	slider,
	value,
});
