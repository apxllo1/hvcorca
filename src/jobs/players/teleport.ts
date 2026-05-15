import { Players } from "@rbxts/services";
import { getSelectedPlayer } from "jobs/helpers/get-selected-player";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import { setJobActive } from "store/actions/jobs.action";
import { setTimeout } from "utils/timeout";
import type { Timeout } from "utils/timeout";

async function main() {
	const store = await getStore();
	const playerSelected = await getSelectedPlayer(() => {
		store.dispatch(setJobActive("teleport", false));
	});

	let timeout: Timeout | undefined;

	onJobChange("teleport", (job) => {
		timeout?.clear();
		timeout = undefined;

		if (job.active) {
			const rootPart = Players.LocalPlayer.Character?.FindFirstChild("HumanoidRootPart");
			const targetRootPart = playerSelected.current?.Character?.FindFirstChild("HumanoidRootPart");

			if (!rootPart || !targetRootPart || !rootPart.IsA("BasePart") || !targetRootPart.IsA("BasePart")) {
				store.dispatch(setJobActive("teleport", false));
				warn(`[teleport-worker] Failed to find root parts (${String(rootPart)} -> ${String(targetRootPart)})`);
				return;
			}

			timeout = setTimeout(() => {
				store.dispatch(setJobActive("teleport", false));
				rootPart.CFrame = targetRootPart.CFrame.mul(new CFrame(0, 0, 1));
			}, 1000);
		}
	}).catch((err) => warn(`[teleport-worker] ${String(err)}`));
}

main().catch((err) => {
	warn(`[teleport-worker] ${String(err)}`);
});
