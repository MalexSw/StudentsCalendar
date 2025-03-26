import UIKit

class EventDetailViewController: UIViewController {
    
    var event: UniversalEvent?

    @IBOutlet weak var eventSummary: UILabel!
//    @IBOutlet weak var eventBegin: UILabel!
//    @IBOutlet weak var eventEnd: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shortDescLabel: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notatesTextField: UITextField!
    weak var delegate: EventInformationParseDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllerSetup()
        if event?.eventType == EventType.userCreated {
            print("Custom event")
        } else if event?.eventType == EventType.scheduleDownloaded {
            print("Schedule event")
        }
    }
    
    func viewControllerSetup() {
        if let demonstrEvent = event {
            eventSummary.text = demonstrEvent.name
            if let eventBegin = extractTime(from: demonstrEvent.start ?? ""), let eventEnd = extractTime(from: demonstrEvent.end ?? "") {
                eventTime.text = "\(eventBegin) - \(eventEnd)"
            } else {
                eventTime.text = "\(demonstrEvent.start!) - \(demonstrEvent.end!)"
            }
            //eventTime.text = "\(eventBegin!) - \(eventEnd!)"
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
    
//    func dateToString(_ date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH:mm"
//        let eventTime = dateFormatter.string(from: date)
//        return eventTime
//    }
    
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

        formatter.dateFormat = "EEEE" // Full weekday name (e.g., Monday)
        let dayName = formatter.string(from: date)

        formatter.dateFormat = "d MMMM" // Example: 25 June 2025
        let formattedDate = formatter.string(from: date)

        return (dayName, formattedDate)
    }
}
