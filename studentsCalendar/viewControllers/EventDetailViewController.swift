import UIKit

protocol TaskInformationParseDelegate: AnyObject {
    func userDidChooseConcreteTask(task: HomeTask)
}

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var event: UniversalEvent?
    var tasks: [HomeTask] = []
    
    let showTaskDetail = "showTaskDetail"
    
    @IBOutlet weak var eventSummary: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shortDescLabel: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var tableViewTopToLocation: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopBelowNotes: NSLayoutConstraint!
    
    weak var delegate: EventInformationParseDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllerSetup()
        
        tableView.register(TaskPrewatchViewCell.nib(), forCellReuseIdentifier: "taskCell")
        
        if event?.eventType == EventType.userCreated {
            print("Custom event")
        } else if event?.eventType == EventType.scheduleDownloaded {
            print("Schedule event")
        }
        tasksListSetUp(event!)
        print(event?.tasks)
        
        // Ensure initial constraints state reflects current content
        applyTopConstraintForContent(animated: false)
    }

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
                notesLabel.text = demonstrEvent.notates ?? ""
                notesLabel.isHidden = (notesLabel.text?.isEmpty ?? true)
                notesTextLabel.isHidden = (notesLabel.text?.isEmpty ?? true)
            } else {
                shortDescLabel.text = ""
                locationLabel.text = "Building \(demonstrEvent.building ?? "Unknown"), room \(demonstrEvent.roomNumber ?? "Unknown")"
                // For schedule events, show/hide description/notes if present
                notesLabel.text = demonstrEvent.notates ?? ""
                notesLabel.isHidden = (notesLabel.text?.isEmpty ?? true)
                notesTextLabel.isHidden = (notesLabel.text?.isEmpty ?? true)
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
        if let index = tasksList.firstIndex(where: { $0.date == taskToDelete.date && $0.testName == taskToDelete.testName && $0.id == taskToDelete.id }),
           let eventIndex = event?.tasks.firstIndex(where: { $0?.date == taskToDelete.date && $0?.testName == taskToDelete.testName && $0?.id == taskToDelete.id }) {
            
            if event?.eventType == .userCreated {
                let customEvents = await loadCustomEventsFromUserDefaults()
                var tasks = customEvents[eventIndex].tasks
                if let taskIdx = tasks.firstIndex(where: { $0?.date == taskToDelete.date && $0?.testName == taskToDelete.testName && $0?.id == taskToDelete.id }) {
                    tasks[taskIdx]?.isDeleted = true
                    customEvents[eventIndex].tasks = tasks
                }
                await saveCustomEventsToUserDefaults(events: customEvents)
            } else {
                let scheduleEvents = await loadScheduleEventsFromUserDefaults()
                var tasks = scheduleEvents[eventIndex].tasks
                if let taskIdx = tasks.firstIndex(where: { $0?.date == taskToDelete.date && $0?.testName == taskToDelete.testName && $0?.id == taskToDelete.id }) {
                    tasks[taskIdx]?.isDeleted = true
                    scheduleEvents[eventIndex].tasks = tasks
                }
                await saveDownloadedEventsToUserDefaults(events: scheduleEvents)
            }
            
            tasksList[index].isDeleted = true
            event?.tasks[eventIndex]?.isDeleted = true
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
        inputFormatter.dateFormat = "yyyy-MM-dd HH.mm"
        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
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
        
        if taskForCell.priority == 1 {
            cell.layer.borderColor = UIColor.red.cgColor
            cell.layer.borderWidth = 5.0
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask: HomeTask = tasks[indexPath.row]
        performSegue(withIdentifier: showTaskDetail, sender: selectedTask)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showTaskDetail,
           let destinationVC = segue.destination as? TaskDetailWatchController,
           let taskToPass = sender as? HomeTask {
            destinationVC.task = taskToPass
            destinationVC.delegate = self
        }
    }
    
    // MARK: - Option B: toggle constraints
    private func applyTopConstraintForContent(animated: Bool) {
        // Decide if description/notes are effectively present
        let hasNotes = !(notesTextLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) && !notesTextLabel.isHidden
        
        // Activate/deactivate the two alternative constraints
        tableViewTopToLocation.isActive = !hasNotes
        tableViewTopBelowNotes.isActive = hasNotes
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    // Call this if you later change descr/notes dynamically
    func updateLayoutBasedOnField(isFieldFilled: Bool) {
        tableViewTopToLocation.isActive = !isFieldFilled
        tableViewTopBelowNotes.isActive = isFieldFilled
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

extension EventDetailViewController: TaskInformationParseDelegate {
    func userDidChooseConcreteTask(task: HomeTask) {
        print("Sent task is \(task)")
    }
}
