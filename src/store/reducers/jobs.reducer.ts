import Rodux from "@rbxts/rodux";
import { JobsAction } from "store/actions/jobs.action";
import { JobsState, JobWithSliders, JobWithValue } from "../models/jobs.model";

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

	// FIXED: Added the sliders object to match the JobWithSliders interface
	facebang: { 
		active: false, 
		sliders: {
			angle: 180,
			distance: 2.5
		} 
	},

	rejoinServer: { active: false },
	switchServer: { active: false },
};

export const jobsReducer = Rodux.createReducer<JobsState, JobsAction>(initialState, {
	setJobActive: (state, action) => {
		const jobName = action.jobName as keyof JobsState;
		return {
			...state,
			[jobName]: {
				...state[jobName],
				active: action.active,
			},
		};
	},

	setJobValue: (state, action) => {
		const jobName = action.jobName as keyof JobsState;
		const currentJob = state[jobName] as JobWithValue<number>;
		
		return {
			...state,
			[jobName]: {
				...currentJob,
				value: action.value,
			},
		};
	},

	// ADDED: Logic to handle slider updates (Angle/Distance)
	setJobSlider: (state, action) => {
		const jobName = action.jobName as keyof JobsState;
		const currentJob = state[jobName] as JobWithSliders;

		return {
			...state,
			[jobName]: {
				...currentJob,
				sliders: {
					...currentJob.sliders,
					[action.slider]: action.value,
				},
			},
		};
	},
});
