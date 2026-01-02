//
//  ViewController.swift
//  1
//
//  Created by Михаил on 06.12.2025.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let storage = TaskStorage()
    let tableView = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // настраиваем tableView
        
        tableView.frame = CGRect(x: 0, y: 300, width: view.frame.width, height: view.frame.height - 300)
        tableView.dataSource = self
        tableView.delegate = self
        
        // регистрируем кастомную ячейку
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        
        view.addSubview(tableView)
        
        // кнопка добавления задачи
        let button = UIButton(type: .system)
        button.setTitle("Добавить задачу", for: .normal)
        button.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        button.addTarget(self, action: #selector(showField), for: .touchUpInside)
        view.addSubview(button)
        
    }
    
    // сколько строк в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storage.tasks.count
    }
    
    // что показывать в каждой ячейке
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //достаем ячейку
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.onToggleDone = { [weak self] in
            self?.storage.toggleDone(at: indexPath.row)
            self?.tableView.reloadData()}
        //достаем задачу
        let task = storage.tasks[indexPath.row]
        cell.configure(with: task)
        
        cell.onEdit = { [weak self] in
            self?.showEditAlert(at: indexPath.row)
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
                self.storage.updateTitle(at: indexPath.row, title: text)

                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func showField() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addTextField()
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                let newTask = Task(title: text, isDone: false)
                self.storage.add(newTask)
                self.tableView.reloadData()
            }
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showEditAlert(at index: Int) {
        let task = storage.tasks[index]
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
        
            self?.storage.updateTitle(at: index, title: text)
            self?.tableView.reloadData()
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}


