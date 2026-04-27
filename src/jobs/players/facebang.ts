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

    // 3. Get the target you selected in the Player Tab
    const targetName = state.dashboard.selectedPlayer;
    const targetPlayer = Players.FindFirstChild(targetName ?? "");

    if (!targetPlayer) return;

    // 4. Start the "Stick-to-Face" loop
    connection = RunService.Heartbeat.Connect(() => {
        const localChar = Players.LocalPlayer.Character;
        const targetChar = targetPlayer.Character;

        if (localChar && targetChar) {
            const localRoot = localChar.FindFirstChild("HumanoidRootPart") as BasePart;
            const targetRoot = targetChar.FindFirstChild("HumanoidRootPart") as BasePart;

            if (localRoot && targetRoot) {
                // Offset: 2.5 studs in front, facing them
                const offset = new CFrame(0, 0, -2.5);
                localRoot.CFrame = targetRoot.CFrame.ToWorldSpace(offset).mul(CFrame.Angles(0, math.rad(180), 0));
            }
        }
    });
});
