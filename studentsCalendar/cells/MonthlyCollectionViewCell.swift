

import UIKit

class MonthlyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayOfMonth: UILabel!
    @IBOutlet weak var eventView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupEventView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = 0
        clipsToBounds = false
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
