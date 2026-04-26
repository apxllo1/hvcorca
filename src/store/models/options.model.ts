export interface OptionsState {
	config: {
		/**
		 * Use a DepthOfField blur with glass near the camera when `acrylic` mode is
		 * enabled in a theme. **May decrease framerate!**
		 */
		acrylicBlur: boolean;
	};

	currentTheme: string;

	shortcuts: Record<string, number | undefined> & {
		toggleDashboard: number;
	};
}

// CRITICAL FIX: Adding this constant forces the compiler to 
// generate 'local exports = {}' and 'return exports' in Lua.
export const __FIX_OPTIONS = true;
