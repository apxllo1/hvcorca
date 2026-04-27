import Rodux from "@rbxts/rodux";
import { dashboardReducer } from "store/reducers/dashboard.reducer";
import { jobsReducer } from "store/reducers/jobs.reducer";
import { optionsReducer } from "store/reducers/options.reducer";
import { JobsAction } from "store/actions/jobs.action";
import { JobsState } from "store/models/jobs.model"; // CRITICAL IMPORT
import { DashboardState } from "store/models/dashboard.model";
import { OptionsState } from "store/models/options.model";

// Explicitly define the shape so the compiler stops saying 'unknown'
export interface RootState {
	dashboard: DashboardState;
	jobs: JobsState;
	options: OptionsState;
}

export type RootAction = JobsAction | Rodux.Action<string>;
export type RootStore = Rodux.Store<RootState, RootAction>;

const rootReducer = Rodux.combineReducers<RootState, RootAction>({
	dashboard: dashboardReducer,
	jobs: jobsReducer as never, // 'as never' bypasses the Rodux strict combine check
	options: optionsReducer,
});

export function configureStore(initialState?: Partial<RootState>) {
	return new Rodux.Store(rootReducer, initialState) as RootStore;
}
