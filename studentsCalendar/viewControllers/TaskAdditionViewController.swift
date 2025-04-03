//
//  TaskAdditionViewController.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 26.03.2025.
//

import UIKit

class TaskAdditionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var taskTF: UITextField!
    @IBOutlet weak var taskshortDescrTF: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var subjectPicker: UIPickerView!
    @IBOutlet weak var taskPassWay: UIPickerView!
    
    
    var subjects: [UniversalEvent] = [] // Example data
    //let taskPassWays: [String] = ["Online", "No pass", "Offline"]
    //let taskPassWays: [WayOfTaskPass] = [.offline, .online, .selfStudy]
    let taskPassWays: [String] = WayOfTaskPass.allCases.map { $0.rawValue }
    // Example data
    var selectedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subjectPicker.delegate = self
        subjectPicker.dataSource = self
        taskPassWay.delegate = self
        taskPassWay.dataSource = self
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        subjects = CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
            let selectedDate = sender.date
            print("Date Selected: \(selectedDate)")
            subjects = CalendarHelper().eventsForDate(eventsList: eventsList, date: selectedDate)
            subjectPicker.reloadAllComponents()
            taskPassWay.reloadAllComponents()
        }
    
    // MARK: - Handle Date Picker Change
    @IBAction func saveAction(_ sender: Any) {
        Task { @MainActor in
            var id: Int
            var testName: String
            var subject: String
            var date: Date
            var task: String
            var description: String
            var wayOfPassing: WayOfTaskPass
            var isDeleted = false
            var additionalNotes: String?
            
            // Assign values from text fields if they are not empty
            if let taskName = taskNameTF.text, !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                testName = taskName
            } else {
                showAlert(message: "Task name is required.")
                return
            }
            
            if let taskTest = taskTF.text, !taskTest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                task = taskTest
            } else {
                showAlert(message: "Task description is required.")
                return
            }
            
            if let shortDesc = taskshortDescrTF.text, !shortDesc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                description = shortDesc
            } else {
                description = ""
            }
            
            // Get selected subject from subjectPicker
            let selectedSubjectIndex = subjectPicker.selectedRow(inComponent: 0)
            guard subjects.indices.contains(selectedSubjectIndex) else {
                showAlert(message: "Please select a subject.")
                return
            }
            subject = subjects[selectedSubjectIndex].name
            
            // Get selected way of passing from taskPassPicker
            let selectedWayIndex = taskPassWay.selectedRow(inComponent: 0)
            guard taskPassWays.indices.contains(selectedWayIndex) else {
                showAlert(message: "Please select a way of passing.")
                return
            }
            
            if let way = WayOfTaskPass(rawValue: taskPassWays[selectedWayIndex]) {
                wayOfPassing = way
            } else {
                showAlert(message: "Invalid way of passing selected.")
                return
            }
            
            //wayOfPassing = taskPassWay.selectedRow(inComponent: 1)
            
            date = subjects[selectedSubjectIndex].date
            id = await loadHomeTasks().count
            
            let newTask = HomeTask(
                id: id,
                testName: testName,
                subject: subject,
                date: date,
                task: task,
                description: description,
                wayOfPassing: wayOfPassing,
                isDeleted: isDeleted,
                additionalNotes: additionalNotes
            )
            
            // Save task to UserDefaults
            var savedTasks = await loadHomeTasks()
            savedTasks.append(newTask)
            savedTasks.sort { $0.date < $1.date }
            
            await saveUsersTasksToUserDefaults(tasks: savedTasks)
            
            let localEventsList = eventsList
            
            // Find an event with the same date and name
            if let eventIndex = localEventsList.firstIndex(where: { $0.date == date && $0.name == subject }) {
                localEventsList[eventIndex].tasks.append(newTask)
                print(localEventsList[eventIndex])
                if localEventsList[eventIndex].eventType == .scheduleDownloaded {
                    var scheduleEventslist: [UniversalEvent] = []
                    for events in localEventsList {
                        if events.eventType == .scheduleDownloaded {
                            scheduleEventslist.append(events)
                        }
                        
                    }
                    await saveDownloadedEventsToUserDefaults(events: scheduleEventslist)
                } else {
                    var userEventslist: [UniversalEvent] = []
                    for events in localEventsList {
                        if events.eventType == .userCreated {
                            userEventslist.append(events)
                        }
                        
                    }
                    await saveCustomEventsToUserDefaults(events: userEventslist)
                }
            }
            
            await loadTheWholeList()
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UIPickerView Data Source & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == subjectPicker ? max(subjects.count, 1) : taskPassWays.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Show a placeholder if no subjects are available
        return pickerView == subjectPicker ? (subjects.isEmpty ? "No available subjects" : subjects[row].name) : taskPassWays[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == subjectPicker {
            if subjects.isEmpty {
                showAlert(message: "No subjects available. Please select another date.")
            } else {
                let selectedValue = subjects[row].name
                print("Selected: \(selectedValue)")
            }
        } else {
            let selectedValue = taskPassWays[row]
            print("Selected: \(selectedValue)")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        
        if pickerView == subjectPicker {
            if subjects.isEmpty {
                label.text = "No available subjects"
            } else if row < subjects.count {
                label.text = subjects[row].name
            }
        } else {
            if row < taskPassWays.count {
                label.text = taskPassWays[row]
            }
        }

        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }

    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    func eventsForDate(_ date: Date) {
        subjects = CalendarHelper().eventsForDate(eventsList: eventsList, date: date)
        subjectPicker.reloadAllComponents()
        if subjects.isEmpty {
            showAlert(message: "No events available for this date.")
        }
    }
    
    func parseDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'" // Adjust format to match ICS date format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString)
    }
}
