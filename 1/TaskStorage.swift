//
//  TaskStorage.swift
//  1
//
//  Created by Михаил on 20.12.2025.
//

import Foundation

final class TaskStorage {
    
    private let tasksKey  = "tasks_key"
    private(set) var tasks: [Task] = []
    
    init() {
        load()
    }
    // MARK: - Public API
    
    func add(_ task: Task) {
        tasks.append(task)
        sort()
        save()
    }
    
    func delete( at index: Int ) {
        tasks.remove(at: index)
        sort()
        save()
    }
    
    func toggleDone( at index: Int ) {
        tasks[index].isDone.toggle()
        sort()
        save()
    }
    
    func updateTitle(at index: Int, title: String) {
        var task = tasks[index]
        task.title = title
        tasks[index] = task
        save()
    }
    
    // MARK: - Private
    
    private func sort() {
        tasks.sort { $0.isDone == false && $1.isDone == true }
    }
    
    private func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(tasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
    }
    
    private func load() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: tasksKey) ,
           let savedTasks = try? decoder.decode([Task].self, from: data) {
            tasks = savedTasks
            sort()
        }
    }
}
