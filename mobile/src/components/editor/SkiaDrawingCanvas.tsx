/**
 * PencilKit replacement: @shopify/react-native-skia with JSON stroke persistence.
 */
import { Canvas, Path, Skia, type SkPath } from "@shopify/react-native-skia";
import { useCallback, useMemo, useState } from "react";
import { LayoutChangeEvent, View } from "react-native";
import { Gesture, GestureDetector } from "react-native-gesture-handler";

import type { DrawingPoint, DrawingStroke } from "../../domain/entities";
import { appendStroke, parseDrawingDocument } from "../../domain/drawingDocument";

const STROKE_COLOR = "#111827";
const STROKE_WIDTH = 3;

function pointsToPath(points: DrawingPoint[]): SkPath {
  const path = Skia.Path.Make();
  if (points.length === 0) {
    return path;
  }
  path.moveTo(points[0].x, points[0].y);
  for (let i = 1; i < points.length; i += 1) {
    path.lineTo(points[i].x, points[i].y);
  }
  return path;
}

interface SkiaDrawingCanvasProps {
  drawingData: string;
  onDrawingDataChange: (next: string) => void;
  height?: number;
}

export function SkiaDrawingCanvas({
  drawingData,
  onDrawingDataChange,
  height = 220,
}: SkiaDrawingCanvasProps) {
  const [size, setSize] = useState({ width: 320, height });
  const [livePoints, setLivePoints] = useState<DrawingPoint[]>([]);

  const document = useMemo(() => parseDrawingDocument(drawingData), [drawingData]);
  const livePath = useMemo(() => pointsToPath(livePoints), [livePoints]);

  const onLayout = (e: LayoutChangeEvent) => {
    const { width, height: h } = e.nativeEvent.layout;
    setSize({ width, height: h });
  };

  const commitStroke = useCallback(
    (points: DrawingPoint[]) => {
      if (points.length < 2) {
        return;
      }
      const stroke: DrawingStroke = {
        color: STROKE_COLOR,
        width: STROKE_WIDTH,
        points,
      };
      onDrawingDataChange(appendStroke(drawingData, stroke));
    },
    [drawingData, onDrawingDataChange],
  );

  const pan = Gesture.Pan()
    .runOnJS(true)
    .onBegin((e) => {
      setLivePoints([{ x: e.x, y: e.y }]);
    })
    .onUpdate((e) => {
      setLivePoints((prev) => [...prev, { x: e.x, y: e.y }]);
    })
    .onEnd(() => {
      setLivePoints((points) => {
        commitStroke(points);
        return [];
      });
    });

  return (
    <View
      className="rounded-xl border border-default-200 overflow-hidden bg-default-50"
      style={{ height }}
      onLayout={onLayout}
    >
      <GestureDetector gesture={pan}>
        <Canvas style={{ flex: 1, width: size.width, height: size.height }}>
          {document.strokes.map((stroke, index) => (
            <Path
              key={`stroke-${index}`}
              path={pointsToPath(stroke.points)}
              color={stroke.color}
              style="stroke"
              strokeWidth={stroke.width}
              strokeCap="round"
              strokeJoin="round"
            />
          ))}
          {livePoints.length > 1 ? (
            <Path
              path={livePath}
              color={STROKE_COLOR}
              style="stroke"
              strokeWidth={STROKE_WIDTH}
              strokeCap="round"
              strokeJoin="round"
            />
          ) : null}
        </Canvas>
      </GestureDetector>
    </View>
  );
}
