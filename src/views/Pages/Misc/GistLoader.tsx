import Roact from "@rbxts/roact";
import { useCallback, useEffect, useState } from "@rbxts/roact-hooked";
import { HttpService } from "@rbxts/services";
import * as http from "utils/http";

export interface CommandEntry {
	name: string;
	description: string;
	gistId: string;
}

declare function loadstring(chunk: string, chunkname?: string): [(...args: unknown[]) => unknown, string];

const INDEX_GIST_ID = "REPLACE_WITH_YOUR_GIST_ID";
const GIST_API_URL = (id: string) => `https://api.github.com/gists/${id}`;

const GREEN = Color3.fromRGB(80, 220, 140);
const BG_INPUT = Color3.fromRGB(20, 20, 20);
const BG_ITEM = Color3.fromRGB(25, 25, 25);
const BG_ITEM_HOVER = Color3.fromRGB(35, 35, 35);
const TEXT_PRIMARY = Color3.fromRGB(255, 255, 255);
const TEXT_SECONDARY = Color3.fromRGB(160, 160, 160);
const TEXT_DIM = Color3.fromRGB(100, 100, 100);

function GistLoader() {
	const [commands, setCommands] = useState<CommandEntry[]>([]);
	const [filtered, setFiltered] = useState<CommandEntry[]>([]);
	const [searchText, setSearchText] = useState("");
	const [selected, setSelected] = useState<CommandEntry | undefined>(undefined);
	const [status, setStatus] = useState("Loading commands...");
	const [isRunning, setIsRunning] = useState(false);

	useEffect(() => {
		task.spawn(() => {
			try {
				const response = http.get(GIST_API_URL(INDEX_GIST_ID));
				response
					.then((body) => {
						const gistData = HttpService.JSONDecode(body) as {
							files: Record<string, { content: string }>;
						};
						let content = "";
						for (const [, file] of pairs(gistData.files)) {
							content = file.content;
							break;
						}
						if (content === "") {
							setStatus("Index gist is empty");
							return;
						}
						const entries = HttpService.JSONDecode(content) as CommandEntry[];
						setCommands(entries);
						setFiltered(entries);
						setStatus(`${entries.size()} commands loaded`);
					})
					.catch((err) => {
						setStatus(`Failed to load: ${err}`);
					});
			} catch (err) {
				setStatus(`Failed to load: ${err}`);
			}
		});
	}, []);

	const handleSearch = useCallback(
		(rbx: TextBox) => {
			const query = rbx.Text.lower();
			setSearchText(rbx.Text);
			if (query === "") {
				setFiltered(commands);
			} else {
				setFiltered(
					commands.filter(
						(cmd) =>
							cmd.name.lower().find(query)[0] !== undefined ||
							cmd.description.lower().find(query)[0] !== undefined,
					),
				);
			}
		},
		[commands],
	);

	const handleRun = useCallback(() => {
		if (!selected || isRunning) return;
		setIsRunning(true);
		setStatus(`Running ${selected.name}...`);
		task.spawn(() => {
			try {
				const content = http.get(GIST_API_URL(selected.gistId));
				content
					.then((body) => {
						const gistData = HttpService.JSONDecode(body) as {
							files: Record<string, { content: string }>;
						};
						let luaCode = "";
						for (const [, file] of pairs(gistData.files)) {
							luaCode = file.content;
							break;
						}
						if (luaCode === "") {
							setStatus("Gist file is empty");
							setIsRunning(false);
							return;
						}
						const [fn, err] = loadstring(luaCode, `@${selected.name}`);
						assert(fn, `loadstring failed: ${err}`);
						task.defer(fn);
						setStatus(`Ran ${selected.name}`);
						setIsRunning(false);
					})
					.catch((err) => {
						setStatus(`Error: ${err}`);
						setIsRunning(false);
					});
			} catch (err) {
				setStatus(`Error: ${err}`);
				setIsRunning(false);
			}
		});
	}, [selected, isRunning]);

	return (
		<frame Key="GistLoader" Size={new UDim2(1, 0, 0, 400)} BackgroundTransparency={1}>
			<uilistlayout Padding={new UDim(0, 8)} SortOrder={Enum.SortOrder.LayoutOrder} />

			{/* Search bar */}
			<frame Key="SearchBar" Size={new UDim2(1, 0, 0, 36)} BackgroundColor3={BG_INPUT} LayoutOrder={0}>
				<uicorner CornerRadius={new UDim(0, 8)} />
				<uistroke Color={Color3.fromRGB(40, 40, 40)} Thickness={1} />
				<textbox
					Key="Input"
					Text={searchText}
					PlaceholderText="Search commands..."
					PlaceholderColor3={TEXT_DIM}
					Size={new UDim2(1, -16, 1, 0)}
					Position={new UDim2(0, 8, 0, 0)}
					BackgroundTransparency={1}
					TextColor3={TEXT_PRIMARY}
					Font={Enum.Font.Gotham}
					TextSize={14}
					TextXAlignment={Enum.TextXAlignment.Left}
					ClearTextOnFocus={false}
					Change={{ Text: handleSearch }}
				/>
			</frame>

			{/* Command list */}
			<scrollingframe
				Key="CommandList"
				Size={new UDim2(1, 0, 0, 260)}
				BackgroundTransparency={1}
				ScrollBarThickness={2}
				ScrollBarImageColor3={TEXT_DIM}
				AutomaticCanvasSize={Enum.AutomaticSize.Y}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				LayoutOrder={1}
			>
				<uilistlayout Padding={new UDim(0, 4)} SortOrder={Enum.SortOrder.LayoutOrder} />
				{filtered.map((cmd, i) => (
					<CommandItem
						Key={`cmd-${i}`}
						entry={cmd}
						isSelected={selected !== undefined && selected.gistId === cmd.gistId}
						layoutOrder={i}
						onSelect={() => setSelected(cmd)}
					/>
				))}
				{filtered.size() === 0 && (
					<textlabel
						Key="NoResults"
						Text={commands.size() === 0 ? status : "No matching commands"}
						Size={new UDim2(1, 0, 0, 40)}
						BackgroundTransparency={1}
						TextColor3={TEXT_DIM}
						Font={Enum.Font.Gotham}
						TextSize={13}
					/>
				)}
			</scrollingframe>

			{/* Run button + status */}
			<frame Key="Footer" Size={new UDim2(1, 0, 0, 44)} BackgroundTransparency={1} LayoutOrder={2}>
				<textbutton
					Key="RunButton"
					Text={isRunning ? "Running..." : selected ? `Run: ${selected.name}` : "Select a command"}
					Size={new UDim2(1, 0, 0, 40)}
					BackgroundColor3={selected && !isRunning ? GREEN : Color3.fromRGB(40, 40, 40)}
					TextColor3={selected && !isRunning ? Color3.fromRGB(10, 10, 10) : TEXT_DIM}
					Font={Enum.Font.GothamBold}
					TextSize={14}
					AutoButtonColor={false}
					Event={{ Activated: handleRun }}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
				</textbutton>
			</frame>

			{/* Status text */}
			<textlabel
				Key="Status"
				Text={status}
				Size={new UDim2(1, 0, 0, 16)}
				BackgroundTransparency={1}
				TextColor3={TEXT_DIM}
				Font={Enum.Font.Gotham}
				TextSize={11}
				TextXAlignment={Enum.TextXAlignment.Left}
				LayoutOrder={3}
			/>
		</frame>
	);
}

