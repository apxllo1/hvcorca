import Roact, { Children, Change, Event } from "@rbxts/roact";
import { hooked, useState, useBinding } from "@rbxts/roact-hooked";
import { px } from "utils/udim2";

// Simple string‑option for now
type Option = {
	label: string;
	value: string;
};

interface Props {
	text: string;
	setText: (text: string) => void;
	options: Option[];
	onSelected: (option: Option) => void;
}

function TextBoxWithDropdown({ text, setText, options, onSelected }: Props) {
	const [focused, setFocused] = useState(false);
	// Just use `boolean`, not `Binding<boolean>`
	const dropdownVisible = focused && options.length > 0;

	const handleInput = (rbx: TextBox, entered: boolean, _input: InputObject) => {
		if (entered) {
			setText(rbx.Text);
		}
	};

	const handleSelection = (option: Option) => {
		setText(option.label);
		onSelected(option);
	};

	return (
		<frame Key="TextBoxWithDropdown" Size={px(300, 60)} BackgroundTransparency={1}>
			<textbox
				Key="TextInput"
				Text={text}
				BackgroundColor3={new Color3(0.2, 0.2, 0.2)}
				TextColor3={new Color3(1, 1, 1)}
				Font={Enum.Font.Gotham}
				TextSize={14}
				AutoButtonColor={false}
				Position={px(0, 0)}
				Size={px(300, 30)}
				Change={{
					Text: (rbx) => {
						// Mirror text to state
						setText(rbx.Text);
					},
				}}
			>
				<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} />
			</textbox>

			{/* Dropdown only visible when focused and options exist */}
			{dropdownVisible && (
				<scrollingframe
					Key="Dropdown"
					Size={px(300, 120)}
					BackgroundColor3={new Color3(0.1, 0.1, 0.1)}
					Position={px(0, 30)}
					ScrollBarThickness={2}
					AutomaticCanvasSize={Enum.AutomaticSize.Y}
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
