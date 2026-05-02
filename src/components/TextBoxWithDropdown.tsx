import Roact from "@rbxts/roact";
import { hooked, useState } from "@rbxts/roact-hooked";
import { px } from "utils/udim2";

// @ts-expect-error
const TextBoxWithDropdown: Roact.FunctionComponent<any> = ({ text, setText, options, onSelected }) => {
	const [focused, setFocused] = useState(false);

	const dropdownVisible = focused && options.length > 0;

	const handleTextChange = (rbx: TextBox) => {
		setText(rbx.Text);
	};

	const handleSelect = (option: any) => {
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
				Position={px(0, 0)}
				Size={px(300, 30)}
				Change={{
					Text: handleTextChange,
				}}
			>
				<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} />
			</textbox>

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
					{(options as any[]).map((opt, i) => (
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
									handleSelect(opt);
								},
							}}
						/>
					))}
				</scrollingframe>
			)}
		</frame>
	);
};

export default hooked(TextBoxWithDropdown);
