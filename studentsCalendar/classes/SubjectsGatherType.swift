//
//  SubjectsGatherType.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 07.11.2025.
//

struct SubjectsGatherType: Decodable {
    let id: UInt64
    let name: String
    let subject: String
    let connectedEvents: [UniversalEvent]
    let tasks: [HomeTask]
    let notes: String
    
    init(id: UInt64, name: String, subject: String, connectedEvents: [UniversalEvent], tasks: [HomeTask], notes: String) {
        self.id = id
        self.name = name
        self.subject = subject
        self.connectedEvents = connectedEvents
        self.tasks = tasks
        self.notes = notes
    }
}

