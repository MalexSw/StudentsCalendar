//
//  calendarInfoParse.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 22.02.2025.
//

import UIKit


//func fetchEventsIfNeeded() async {
//    let lastFetchTime = UserDefaults.standard.object(forKey: "lastFetchTime") as? Date ?? Date.distantPast
//    let oneHourAgo = Date().addingTimeInterval(-3600) // 1 hour = 3600 seconds
//
//    if lastFetchTime < oneHourAgo {
//        print("Fetching new event data...") // Debug log
//        await uploadAndParseEvents()
//        UserDefaults.standard.set(Date(), forKey: "lastFetchTime") // Save current time
//    } else {
//        print("Using cached event data") // Debug log
//    }
//}

func saveEventsToUserDefaults(events: [Event]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(events) {
        UserDefaults.standard.set(encoded, forKey: "savedEvents")
    }
}

func loadEventsFromUserDefaults() -> [Event] {
    if let savedData = UserDefaults.standard.data(forKey: "savedEvents"),
       let decodedEvents = try? JSONDecoder().decode([Event].self, from: savedData) {
        return decodedEvents
    }
    return []
}

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
            saveEventsToUserDefaults(events: events) // Store in UserDefaults
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

// Helper function to convert String to Date
func parseDate(from dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'" // Adjust format to match ICS date format
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter.date(from: dateString)
}

//func uploadAndParseEvents() {
//    let urlString = "https://apps.usos.agh.edu.pl/services/tt/upcoming_ical?lang=en&user_id=138230&key=SjJz4MZnfTsGCjUPjxye"
//        //https://apps.usos.agh.edu.pl/services/tt/upcoming_ical?lang=en&user_id=138230&key=SjJz4MZnfTsGCjUPjxye
//
//    guard let url = URL(string: urlString) else {
//        print("Invalid URL")
//        return
//    }
//
//    let task = URLSession.shared.dataTask(with: url) { data, response, error in
//        if let error = error {
//            print("Error fetching calendar: \(error.localizedDescription)")
//            return
//        }
//
//        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//            print("Server error: Invalid response")
//            return
//        }
//
//        guard let data = data, let icsString = String(data: data, encoding: .utf8) else {
//            print("Error decoding ICS data")
//            return
//        }
//
//        let events = parseICSEvents(icsData: icsString)
//
//        DispatchQueue.main.async {
//            handleParsedEvents(events)
//        }
//    }
//    task.resume()
//}

//func handleParsedEvents(_ events: [UniEvent]) {
//    for event in events {
//        print("Event: \(event.summary), Start: \(event.start), End: \(event.end), Room: \(event.roomNumber), Building: \(event.building), Location: \(event.location ?? "not mentioned")")
//    }
//    // Here you could update the UI with the fetched events
//}

func handleParsedEvents(_ events: [UniEvent]) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.timeZone = TimeZone.current

    for event in events {
        if let eventDate = dateFormatter.date(from: event.start) {
            let newEvent = Event()
            newEvent.id = eventsList.count + 1
            newEvent.name = event.summary
            newEvent.date = eventDate
            
            eventsList.append(newEvent)
        }
    }
    
    DispatchQueue.main.async {
        NotificationCenter.default.post(name: NSNotification.Name("EventsUpdated"), object: nil)
    }
}


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


