import { Workspace } from "@rbxts/services";
import { getSelectedPlayer } from "jobs/helpers/get-selected-player";
import { getStore, onJobChange } from "jobs/helpers/job-store";
import { setJobActive } from "store/actions/jobs.action";

const warnLog = warn as (msg: string) => void;

async function main() {
	const store = await getStore();
	const playerSelected = await getSelectedPlayer(() => {
		store.dispatch(setJobActive("spectate", false));
	});

	let shouldResetCameraSubject = false;
	let currentSubject: Humanoid | BasePart | undefined;
	let defaultSubject: Humanoid | BasePart | undefined;

	function connectCameraSubject(camera: Camera) {
		camera.GetPropertyChangedSignal("CameraSubject").Connect(() => {
			if (currentSubject !== camera.CameraSubject && store.getState().jobs.spectate.active) {
				shouldResetCameraSubject = false;
				store.dispatch(setJobActive("spectate", false));
			}
		});
	}

	Workspace.GetPropertyChangedSignal("CurrentCamera").Connect(() => {
		connectCameraSubject(Workspace.CurrentCamera!);
	});
	connectCameraSubject(Workspace.CurrentCamera!);

	onJobChange("spectate", (job) => {
		const camera = Workspace.CurrentCamera!;
		if (job.active) {
			const cameraSubject = playerSelected.current?.Character?.FindFirstChildWhichIsA("Humanoid");
			if (!cameraSubject) {
				store.dispatch(setJobActive("spectate", false));
			} else {
				shouldResetCameraSubject = true;
				defaultSubject = camera.CameraSubject;
				currentSubject = cameraSubject;
				camera.CameraSubject = cameraSubject;
			}
		} else if (shouldResetCameraSubject) {
			shouldResetCameraSubject = false;
			camera.CameraSubject = defaultSubject;
			defaultSubject = undefined;
			currentSubject = undefined;
		}
	}).catch((err: unknown) => warnLog(`[spectate-worker] ${tostring(err)}`));
}

main().catch((err: unknown) => {
	warnLog(`[spectate-worker] ${tostring(err)}`);
});
