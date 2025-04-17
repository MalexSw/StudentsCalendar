import UIKit

protocol CalendarInformationParseDelegate: AnyObject {
    func userDidChooseConcreteDay(events: [UniversalEvent])
}

class MonthlyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedDate = Date()
    var totalSquares = [String]()
    let showConcreteDay = "showConcreteDay"
    let scheduleURLKey = "scheduleURL"
    
    var cellSize: CGSize {
        let width = (collectionView.frame.size.width - 2.0) / 7.0
        let height = (collectionView.frame.size.height - 2.0) / 8.0
        
        let itemSize = CGSize(width: width, height: height)
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        return itemSize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(MonthlyCollectionViewCell.nib(), forCellWithReuseIdentifier: "MonthlyCollectionViewCell")
        checkAndRequestScheduleURL()
//        Task {
//            await uploadAndParseEvents()
//            await loadTheWholeList()
//            await setMonthView()
//        }
        
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//            collectionView.addGestureRecognizer(longPressGesture)
        
//        UserDefaults.standard.removeObject(forKey: "savedTasks")
//        UserDefaults.standard.synchronize()
//        UserDefaults.standard.removeObject(forKey: "savedCustomEvents")
//        UserDefaults.standard.synchronize()
//        UserDefaults.standard.removeObject(forKey: "savedLoadedEvents")
//        UserDefaults.standard.synchronize()
        
        
        
    }
    //TODO: Test addition
//    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
//        if gesture.state == .began {
//            let touchPoint = gesture.location(in: collectionView)
//            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
//                print("Long pressed cell at section \(indexPath.section), row \(indexPath.item)")
//                
//                // Perform action, e.g., delete or edit
//            }
//        }
//    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        Task {
            await uploadAndParseEvents()
            await loadTheWholeList()
            await tasksList = loadHomeTasks()
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
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthlyCollectionViewCell", for: indexPath) as! MonthlyCollectionViewCell
//        cell.configure(day: totalSquares[indexPath.item], hasEvent: checkIfEventExists(for: totalSquares[indexPath.item]))
////        cell.layer.borderColor = UIColor.blue.cgColor
////        cell.layer.cornerRadius = 8.0
////        cell.layer.borderWidth = 1.5
//        return cell
//    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthlyCollectionViewCell", for: indexPath) as! MonthlyCollectionViewCell
        let day = totalSquares[indexPath.item]  // Get the specific day
        
        // Check if an event exists for this day and if it has an exam
        let hasEvent = checkIfEventExists(for: totalSquares[indexPath.item])
        let hasExam = checkIfExamExists(for: totalSquares[indexPath.item])
        
        // Configure the cell based on whether there is an event and/or an exam
        cell.configure(day: day, hasEvent: hasEvent)
        if hasExam {
            // Add a border or any visual cue to indicate there's an exam
            cell.backgroundColor = UIColor(red: 210/255.0, green: 148/255.0, blue: 151/255.0, alpha: 0.4)
            cell.layer.borderColor = UIColor.red.cgColor
            cell.layer.borderWidth = 2.0
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
        }
        
        return cell
    }
    
    func checkIfExamExists(for day: String) -> Bool {
        // Ensure the day string is a valid number
        guard let dayInt = Int(day) else { return false }

        // Extract the current selected month and year
        var dateComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        dateComponents.day = dayInt

        // Create a proper Date object
        guard let fullDate = Calendar.current.date(from: dateComponents) else { return false }

        // Get all events for the specific date
        let eventsForDay = CalendarHelper().eventsForDate(eventsList: eventsList, date: fullDate)

        // Check each event's task array to see if any task qualifies as an "exam"
        for event in eventsForDay {
            for task in event.tasks {
                if let task = task {
//                    let testName = task.testName.lowercased()
//                    let taskDescription = task.task.lowercased()
//                    // You can adjust the logic below to suit your app's exam identification rules
//                    if testName.contains("exam") || taskDescription.contains("exam") || task.wayOfPassing == .exam {
                    if task.priority == 1 {
                        return true
                    }
                }
            }
        }

        return false
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

extension MonthlyViewController: CalendarInformationParseDelegate {
    func userDidChooseConcreteDay(events: [UniversalEvent]) {
        print("Received events from DailyViewController:", events)
    }
}
