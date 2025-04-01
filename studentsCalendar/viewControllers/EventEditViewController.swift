//
//  EventEditViewController.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 25.02.2025.
//

import UIKit

class EventEditViewController: UIViewController
{
    
    var date: Date?
    weak var delegate: DateForAddParseDelegate!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var eventStartdatePicker: UIDatePicker!
    @IBOutlet weak var eventEnddatePicker: UIDatePicker!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var shortDescTF: UITextField!
    @IBOutlet weak var notatesTF: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        eventStartdatePicker.date = date ?? selectedDate
    }
    
    @IBAction func saveAction(_ sender: Any) {
        Task { @MainActor in
            var summary: String = ""
            var start: String = ""
            var end: String = ""
            var location: String = ""
            var notates: String = ""
            var shortDescr: String = ""
            var eventType = EventType.userCreated
            var isEventOblig: Bool = true
            
            if let name = nameTF.text, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                summary = name
            }
            if let loc = locationTF.text {
                location = loc
            }
            if let shortDesc = shortDescTF.text, !shortDesc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                shortDescr = shortDesc
            }
            if let notes = notatesTF.text {
                notates = notes
            }
            
            // Check if both name and short description are empty
            if summary.isEmpty && shortDescr.isEmpty {
                showAlert(message: "You need to add at least one of those fields: Name or Short Description.")
                return
            }
            
            let id = eventsList.count
            date = eventStartdatePicker.date
            start = dateToString(eventStartdatePicker.date)
            end = dateToString(eventEnddatePicker.date)
            
            let newEvent = UniversalEvent(id: id, name: summary, date: date!, eventType: eventType, summary: summary, start: start, end: end, location: location, shortDescription: shortDescr, notates: notates, isEventOblig: isEventOblig)
            
            var savedEvents = loadCustomEventsFromUserDefaults()
            savedEvents.append(newEvent)
            savedEvents.sort { $0.date < $1.date }
            
            await saveCustomEventsToUserDefaults(events: savedEvents)
            await loadTheWholeList()
            
            navigationController?.popViewController(animated: true)
        }
    }

    // Function to show an alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let eventTime = dateFormatter.string(from: date)
        return eventTime
    }

}
