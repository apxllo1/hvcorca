import Roact from "@rbxts/roact";
import { useDelayedUpdate } from "hooks/common/use-delayed-update";
import { useCurrentPage } from "hooks/use-current-page";
import { DashboardPage } from "store/models/dashboard.model";

import Apps from "./Apps";
import Home from "./Home";
import Options from "./Options";
import Scripts from "./Scripts";
import Misc from "./Misc/Misc";

function Pages() {
	const currentPage = useCurrentPage();
	const isScriptsVisible = useDelayedUpdate(currentPage === DashboardPage.Scripts, 2000, (isVisible) => isVisible);

	return (
		<>
			<Home Key="home" />
			<Apps Key="apps" />
			{isScriptsVisible && <Scripts Key="scripts" />}
			<Options Key="options" />
			{currentPage === DashboardPage.Misc && <Misc Key="misc" />}
		</>
	);
}

export = Pages;
