//
//  EventEditViewController.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 25.02.2025.
//

import UIKit

class EventEditViewController: UIViewController, UITextFieldDelegate
{
    
    var date: Date?
    weak var delegate: DateForAddParseDelegate!
    var isImportantTextFieldActive = false

    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var eventStartdatePicker: UIDatePicker!
    @IBOutlet weak var eventEnddatePicker: UIDatePicker!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var shortDescTF: UITextField!
    @IBOutlet weak var notatesTF: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupKeyboardObservers()
        eventStartdatePicker.date = date ?? selectedDate
        eventEnddatePicker.date = date ?? selectedDate
        notatesTF.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        if !isImportantTextFieldActive { return }  // Only move if fifth field is active
        
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        self.view.frame.origin.y = -keyboardHeight / 4   // Move up a bit (adjust if needed)
    }

    @objc private func keyboardWillHide(notification: Notification) {
        /*if !isImportantTextFieldActive { return }*/  // Only reset if fifth field was active
        
        self.view.frame.origin.y = 0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == notatesTF {
            isImportantTextFieldActive = true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == notatesTF {
            isImportantTextFieldActive = false
        }
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
            
//            let id = eventsList.count
//            date = eventStartdatePicker.date
//            start = dateToString(eventStartdatePicker.date)
//            end = dateToString(eventEnddatePicker.date)
//            
//            let newEvent = UniversalEvent(id: id, name: summary, date: date!, eventType: eventType, summary: summary, start: start, end: end, location: location, shortDescription: shortDescr, notates: notates, isEventOblig: isEventOblig)
//            
//            var savedEvents = await loadCustomEventsFromUserDefaults()
//            savedEvents.append(newEvent)
//            savedEvents.sort { $0.date < $1.date }
//            
//            await saveCustomEventsToUserDefaults(events: savedEvents)
//            await loadTheWholeList()
//            
//            navigationController?.popViewController(animated: true)
            let calendar = Calendar.current
            let startDate = eventStartdatePicker.date
            let endDate = eventEnddatePicker.date

            guard startDate <= endDate else {
                showAlert(message: "End date must be after start date.")
                return
            }

//            var currentDate = calendar.startOfDay(for: startDate)
//            let endDateDay = calendar.startOfDay(for: endDate)
            var currentDate = startDate
            let endDateDay = endDate


            var savedEvents = await loadCustomEventsFromUserDefaults()
            let origin = currentDate;
            while currentDate <= endDateDay {
                let newEvent = UniversalEvent(
                    id: savedEvents.count,
                    name: summary,
                    date: dateCheck(origin: origin, current: currentDate),
                    eventType: eventType,
                    summary: summary,
                    start: startTimeCheck(origin: origin, current: currentDate),
                    end: endTimeCheck(start: currentDate, end: endDateDay),
                    location: location,
                    shortDescription: shortDescr,
                    notates: notates,
                    isEventOblig: isEventOblig
                )
                
                savedEvents.append(newEvent)
                
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDate
            }

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
    
    func startTimeCheck(origin: Date, current: Date) -> String {
        let calendar = Calendar.current
        let originDate = calendar.component(.day, from: origin)
        let currentDate = calendar.component(.day, from: current)
        if originDate != currentDate {
            return "00:00"
        } else {
            return dateToString(origin);
        }
    }
    
    func endTimeCheck(start: Date, end: Date) -> String {
        let calendar = Calendar.current
        let beginDate = calendar.component(.day, from: start)
        let endDate = calendar.component(.day, from: end)
        if beginDate != endDate {
            return "23:59"
        } else {
            return dateToString(end);
        }
    }
    
    func dateCheck(origin: Date, current: Date) -> Date {
        let calendar = Calendar.current
        let originalDate = current

        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: originalDate)
        if current == origin {
            components.hour = components.hour! + 2
            let newDate = calendar.date(from: components)
            return newDate!
        } else {
            components.hour = 02
            components.minute = 0
            let newDate = calendar.date(from: components)
            return newDate!
        }
    }

}

