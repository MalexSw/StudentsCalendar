//
//  TaskWatchControllerTableViewCell.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 18.04.2025.
//

import UIKit

class TaskWatchControllerTableViewCell: UITableViewCell {

    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var subjectData: UILabel!
 
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = 0
        clipsToBounds = false
        
        
        
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "TaskWatchControllerTableViewCell", bundle: nil)
    }
    
    func configure(name: String, subject: String, date: String, status: Bool) {
        taskName.text = name
        subjectName.text = subject
        subjectData.text = date
        if status {
            backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 0.4)
        }
    }
}
