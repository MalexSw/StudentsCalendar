//
//  calendarInfoParse.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 22.02.2025.
//

import UIKit

func uploadAndParseEvents() async {
    do {
        tasksList = await loadHomeTasks()
        guard let urlString = loadScheduleURL(), !urlString.isEmpty else {
            print("No schedule URL saved")
            return
        }

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Server error: Invalid response")
            return
        }

        guard let icsString = String(data: data, encoding: .utf8) else {
            print("Error decoding ICS data")
            return
        }

        var events = parseICSEvents(icsData: icsString)
        events = await associateTasksWithEvents(events) // Await async function

        DispatchQueue.main.async {
            eventsList = events  // Update global/local events list
             // Store in UserDefaults
        }
        await saveDownloadedEventsToUserDefaults(events: events)
    } catch {
        print("Error fetching calendar: \(error.localizedDescription)")
    }
}

func loadScheduleURL() -> String? {
    return UserDefaults.standard.string(forKey: "scheduleURL")
}

func associateTasksWithEvents(_ events: [UniversalEvent]) async -> [UniversalEvent] {
    var updatedEvents = events
    let tasksList = await loadHomeTasks()
    
    for task in tasksList {
//        if let eventIndex = updatedEvents.firstIndex(where: { $0.id == Int(parentID(from: UInt64(task.id)))}) {
//            if updatedEvents[eventIndex].tasks == nil {
//                updatedEvents[eventIndex].tasks = []
//            }
//            if task.isDeleted != true {
//                updatedEvents[eventIndex].tasks.append(task)
//            }
//        }
            let parent = task.parentId
            if let eventIndex = updatedEvents.firstIndex(where: { $0.id == parent }) {
                if updatedEvents[eventIndex].tasks == nil {
                    updatedEvents[eventIndex].tasks = []
                }
                if task.isDeleted != true {
                    updatedEvents[eventIndex].tasks.append(task)
                }
            }

    }
    
    return updatedEvents
}

func parseICSEvents(icsData: String) -> [UniversalEvent] {
    let lines = icsData.components(separatedBy: CharacterSet.newlines)
    var events: [UniversalEvent] = []

    var summary = ""
    var start = ""
    var end = ""
    var location = ""
    var roomNumber = ""
    var buildingName = ""
    let eventType = EventType.scheduleDownloaded
    var isEventOblig = true

    for line in lines {
        print(line)
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty { continue }

        if trimmed.hasPrefix("SUMMARY:") {
            summary = String(trimmed.dropFirst(8))
        } else if trimmed.hasPrefix("DTSTART") {
            if let range = trimmed.range(of: ":") {
                start = decodeICSTime(String(trimmed[range.upperBound...]))
            }
        } else if trimmed.hasPrefix("DTEND") {
            if let range = trimmed.range(of: ":") {
                end = decodeICSTime(String(trimmed[range.upperBound...]))
            }
        } else if trimmed.hasPrefix("LOCATION:") {
            location = String(trimmed.dropFirst(9))
        } else if trimmed.hasPrefix("DESCRIPTION:") {
            let descriptionContent = String(trimmed.dropFirst(12))  // Remove "DESCRIPTION:"
            let descriptionLines = descriptionContent.components(separatedBy: "\\n")

            if descriptionLines.count > 0 {
                roomNumber = descriptionLines[0].replacingOccurrences(of: "Sala: ", with: "").trimmingCharacters(in: .whitespaces)
            }
            if descriptionLines.count > 1 {
                buildingName = descriptionLines[1].trimmingCharacters(in: .whitespaces)
            }
        } else if trimmed == "END:VEVENT" {
            print(start)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")


            guard let eventDate = dateFormatter.date(from: start) else {
                print("Error parsing date for event: \(summary)")
                continue
            }

            let event = UniversalEvent(
                id: compactEventID64(subject: summary, beginDate: eventDate),
                name: summary,
                date: eventDate,
                eventType: eventType,
                summary: summary,
                start: start,
                end: end,
                roomNumber: roomNumber,
                building: buildingName,
                location: location,
                isEventOblig: isEventOblig
            )
            print(event)
            
            events.append(event)

            // Reset variables
            summary = ""
            start = ""
            end = ""
            location = ""
            roomNumber = ""
            buildingName = ""
            isEventOblig = true
        }
    }
    
    print("Total events found: \(events.count)")
    return events
}

