import { useAppSelector } from "hooks/common/rodux-hooks";
import type { DashboardPage } from "store/models/dashboard.model";

export function useCurrentPage() {
	return useAppSelector((state) => state.dashboard.page);
}

export function useIsPageOpen(page: DashboardPage) {
	return useAppSelector((state) => state.dashboard.page === page);
}
