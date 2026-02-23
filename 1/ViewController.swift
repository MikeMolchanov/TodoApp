//
//  ViewController.swift
//  1
//
//  Created by Михаил on 06.12.2025.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    let storage = TaskStorage()
    let tableView = UITableView()
    
    private var filteredTasks: [Task] = []
    private var isSearching = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // настраиваем tableView
        
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
        setupSearch()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(showField)
        )
        
//        tableView.frame = CGRect(x: 0, y: 300, width: view.frame.width, height: view.frame.height - 300)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.dataSource = self
        tableView.delegate = self
        
        // регистрируем кастомную ячейку
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        
        view.addSubview(tableView)
    
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    // сколько строк в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching
        ? filteredTasks.count
        : storage.tasks.count
    }
    
    // что показывать в каждой ячейке
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //достаем ячейку
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        let task = isSearching
        ? filteredTasks[indexPath.row]
        : storage.tasks[indexPath.row]
        
        cell.configure(with: task)
        cell.animateStatusChange(isDone: task.isDone)
        
        cell.onToggleDone = { [weak self, weak cell] in
            guard let self = self,
            let cell = cell,
                  let indexPath = self.tableView.indexPath(for: cell)
            else { return }
            
            let currentTask = self.storage.tasks[indexPath.row]
            
            self.storage.toggleDone(currentTask)
            
            guard let newIndex = self.storage.tasks.firstIndex(where: { $0.id == currentTask.id }) else { return }
            let newIndexPath = IndexPath(row: newIndex, section: 0)
            
            let updatedTask = self.storage.tasks[newIndex]
            
            
            cell.configure(with: updatedTask)
            
            self.tableView.moveRow(at: indexPath, to: newIndexPath)
            
            self.tableView.reloadRows(at: [newIndexPath], with: .none)
        }
        
        cell.onEdit = { [weak self] in
            self?.showEditAlert(for: task)
        }
        
        return cell
    }
    
    // удаление строки из таблицы
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // если editingStyle == delete
        // удалить элемент из массива
        // удалить строку из таблицы
        if editingStyle == .delete {
            storage.delete(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let task = storage.tasks[indexPath.row]
        let alert = UIAlertController(title: "Редактировать задачу", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = task.title}
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                //создаем новую задачу с обновленным title
                self.storage.updateTitle(task, title: text)

                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text,
              !text.isEmpty else {
            isSearching = false
            filteredTasks.removeAll()
            tableView.reloadData()
            return
        }
        
        isSearching = true
        filteredTasks = storage.tasks.filter {
            $0.title.lowercased().contains(text.lowercased())
        }
        
        tableView.reloadData()
    }
    
    @objc func showField() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addTextField()
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                let newTask = Task(id: UUID(), title: text, isDone: false)
                self.storage.add(newTask)
                self.tableView.reloadData()
            }
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func setupSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск задач"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func showEditAlert(for task: Task) {
        
        let alert = UIAlertController(title: "Редактировать задачу",
                                      message: nil,
                                      preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
            !text.isEmpty else { return }
        
            self?.storage.updateTitle(task, title: text)
            self?.tableView.reloadData()
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}


