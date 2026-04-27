import { TypedUseSelectorHook, useDispatch as useBaseDispatch, useSelector as useBaseSelector, useStore as useBaseStore } from "@rbxts/roact-rodux-hooked";
import { RootState } from "store/store";

// We define a simple Action interface here so we don't need the external 'rodux' library
interface Action {
	type: string;
}

// Export the standard names
export const useSelector: TypedUseSelectorHook<RootState> = useBaseSelector;
export const useDispatch: () => (action: Action) => void = useBaseDispatch;
// Fix: Use 'ReturnType' to get the proper type of the store
export const useStore = (): ReturnType<typeof useBaseStore> => useBaseStore();

// Export the "App" names that the rest of your project uses
export const useAppSelector = useSelector;
export const useAppDispatch = useDispatch;
export const useAppStore = useStore;
