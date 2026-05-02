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

function GistLoader() {
	// Instead of .misc, hard‑code or use a generic theme
	const theme = /* useTheme("apps").misc */ {
		button: {
			background: new Color3(0.15, 0.15, 0.15),
			foreground: new Color3(1, 1, 1),
		},
	};

	const [gistUrl, setGistUrl] = useState("");
	const [gistList, setGistList] = useState<GistInfo[]>([]);
	const [selectedGist, setSelectedGist] = useState<GistInfo | undefined>(undefined);

	// Search behavior (mocked)
	const fetchGists = useCallback((query: string) => {
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

	const updateGistList = useCallback(
		(text: string) => {
			setGistUrl(text);
			fetchGists(text);
		},
		[fetchGists],
	);

	const runGist = useCallback(() => {
		if (!selectedGist) return;
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
				Event={{ Activated: runGist }}
			>
				<uicorner CornerRadius={new UDim(0, 8)} />
			</textbutton>
			<TextBoxWithDropdown text={gistUrl} setText={updateGistList} options={gistList} onSelected={onSelected} />
		</frame>
	);
}

export default hooked(GistLoader);
