import { RunService, Players } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";
import { JobWithSliders } from "store/models/jobs.model";

let connection: RBXScriptConnection | undefined;

onJobChange("facebang", (job, state) => {
    if (connection) {
        connection.Disconnect();
        connection = undefined;
    }

    // Cast to JobWithSliders to access the slider data
    const sliderJob = job as unknown as JobWithSliders;

    if (!sliderJob.active || !sliderJob.sliders) return;

    const targetName = state.dashboard.apps.playerSelected;
    const targetPlayer = Players.FindFirstChild(targetName ?? "") as Player | undefined;

    if (!targetPlayer) return;

    connection = RunService.Heartbeat.Connect(() => {
        const localChar = Players.LocalPlayer.Character;
        const targetChar = targetPlayer.Character;

        if (localChar && targetChar) {
            const localRoot = localChar.FindFirstChild("HumanoidRootPart") as BasePart;
            const targetRoot = targetChar.FindFirstChild("HumanoidRootPart") as BasePart;

            if (localRoot && targetRoot) {
                // FIXED: Now uses the actual slider values from your UI
                const distance = sliderJob.sliders.distance;
                const angle = sliderJob.sliders.angle;

                const offset = new CFrame(0, 0, -distance);
                const rotation = CFrame.Angles(0, math.rad(angle), 0);

                localRoot.CFrame = targetRoot.CFrame.ToWorldSpace(offset).mul(rotation);
            }
        }
    });
});