interface CommandItemProps {
	entry: CommandEntry;
	isSelected: boolean;
	layoutOrder: number;
	onSelect: () => void;
}

function CommandItem({ entry, isSelected, layoutOrder, onSelect }: CommandItemProps) {
	const [hovered, setHovered] = useState(false);

	return (
		<textbutton
			Key={entry.gistId}
			Text=""
			Size={new UDim2(1, 0, 0, 50)}
			BackgroundColor3={isSelected ? Color3.fromRGB(30, 50, 35) : hovered ? BG_ITEM_HOVER : BG_ITEM}
			AutoButtonColor={false}
			LayoutOrder={layoutOrder}
			Event={{
				Activated: onSelect,
				MouseEnter: () => setHovered(true),
				MouseLeave: () => setHovered(false),
			}}
		>
			<uicorner CornerRadius={new UDim(0, 8)} />
			{isSelected && <uistroke Color={GREEN} Thickness={1} />}
			<textlabel
				Key="Name"
				Text={entry.name}
				Size={new UDim2(1, -16, 0, 22)}
				Position={new UDim2(0, 12, 0, 6)}
				BackgroundTransparency={1}
				TextColor3={TEXT_PRIMARY}
				Font={Enum.Font.GothamBold}
				TextSize={14}
				TextXAlignment={Enum.TextXAlignment.Left}
			/>
			<textlabel
				Key="Description"
				Text={entry.description}
				Size={new UDim2(1, -16, 0, 16)}
				Position={new UDim2(0, 12, 0, 28)}
				BackgroundTransparency={1}
				TextColor3={TEXT_SECONDARY}
				Font={Enum.Font.Gotham}
				TextSize={11}
				TextXAlignment={Enum.TextXAlignment.Left}
			/>
		</textbutton>
	);
}

export default GistLoader;
