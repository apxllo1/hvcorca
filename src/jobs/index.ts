// Triggering new build - Facebang update
export { setStore } from "./helpers/job-store";

// We removed ".client" because these are now ModuleScripts
import "./facebang";

// Updated imports for existing features
import "./acrylic";
import "./freecam";
import "./server";

// Updated subfolder imports
import "./character/flight";
import "./character/ghost";
import "./character/godmode";
import "./character/humanoid";
import "./character/refresh";

import "./players/hide";
import "./players/kill";
import "./players/spectate";
import "./players/teleport";
