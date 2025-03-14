import UIKit

class DailyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedDate: Date?
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var totalEventsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: CalendarInformationParseDelegate?
    
    let showConcreteDay = "showConcreteDay"
    var totalEventsAmount: Int = 0
    var dailyEvents:[Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: NSNotification.Name("EventsUpdated"), object: nil)
        Task {
            await updateEventsList()
            updateEvents()
        }
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
            self.totalEventsLabel.text = "Total events for today: \(Event().eventsForDate(date: selectedDate!).count)"
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
        tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Event().eventsForDate(date: selectedDate!).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell") as! DailyTableViewCell
        let event = Event().eventsForDate(date: selectedDate!)[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let eventTime = dateFormatter.string(from: event.date)
        cell.eventLabel.text = "\(eventTime) - \(event.name!)"
        return cell
    }
}
