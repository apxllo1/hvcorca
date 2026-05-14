import Roact from "@rbxts/roact";
import { useCallback, useState } from "@rbxts/roact-hooked";
import { HttpService } from "@rbxts/services";
import * as http from "utils/http";

export interface CommandEntry {
	name: string;
	description: string;
	gistId: string;
}

declare function loadstring(chunk: string, chunkname?: string): LuaTuple<[(...args: unknown[]) => unknown, string]>;

const COMMANDS: CommandEntry[] = [
	{
		name: "Example Script",
		description: "A placeholder — replace with your own Gist",
		gistId: "YOUR_GIST_ID_HERE",
	},
];

const GREEN = Color3.fromRGB(80, 220, 140);
const BG_INPUT = Color3.fromRGB(20, 20, 20);
const BG_ITEM = Color3.fromRGB(25, 25, 25);
const BG_ITEM_HOVER = Color3.fromRGB(35, 35, 35);
const TEXT_PRIMARY = Color3.fromRGB(255, 255, 255);
const TEXT_SECONDARY = Color3.fromRGB(160, 160, 160);
const TEXT_DIM = Color3.fromRGB(100, 100, 100);

const GIST_RAW_URL = (id: string) => `https://gist.githubusercontent.com/${id}/raw`;

function GistLoader() {
	const [filtered, setFiltered] = useState<CommandEntry[]>(COMMANDS);
	const [searchText, setSearchText] = useState("");
	const [selected, setSelected] = useState<CommandEntry | undefined>(undefined);
	const [status, setStatus] = useState(`${COMMANDS.size()} commands available`);
	const [isRunning, setIsRunning] = useState(false);

	const handleSearch = useCallback(
		(rbx: TextBox) => {
			const query = rbx.Text.lower();
			setSearchText(rbx.Text);
			if (query === "") {
				setFiltered(COMMANDS);
			} else {
				setFiltered(
					COMMANDS.filter(
						(cmd) =>
							cmd.name.lower().find(query, 1, true)[0] !== undefined ||
							cmd.description.lower().find(query, 1, true)[0] !== undefined,
					),
				);
			}
		},
		[],
	);

	const handleRun = useCallback(() => {
		if (selected === undefined || isRunning) return;
		setIsRunning(true);
		setStatus(`Fetching ${selected.name}...`);

		const entry = selected;
		task.spawn(() => {
			const [fetchOk, bodyOrErr] = pcall(() => http.get(GIST_RAW_URL(entry.gistId)));
			if (!fetchOk) {
				setStatus(`Fetch error: ${String(bodyOrErr)}`);
				setIsRunning(false);
				return;
			}

			(bodyOrErr as Promise<string>)
				.then((body) => {
					if (body === undefined || body === "") {
						setStatus("Gist returned empty content");
						setIsRunning(false);
						return;
					}

					const [fn, err] = loadstring(body, `@${entry.name}`);
					if (fn === undefined) {
						setStatus(`Compile error: ${String(err)}`);
						setIsRunning(false);
						return;
					}

					const [runOk, runErr] = pcall(fn);
					if (!runOk) {
						setStatus(`Runtime error: ${String(runErr)}`);
					} else {
						setStatus(`✓ Ran ${entry.name}`);
					}
					setIsRunning(false);
				})
				.catch((err: unknown) => {
					setStatus(`Error: ${String(err)}`);
					setIsRunning(false);
				});
		});
	}, [selected, isRunning]);

	const runButtonActive = selected !== undefined && !isRunning;

	return (
		<frame Key="GistLoader" Size={new UDim2(1, 0, 0, 400)} BackgroundTransparency={1}>
			<uilistlayout Padding={new UDim(0, 8)} SortOrder={Enum.SortOrder.LayoutOrder} />

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
						Key={cmd.gistId}
						entry={cmd}
						isSelected={selected !== undefined && selected.gistId === cmd.gistId}
						layoutOrder={i}
						onSelect={() => setSelected(cmd)}
					/>
				))}
				{filtered.size() === 0 && (
					<textlabel
						Key="NoResults"
						Text="No matching commands"
						Size={new UDim2(1, 0, 0, 40)}
						BackgroundTransparency={1}
						TextColor3={TEXT_DIM}
						Font={Enum.Font.Gotham}
						TextSize={13}
						TextXAlignment={Enum.TextXAlignment.Center}
					/>
				)}
			</scrollingframe>

			<frame Key="Footer" Size={new UDim2(1, 0, 0, 40)} BackgroundTransparency={1} LayoutOrder={2}>
				<textbutton
					Key="RunButton"
					Text={
						isRunning
							? "Running..."
							: selected !== undefined
								? `Run: ${selected.name}`
								: "Select a command"
					}
					Size={new UDim2(1, 0, 1, 0)}
					BackgroundColor3={runButtonActive ? GREEN : Color3.fromRGB(40, 40, 40)}
					TextColor3={runButtonActive ? Color3.fromRGB(10, 10, 10) : TEXT_DIM}
					Font={Enum.Font.GothamBold}
					TextSize={14}
					AutoButtonColor={false}
					Active={runButtonActive}
					Event={{ Activated: handleRun }}
				>
					<uicorner CornerRadius={new UDim(0, 8)} />
				</textbutton>
			</frame>

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
			Size={new UDim2(1, 0, 0, 52)}
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
				Position={new UDim2(0, 12, 0, 7)}
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
				Position={new UDim2(0, 12, 0, 29)}
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
