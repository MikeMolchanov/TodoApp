//
//  TodoService.swift
//  TodoApp
//
//  Created by Михаил on 30.03.2026.
//

import Foundation

final class TodoService {
    
    struct TodoResponse: Decodable {
        let todos: [TodoDTO]
    }
    
    func fetchTodos(completion: @escaping (Result<[Task], Error>) -> Void) {
        
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
                let tasks = decoded.todos.map { $0.toTask() }
                completion(.success(tasks))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
        
    }
}
