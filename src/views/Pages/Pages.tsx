import Roact from "@rbxts/roact";
import { hooked } from "@rbxts/roact-hooked";
import { useDelayedUpdate } from "hooks/common/use-delayed-update";
import { useCurrentPage } from "hooks/use-current-page";
import { DashboardPage } from "store/models/dashboard.model";

import Apps from "./Apps";
import Home from "./Home";
import Options from "./Options";
import Scripts from "./Scripts";
import Misc from "./Misc/Misc"; // The file we just created

function Pages() {
	const currentPage = useCurrentPage();

	// This helps prevent lag when switching to the heavy Scripts list
	const isScriptsVisible = useDelayedUpdate(currentPage === DashboardPage.Scripts, 2000, (isVisible) => isVisible);

	return (
		<>
			{currentPage === DashboardPage.Home && <Home Key="home" />}
			{currentPage === DashboardPage.Apps && <Apps Key="apps" />}
			{isScriptsVisible && <Scripts Key="scripts" />}
			{currentPage === DashboardPage.Options && <Options Key="options" />}
			
			{/* Added the Misc Page routing here */}
			{currentPage === DashboardPage.Misc && <Misc Key="misc" />}
		</>
	);
}

export default hooked(Pages);
