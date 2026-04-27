import { RunService, Players } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";

let connection: RBXScriptConnection | undefined;

onJobChange("facebang", (job, state) => {
    if (connection) {
        connection.Disconnect();
        connection = undefined;
    }

    if (!job.active) return;

    // Path updated to match your dashboard model
    const targetName = state.dashboard.apps.playerSelected;
    
    // We cast this as Player | undefined so TypeScript knows it has a .Character
    const targetPlayer = Players.FindFirstChild(targetName ?? "") as Player | undefined;

    if (!targetPlayer) return;

    connection = RunService.Heartbeat.Connect(() => {
        const localChar = Players.LocalPlayer.Character;
        const targetChar = targetPlayer.Character;

        if (localChar && targetChar) {
            const localRoot = localChar.FindFirstChild("HumanoidRootPart") as BasePart;
            const targetRoot = targetChar.FindFirstChild("HumanoidRootPart") as BasePart;

            if (localRoot && targetRoot) {
                // Stick to their face
                const offset = new CFrame(0, 0, -2.5);
                localRoot.CFrame = targetRoot.CFrame.ToWorldSpace(offset).mul(CFrame.Angles(0, math.rad(180), 0));
            }
        }
    });
});
