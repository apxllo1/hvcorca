import Roact, { Children, Change, Event } from "@rbxts/roact";
import { hooked, useState, useBinding } from "@rbxts/roact-hooked";
import { px } from "utils/udim2";

// Option type for dropdown
type Option = {
	label: string;
	value: any;
};

// Props for TextBoxWithDropdown
interface Props<T extends Option> {
	text: string;
	setText: (text: string) => void;
	options: T[];
	onSelected: (option: T) => void;
	theme?: any; // your theme (button.background, button.foreground etc.)
}

function TextBoxWithDropdown<T extends Option>({ text, setText, options, onSelected, theme }: Props<T>) {
	const [focused, setFocused] = useState(false);
	// Use `Binding<boolean>` so `.getValue()` is valid
	const dropdownVisible = useBinding<boolean>(focused && options.length > 0);

	const handleInput = Event.textBox.FocusLost((rbx, entered, _input) => {
		if (entered) {
			setText(rbx.Text);
		}
	});

	const handleSelection = (option: T) => {
		setText(option.label);
		onSelected(option);
	};

	return (
		<frame Key="TextBoxWithDropdown" Size={px(300, 60)} BackgroundTransparency={1}>
			{/* Roact‑style textbox; Roblox tag */}
			<textbox
				Key="TextInput"
				Text={text}
				BackgroundColor3={theme?.button?.background ?? new Color3(0.2, 0.2, 0.2)}
				TextColor3={theme?.button?.foreground ?? new Color3(1, 1, 1)}
				Font={Enum.Font.Gotham}
				TextSize={14}
				AutoButtonColor={false}
				Position={px(0, 0)}
				Size={px(300, 30)}
				Event={{
					FocusLost: handleInput,
				}}
			>
				<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} />
			</textbox>

			{/* Dropdown only visible when focused and options exist */}
			{dropdownVisible.getValue() && (
				<scrollingframe
					Key="Dropdown"
					Size={px(300, 120)}
					BackgroundColor3={new Color3(0.1, 0.1, 0.1)}
					Position={px(0, 30)}
					ScrollBarThickness={2}
					AutomaticCanvasSize={Enum.AutomaticSize.Y}
					BorderStyle={Enum.FrameStyle.RobloxRound}
				>
					<uilistlayout Padding={new UDim(0, 2)} SortOrder={Enum.SortOrder.LayoutOrder} />

					{options.map((opt, i) => (
						<textbutton
							Key={`Option${i}`}
							Text={opt.label}
							Size={px(300, 30)}
							BackgroundColor3={new Color3(0.15, 0.15, 0.15)}
							TextColor3={new Color3(1, 1, 1)}
							Font={Enum.Font.Gotham}
							TextSize={14}
							AutoButtonColor={false}
							Event={{
								Activated: () => {
									handleSelection(opt);
								},
							}}
						/>
					))}
				</scrollingframe>
			)}
		</frame>
	);
}

export default hooked(TextBoxWithDropdown);
