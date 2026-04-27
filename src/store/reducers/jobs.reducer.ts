import Rodux from "@rbxts/rodux";
import { JobsAction } from "store/actions/jobs.action";
import { JobsState, JobWithSliders } from "../models/jobs.model";

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
	facebang: { active: false, sliders: { angle: 180, distance: 2.5 } },
	rejoinServer: { active: false },
	switchServer: { active: false },
};

export const jobsReducer = Rodux.createReducer<JobsState, JobsAction>(initialState, {
	"jobs/setJobActive": (state, action) => ({
		...state,
		[action.jobName]: { 
			...state[action.jobName], 
			active: action.active 
		},
	}),
	"jobs/setJobValue": (state, action) => ({
		...state,
		[action.jobName]: { 
			...state[action.jobName], 
			value: action.value 
		},
	}),
	"jobs/setJobSlider": (state, action) => {
		const job = state[action.jobName];
		
		// Use a type guard and explicit cast to ensure slider property accessibility
		if ("sliders" in job) {
			const jobWithSliders = job as JobWithSliders;
			return {
				...state,
				[action.jobName]: {
					...jobWithSliders,
					sliders: { 
						...jobWithSliders.sliders, 
						[action.slider]: action.value 
					},
				},
			};
		}
		
		return state;
	},
});
