//
//  TaskPrewatchViewCell.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 28.03.2025.
//

import UIKit

class TaskPrewatchViewCell: UITableViewCell {

    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var shortTaskDescr: UILabel!
    @IBOutlet weak var typeOfPass: UILabel!
 
    static func nib() -> UINib {
        return UINib(nibName: "TaskPrewatchViewCell", bundle: nil)
    }
    
}
