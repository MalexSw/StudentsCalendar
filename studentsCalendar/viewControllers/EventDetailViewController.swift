import UIKit

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var event: UniversalEvent?
    var tasks: [HomeTask] = []
    
    @IBOutlet weak var eventSummary: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shortDescLabel: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: EventInformationParseDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllerSetup()
        tableView.register(TaskPrewatchViewCell.nib(), forCellReuseIdentifier: "taskCell")
        //tableView.register(TaskPrewatchViewCell.nib(), forCellReuseIdentifier: })
        if event?.eventType == EventType.userCreated {
            print("Custom event")
        } else if event?.eventType == EventType.scheduleDownloaded {
            print("Schedule event")
        }
        tasksListSetUp(event!)
        print(event?.tasks)
        
    }
    //    override func viewWillAppear(_ animated: Bool) {
    //        tasksListSetUp(event ?? nil)
    //        print(event?.tasks)
    //    }

    
    func viewControllerSetup() {
        if let demonstrEvent = event {
            eventSummary.text = demonstrEvent.name
            if let eventBegin = extractTime(from: demonstrEvent.start ?? ""), let eventEnd = extractTime(from: demonstrEvent.end ?? "") {
                eventTime.text = "\(eventBegin) - \(eventEnd)"
            } else {
                eventTime.text = "\(demonstrEvent.start!) - \(demonstrEvent.end!)"
            }
            let eventDateConverted = getDayNameAndDate(from: demonstrEvent.date)
            dateLabel.text = "\(eventDateConverted.dayName), \(eventDateConverted.formattedDate)"
            if demonstrEvent.eventType == EventType.userCreated {
                shortDescLabel.text = demonstrEvent.shortDescription
                locationLabel.text = demonstrEvent.location
            } else {
                shortDescLabel.text = ""
                locationLabel.text = "Building \(demonstrEvent.building ?? "Unknown"), room \(demonstrEvent.roomNumber ?? "Unknown")"
            }
        }
        
    }
    
    func tasksListSetUp(_ event: UniversalEvent?) {
        if let eventForTask = event {
            tasks = eventForTask.tasks.compactMap { task in
                (task?.isDeleted == false) ? task : nil
            }
        }
    }

    
    func deleteTask(_ taskToDelete: HomeTask) async {
        var tasksList = await loadHomeTasks()
        if let index = tasksList.firstIndex(where: { $0.date == taskToDelete.date && $0.testName == taskToDelete.testName }),
           let eventIndex = event?.tasks.firstIndex(where: { $0?.date == taskToDelete.date && $0?.testName == taskToDelete.testName }) {
            if event?.eventType == .userCreated {
                var customEvents = loadCustomEventsFromUserDefaults()
                customEvents[eventIndex].tasks.removeAll(where: { $0?.date == taskToDelete.date && $0?.testName == taskToDelete.testName })
                await saveCustomEventsToUserDefaults(events: customEvents)
            } else {
                var scheduleEvents = await loadScheduleEventsFromUserDefaults()
                scheduleEvents[eventIndex].tasks.removeAll(where: { $0?.date == taskToDelete.date && $0?.testName == taskToDelete.testName })
                await saveDownloadedEventsToUserDefaults(events: scheduleEvents)
            }
            tasksList[index].isDeleted = true
            event?.tasks.removeAll(where: { $0?.date == taskToDelete.date && $0?.testName == taskToDelete.testName })
            await saveUsersTasksToUserDefaults(tasks: tasksList)
            tasksList = await loadHomeTasks()
            await loadTheWholeList()
            
            DispatchQueue.main.async {
                self.tasksListSetUp(self.event)
                self.tableView.reloadData()
            }
            print("Task marked as deleted")
        } else {
            print("Task not found")
        }
    }

    
    func extractTime(from dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH.mm" // Match input format
        guard let date = inputFormatter.date(from: dateString) else {
            return nil // Return nil if parsing fails
        }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm" // Extract time in HH:mm format
        return outputFormatter.string(from: date)
    }
    
    func getDayNameAndDate(from date: Date) -> (dayName: String, formattedDate: String) {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        formatter.dateFormat = "EEEE"
        let dayName = formatter.string(from: date)
        
        formatter.dateFormat = "d MMMM"
        let formattedDate = formatter.string(from: date)
        
        return (dayName, formattedDate)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tasks.count)
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! TaskPrewatchViewCell
        let taskForCell = tasks[indexPath.row]
        cell.taskName.text = "\(taskForCell.testName)"
        cell.typeOfPass.text = "\(taskForCell.wayOfPassing)"
        cell.shortTaskDescr.text = "\(taskForCell.task)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = tasks[indexPath.row]
            Task {
                await deleteTask(taskToDelete)
            }
            print("Deleted item at row \(indexPath.row)")
        }
        
    }
    
}