func decodeICSTime(_ icsTime: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
    dateFormatter.timeZone = TimeZone(identifier: "Europe/Warsaw") // or .current if local time


    guard let date = dateFormatter.date(from: icsTime) else {
        return "Invalid Date"
    }

    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    outputFormatter.timeZone = TimeZone.current // Convert to the current local timezone

    return outputFormatter.string(from: date)
}

func compactEventID64(subject: String, beginDate: Date) -> UInt64 {
    let iso = ISO8601DateFormatter()
    iso.timeZone = .init(secondsFromGMT: 0)
    let key = subject + "|" + iso.string(from: beginDate)
    // FNV-1a 64-bit
    var hash: UInt64 = 0xcbf29ce484222325
    for b in key.utf8 {
        hash ^= UInt64(b)
        hash &*= 0x100000001b3
    }
    return hash
}

//func idCreation(subject: String, start: Date) -> UInt64 {
//    let subjectID = UInt64(subjectHash(subject))               // 16 bits
//    //let minutes = UInt64(start.timeIntervalSince1970 / 60)    // epoch minutes
//    
//    //let eventID = (subjectID << 48)/* | (minutes << 8)*/
//    return subjectID
//}

//func subjectHash(_ subject: String) -> UInt16 {
//    var hash: UInt32 = 0x811C9DC5 // 32-bit FNV offset basis
//    for byte in subject.utf8 {
//        hash ^= UInt32(byte)
//        hash = hash &* 16777619 // 32-bit FNV prime
//    }
//    return UInt16(truncatingIfNeeded: hash) // fold to 16-bit
//}

//func subjectID(from eventID: UInt64) -> UInt16 {
//    return UInt16((eventID >> 48) & 0xFFFF)
//}


// Theoreticaly useless

// Helper function to convert String to Date
//func parseDate(from dateString: String) -> Date? {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'" // Adjust format to match ICS date format
//    formatter.timeZone = TimeZone(abbreviation: "UTC")
//    return formatter.date(from: dateString)
//}
//
//
//func handleParsedEvents(_ events: [UniEvent]) {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//    dateFormatter.timeZone = TimeZone.current
//
//    for event in events {
//        if let eventDate = dateFormatter.date(from: event.start) {
//            let newEvent = Event()
//            newEvent.id = eventsList.count + 1
//            newEvent.name = event.summary
//            newEvent.date = eventDate
//
//            eventsList.append(newEvent)
//        }
//    }
//
//    DispatchQueue.main.async {
//        NotificationCenter.default.post(name: NSNotification.Name("EventsUpdated"), object: nil)
//    }
//}
//
//
//func decodeICSTime(_ icsTime: String) -> String {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
//    dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Read as UTC
//
//    if let date = dateFormatter.date(from: icsTime) {
//        let correctedDate = Calendar.current.date(byAdding: .hour, value: -2, to: date)! // Subtract 1 hour
//        
//        let outputFormatter = DateFormatter()
//        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//        outputFormatter.timeZone = TimeZone.current // Convert to local time zone
//        
//        return outputFormatter.string(from: correctedDate)
//    } else {
//        return "Invalid Date"
//    }
//}

//func decodeICSTime(_ icsTime: String) -> String {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
//    dateFormatter.timeZone = TimeZone(identifier: "Europe/Warsaw") // Use Warsaw timezone directly
//
//    guard let date = dateFormatter.date(from: icsTime) else {
//        return "Invalid Date"
//    }
//
//    let outputFormatter = DateFormatter()
//    outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//    outputFormatter.timeZone = TimeZone.current // Convert to the current local timezone
//
//    return outputFormatter.string(from: date)
//}


