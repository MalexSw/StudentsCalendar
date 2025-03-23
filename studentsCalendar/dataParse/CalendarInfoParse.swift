//
//  calendarInfoParse.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 22.02.2025.
//

import UIKit

func uploadAndParseEvents() {
    guard let urlString = loadScheduleURL(), !urlString.isEmpty else {
        print("No schedule URL saved")
        return
    }

    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching calendar: \(error.localizedDescription)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Server error: Invalid response")
            return
        }

        guard let data = data, let icsString = String(data: data, encoding: .utf8) else {
            print("Error decoding ICS data")
            return
        }

        let events = parseICSEvents(icsData: icsString)

        DispatchQueue.main.async {
            eventsList = events  // Update global/local events list
            saveDownloadedEventsToUserDefaults(events: events) // Store in UserDefaults
        }
    }
    task.resume()
}

func loadScheduleURL() -> String? {
    return UserDefaults.standard.string(forKey: "scheduleURL")
}

func parseICSEvents(icsData: String) -> [UniEvent] {
    let lines = icsData.components(separatedBy: CharacterSet.newlines)
    var events: [UniEvent] = []

    var summary = ""
    var start = ""
    var end = ""
    var location = ""
    var roomNumber = ""
    var buildingName = ""
    var isEventOblig = true

    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty { continue }

        if trimmed.hasPrefix("SUMMARY:") {
            summary = String(trimmed.dropFirst(8))
        } else if trimmed.hasPrefix("DTSTART") {
            if let range = trimmed.range(of: ":") {
                let timeForDecode = String(trimmed[range.upperBound...])
                start = decodeICSTime(timeForDecode)
            }
        } else if trimmed.hasPrefix("DTEND") {
            if let range = trimmed.range(of: ":") {
                let timeForDecode = String(trimmed[range.upperBound...])
                end = decodeICSTime(timeForDecode)
            }
        } else if trimmed.hasPrefix("LOCATION:") {
            location = String(trimmed.dropFirst(9))
        } else if trimmed.hasPrefix("DESCRIPTION:") {
            if let roomRange = trimmed.range(of: "Room: ") {
                let roomSubstring = trimmed[roomRange.upperBound...]
                let roomParts = roomSubstring.components(separatedBy: "\\n").filter { !$0.isEmpty }
                if let room = roomParts.first {
                    roomNumber = room.trimmingCharacters(in: .whitespaces)
                }
            }
            
            if let buildingRange = trimmed.range(of: "Room: ") {
                let buildingSubstring = trimmed[buildingRange.lowerBound...]
                let buildingParts = buildingSubstring.components(separatedBy: "\\n").filter { !$0.isEmpty }
                if buildingParts.count > 1 {
                     buildingName = String(buildingParts[1])
                }
            }
        } else if trimmed == "END:VEVENT" {
            // Convert start string to Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.timeZone = TimeZone.current
            var eventDate = dateFormatter.date(from: start)// Default to current date if parsing fails
            
            let event = UniEvent(id: events.count + 1, // Unique ID
                                 name: summary,
                                 date: eventDate!,
                                 summary: summary,
                                 start: start,
                                 end: end,
                                 roomNumber: roomNumber,
                                 building: buildingName,
                                 location: location,
                                 isEventOblig: isEventOblig)
            
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
func decodeICSTime(_ icsTime: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Read as UTC

    if let date = dateFormatter.date(from: icsTime) {
        let correctedDate = Calendar.current.date(byAdding: .hour, value: -1, to: date)! // Subtract 1 hour
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        outputFormatter.timeZone = TimeZone.current // Convert to local time zone
        
        return outputFormatter.string(from: correctedDate)
    } else {
        return "Invalid Date"
    }
}
