import UIKit

protocol EventInformationParseDelegate: AnyObject {
    func userDidChooseConcreteEvent(event: UniversalEvent)
}

class DailyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedDate: Date?
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var totalEventsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: CalendarInformationParseDelegate?
    
    let showConcreteDay = "showConcreteDay"
    let showEventDetail = "showEventDetail"
    let dailyController = "dailyController"
    var totalEventsAmount: Int = 0
    var dailyEvents:[UniversalEvent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await loadTheWholeList()
            await updateEventsList()
            updateEvents()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: NSNotification.Name("EventsUpdated"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await MainActor.run {
                updateEvents()
            }
        }
    }
    
    func updateEventsList() async {
        guard let date = selectedDate else { return }
        DispatchQueue.main.async { [self] in
            let day = CalendarHelper().dayOfMonth(date: date)
            let month = CalendarHelper().monthString(date: date)
            let year = CalendarHelper().yearString(date: date)
            
            self.monthLabel.text = month
            self.totalEventsLabel.text = "Total events for today: \(CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate!).count)"
            self.dayLabel.text = "\(dayOfWeek(from: date)), \(day)"
            print("Selected Date: \(day) \(month) \(year)")

            updateEvents()
        }
    }

    func dayOfWeek(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Full weekday name (e.g., Monday)
        dateFormatter.locale = Locale.current // Ensures localization if needed
        return dateFormatter.string(from: date)
    }
    
    @objc func updateEvents() {
        guard let selectedDate = selectedDate else { return }
        dailyEvents = CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate) // Refresh data
        DispatchQueue.main.async {
            self.totalEventsLabel.text = "Total events for today: \(self.dailyEvents.count)"
            self.tableView.reloadData()
        }
    }
    
    @IBAction func nextDay(_ sender: Any) {
        selectedDate = CalendarHelper().addDay(date: selectedDate!, days: 1)
        Task {
            await updateEventsList()
        }
    }
    
    @IBAction func previousDay(_ sender: Any) {
        selectedDate = CalendarHelper().addDay(date: selectedDate!, days: -1)
        Task {
            await updateEventsList()
        }
    }
    
    func deleteEvent(_ event: UniversalEvent) async {
        var customEventsSaved = loadCustomEventsFromUserDefaults()
        
        if let index = customEventsSaved.firstIndex(where: { $0.id == event.id }) {
            customEventsSaved.remove(at: index)
            await saveCustomEventsToUserDefaults(events: customEventsSaved)
            await loadTheWholeList()
            
            DispatchQueue.main.async {
                self.updateEvents() // Ensure UI reflects changes
            }
            
            print("Event found, proceed with deletion")
        } else {
            print("Event not found")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate!).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell") as! DailyTableViewCell
        let event = CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate!)[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let eventTime = dateFormatter.string(from: event.date)
        cell.eventLabel.text = "\(eventTime) - \(event.name)"
        if event.eventType == EventType.scheduleDownloaded {
            cell.descriptionLabel.text = "Building \(event.building ?? "Unknown"), room \(event.roomNumber ?? "Unknown")"
        } else if event.eventType == EventType.userCreated {
            cell.descriptionLabel.text = event.shortDescription
        }
        if event.tasks.isEmpty {
            cell.taskMark.text = ""
        } else {
            cell.taskMark.text = "!"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent = CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate!)[indexPath.row]
        performSegue(withIdentifier: showEventDetail, sender: selectedEvent)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate!)[indexPath.row]
            
            Task {
                await deleteEvent(event) // Ensure event is deleted
                await loadTheWholeList() // Reload entire list
                DispatchQueue.main.async {
                    self.updateEvents() // Ensure UI updates properly
                }
            }
            
            print("Deleted item at row \(indexPath.row)")
        }
    }




    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showEventDetail,
           let destinationVC = segue.destination as? EventDetailViewController,
           let eventToPass = sender {
            destinationVC.event = eventToPass as? UniversalEvent
            destinationVC.delegate = self
        } else if segue.identifier == dailyController,
            let destinationVC = segue.destination as? EventEditViewController,
                  let _ = sender {
            destinationVC.date = selectedDate
            destinationVC.delegate = self
        }
    }
}

extension DailyViewController: EventInformationParseDelegate {
    func userDidChooseConcreteEvent(event: UniversalEvent) {
        print("Event \(event)")
    }
}

extension DailyViewController: DateForAddParseDelegate
{
    func userWantToAddEvent(date: Date) {
        print("Sent date is \(date)")
    }
}
