import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange } from "../helpers/job-store";

// Global declaration to interact with the exploit environment
declare const getgenv: () => { facefuckactive: boolean };

let heartbeatConn: RBXScriptConnection | undefined;

// --- Character State Helpers (Replica of Original Lua) ---

const disableActions = (char: Model) => {
    const animate = char.FindFirstChild("Animate") as LocalScript;
    if (animate) animate.Disabled = true; [cite: 3]

    const humanoid = char.FindFirstChild("Humanoid") as Humanoid;
    if (humanoid) {
        humanoid.GetPlayingAnimationTracks().forEach((track) => track.Stop()); [cite: 3]
        humanoid.PlatformStand = true; [cite: 3]
        humanoid.AutoRotate = false; [cite: 3]
        humanoid.ChangeState(Enum.HumanoidStateType.Physics); [cite: 3]
    }
    Workspace.Gravity = 0; [cite: 3]
};

const enableActions = (char: Model) => {
    const animate = char.FindFirstChild("Animate") as LocalScript;
    if (animate) animate.Disabled = false; [cite: 3]

    const humanoid = char.FindFirstChild("Humanoid") as Humanoid;
    if (humanoid) {
        humanoid.PlatformStand = false; [cite: 3]
        humanoid.AutoRotate = true; [cite: 3]
        humanoid.ChangeState(Enum.HumanoidStateType.GettingUp); [cite: 3]
    }
    Workspace.Gravity = 192.2; [cite: 3]
};

// --- Exact Logic Replica ---

const startFacebangLoop = async (targetHead: BasePart, lp: Player) => {
    const root = lp.Character?.FindFirstChild("HumanoidRootPart") as BasePart;
    
    // Original Constants from Lua source 
    const fd = -0.7; // Forward depth 
    const ho = 0.8;  // Height offset 
    const td = 1.9;  // Thrust distance 
    const ft = 0.1;  // Forward time 
    const bt = 0.1;  // Back time 

    while (getgenv().facefuckactive && targetHead.IsDescendantOf(Workspace)) {
        if (!lp.Character) break;
        disableActions(lp.Character);

        const headCF = targetHead.CFrame;
        const dist = headCF.Position.sub(root.Position).Magnitude;

        // Teleport if distance > 10 
        if (dist > 10) {
            root.CFrame = headCF.mul(new CFrame(0, ho, fd + 1)).mul(CFrame.Angles(0, math.rad(180), 0)); [cite: 3]
            RunService.RenderStepped.Wait();
            continue;
        }

        const bp = headCF.mul(new CFrame(0, ho, fd)).mul(CFrame.Angles(0, math.rad(180), 0)); [cite: 3]
        const tp = headCF.mul(new CFrame(0, ho, fd - td)).mul(CFrame.Angles(0, math.rad(180), 0)); [cite: 3]

        // Forward thrust 
        let ts = tick();
        while (tick() - ts < ft && getgenv().facefuckactive) {
            const alpha = math.min((tick() - ts) / ft, 1);
            const eased = -(math.cos(math.pi * alpha) - 1) / 2; [cite: 3]
            root.CFrame = bp.Lerp(tp, eased); [cite: 3]
            RunService.RenderStepped.Wait();
        }

        // Backward thrust 
        ts = tick();
        while (tick() - ts < bt && getgenv().facefuckactive) {
            const alpha = math.min((tick() - ts) / bt, 1);
            const eased = -(math.cos(math.pi * alpha) - 1) / 2; [cite: 3]
            root.CFrame = tp.Lerp(bp, eased); [cite: 3]
            RunService.RenderStepped.Wait();
        }
    }
    
    if (lp.Character) enableActions(lp.Character); [cite: 3]
};

// --- Integration with your Store ---

onJobChange("facebang", (job, state) => {
    const lp = Players.LocalPlayer;

    if (job.active) {
        getgenv().facefuckactive = true; [cite: 3]

        // Target finding logic: uses your selected player from the dashboard
        const targetName = state.dashboard.apps.playerSelected;
        const targetPlayer = Players.FindFirstChild(targetName ?? "") as Player | undefined;
        const head = targetPlayer?.Character?.FindFirstChild("Head") as BasePart;

        if (head) {
            task.spawn(() => startFacebangLoop(head, lp));
        }

        // Keep character in Physics state during loop 
        heartbeatConn = RunService.Heartbeat.Connect(() => {
            if (getgenv().facefuckactive && lp.Character) {
                const hum = lp.Character.FindFirstChild("Humanoid") as Humanoid;
                if (hum) {
                    hum.GetPlayingAnimationTracks().forEach(t => t.Stop()); [cite: 3]
                    hum.PlatformStand = true; [cite: 3]
                    hum.ChangeState(Enum.HumanoidStateType.Physics); [cite: 3]
                }
            }
        });
    } else {
        getgenv().facefuckactive = false; [cite: 3]
        if (heartbeatConn) heartbeatConn.Disconnect();
        if (lp.Character) enableActions(lp.Character); [cite: 3]
    }
});
