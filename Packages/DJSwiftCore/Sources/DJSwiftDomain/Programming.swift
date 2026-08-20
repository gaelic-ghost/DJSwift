import Foundation

public struct Program: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let stationID: Station.ID
    public let name: String
    public let summary: String

    public init(id: UUID, stationID: Station.ID, name: String, summary: String) {
        self.id = id
        self.stationID = stationID
        self.name = name
        self.summary = summary
    }
}

public enum Weekday: Int, CaseIterable, Hashable, Sendable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

public struct ScheduleRule: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let programID: Program.ID
    public let timeZoneIdentifier: String
    public let weekdays: Set<Weekday>
    public let startMinuteOfDay: Int
    public let durationMinutes: Int
    public let priority: Int

    public init(
        id: UUID,
        programID: Program.ID,
        timeZoneIdentifier: String,
        weekdays: Set<Weekday>,
        startMinuteOfDay: Int,
        durationMinutes: Int,
        priority: Int = 0
    ) {
        self.id = id
        self.programID = programID
        self.timeZoneIdentifier = timeZoneIdentifier
        self.weekdays = weekdays
        self.startMinuteOfDay = startMinuteOfDay
        self.durationMinutes = durationMinutes
        self.priority = priority
    }
}
