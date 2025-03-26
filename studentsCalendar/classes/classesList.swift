//
//  classesList.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 22.02.2025.
//

import Foundation

enum EventType: Codable {
    case scheduleDownloaded
    case userCreated
}

var eventsList = [UniversalEvent]()

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
    
    init(id: Int, name: String, date: Date, eventType: EventType? = nil, summary: String? = nil, start: String? = nil, end: String? = nil, roomNumber: String? = nil, building: String? = nil, location: String? = nil, shortDescription: String? = nil, notates: String? = nil, isEventOblig: Bool? = nil) {
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

