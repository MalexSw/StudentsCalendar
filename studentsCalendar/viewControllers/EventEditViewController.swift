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
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        datePicker.date = date ?? selectedDate
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let newEvent = Event()
        newEvent.id = eventsList.count
        newEvent.name = nameTF.text
        newEvent.date = datePicker.date

        var savedEvents = loadEventsFromUserDefaults()
        savedEvents.append(newEvent)
        savedEvents.sort { $0.date < $1.date }

        saveEventsToUserDefaults(events: savedEvents)

        // Update global list after saving
        eventsList = savedEvents

        navigationController?.popViewController(animated: true)
    }


}
