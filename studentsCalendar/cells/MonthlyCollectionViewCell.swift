

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
        eventView.backgroundColor = .black
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        eventView.layer.cornerRadius = 1 // Ensure it's a perfect circle
    }

    static func nib() -> UINib {
        return UINib(nibName: "MonthlyCollectionViewCell", bundle: nil)
    }
}
