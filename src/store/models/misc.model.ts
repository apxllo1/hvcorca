export interface GistLoaderState {
	active: boolean;
	currentScript:
		| {
				url: string;
				id: string;
		  }
		| undefined;
	lastRunTimestamp: number | undefined;
	error: string | undefined;
}

export const MiscInitialState: GistLoaderState = {
	active: false,
	currentScript: undefined,
	lastRunTimestamp: undefined,
	error: undefined,
};
