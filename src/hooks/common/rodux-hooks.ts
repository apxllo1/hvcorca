import type { TypedUseSelectorHook } from "@rbxts/roact-rodux-hooked";
import { useDispatch, useSelector, useStore } from "@rbxts/roact-rodux-hooked";
import type Rodux from "@rbxts/rodux";
import type { RootState, RootStore } from "store/store";
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
export const useAppDispatch = () => useDispatch<Rodux.Action>();
export const useAppStore = () => useStore<RootStore>();
export { useSelector, useDispatch };
