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
        }
    }
    
    func updateEventsList() async {
        guard let date = selectedDate else { return }
        DispatchQueue.main.async {
            let day = CalendarHelper().dayOfMonth(date: date)
            let month = CalendarHelper().monthString(date: date)
            let year = CalendarHelper().yearString(date: date)
            
            self.monthLabel.text = month
            print("Selected Date: \(day) \(month) \(year)")

            self.tableView.reloadData()
        }
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
        if Event().eventsForDate(date: selectedDate!).count != 0 {
            totalEventsLabel.text = "Total events for today: \(Event().eventsForDate(date: selectedDate!).count)"
        } else {
            totalEventsLabel.text = "Waiting......"
        }
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
