import UIKit

class EventDetailViewController: UIViewController {
    
    var event: UniversalEvent?

    @IBOutlet weak var eventSummary: UILabel!
    @IBOutlet weak var eventBegin: UILabel!
    @IBOutlet weak var eventEnd: UILabel!
    weak var delegate: EventInformationParseDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllerSetup()
    }
    
    func viewControllerSetup() {
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
