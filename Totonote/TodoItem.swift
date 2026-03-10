import Foundation
import SwiftData

@Model
final class TodoItem {
    var title: String
    var detailText: String
    var dueDate: Date
    var priority: Int
    var isCompleted: Bool = false

    init(title: String, detailText: String, dueDate: Date, priority: Int,isCompleted: Bool) {
        self.title = title
        self.detailText = detailText
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted 
    }
}
