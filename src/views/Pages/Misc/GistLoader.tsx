import Roact from "@rbxts/roact";
import { hooked, useState, useBinding, useEffect, useCallback } from "@rbxts/roact-hooked";
import TextBoxWithDropdown from "components/TextBoxWithDropdown";
import { px } from "utils/udim2";
import { useTheme } from "hooks/use-theme";

type GistInfo = {
	id: string;
	url: string;
	description: string;
};

function GistLoader() {
	const theme = useTheme("apps").misc;
	const [gistUrl, setGistUrl] = useState("");
	const [gistList, setGistList] = useState<GistInfo[]>([]);
	const [selectedGist, setSelectedGist] = useState<GistInfo | undefined>(undefined);

	// Search behavior (mocked; you can replace with real API)
	const fetchGists = useCallback((query: string) => {
		// Example: simulate fetching gists
		const fakeGists: GistInfo[] =
			query.length > 0
				? [
						{ id: "123", url: `https://api.github.com/gists/123`, description: "Misc utilities" },
						{ id: "456", url: `https://api.github.com/gists/456`, description: "UI tweaks" },
				  ]
				: [];
		setGistList(fakeGists);
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
		const code = _G.Havoc.fetchAsync(selectedGist.url).Body;
		// Example: parse gist body and run
		_G.Havoc.runScript(code); // or extract file content
	}, [selectedGist]);

	// Set selected Gist from dropdown selection
	const onSelected = useCallback((gist: GistInfo) => {
		setSelectedGist(gist);
	}, []);

	return (
		<frame Key="GistLoader" Size={px(400, 300)} BackgroundTransparency={1}>
			<TextButton
				Key="RunButton"
				Text="Run Gist"
				Size={px(100, 40)}
				BackgroundColor3={theme.button.background}
				TextColor3={theme.button.foreground}
				Font={Enum.Font.GothamBold}
				AutoButtonColor={false}
				Event={{ Activated: runGist }}
			>
				<uicorner CornerRadius={new UDim(0, 8)} />
			</TextButton>
			<TextBoxWithDropdown
				text={gistUrl}
				setText={updateGistList}
				options={gistList}
				onSelected={onSelected}
				theme={theme}
			/>
		</frame>
	);
}

export default hooked(GistLoader);
