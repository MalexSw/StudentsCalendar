//
//  Hometask.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 07.11.2025.
//

import Foundation


struct HomeTask: Codable, Hashable {
    var id: UInt64
    var parentId: UInt64
    var priority: Int       // 0 - task, 1 - exam
    var testName: String
    var subject: String
    var date: Date
    var task: String
    var description: String
    var wayOfPassing: WayOfTaskPass
    var isDeleted: Bool
    var additionalNotes: String?
    
    init(id: UInt64, parentId: UInt64, priority: Int, testName: String, subject: String, date: Date, task: String, description: String, wayOfPassing: WayOfTaskPass, isDeleted: Bool, additionalNotes: String? = nil) {
        self.id = id
        self.parentId = parentId
        self.priority = priority
        self.testName = testName
        self.subject = subject
        self.date = date
        self.task = task
        self.description = description
        self.wayOfPassing = wayOfPassing
        self.isDeleted = isDeleted
        self.additionalNotes = additionalNotes
    }
}
