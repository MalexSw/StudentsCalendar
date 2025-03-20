////
////  MonthlyCollectionViewCell.swift
////  studentsCalendar
////
////  Created by Олександр Малютин on 19.03.2025.
////
//
//import UIKit
//
//class MonthlyCollectionViewCell: UICollectionViewCell {
//
//    @IBOutlet weak var dayOfMonth: UILabel!
//    @IBOutlet weak var eventView: UIView!
//    
//    var eventAtDay: Bool = false {
//         didSet {
//             updateEventView()
//         }
//     }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        updateEventView()
//        
//        // Initialization code
//    }
//    
//    func configure(day: String, hasEvent: Bool) {
//        dayOfMonth.text = day
//        eventAtDay = true  // Show if there is an event
//    }
//    
//    private func updateEventView() {
//            eventView.backgroundColor = eventAtDay ? .red : .clear
//        }
//    
//    static func nib() -> UINib {
//        return UINib(nibName: "MonthlyCollectionViewCell", bundle: nil)
//    }
//
//}

import UIKit

class MonthlyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayOfMonth: UILabel!
    @IBOutlet weak var eventView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupEventView()
    }
    
    func configure(day: String, hasEvent: Bool) {
        dayOfMonth.text = day
        eventView.isHidden = !hasEvent
    }
    
    private func setupEventView() {
        eventView.clipsToBounds = true
//        eventView.layer.cornerRadius = eventView.frame.size.height / 2
        eventView.backgroundColor = .black
        eventView.isHidden = true  // Hidden by default, only shown if an event exists
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        eventView.layer.cornerRadius = 110 // Ensure it's a perfect circle
    }

    static func nib() -> UINib {
        return UINib(nibName: "MonthlyCollectionViewCell", bundle: nil)
    }
}
