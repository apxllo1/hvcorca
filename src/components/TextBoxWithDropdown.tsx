import Roact from "@rbxts/roact";
import { hooked, useBinding, useState } from "@rbxts/roact-hooked";
import { px, scale } from "utils/udim2";

type Option = { label: string; value: any };

interface Props<T> {
	text: string;
	setText: (text: string) => void;
	options: T[];
	onSelected: (option: T) => void;
	theme?: any; // pass your theme if needed
}

function TextBoxWithDropdown<T extends Option>({ text, setText, options, onSelected, theme }: Props<T>) {
	const [focused, setFocused] = useState(false);
	const dropdownVisible = useBinding(focused && options.length > 0);

	return (
		<frame Key="TextBoxWithDropdown" Size={px(300, 60)} BackgroundTransparency={1}>
			<textbutton
				Key="TextInput"
				Text={text}
				BackgroundColor3={theme?.button.background || Color3.new(0.2, 0.2, 0.2)}
				TextColor3={theme?.button.foreground || Color3.new(1, 1, 1)}
				Font={Enum.Font.Gotham}
				TextSize={14}
				AutoButtonColor={false}
				Position={px(0, 0)}
				Size={px(300, 30)}
				Event={{
					Activated: () => setFocused(true),
					StateChanged: (_, newFocus) => {
						if (newFocus === Enum.FocusState.Focused) setFocused(true);
						else setFocused(false);
					},
				}}
			/>
			{dropdownVisible.getValue() && (
				<ScrollingFrame
					Key="Dropdown"
					Size={px(300, 120)}
					BackgroundColor3={Color3.new(0.1, 0.1, 0.1)}
					Position={px(0, 30)}
				>
					<UILisstLayout />
					{options.map((opt, i) => (
						<textbutton
							Key={`Option${i}`}
							Text={opt.label}
							Size={px(300, 30)}
							BackgroundColor3={Color3.new(0.15, 0.15, 0.15)}
							TextColor3={Color3.new(1, 1, 1)}
							Event={{
								Activated: () => {
									setText(opt.label);
									onSelected(opt);
								},
							}}
						/>
					))}
				</ScrollingFrame>
			)}
		</frame>
	);
}

export default hooked(TextBoxWithDropdown);
