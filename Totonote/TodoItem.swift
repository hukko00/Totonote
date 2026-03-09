import Foundation
import SwiftData

@Model
final class TodoItem {
    var title: String
    var detailText: String
    var dueDate: Date
    var priority: Int

    init(title: String, detailText: String, dueDate: Date, priority: Int) {
        self.title = title
        self.detailText = detailText
        self.dueDate = dueDate
        self.priority = priority
    }
}
