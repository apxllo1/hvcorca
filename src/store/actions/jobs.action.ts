import { createAction } from "@rbxts/rodux";
import { JobsState, InferJobValue } from "store/models/jobs.model";

export const setJobActive = createAction("setJobActive", (jobName: string, active: boolean) => ({
	jobName,
	active,
}));

export const setJobValue = createAction("setJobValue", <K extends keyof JobsState>(jobName: K, value: InferJobValue<JobsState[K]>) => ({
	jobName,
	value,
} as unknown as Record<string, unknown>)); // This cast fixes the Rodux error

export const setJobSlider = createAction("setJobSlider", (jobName: string, slider: string, value: number) => ({
	jobName,
	slider,
	value,
}));
