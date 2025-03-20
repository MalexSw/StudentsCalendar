import UIKit

protocol CalendarInformationParseDelegate: AnyObject {
    func userDidChooseConcreteDay(events: [Event])
}

class MonthlyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedDate = Date()
    var totalSquares = [String]()
    let showConcreteDay = "showConcreteDay"
    let scheduleURLKey = "scheduleURL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(MonthlyCollectionViewCell.nib(), forCellWithReuseIdentifier: "MonthlyCollectionViewCell")
        checkAndRequestScheduleURL()
        uploadAndParseEvents()
        eventsList = loadEventsFromUserDefaults()
//        UserDefaults.standard.removeObject(forKey: "savedEvents")
//        UserDefaults.standard.synchronize()
//        UserDefaults.standard.removeObject(forKey: "scheduleURL")
//        UserDefaults.standard.synchronize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setCellsView()
        Task {
            await setMonthView()
        }
    }
    
    func checkAndRequestScheduleURL() {
        if UserDefaults.standard.string(forKey: scheduleURLKey) == nil {
            promptForScheduleURL()
        }
    }

    func promptForScheduleURL() {
        let alert = UIAlertController(title: "Enter Schedule URL", message: "Please enter the URL for the schedule.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "https://example.com/schedule"
            textField.keyboardType = .URL
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let urlText = alert.textFields?.first?.text, !urlText.isEmpty {
                UserDefaults.standard.set(urlText, forKey: self.scheduleURLKey)
            } else {
                self.promptForScheduleURL() // Re-prompt if input is empty
            }
        }
        
        alert.addAction(saveAction)
        present(alert, animated: true)
    }

    func getScheduleURL() -> String? {
        return UserDefaults.standard.string(forKey: scheduleURLKey)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDayString = totalSquares[indexPath.item]
        if selectedDayString.isEmpty { return }

        guard let selectedDay = Int(selectedDayString) else { return }
        var components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        components.day = selectedDay

        if let fullDate = Calendar.current.date(from: components) {
            selectedDate = fullDate
            performSegue(withIdentifier: showConcreteDay, sender: fullDate)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showConcreteDay {
            if let destController = segue.destination as? DailyViewController,
               let fullDate = sender as? Date {
                destController.selectedDate = fullDate
                destController.delegate = self
            }
        }
    }
    
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setMonthView() async {
        totalSquares.removeAll()
        let daysInMonth = await CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = await CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = await CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        
        while count <= 42 {
            if count <= startingSpaces || count - startingSpaces > daysInMonth {
                totalSquares.append("")
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        
        await MainActor.run {
            monthLabel.text = "\(CalendarHelper().monthString(date: selectedDate)) \(CalendarHelper().yearString(date: selectedDate))"
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! GlobalCalendarCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthlyCollectionViewCell", for: indexPath) as! MonthlyCollectionViewCell
        //cell.dayOfMonth.text = totalSquares[indexPath.item]
        //cell.ifEventPresent = checkIfEventExists(for: totalSquares[indexPath.item])
        checkIfEventExists(for: totalSquares[indexPath.item])
        cell.configure(day: totalSquares[indexPath.item], hasEvent: checkIfEventExists(for: totalSquares[indexPath.item]))
        
        return cell
    }
    
    func checkIfEventExists(for day: String) -> Bool {
        guard let dayInt = Int(day) else { return false }
        let components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        
        var dateComponents = components
        dateComponents.day = dayInt

        guard let fullDate = Calendar.current.date(from: dateComponents) else { return false }

        // Check if any event exists on this day
        return eventsList.contains { Calendar.current.isDate($0.date, inSameDayAs: fullDate) }
    }

    
    @IBAction func previousMonth(_ sender: Any) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        Task { await setMonthView() }
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        Task { await setMonthView() }
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
}

extension MonthlyViewController: CalendarInformationParseDelegate {
    func userDidChooseConcreteDay(events: [Event]) {
        print("Received events from DailyViewController:", events)
    }
}
