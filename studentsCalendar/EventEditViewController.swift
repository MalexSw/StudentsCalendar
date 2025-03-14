//
//  EventEditViewController.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 25.02.2025.
//

import UIKit

class EventEditViewController: UIViewController
{
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        datePicker.date = selectedDate
    }
    
    @IBAction func saveAction(_ sender: Any)
    {
        let newEvent = Event()
        newEvent.id = eventsList.count
        newEvent.name = nameTF.text
        newEvent.date = datePicker.date
        eventsList.append(newEvent)
        eventsList = eventsList.sorted { $0.date < $1.date }
        navigationController?.popViewController(animated: true)
    }
}
