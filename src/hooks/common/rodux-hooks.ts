import { TypedUseSelectorHook, useDispatch as useBaseDispatch, useSelector as useBaseSelector, useStore as useBaseStore } from "@rbxts/roact-rodux-hooked";
import { RootState } from "store/store";
import { Store } from "@rbxts/rodux";

interface Action {
	type: string;
}

// 1. Standard Hooks
export const useSelector: TypedUseSelectorHook<RootState> = useBaseSelector;
export const useDispatch: () => (action: Action) => void = useBaseDispatch;

// 2. The Store Hook - This is the part causing the Shortcuts.tsx error
// We explicitly tell it that the store uses our RootState
export const useStore: () => Store<RootState> = useBaseStore;

// 3. The "App" Hooks for your project
export const useAppSelector = useSelector;
export const useAppDispatch = useDispatch;
export const useAppStore = useStore;
