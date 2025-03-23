import UIKit

class EventDetailViewController: UIViewController {
    
    var event: Event?

    @IBOutlet weak var eventSummary: UILabel!
    @IBOutlet weak var eventBegin: UILabel!
    @IBOutlet weak var eventEnd: UILabel!
    weak var delegate: EventInformationParseDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllerSetup()
    }
    
    func viewControllerSetup() {
        if let uniEvent = event as? UniEvent {
            print("Received a UniEvent: \(uniEvent)")
        } else if let customEvent = event as? CustomEvent {
            print("Received a CustomEvent: \(customEvent)")
        } else {
            print("Received an unknown Event type")
        }

//        if let uniEvent = event as? UniEvent {
//            eventSummary.text = uniEvent.summary
//            eventBegin.text = uniEvent.start
//            eventEnd.text = uniEvent.end
//            print("Received UniEvent:", uniEvent)
//        } else if let normalEvent = event as? CustomEvent {
//            eventSummary.text = normalEvent.name
//            eventBegin.text = dateToString(normalEvent.date)
//            eventEnd.text = "Unknown End Time"
//            print("Received Event:", normalEvent)
//        } else {
//            print("Unknown event type")
//        }
        eventSummary.text = event!.name
        eventBegin.text = dateToString(event!.date)
        eventEnd.text = "Not mentioned"
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let eventTime = dateFormatter.string(from: date)
        return eventTime
    }
}
