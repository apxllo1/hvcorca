import { TypedUseSelectorHook, useDispatch as useBaseDispatch, useSelector as useBaseSelector, useStore as useBaseStore } from "@rbxts/roact-rodux-hooked";
import { RootState } from "store/store";
import { AnyAction } from "rodux";

// Export the standard names
export const useSelector: TypedUseSelectorHook<RootState> = useBaseSelector;
export const useDispatch: () => (action: AnyAction) => void = useBaseDispatch;
export const useStore: () => useBaseStore<RootState> = useBaseStore;

// Export the "App" names that your other files are looking for
export const useAppSelector = useSelector;
export const useAppDispatch = useDispatch;
export const useAppStore = useStore;
