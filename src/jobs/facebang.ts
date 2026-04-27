// src/jobs/players/facebang.ts
import { onJobChange } from "../helpers/job-store";

let connection: rbxts.Subscription | undefined;

onJobChange("facebang", (job, state) => {
    // 1. If the button was turned OFF, stop the loop
    if (!job.active) {
        if (connection) {
            connection.unsubscribe(); // Or connection.Disconnect()
            connection = undefined;
        }
        return;
    }

    // 2. If the button was turned ON, start the logic
    print("Facebang Started!");
    
    // Example logic loop
    connection = game.GetService("RunService").Heartbeat.Connect(() => {
        // Your teleport math here
        // It only runs while 'active' is true
    });
});
