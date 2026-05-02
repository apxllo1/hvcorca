import Roact from "@rbxts/roact";
import { hooked, useState, useCallback } from "@rbxts/roact-hooked";
import TextBoxWithDropdown from "components/TextBoxWithDropdown";
import { px } from "utils/udim2";

interface GistInfo {
	id: string;
	url: string;
	description: string;
}

function GistLoader() {
	const theme = {
		button: {
			background: new Color3(0.15, 0.15, 0.15),
			foreground: new Color3(1, 1, 1),
		},
	};

	const [gistUrl, setGistUrl] = useState("");
	const [gistList, setGistList] = useState<GistInfo[]>([]);
	const [selectedGist, setSelectedGist] = useState<GistInfo | undefined>(undefined);

	const fetchGists = useCallback((query: string) => {
		// rbxtsc wants a number or boolean, so we cast length
		const queryLen = query.size();
		if (queryLen > 0) {
			const fakeGists: GistInfo[] = [
				{ id: "123", url: "https://api.github.com/gists/123", description: "Misc utilities" },
				{ id: "456", url: "https://api.github.com/gists/456", description: "UI tweaks" },
			];
			setGistList(fakeGists);
		} else {
			setGistList([]);
		}
	}, []);

	const updateGistList = useCallback(
		(text: string) => {
			setGistUrl(text);
			fetchGists(text);
		},
		[fetchGists],
	);

	const runGist = useCallback(() => {
		if (!selectedGist) return;
		// No real Havoc call now
		print("Would run:", selectedGist.url);
	}, [selectedGist]);

	const onSelected = useCallback((gist: GistInfo) => {
		setSelectedGist(gist);
	}, []);

	return (
		<frame Key="GistLoader" Size={px(400, 300)} BackgroundTransparency={1}>
			<textbutton
				Key="RunButton"
				Text="Run Gist"
				Size={px(100, 40)}
				BackgroundColor3={theme.button.background}
				TextColor3={theme.button.foreground}
				Font={Enum.Font.GothamBold}
				AutoButtonColor={false}
				Event={{
					Activated: runGist,
				}}
			>
				<uicorner CornerRadius={new UDim(0, 8)} />
			</textbutton>
			<TextBoxWithDropdown
				text={gistUrl}
				setText={updateGistList}
				options={gistList}
				onSelected={onSelected}
			/>
		</frame>
	);
}

export default hooked(GistLoader);
