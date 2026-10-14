export interface CalendarLike {
  startOfDay(date: Date): Date;
  isSameDay(a: Date, b: Date): boolean;
  addDays(date: Date, days: number): Date;
}

export const defaultCalendar: CalendarLike = {
  startOfDay(date: Date): Date {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    return d;
  },
  isSameDay(a: Date, b: Date): boolean {
    return (
      a.getFullYear() === b.getFullYear() &&
      a.getMonth() === b.getMonth() &&
      a.getDate() === b.getDate()
    );
  },
  addDays(date: Date, days: number): Date {
    const d = new Date(date);
    d.setDate(d.getDate() + days);
    return d;
  },
};

export const taskScheduling = {
  normalizedDay(date: Date, calendar: CalendarLike = defaultCalendar): Date {
    return calendar.startOfDay(date);
  },

  normalizedPeriod(
    start: Date,
    end: Date | null | undefined,
    calendar: CalendarLike = defaultCalendar,
  ): { start: Date; end: Date } {
    const normalizedStart = calendar.startOfDay(start);
    const normalizedEnd = calendar.startOfDay(end ?? start);
    if (normalizedEnd.getTime() < normalizedStart.getTime()) {
      return { start: normalizedEnd, end: normalizedEnd };
    }
    return { start: normalizedStart, end: normalizedEnd };
  },

  rangeContains(
    date: Date,
    start: Date | null | undefined,
    end: Date | null | undefined,
    calendar: CalendarLike = defaultCalendar,
  ): boolean {
    if (!start) {
      return false;
    }
    const period = taskScheduling.normalizedPeriod(start, end, calendar);
    const day = calendar.startOfDay(date);
    return day.getTime() >= period.start.getTime() && day.getTime() <= period.end.getTime();
  },
};
