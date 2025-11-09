//
//  TaskDetailWatchController.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 02.11.2025.
//

import UIKit

class TaskDetailWatchController: UIViewController {
    
    var task: HomeTask!
    
    //weak var delegate: EventInformationParseDelegate?
    weak var delegate: TaskInformationParseDelegate?
    @IBOutlet weak var TaskPlusTypeLabel: UILabel!
    @IBOutlet weak var TaskNameLabel: UILabel!
    @IBOutlet weak var TaskSubjectLabel: UILabel!
    @IBOutlet weak var TaskPassTypeLabel: UILabel!
    @IBOutlet weak var TaskInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllerSetup(task: task)
        
    }
    
    func viewControllerSetup(task: HomeTask) {
        let dateString: String = {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            df.timeZone = TimeZone(identifier: "UTC")
            return df.string(from: task.date)
        }()
        
        switch task.priority {
        case 0:
            TaskPlusTypeLabel.text = "Task on \(dateString)"
        case 1:
            TaskPlusTypeLabel.text = "Exam on \(dateString)"
        default:
            break
        }
        
        TaskNameLabel.text = task.testName
        TaskSubjectLabel.text = task.subject
        TaskPassTypeLabel.text = task.wayOfPassing.rawValue
        TaskInfoLabel.text = task.description
        
    }
    
}
