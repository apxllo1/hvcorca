import Roact from "@rbxts/roact";
import { StoreProvider } from "@rbxts/roact-rodux-hooked"; // Changed from Provider
import { DashboardPage } from "store/models/dashboard.model";
import { configureStore } from "store/store";
import Navbar from "./Navbar";

export = (target: Frame) => {
    const handle = Roact.mount(
        <StoreProvider
            store={configureStore({
                dashboard: {
                    isOpen: true,
                    page: DashboardPage.Home,
                    hint: undefined,
                    apps: {},
                },
            })}
        >
            <Navbar />
        </StoreProvider>,
        target,
        "Navbar",
    );
    return () => Roact.unmount(handle);
};