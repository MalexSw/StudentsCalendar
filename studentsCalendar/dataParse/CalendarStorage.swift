import UIKit

// Save Downloaded Events
func saveDownloadedEventsToUserDefaults(events: [Event]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(events) {
        UserDefaults.standard.set(encoded, forKey: "savedLoadedEvents")
    }
}

// Save Custom Events
func saveCustomEventsToUserDefaults(events: [Event]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(events) {
        UserDefaults.standard.set(encoded, forKey: "savedCustomEvents")
    }
}
/*
func saveCustomEventsToUserDefaults(events: [CustomEvent]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(events) {
        UserDefaults.standard.set(encoded, forKey: "savedCustomEvents")
    }
}
 */

// Load Downloaded (Schedule) Events
func loadScheduleEventsFromUserDefaults() -> [Event] {
    if let savedDownloadedData = UserDefaults.standard.data(forKey: "savedLoadedEvents"),
       let downloadedEvents = try? JSONDecoder().decode([Event].self, from: savedDownloadedData) {
        return downloadedEvents
    }
    return []
}

// Load Custom Events
func loadCustomEventsFromUserDefaults() -> [Event] {
    if let savedCustomData = UserDefaults.standard.data(forKey: "savedCustomEvents"),
       let customEvents = try? JSONDecoder().decode([Event].self, from: savedCustomData) {
        return customEvents
    }
    return []
}

// Load the Whole List (Combined Events)
func loadTheWholeList() -> [Event] {
    var allEvents = loadScheduleEventsFromUserDefaults() + loadCustomEventsFromUserDefaults()
    allEvents.sort { $0.date < $1.date }
    return allEvents
}
