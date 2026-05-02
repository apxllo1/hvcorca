export interface GistLoaderState {
	active: boolean;
	currentScript: {
		url: string;
		id: string;
	} | null;
	lastRunTimestamp: number | null;
	error: string | null;
}

export const MiscInitialState: GistLoaderState = {
	active: false,
	currentScript: null,
	lastRunTimestamp: null,
	error: null,
};
