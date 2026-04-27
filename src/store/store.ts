import Rodux from "@rbxts/rodux";
import { dashboardReducer } from "store/reducers/dashboard.reducer";
import { jobsReducer } from "store/reducers/jobs.reducer";
import { optionsReducer } from "store/reducers/options.reducer";
import { JobsAction } from "store/actions/jobs.action"; // Import your action type

// Combine all possible action types in the store
export type RootAction = JobsAction | Rodux.Action<string> | any; 

export type RootReducer = typeof rootReducer;
export type RootState = ReturnType<RootReducer>;
export type RootStore = Rodux.Store<RootState, RootAction>;

const rootReducer = Rodux.combineReducers({
	dashboard: dashboardReducer,
	jobs: jobsReducer,
	options: optionsReducer,
});

export function configureStore(initialState?: Partial<RootState>) {
	// We cast to RootStore to ensure the store accepts our custom Actions
	return new Rodux.Store(rootReducer, initialState) as RootStore;
}
