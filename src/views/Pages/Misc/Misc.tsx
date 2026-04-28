import Roact from "@rbxts/roact";
import { hooked, useState, useCallback } from "@rbxts/roact-hooked";
import { useTheme } from "hooks/use-theme";
import FacebangModal from "./FacebangModal";

function MiscPage() {
    const theme = useTheme("home").profile;
    const [modalVisible, setModalVisible] = useState(false);
    const [isHovered, setHovered] = useState(false);

    // Optimized callback to prevent unnecessary re-renders
    const toggleModal = useCallback(() => setModalVisible((prev) => !prev), []);

    return (
        <frame Size={new UDim2(1, 0, 1, 0)} BackgroundTransparency={1}>
            <uipadding 
                PaddingTop={new UDim(0, 20)} 
                PaddingLeft={new UDim(0, 20)} 
                PaddingRight={new UDim(0, 20)} 
            />
            <scrollingframe 
                Size={new UDim2(1, 0, 1, 0)} 
                BackgroundTransparency={1} 
                ScrollBarThickness={2}
                CanvasSize={new UDim2(0, 0, 0, 0)}
                AutomaticCanvasSize={Enum.AutomaticSize.Y} // Important: Makes scrolling work as you add more buttons
            >
                <uilistlayout Padding={new UDim(0, 10)} SortOrder={Enum.SortOrder.LayoutOrder} />
                
                <textbutton
                    Text="Facebang Settings"
                    Size={new UDim2(1, 0, 0, 50)}
                    // Dynamic background: lightens slightly on hover
                    BackgroundColor3={isHovered ? theme.button.background.Lerp(new Color3(1, 1, 1), 0.1) : theme.button.background}
                    TextColor3={theme.button.foreground}
                    Font={Enum.Font.GothamBold}
                    TextSize={16}
                    AutoButtonColor={false} // Disable default Roblox grey-out for custom hover
                    Event={{ 
                        Activated: toggleModal,
                        MouseEnter: () => setHovered(true),
                        MouseLeave: () => setHovered(false)
                    }}
                >
                    <uicorner CornerRadius={new UDim(0, 8)} />
                    <uiuiastroke 
                        Thickness={1.5} 
                        Color={theme.button.background.Lerp(new Color3(1, 1, 1), 0.2)} 
                        Transparency={isHovered ? 0 : 0.5} 
                    />
                </textbutton>
            </scrollingframe>

            {/* Only render the modal if it's visible to save performance */}
            {modalVisible && (
                <FacebangModal isVisible={modalVisible} onClose={() => setModalVisible(false)} />
            )}
        </frame>
    );
}

export default hooked(MiscPage);
