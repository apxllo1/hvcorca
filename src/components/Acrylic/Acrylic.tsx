import Roact from "@rbxts/roact";
import { useCallback, useEffect, useMemo, useMutable } from "@rbxts/roact-hooked";
import { Workspace } from "@rbxts/services";
import { acrylicInstance } from "components/Acrylic/acrylic-instance";
import { useAppSelector } from "hooks/common/rodux-hooks";
import { map } from "utils/number-util";
import { scale } from "utils/udim2";

const cylinderAngleOffset = CFrame.Angles(0, math.rad(90), 0);

interface Props {
    radius?: number;
    distance?: number;
}

function viewportPointToWorld(location: Vector2, distance: number): Vector3 {
    const unitRay = Workspace.CurrentCamera!.ScreenPointToRay(location.X, location.Y);
    return unitRay.Origin.add(unitRay.Direction.mul(distance));
}

function getOffset() {
    return map(Workspace.CurrentCamera!.ViewportSize.Y, 0, 2560, 8, 56);
}

function Acrylic({ radius, distance }: Props) {
    const isAcrylicBlurEnabled = useAppSelector((state) => state.options.config.acrylicBlur);
    return <>{isAcrylicBlurEnabled && <AcrylicBlur radius={radius} distance={distance} />}</>;
}

export default Acrylic; // Export directly

function AcrylicBlur({ radius = 0, distance = 0.001 }: Props) {
    const frameInfo = useMutable({
        topleft2d: new Vector2(),
        topright2d: new Vector2(),
        bottomright2d: new Vector2(),
        topleftradius2d: new Vector2(),
    });

    const acrylic = useMemo(() => {
        const clone = acrylicInstance.Clone();
        clone.Parent = Workspace;
        return clone;
    }, []);

    useEffect(() => {
        return () => acrylic.Destroy();
    }, []);

    const updateFrameInfo = useCallback((size: Vector2, position: Vector2) => {
        const topleftRaw = position.sub(size.div(2));
        const info = frameInfo.current;
        info.topleft2d = new Vector2(math.ceil(topleftRaw.X), math.ceil(topleftRaw.Y));
        info.topright2d = info.topleft2d.add(new Vector2(size.X, 0));
        info.bottomright2d = info.topleft2d.add(size);
        info.topleftradius2d = info.topleft2d.add(new Vector2(radius, 0));
    }, [distance, radius]);

    const updateInstance = useCallback(() => {
        const { topleft2d, topright2d, bottomright2d, topleftradius2d } = frameInfo.current;
        const topleft = viewportPointToWorld(topleft2d, distance);
        const topright = viewportPointToWorld(topright2d, distance);
        const bottomright = viewportPointToWorld(bottomright2d, distance);
        const topleftradius = viewportPointToWorld(topleftradius2d, distance);

        const cornerRadius = topleftradius.sub(topleft).Magnitude;
        const width = topright.sub(topleft).Magnitude;
        const height = topright.sub(bottomright).Magnitude;

        const center = CFrame.fromMatrix(
            topleft.add(bottomright).div(2),
            Workspace.CurrentCamera!.CFrame.XVector,
            Workspace.CurrentCamera!.CFrame.YVector,
            Workspace.CurrentCamera!.CFrame.ZVector,
        );

        if (radius !== undefined && radius > 0) {
            acrylic.Horizontal.CFrame = center;
            acrylic.Horizontal.Mesh.Scale = new Vector3(width - cornerRadius * 2, height, 0);
            acrylic.Vertical.CFrame = center;
            acrylic.Vertical.Mesh.Scale = new Vector3(width, height - cornerRadius * 2, 0);
        } else {
            acrylic.Horizontal.CFrame = center;
            acrylic.Horizontal.Mesh.Scale = new Vector3(width, height, 0);
        }

        if (radius !== undefined && radius > 0) {
            acrylic.TopLeft.CFrame = center.mul(new CFrame(-width / 2 + cornerRadius, height / 2 - cornerRadius, 0)).mul(cylinderAngleOffset);
            acrylic.TopLeft.Mesh.Scale = new Vector3(0, cornerRadius * 2, cornerRadius * 2);
            acrylic.TopRight.CFrame = center.mul(new CFrame(width / 2 - cornerRadius, height / 2 - cornerRadius, 0)).mul(cylinderAngleOffset);
            acrylic.TopRight.Mesh.Scale = new Vector3(0, cornerRadius * 2, cornerRadius * 2);
            acrylic.BottomLeft.CFrame = center.mul(new CFrame(-width / 2 + cornerRadius, -height / 2 + cornerRadius, 0)).mul(cylinderAngleOffset);
            acrylic.BottomLeft.Mesh.Scale = new Vector3(0, cornerRadius * 2, cornerRadius * 2);
            acrylic.BottomRight.CFrame = center.mul(new CFrame(width / 2 - cornerRadius, -height / 2 + cornerRadius, 0)).mul(cylinderAngleOffset);
            acrylic.BottomRight.Mesh.Scale = new Vector3(0, cornerRadius * 2, cornerRadius * 2);
        }
    }, [radius, distance]);

    useEffect(() => {
        updateInstance();
        const posHandle = Workspace.CurrentCamera!.GetPropertyChangedSignal("CFrame").Connect(updateInstance);
        const fovHandle = Workspace.CurrentCamera!.GetPropertyChangedSignal("FieldOfView").Connect(updateInstance);
        const viewportHandle = Workspace.CurrentCamera!.GetPropertyChangedSignal("ViewportSize").Connect(updateInstance);
        return () => {
            posHandle.Disconnect();
            fovHandle.Disconnect();
            viewportHandle.Disconnect();
        };
    }, [updateInstance]);

    return (
        <frame
            Change={{
                AbsoluteSize: (rbx) => {
                    const blurOffset = getOffset();
                    const size = rbx.AbsoluteSize.sub(new Vector2(blurOffset, blurOffset));
                    const position = rbx.AbsolutePosition.add(rbx.AbsoluteSize.div(2));
                    updateFrameInfo(size, position);
                    task.spawn(updateInstance);
                },
                AbsolutePosition: (rbx) => {
                    const blurOffset = getOffset();
                    const size = rbx.AbsoluteSize.sub(new Vector2(blurOffset, blurOffset));
                    const position = rbx.AbsolutePosition.add(rbx.AbsoluteSize.div(2));
                    updateFrameInfo(size, position);
                    task.spawn(updateInstance);
                },
            }}
            Size={scale(1, 1)}
            BackgroundTransparency={1}
        />
    );
}