import UIKit

var selectedDate = Date()

protocol DateForAddParseDelegate: AnyObject {
    func userWantToAddEvent(date: Date)
}

class WeeklyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let showEventDetail = "showEventDetail"
    let weekController = "weekController"
    var totalSquares = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: NSNotification.Name("EventsUpdated"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await uploadAndParseEvents()
            await loadTheWholeList()
            await setCellsView()
            await setWeekView()
            
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: NSNotification.Name("EventsUpdated"), object: nil)
        }
    
    @objc func updateEvents() {
        Task {
            await MainActor.run {
                tableView.reloadData()
            }
        }
    }
    
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2)
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setWeekView() async {
        totalSquares.removeAll()
        
        let calendarHelper = CalendarHelper()
        var current = await calendarHelper.mondayForDate(date: selectedDate)
        let nextMonday = await calendarHelper.addWeek(date: current, days: 7)
        
        while current < nextMonday {
            totalSquares.append(current)
            current = await calendarHelper.addWeek(date: current, days: 1)
        }
        
        await MainActor.run {
            monthLabel.text = "\(calendarHelper.monthString(date: selectedDate)) \(calendarHelper.yearString(date: selectedDate))"
            collectionView.reloadData()
            tableView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! GlobalCalendarCell
        
        let date = totalSquares[indexPath.item]
        cell.dayOfMonth.text = String(CalendarHelper().dayOfMonth(date: date))
        
        cell.backgroundColor = (date == selectedDate) ? UIColor.systemGreen : UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDate = totalSquares[indexPath.item]
        
        Task {
            await MainActor.run {
                collectionView.reloadData()
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func previousWeek(_ sender: Any) {
        Task {
            selectedDate = await CalendarHelper().addWeek(date: selectedDate, days: -7)
            await setWeekView()
        }
    }
    
    @IBAction func nextWeek(_ sender: Any) {
        Task {
            selectedDate = await CalendarHelper().addWeek(date: selectedDate, days: 7)
            await setWeekView()
        }
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    func deleteEvent(_ event: UniversalEvent) async {
        var customEventsSaved = await loadCustomEventsFromUserDefaults()
        if customEventsSaved.contains(where: { $0.id == event.id }) {
            customEventsSaved.removeAll { $0.id == event.id}
            await saveCustomEventsToUserDefaults(events: customEventsSaved)
            await loadTheWholeList()
            updateEvents()
            print("Event found, proceed with deletion")
            // Perform deletion logic here
        } else {
            print("Event not found")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as! EventCell
        let event = CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate)[indexPath.row]
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
            if event.tasks.contains(where: { $0!.priority == 1 }) {
                cell.backgroundColor = UIColor(red: 210/255.0, green: 148/255.0, blue: 151/255.0, alpha: 0.4)
                cell.layer.borderColor = UIColor.red.cgColor
                cell.layer.borderWidth = 2.0
                cell.layer.cornerRadius = 8
                cell.clipsToBounds = true
            }
        }
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await MainActor.run {
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent = CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate)[indexPath.row]
        performSegue(withIdentifier: showEventDetail, sender: selectedEvent)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showEventDetail,
           let destinationVC = segue.destination as? EventDetailViewController,
           let eventToPass = sender {
            destinationVC.event = eventToPass as! UniversalEvent
            destinationVC.delegate = self
        } else if segue.identifier == weekController,
                  let destinationVC = segue.destination as? EventEditViewController,
            let eventToPass = sender {
            destinationVC.date = selectedDate
            destinationVC.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) async {
        if editingStyle == .delete {
            let event = CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate)[indexPath.row]
            await deleteEvent(event)
            
            print("Deleted item at row \(indexPath.row)")
        }
    }
}

extension WeeklyViewController: EventInformationParseDelegate {
    func userDidChooseConcreteEvent(event: UniversalEvent) {
        print("Event \(event)")
    }
    
//    func userDidChooseConcreteEvent(event: Any) {
//        if let uniEvent = event as? UniEvent {
//            print("Received UniEvent:", uniEvent)
//        } else if let normalEvent = event as? CustomEvent {
//            print("Received Event:", normalEvent)
//        } else {
//            print("Unknown event type")
//        }
//    }
    
}

extension WeeklyViewController: DateForAddParseDelegate
{
    func userWantToAddEvent(date: Date) {
        print("Sent date is \(date)")
    }
}
