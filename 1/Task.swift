//
//  Task.swift
//  1
//
//  Created by Михаил on 20.12.2025.
//

import Foundation

struct Task: Codable {
    let id: UUID //уникальный идентификатор
    var title: String
    var isDone: Bool
}
