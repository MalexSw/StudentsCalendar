import UIKit

// Save Downloaded Events
func saveDownloadedEventsToUserDefaults(events: [UniversalEvent]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(events) {
        UserDefaults.standard.set(encoded, forKey: "savedLoadedEvents")
    }
}

// Save Custom Events
func saveCustomEventsToUserDefaults(events: [UniversalEvent]) async {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(events) {
        UserDefaults.standard.set(encoded, forKey: "savedCustomEvents")
    }
}

func saveUsersTasksToUserDefaults(tasks: [HomeTask]) async {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(tasks) {
        UserDefaults.standard.set(encoded, forKey: "savedTasks")
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
func loadScheduleEventsFromUserDefaults() async -> [UniversalEvent] {
    if let savedDownloadedData = UserDefaults.standard.data(forKey: "savedLoadedEvents"),
       let downloadedEvents = try? JSONDecoder().decode([UniversalEvent].self, from: savedDownloadedData) {
        return downloadedEvents
    }
    return []
}

// Load Custom Events
func loadCustomEventsFromUserDefaults() -> [UniversalEvent] {
    if let savedCustomData = UserDefaults.standard.data(forKey: "savedCustomEvents"),
       let customEvents = try? JSONDecoder().decode([UniversalEvent].self, from: savedCustomData) {
        return customEvents
    }
    return []
}

func loadHomeTasks() async -> [HomeTask] {
    if let savedData = UserDefaults.standard.data(forKey: "savedTasks"),
       let decodedTasks = try? JSONDecoder().decode([HomeTask].self, from: savedData) {
        return decodedTasks
    }
    return []
}


// Load the Whole List (Combined Events)
func loadTheWholeList() async {
    var allEvents = await loadScheduleEventsFromUserDefaults() + loadCustomEventsFromUserDefaults()
    allEvents.sort { $0.date < $1.date }
    eventsList = allEvents
}



