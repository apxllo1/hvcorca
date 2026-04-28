/**
 * Global variables injected by the Havoc Bundler & Runtime
 */
declare const VERSION: string;

/**
 * Roblox Executor Globals
 */
declare const queue_on_teleport: ((script: string) => void) | undefined;
declare const gethui: (() => BasePlayerGui) | undefined;
declare const protect_gui: ((object: ScreenGui) => void) | undefined;
declare function getgenv(): any;

declare namespace syn {
	function queue_on_teleport(script: string): void;
	function protect_gui(object: ScreenGui): void;
}

/**
 * Havoc Runtime Handshake Globals
 * (Optional: only needed if you call these from TS)
 */
declare namespace _G {
    let Havoc_Init: (env: any) => void;
    let Havoc_NewModule: (...args: any[]) => void;
    let Havoc_NewInstance: (...args: any[]) => void;
}
