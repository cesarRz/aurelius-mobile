import { Chip } from "heroui-native";
import type { JSX } from "react";

import type { WorkStatus } from "../domain/entities";
import { WORK_STATUS_LABELS } from "../domain/labels";

export function StatusBadge({ status }: { status: WorkStatus }): JSX.Element {
  return (
    <Chip size="sm" variant="soft" color="default">
      {WORK_STATUS_LABELS[status]}
    </Chip>
  );
}
