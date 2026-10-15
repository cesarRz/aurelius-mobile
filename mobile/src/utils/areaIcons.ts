import { Ionicons } from "@expo/vector-icons";
import type { ComponentProps } from "react";

type IoniconName = ComponentProps<typeof Ionicons>["name"];

const ICON_MAP: Record<string, IoniconName> = {
  "square.grid.2x2": "grid-outline",
  briefcase: "briefcase-outline",
  person: "person-outline",
  heart: "heart-outline",
  house: "home-outline",
  "dollarsign.circle": "cash-outline",
  "figure.run": "walk-outline",
  book: "book-outline",
  car: "car-outline",
  "building.2": "business-outline",
};

export const AREA_ICON_OPTIONS = Object.keys(ICON_MAP);

export function areaIoniconName(sfSymbol: string): IoniconName {
  return ICON_MAP[sfSymbol] ?? "ellipse-outline";
}
