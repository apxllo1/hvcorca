import { TypedUseSelectorHook, useDispatch as useBaseDispatch, useSelector as useBaseSelector, useStore } from "@rbxts/roact-rodux-hooked";
import { RootState } from "store/store";

// We must explicitly export these so other files can use them!
export const useSelector: TypedUseSelectorHook<RootState> = useBaseSelector;
export const useDispatch = useBaseDispatch;
export { useStore };
