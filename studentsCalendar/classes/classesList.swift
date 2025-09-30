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

enum WayOfTaskPass: String, Codable, CaseIterable {
    case online = "Online"
    case selfStudy = "For self study"
    case offline = "In class"
}

var eventsList = [UniversalEvent]()
var tasksList = [HomeTask]()

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
    var tasks: [HomeTask?]
    
    init(id: Int, name: String, date: Date, eventType: EventType? = nil, summary: String? = nil, start: String? = nil, end: String? = nil, roomNumber: String? = nil, building: String? = nil, location: String? = nil, shortDescription: String? = nil, notates: String? = nil, isEventOblig: Bool? = nil, tasks: [HomeTask?] = []) {
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
        self.tasks = tasks
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
        self.tasks = try container.decode([HomeTask].self, forKey: .tasks)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, date, summary, start, end, location, isEventOblig, eventType,
        roomNumber, building, shortDescription, notates, tasks
    }
}

struct HomeTask: Codable, Hashable {
    var id: Int
    var priority: Int
    var testName: String
    var subject: String
    var date: Date
    var task: String
    var description: String
    var wayOfPassing: WayOfTaskPass
    var isDeleted: Bool
    var additionalNotes: String?
    
    init(id: Int, priority: Int, testName: String, subject: String, date: Date, task: String, description: String, wayOfPassing: WayOfTaskPass, isDeleted: Bool, additionalNotes: String? = nil) {
        self.id = id
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
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        self.id = try container.decode(Int.self, forKey: .id)
//        self.priority = try container.decode(Int.self, forKey: .priority)
//        self.testName = try container.decode(String.self, forKey: .testName)
//        self.subject = try container.decode(String.self, forKey: .subject)
//        self.date = try container.decode(Date.self, forKey: .date)
//        self.task = try container.decode(String.self, forKey: .task)
//        self.description = try container.decode(String.self, forKey: .description)
//        self.wayOfPassing = try container.decode(WayOfTaskPass.self, forKey: .wayOfPassing)
//        self.isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
//        self.additionalNotes = try container.decodeIfPresent(String.self, forKey: .additionalNotes)
//    }
    
//    enum CodingKeys: String, CodingKey {
//        case id, priority, testName, subject, date, task, description, wayOfPassing, isDeleted, additionalNotes
//    }

//    static func sortByPriority(_ tasks: [HomeTask?]) -> [HomeTask] {
//        return tasks.compactMap { $0 } 
//                    .sorted { $0.priority < $1.priority }
//    }




//TODO: add image adding to task
/*
import UIKit

class HomeTaskViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var homeTask = HomeTask(id: 1, testName: "Math Homework", date: Date(), task: "Solve problems", description: "Chapter 5")

    @IBAction func addPhotoTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary // or .camera for camera
        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            homeTask.images.append(imageData)
        }
        dismiss(animated: true)
    }
}
*/
