declare global {
    const VERSION: string;
    const queue_on_teleport: ((script: string) => void) | undefined;
    const gethui: (() => BasePlayerGui) | undefined;
    const protect_gui: ((object: ScreenGui) => void) | undefined;
    
    function getgenv(): Record<string, any>;

    namespace syn {
        function queue_on_teleport(script: string): void;
        function protect_gui(object: ScreenGui): void;
    }

    interface _G {
        [key: string]: any;
        Havoc_Init: (env: any) => void;
        Havoc_NewModule: (...args: any[]) => void;
        Havoc_NewInstance: (...args: any[]) => void;
    }
}

export {};