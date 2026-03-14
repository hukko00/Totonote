import Foundation
import EventKit
import Combine

@MainActor
final class EventManager: ObservableObject {
    let store = EKEventStore()
    @Published var statusMessage = ""

    func requestCalendarAccess() async {
        do {
            if #available(iOS 17.0, *) {
                let granted = try await store.requestWriteOnlyAccessToEvents()
                statusMessage = granted ? "カレンダー書き込み権限があります。" : "カレンダー権限が拒否されました。"
            } else {
                let granted = try await store.requestAccess(to: .event)
                statusMessage = granted ? "カレンダー権限があります。" : "カレンダー権限が拒否されました。"
            }
        } catch {
            statusMessage = "権限リクエスト失敗: \(error.localizedDescription)"
        }
    }

    func saveTodoAsEvent(title: String, notes: String, dueDate: Date) {
        guard let calendar = store.defaultCalendarForNewEvents else {
            statusMessage = "保存先のカレンダーが見つかりません。"
            return
        }

        let event = EKEvent(eventStore: store)

        event.calendar = calendar
        event.title = title
        event.notes = notes

        event.isAllDay = true
        event.startDate = Calendar.current.startOfDay(for: dueDate)
        event.endDate = Calendar.current.date(byAdding: .day, value: 1, to: event.startDate)

        do {
            try store.save(event, span: .thisEvent)
            statusMessage = "予定をカレンダーに追加しました。"
        } catch {
            statusMessage = "予定の保存に失敗しました: \(error.localizedDescription)"
        }
    }
}
