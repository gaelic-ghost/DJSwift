import DJSwiftAPI

public typealias Program = Components.Schemas.Program
public typealias ScheduleRule = Components.Schemas.ScheduleRule
public typealias Weekday = Components.Schemas.Weekday

public extension Weekday {
    static var sunday: Self { ._1 }
    static var monday: Self { ._2 }
    static var tuesday: Self { ._3 }
    static var wednesday: Self { ._4 }
    static var thursday: Self { ._5 }
    static var friday: Self { ._6 }
    static var saturday: Self { ._7 }
}
