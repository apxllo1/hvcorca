// ... (initialState stays the same)

export const jobsReducer = Rodux.createReducer<JobsState, JobsAction>(initialState, {
	"jobs/setJobActive": (state, action) => ({
		...state,
		[action.jobName]: { ...state[action.jobName], active: action.active },
	}),
	"jobs/setJobValue": (state, action) => ({
		...state,
		[action.jobName]: { ...state[action.jobName], value: action.value },
	}),
	"jobs/setJobSlider": (state, action) => {
		const job = state[action.jobName];
		if ("sliders" in job) {
			return {
				...state,
				[action.jobName]: {
					...job,
					sliders: { ...job.sliders, [action.slider]: action.value },
				},
			};
		}
		return state;
	},
});
