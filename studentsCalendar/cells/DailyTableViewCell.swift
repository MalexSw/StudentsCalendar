//
//  DailyTableViewCell.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 02.03.2025.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var taskMark: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = 0
        clipsToBounds = false
    }
}
