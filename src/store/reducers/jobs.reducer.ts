import Rodux from "@rbxts/rodux";
import { JobsAction } from "store/actions/jobs.action";
import { JobsState } from "../models/jobs.model";

const initialState: JobsState = {
	flight: { value: 60, active: false },
	walkSpeed: { value: 80, active: false },
	jumpHeight: { value: 200, active: false },

	refresh: { active: false },
	ghost: { active: false },
	godmode: { active: false },
	freecam: { active: false },

	teleport: { active: false },
	hide: { active: false },
	kill: { active: false },
	spectate: { active: false },

	// 1. Initialized as false so it doesn't run until you "pick and choose"
	facebang: { active: false, sliders: {} },

	rejoinServer: { active: false },
	switchServer: { active: false },
};

export const jobsReducer = Rodux.createReducer<JobsState, JobsAction>(initialState, {
	"jobs/setJobActive": (state, action) => {
		const jobName = action.jobName as keyof JobsState;
		return {
			...state,
			[jobName]: {
				...state[jobName],
				active: action.active,
			},
		};
	},
	"jobs/setJobValue": (state, action) => {
		const jobName = action.jobName as keyof JobsState;
		// 2. Added a safety check to ensure we only update values for jobs that HAVE values
		const currentJob = state[jobName];
		
		return {
			...state,
			[jobName]: {
				...currentJob,
				value: action.value,
			},
		};
	},
});
