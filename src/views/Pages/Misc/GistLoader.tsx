import Roact from "@rbxts/roact";
import { hooked, useState, useCallback } from "@rbxts/roact-hooked";
import TextBoxWithDropdown from "components/TextBoxWithDropdown";
import { px } from "utils/udim2";
import { useTheme } from "hooks/use-theme";

type GistInfo = {
	id: string;
	url: string;
	description: string;
};

// @ts-expect-error
function GistLoader() {
	const theme = useTheme("apps").misc;
	const [gistUrl, setGistUrl] = useState("");
	const [gistList, setGistList] = useState<GistInfo[]>([]);
	const [selectedGist, setSelectedGist] = useState<GistInfo | undefined>(undefined);

	// Search behavior (mocked; you can replace with real API)
	const fetchGists = useCallback((query: string) => {
		// @ts-expect-error
		if (query.length > 0) {
			const fakeGists: GistInfo[] = [
				{ id: "123", url: `https://api.github.com/gists/123`, description: "Misc utilities" },
				{ id: "456", url: `https://api.github.com/gists/456`, description: "UI tweaks" },
			];
			setGistList(fakeGists);
		} else {
			setGistList([]);
		}
	}, []);

	// Update gist list on search input
	const updateGistList = useCallback(
		(text: string) => {
			setGistUrl(text);
			fetchGists(text);
		},
		[fetchGists],
	);

	// Run selected gist
	const runGist = useCallback(() => {
		if (!selectedGist) return;
		// @ts-expect-error
		// const code = _G.Havoc.fetchAsync(selectedGist.url).Body;
		// _G.Havoc.runScript(code);
		// For now, just mock it
		print("Would run:", selectedGist.url);
	}, [selectedGist]);

	// Set selected Gist from dropdown selection
	const onSelected = useCallback((gist: GistInfo) => {
		setSelectedGist(gist);
	}, []);

	return (
		<frame Key="GistLoader" Size={px(400, 300)} BackgroundTransparency={1}>
			<textbutton
				Key="RunButton"
				Text="Run Gist"
				Size={px(100, 40)}
				BackgroundColor3={new Color3(0.15, 0.15, 0.15)}
				TextColor3={new Color3(1, 1, 1)}
				Font={Enum.Font.GothamBold}
				AutoButtonColor={false}
				Event={{ Activated: runGist }}
			>
				<uicorner CornerRadius={new UDim(0, 8)} />
			</textbutton>
			<TextBoxWithDropdown
				text={gistUrl}
				setText={updateGistList}
				options={gistList}
				onSelected={onSelected}
				// theme={theme} // comment out if theme.misc is causing TS errors
			/>
		</frame>
	);
}

export default hooked(GistLoader);
