import { RunService, Players, Workspace } from "@rbxts/services";
import { onJobChange, getStore } from "./helpers/job-store";

const lp = Players.LocalPlayer;
let isActive = false;
const originalGravity = Workspace.Gravity;

async function initFacebang() {
    const store = await getStore();
    
    onJobChange("facebang", (job) => {
        isActive = job.active;
        if (!isActive) {
            Workspace.Gravity = originalGravity;
        }
    });

    RunService.Stepped.Connect(() => {
        if (!isActive) return;

        const state = store.getState();
        const targetIdentifier = state.dashboard.apps.playerSelected;

        if (targetIdentifier === undefined || targetIdentifier === "") return;

        const char = lp.Character;
        const target = Players.FindFirstChild(tostring(targetIdentifier)) as Player;
        
        if (!char || !target || !target.Character) return;

        const hrp = char.FindFirstChild("HumanoidRootPart") as Part;
        const targetHrp = target.Character.FindFirstChild("HumanoidRootPart") as Part;
        const targetHead = target.Character.FindFirstChild("Head") as Part;

        if (hrp && targetHrp && targetHead) {
            const targetPos = targetHead.Position.add(targetHrp.CFrame.LookVector.mul(1.9));
            hrp.CFrame = new CFrame(targetPos, targetHead.Position)
                .add(new Vector3(0, 0.8, 0))
                .mul(CFrame.Angles(0, math.rad(180), 0));
            
            Workspace.Gravity = 0;
        }
    });
}

initFacebang().catch((err) => warn(`[Facebang] Init Error: ${err}`));
