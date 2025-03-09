//
//  classesList.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 22.02.2025.
//

import Foundation

class UniEvent: Event {
    var summary: String
    var start: String
    var end: String
    var roomNumber: String
    var building: String
    var location: String?
    var isEventOblig: Bool?
    
    init(summary: String, start: String, end: String, roomNumber: String, building: String, location: String?, isEventOblig: Bool?) {
        self.summary = summary
        self.start = start
        self.end = end
        self.roomNumber = roomNumber
        self.building = building
        self.location = location
        self.isEventOblig = isEventOblig
    }

}

var eventsList = [Event]()

class Event
{
    var id: Int!
    var name: String!
    var date: Date!
    
    func eventsForDate(date: Date) -> [Event]
    {
        var daysEvents = [Event]()
        for event in eventsList
        {
            if(Calendar.current.isDate(event.date, inSameDayAs:date))
            {
                daysEvents.append(event)
            }
        }
        return daysEvents
    }
}
