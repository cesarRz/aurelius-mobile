import { describe, expect, it } from "vitest";

import { taskScheduling, type CalendarLike } from "./taskScheduling";

const nyCalendar: CalendarLike = {
  startOfDay(date) {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    return d;
  },
  isSameDay(a, b) {
    return a.getTime() === b.getTime();
  },
  addDays(date, days) {
    const d = new Date(date);
    d.setDate(d.getDate() + days);
    return d;
  },
};

describe("taskScheduling", () => {
  it("orders inverted period bounds", () => {
    const later = new Date(2026, 2, 10);
    const earlier = new Date(2026, 2, 8);
    const period = taskScheduling.normalizedPeriod(later, earlier, nyCalendar);
    expect(nyCalendar.isSameDay(period.start, earlier)).toBe(true);
    expect(nyCalendar.isSameDay(period.end, earlier)).toBe(true);
  });

  it("rangeContains is inclusive", () => {
    const start = new Date(2026, 2, 8);
    const end = new Date(2026, 2, 10);
    const middle = new Date(2026, 2, 9);
    const outside = new Date(2026, 2, 11);
    expect(taskScheduling.rangeContains(start, start, end, nyCalendar)).toBe(true);
    expect(taskScheduling.rangeContains(middle, start, end, nyCalendar)).toBe(true);
    expect(taskScheduling.rangeContains(end, start, end, nyCalendar)).toBe(true);
    expect(taskScheduling.rangeContains(outside, start, end, nyCalendar)).toBe(false);
  });
});
