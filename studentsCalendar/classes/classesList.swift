//
//  classesList.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 22.02.2025.
//

//import Foundation

enum EventType: Codable {
    case scheduleDownloaded
    case userCreated
}

var eventsList = [Event]()

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

class CustomEvent: Event {
    var summary: String
    var start: String
    var end: String
    var location: String?
    var shortDescription: String?
    var notates: String?
    var isEventOblig: Bool?

    init(id: Int, name: String, date: Date, summary: String, start: String, end: String, location: String?, isEventOblig: Bool?) {
        self.summary = summary
        self.start = start
        self.end = end
        self.location = location
        self.isEventOblig = isEventOblig
        super.init()
        self.id = id
        self.date = date
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let date = try container.decode(Date.self, forKey: .date)

        self.summary = try container.decode(String.self, forKey: .summary)
        self.start = try container.decode(String.self, forKey: .start)
        self.end = try container.decode(String.self, forKey: .end)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.isEventOblig = try container.decodeIfPresent(Bool.self, forKey: .isEventOblig)
        
        super.init()
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.date = try container.decode(Date.self, forKey: .date)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, date, summary, start, end, location, isEventOblig
    }
}


class Event: Encodable, Decodable
{
    var id: Int!
    var name: String!
    var date: Date!
    

}

import Foundation

class UniversalEvent: Codable {
    var id: Int
    var name: String
    var date: Date
    var eventType: EventType?
    
    var summary: String?
    var start: String?
    var end: String?
    var roomNumber: String?
    var building: String?
    var location: String?
    
    var shortDescription: String?
    var notates: String?
    var isEventOblig: Bool?
    
    init(id: Int, name: String, date: Date, eventType: EventType?, summary: String?, start: String?, end: String?, roomNumber: String?, building: String?, location: String?, shortDescription: String?, notates: String?, isEventOblig: Bool?) {
        self.id = id
        self.name = name
        self.date = date
        self.eventType = eventType
        self.summary = summary
        self.start = start
        self.end = end
        self.roomNumber = roomNumber
        self.building = building
        self.location = location
        self.shortDescription = shortDescription
        self.notates = notates
        self.isEventOblig = isEventOblig
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.date = try container.decode(Date.self, forKey: .date)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        self.start = try container.decodeIfPresent(String.self, forKey: .start)
        self.end = try container.decodeIfPresent(String.self, forKey: .end)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.isEventOblig = try container.decodeIfPresent(Bool.self, forKey: .isEventOblig)
        self.eventType = try container.decodeIfPresent(EventType.self, forKey: .eventType)
        self.roomNumber = try container.decodeIfPresent(String.self, forKey: .roomNumber)
        self.building = try container.decodeIfPresent(String.self, forKey: .building)
        self.shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        self.notates = try container.decodeIfPresent(String.self, forKey: .notates)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, date, summary, start, end, location, isEventOblig, eventType,
        roomNumber, building, shortDescription, notates
    }
}

