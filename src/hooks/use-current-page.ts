import { useAppSelector } from "hooks/common/rodux-hooks";
import { DashboardPage } from "store/models/dashboard.model";

export function useCurrentPage() {
	return useAppSelector((state) => state.dashboard.page);
}

export function useIsPageOpen(page: DashboardPage) {
	// We removed state.dashboard.isOpen so the tab stays "Active"
	// even when the UI is toggled shut.
	return useAppSelector((state) => state.dashboard.page === page);
}