//
//import Foundation
//import UIKit
//
//
//class DataStorage {
//    enum StorageKeys: String {
//        case lastFetchTime
//        case storedEvents
//    }
//    
//    static let shared = DataStorage()
//    private init() {}
//
//    var storedEvents: [Event] {
//        get {
//            if let savedData = UserDefaults.standard.data(forKey: StorageKeys.storedEvents.rawValue),
//               let decodedObj = try? JSONDecoder().decode([UniEvent].self, from: savedData) {
//                return decodedObj
//            }
//            return []
//        }
//        set {
//            if let data = try? JSONEncoder().encode(newValue) {
//                UserDefaults.standard.set(data, forKey: StorageKeys.storedEvents.rawValue)
//            } else {
//                UserDefaults.standard.removeObject(forKey: StorageKeys.storedEvents.rawValue)
//            }
//        }
//    }
//
//    var lastFetchTime: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: StorageKeys.lastFetchTime.rawValue) as? Date
//        }
//        set {
//            UserDefaults.standard.setValue(newValue, forKey: StorageKeys.lastFetchTime.rawValue)
//        }
//    }
//
//    /// Fetch events if one hour has passed since the last update
//    func fetchEventsIfNeeded(fetchFunction: @escaping () async -> [Event]) async {
//        let oneHourAgo = Date().addingTimeInterval(-3600)
//
//        if let lastFetch = lastFetchTime, lastFetch > oneHourAgo {
//            print("Using cached events (\(storedEvents.count) found)")
//            handleParsedEvents(storedEvents)
//            return
//        }
//
//        print("Fetching new event data...")
//        let newEvents = await fetchFunction()
//        storedEvents = newEvents
//        lastFetchTime = Date()
//        
//        handleParsedEvents(newEvents)
//    }
//}
//
//var eventsList: [Event] = []
//
//func uploadAndParseEvents() async -> [Event] {
//    let urlString = "https://apps.usos.agh.edu.pl/services/tt/upcoming_ical?lang=en&user_id=138230&key=SjJz4MZnfTsGCjUPjxye"
//    
//    guard let url = URL(string: urlString) else {
//        print("Invalid URL")
//        return []
//    }
//
//    do {
//        let (data, response) = try await URLSession.shared.data(from: url)
//        
//        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//            print("Server error: Invalid response")
//            return []
//        }
//
//        guard let icsString = String(data: data, encoding: .utf8) else {
//            print("Error decoding ICS data")
//            return []
//        }
//
//        return parseICSEvents(icsData: icsString)
//    } catch {
//        print("Error fetching calendar: \(error.localizedDescription)")
//        return []
//    }
//}
//
//func parseICSEvents(icsData: String) -> [Event] {
//    let lines = icsData.components(separatedBy: .newlines)
//    var events: [Event] = []
//
//    var summary = "", start = "", end = "", location = "", roomNumber = "", buildingName = ""
//    var isEventOblig = true
//
//    for line in lines {
//        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
//        if trimmed.isEmpty { continue }
//
//        if trimmed.hasPrefix("SUMMARY:") {
//            summary = String(trimmed.dropFirst(8))
//        } else if trimmed.hasPrefix("DTSTART"), let range = trimmed.range(of: ":") {
//            start = decodeICSTime(String(trimmed[range.upperBound...]))
//        } else if trimmed.hasPrefix("DTEND"), let range = trimmed.range(of: ":") {
//            end = decodeICSTime(String(trimmed[range.upperBound...]))
//        } else if trimmed.hasPrefix("LOCATION:") {
//            location = String(trimmed.dropFirst(9))
//        } else if trimmed.hasPrefix("DESCRIPTION:") {
//            if let roomRange = trimmed.range(of: "Room: ") {
//                roomNumber = String(trimmed[roomRange.upperBound...]).components(separatedBy: "\\n").first?.trimmingCharacters(in: .whitespaces) ?? ""
//            }
//            if let buildingRange = trimmed.range(of: "Room: ") {
//                let buildingParts = String(trimmed[buildingRange.lowerBound...]).components(separatedBy: "\\n").filter { !$0.isEmpty }
//                if buildingParts.count > 1 {
//                    buildingName = String(buildingParts[1])
//                }
//            }
//        } else if trimmed == "END:VEVENT" {
//            events.append(UniEvent(summary: summary, start: start, end: end, roomNumber: roomNumber, building: buildingName, location: location, isEventOblig: isEventOblig))
//            summary = ""; start = ""; end = ""; location = ""; roomNumber = ""; buildingName = ""; isEventOblig = true
//        }
//    }
//    
//    print("Total events parsed: \(events.count)")
//    return events
//}
//
//func handleParsedEvents(_ events: [Event]) {
//    eventsList = events
//    
//    DispatchQueue.main.async {
//        NotificationCenter.default.post(name: NSNotification.Name("EventsUpdated"), object: nil)
//    }
//}
//
//func decodeICSTime(_ icsTime: String) -> String {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
//    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//
//    if let date = dateFormatter.date(from: icsTime) {
//        let correctedDate = Calendar.current.date(byAdding: .hour, value: -1, to: date)!
//
//        let outputFormatter = DateFormatter()
//        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//        outputFormatter.timeZone = TimeZone.current
//
//        return outputFormatter.string(from: correctedDate)
//    }
//    return "Invalid Date"
//}
//
//
