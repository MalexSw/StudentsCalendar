//
//  EventCell.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 25.02.2025.
//

import UIKit

class EventCell: UITableViewCell
{
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
