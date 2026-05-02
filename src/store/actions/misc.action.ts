import Rodux = require("@rbxts/rodux");
import { GistLoaderState } from "../models/misc.model";

export type MiscAction =
	| Rodux.InferActionFromCreator<typeof setGistActive>
	| Rodux.InferActionFromCreator<typeof setCurrentGist>
	| Rodux.InferActionFromCreator<typeof clearGistError>;

export const setGistActive = Rodux.makeActionCreator("misc/setGistActive", (active: boolean) => ({ active }));

export const setCurrentGist = Rodux.makeActionCreator(
	"misc/setCurrentGist",
	(gist: { url: string; id: string } | undefined) => {
		return { gist: gist ?? {} };
	},
);

export const clearGistError = Rodux.makeActionCreator("misc/clearGistError", () => ({}));
