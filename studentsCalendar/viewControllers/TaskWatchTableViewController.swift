//
//  TaskWatchTableViewController.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 18.04.2025.
//

import UIKit

class TaskWatchTableViewController: UITableViewController {

    private var selectedOptions: Set<String> = []
       
    private lazy var multiSelectMenu: UIMenu = createMultiSelectMenu()
    
    var active: Bool = false
    var tasks: Bool = false
    var exams: Bool = false
    
    var tasksToShow: [HomeTask] = tasksList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TaskWatchControllerTableViewCell.nib(), forCellReuseIdentifier: "taskListCell")
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            primaryAction: nil,
            menu: createMultiSelectMenu()
        )
        navigationItem.rightBarButtonItem = menuButton
    }
    
    private func createMultiSelectMenu() -> UIMenu {
        let options = ["Active", "Tasks", "Exams"]
        
        let actions = options.map { optionName in
            UIAction(
                title: optionName,
                state: selectedOptions.contains(optionName) ? .on : .off
            ) { [weak self] action in
                self?.toggleSelection(for: optionName)
            }
        }
        
        return UIMenu(title: "Select Options", options: .displayInline, children: actions)
    }
    
    private func toggleSelection(for option: String) {
        switch option {
        case "Active":
            active.toggle()
        case "Tasks":
            tasks.toggle()
        case "Exams":
            exams.toggle()
        default:
            break
        }
        
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
        
        // Update the menu to reflect checkmarks
        navigationItem.rightBarButtonItem?.menu = createMultiSelectMenu()
        
        // Update tasksToShow
        tasksToShowSetUp(active, tasks, exams)
        
        print("Selected Options: \(selectedOptions)")
    }
    
    func tasksToShowSetUp(_ active: Bool, _ tasks: Bool, _ exams: Bool) {
        tasksToShow = []
        
        if active {
            tasksToShow += tasksList.filter { !$0.isDeleted }
        }
        if tasks {
            tasksToShow += tasksList.filter { $0.priority == 0 }
        }
        if exams {
            tasksToShow += tasksList.filter { $0.priority == 1 }
        }
        
        // Remove duplicates (if some tasks fit multiple conditions)
        tasksToShow = Array(Set(tasksToShow))
        tasksToShow.sort { $0.date < $1.date }
        tableView.reloadData()
    }
    // MARK: - Table view data source


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksToShow.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListCell") as! TaskWatchControllerTableViewCell
        let taskForCell = tasksToShow[indexPath.row]
        cell.configure(name: taskForCell.testName, subject: taskForCell.subject, date: formatDateToDayAndTime(taskForCell.date), status: taskForCell.isDeleted)

        return cell
    }
    
    func formatDateToDayAndTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
