//
//  TaskAdditionViewController.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 26.03.2025.
//

import UIKit

class TaskAdditionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var shortDescr: UILabel!
    @IBOutlet weak var howToPass: UILabel!
    
    
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var taskTF: UITextField!
    @IBOutlet weak var taskshortDescrTF: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var subjectPicker: UIPickerView!
    @IBOutlet weak var taskPassWay: UIPickerView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    
    var subjects: [UniversalEvent] = []
    let taskPassWays: [String] = WayOfTaskPass.allCases.map { $0.rawValue }
    var selectedDate: Date = Date()
    var isImportantTextFieldActive = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupKeyboardObservers()
        viewSetUp(0)
        
        subjectPicker.delegate = self
        subjectPicker.dataSource = self
        taskPassWay.delegate = self
        taskPassWay.dataSource = self
        taskshortDescrTF.delegate = self
        
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
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewSetUp(0)
        case 1:
            viewSetUp(1)
        default:
            break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == taskshortDescrTF {
            isImportantTextFieldActive = true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == taskshortDescrTF {
            isImportantTextFieldActive = false
        }
    }
    
    func viewSetUp(_ state: Int) {
        switch state {
        case 0:
            taskLabel.text = "Task:"
            shortDescr.text = "Short descr.:"
            howToPass.text = "How to pass"
            // Change something here
        case 1:
            taskLabel.text = "Theme:"
            shortDescr.text = "Mater. to prepare:"
            howToPass.text = "Exam type:"
            // Change something else
        default:
            break
        }
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
//        if !isImportantTextFieldActive { return }  // Only reset if fifth field was active
        
        self.view.frame.origin.y = 0
    }


    
    // MARK: - Handle Date Picker Change
    @IBAction func saveAction(_ sender: Any) {
        Task { @MainActor in
            var id: Int
            var priority: Int
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
            
            priority = segmentController.selectedSegmentIndex
            
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
                id: Int(idCreation(parentID: UInt64(subjects[selectedSubjectIndex].id), taskName: testName)),
                priority: priority,
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
            
//            if let eventIndex = localEventsList.firstIndex(where: { $0.date == date && $0.name == subject }) {
//                localEventsList[eventIndex].tasks.append(newTask)
////                localEventsList[eventIndex].tasks = HomeTask.sortByPriority(localEventsList[eventIndex].tasks)
//                print(localEventsList[eventIndex])
//                if localEventsList[eventIndex].eventType == .scheduleDownloaded {
//                    var scheduleEventslist: [UniversalEvent] = []
//                    for events in localEventsList {
//                        if events.eventType == .scheduleDownloaded {
//                            scheduleEventslist.append(events)
//                        }
//                        
//                    }
//                    
//                    await saveDownloadedEventsToUserDefaults(events: scheduleEventslist)
//                } else {
//                    var userEventslist: [UniversalEvent] = []
//                    for events in localEventsList {
//                        if events.eventType == .userCreated {
//                            userEventslist.append(events)
//                        }
//                        
//                    }
//                    await saveCustomEventsToUserDefaults(events: userEventslist)
//                }
//            }
            
            if let eventIndex = localEventsList.firstIndex(where: { $0.id == parentID(from: UInt64(id))}) {
                localEventsList[eventIndex].tasks.append(newTask)
//                localEventsList[eventIndex].tasks = HomeTask.sortByPriority(localEventsList[eventIndex].tasks)
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
    
    func idCreation(parentID: UInt64, taskName: String) -> UInt64 {
        let taskId = UInt64(subjectHash(taskName))               // 16 bits
        return (parentID << 16) | taskId
        
    }

    func subjectHash(_ subject: String) -> UInt16 {
        var hash: UInt32 = 0x811C9DC5 // 32-bit FNV offset basis
        for byte in subject.utf8 {
            hash ^= UInt32(byte)
            hash = hash &* 16777619 // 32-bit FNV prime
        }
        return UInt16(truncatingIfNeeded: hash) // fold to 16-bit
    }
    
    func parentID(from childID: UInt64) -> UInt64 {
        return childID >> 16
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // so your table rows are still clickable
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

