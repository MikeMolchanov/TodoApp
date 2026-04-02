//
//  ViewController.swift
//  1
//
//  Created by Михаил on 06.12.2025.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    let service = TodoService()
    let storage = TaskStorage()
    let tableView = UITableView()
    
    private let loader = UIActivityIndicatorView(style: .large)
    private var filteredTasks: [Task] = []
    private var isSearching = false
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEmptyLabel()
        updateEmptyState()
        
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
        setupSearch()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(showField)
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        
        view.addSubview(tableView)
    
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        loader.center = view.center
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        
        if storage.tasks.isEmpty {
            loader.startAnimating()
            fetchTasks()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching
        ? filteredTasks.count
        : storage.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        let task = isSearching
        ? filteredTasks[indexPath.row]
        : storage.tasks[indexPath.row]
        
        cell.configure(with: task)
        
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
            
            
            cell.animateStatusChange(isDone: updatedTask.isDone)
            
            self.tableView.moveRow(at: indexPath, to: newIndexPath)
        }
        
        cell.onEdit = { [weak self] in
            self?.showEditAlert(for: task)
        }
        return cell
    }
    // удаление строки из таблицы
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            storage.delete(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateEmptyState()
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
            updateEmptyState()
            tableView.reloadData()
            return
        }
        
        isSearching = true
        filteredTasks = storage.tasks.filter {
            $0.title.lowercased().contains(text.lowercased())
        }
        updateEmptyState()
        tableView.reloadData()
    }
    
    @objc func showField() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addTextField()
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                let newTask = Task(id: UUID(), title: text, isDone: false)
                self.storage.add(newTask)
                
                if self.isSearching {
                    self.tableView.reloadData()
                    self.updateEmptyState()
                } else {
                    self.tableView.reloadData()
                    self.updateEmptyState()
                }
            }
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchTasks() {
        service.fetchTodos { [weak self] result in
            DispatchQueue.main.async {
                
                self?.loader.stopAnimating()
                
                switch result {
                case .success(let tasks):
                    self?.storage.setTasks(tasks: tasks)
                    self?.tableView.reloadData()
                    self?.updateEmptyState()
                    
                case .failure(let error):
                    self?.showError(error: error)
                }
            }
        }
    }
    
    private func showError(error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "Нет задач"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 18)
        emptyLabel.isHidden = true
        
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    private func updateEmptyState() {
        let isEmpty: Bool
        if isSearching {
            isEmpty = filteredTasks.isEmpty
            emptyLabel.text = "Ничего не найдено"
        } else {
            isEmpty = storage.tasks.isEmpty
            emptyLabel.text = "Нет задач"
        }
        
        tableView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
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
            guard let self = self,
                  let text = alert.textFields?.first?.text,
            !text.isEmpty else { return }
        
            self.storage.updateTitle(task, title: text)
            
            // находим обновлённую задачу в массиве
            guard let updatedIndex = self.storage.tasks.firstIndex(where: { $0.id == task.id}) else { return }
            let indexPath = IndexPath(row: updatedIndex, section: 0)
            
            if self.isSearching {
                if let searchText = self.navigationItem.searchController?.searchBar.text {
                    self.filteredTasks = self.storage.tasks.filter {
                        $0.title.lowercased().contains(searchText.lowercased())
                    }
                }
                self.tableView.reloadData()
                updateEmptyState()
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}


