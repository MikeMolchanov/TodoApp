//
//  TodoDTO.swift
//  TodoApp
//
//  Created by Михаил on 30.03.2026.
//

import Foundation

struct TodoDTO: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}

extension TodoDTO {
    func toTask() -> Task {
        return Task(
            id: UUID(),
            title: todo,
            isDone: completed)
    }
}
