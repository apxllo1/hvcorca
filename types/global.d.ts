declare global {
    const VERSION: string;
    const queue_on_teleport: ((script: string) => void) | undefined;
    const gethui: (() => BasePlayerGui) | undefined;
    const protect_gui: ((object: ScreenGui) => void) | undefined;
    
    function getgenv(): Record<string, unknown>;

    namespace syn {
        function queue_on_teleport(script: string): void;
        function protect_gui(object: ScreenGui): void;
    }

    interface _G {
        [key: string]: unknown;
        Havoc_Init: (env: unknown) => void;
        Havoc_NewModule: (...args: unknown[]) => void;
        Havoc_NewInstance: (...args: unknown[]) => void;
    }
}

export {};