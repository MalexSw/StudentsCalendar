import UIKit

class GlobalCalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var dayOfMonth: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = 0
        clipsToBounds = false
    }
}
