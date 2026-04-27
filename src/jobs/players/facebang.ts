import { RunService, Players } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";

let connection: RBXScriptConnection | undefined;

onJobChange("facebang", (job, state) => {
    // 1. Clean up old loops
    if (connection) {
        connection.Disconnect();
        connection = undefined;
    }

    // 2. Only run if the button in the Misc tab is toggled ON
    if (!job.active) return;

    // 3. FIX: Updated path to match your DashboardState
    const targetName = state.dashboard.apps.playerSelected;
    const targetPlayer = Players.FindFirstChild(targetName ?? "");

    if (!targetPlayer) {
        warn("Facebang: No target player selected in dashboard!");
        return;
    }

    // 4. Start the "Stick-to-Face" loop
    connection = RunService.Heartbeat.Connect(() => {
        // Safety: If the target player leaves, stop the connection
        if (!targetPlayer.Parent) {
            connection?.Disconnect();
            return;
        }

        const localChar = Players.LocalPlayer.Character;
        const targetChar = targetPlayer.Character;

        if (localChar && targetChar) {
            const localRoot = localChar.FindFirstChild("HumanoidRootPart") as BasePart;
            const targetRoot = targetChar.FindFirstChild("HumanoidRootPart") as BasePart;

            if (localRoot && targetRoot) {
                // Offset: 2.5 studs in front, facing them
                const offset = new CFrame(0, 0, -2.5);
                
                // Teleport and rotate 180 degrees to face them
                localRoot.CFrame = targetRoot.CFrame
                    .ToWorldSpace(offset)
                    .mul(CFrame.Angles(0, math.rad(180), 0));
            }
        }
    });
});
