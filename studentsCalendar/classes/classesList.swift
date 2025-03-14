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

    init(id: Int, name: String, date: Date, summary: String, start: String, end: String, roomNumber: String, building: String, location: String?, isEventOblig: Bool?) {
        self.summary = summary
        self.start = start
        self.end = end
        self.roomNumber = roomNumber
        self.building = building
        self.location = location
        self.isEventOblig = isEventOblig
        super.init() // Call parent class initializer
        self.id = id
        self.name = name
        self.date = date
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.summary = try container.decode(String.self, forKey: .summary)
        self.start = try container.decode(String.self, forKey: .start)
        self.end = try container.decode(String.self, forKey: .end)
        self.roomNumber = try container.decode(String.self, forKey: .roomNumber)
        self.building = try container.decode(String.self, forKey: .building)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.isEventOblig = try container.decodeIfPresent(Bool.self, forKey: .isEventOblig)
        
        super.init()
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.date = try container.decode(Date.self, forKey: .date)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, date, summary, start, end, roomNumber, building, location, isEventOblig
    }
}


var eventsList = [Event]()

class Event: Encodable, Decodable
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
