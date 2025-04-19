//
//  FilterScreen.swift
//  studentsCalendar
//
//  Created by Олександр Малютин on 19.04.2025.
//

import UIKit

protocol FilterSelectionDelegate: AnyObject {
    func didSelectFilters(_ filters: [String])
}

class FilterViewController: UITableViewController {
    weak var delegate: FilterSelectionDelegate?
    
    let options = ["Today", "This Week", "This Month"]
    var selectedOptions = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Filters"
        tableView.allowsMultipleSelection = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let option = options[indexPath.row]
        cell.textLabel?.text = option
        if selectedOptions.contains(option) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.row]
        selectedOptions.insert(option)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let option = options[indexPath.row]
        selectedOptions.remove(option)
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    @objc func doneTapped() {
        delegate?.didSelectFilters(Array(selectedOptions))
        navigationController?.popViewController(animated: true)
    }
}
