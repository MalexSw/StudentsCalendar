import UIKit

class GlobalCalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var dayOfMonth: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    private var eventView: UIView!

    override func awakeFromNib() {
        //super.awakeFromNib()
                eventView = UIView(frame: CGRect(x: self.bounds.width / 2 - 3, y: self.bounds.height - 12, width: 6, height: 6))
        eventView.backgroundColor = .red
        eventView.layer.cornerRadius = 3  // Make it a small circle
        eventView.isHidden = true  // Start as hidden
        eventView.clipsToBounds = true  // Ensure rounded corners apply properly
        self.addSubview(eventView)
    }

    
    func configure(day: String, hasEvent: Bool) {
        dayOfMonth.text = day
        eventView.isHidden = false  // Show if there is an event
    }
}
