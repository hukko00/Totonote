import SwiftUI
import SwiftData

struct AddTodoSheetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var detailText = ""
    @State private var dueDate = Date()
    @State private var priority = 1
    @State private var isCompleted = false
    @State private var color = 1

    private var canSave: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 249.0 / 255.0)
                    .ignoresSafeArea()

                Form {
                    Section("新しいTodoを追加") {
                        TextField("タイトル", text: $title)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("内容")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            ZStack(alignment: .topLeading) {
                                if detailText.isEmpty {
                                    Text("具体的な内容を入力")
                                        .foregroundColor(.gray)
                                        .padding(.top, 6)
                                        .padding(.leading, 2)
                                }

                                TextEditor(text: $detailText)
                                    .frame(minHeight: 50)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("優先度")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("優先度", selection: $priority) {
                                Text("I").tag(1)
                                Text("II").tag(2)
                                Text("III").tag(3)
                                Text("IV").tag(4)
                                Text("V").tag(5)
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                        HStack{
                            VStack(alignment: .leading, spacing: 8) {
                                Text("色")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 12) {
                                    colorButton(.white, tag: 1, stroke: .gray, checkmark: .black)
                                    colorButton(Color(red: 219.0 / 255.0, green: 255.0 / 255.0, blue: 249.0 / 255.0), tag: 2, stroke: .gray, checkmark: .black)
                                    colorButton(Color(red: 219.0 / 255.0, green: 255.0 / 255.0, blue: 219.0 / 255.0), tag: 3, stroke: .gray, checkmark: .black)
                                    colorButton(Color(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 153.0 / 255.0), tag: 4, stroke: .gray, checkmark: .black)
                                    colorButton(Color(red: 255.0 / 255.0, green: 219.0 / 255.0, blue: 219.0 / 255.0), tag: 5, stroke: .gray, checkmark: .black)
                                }
                                .padding(.vertical, 4)
                            }
                            DatePicker(
                                "期日",
                                selection: $dueDate,
                                displayedComponents: .date
                            )
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        addTodo()
                    }
                    .disabled(!canSave)
                    .tint(canSave ? .blue : .gray)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func addTodo() {
        let newTodo = TodoItem(
            title: title,
            detailText: detailText,
            dueDate: dueDate,
            priority: priority,
            isCompleted: isCompleted,
            color: color
        )

        context.insert(newTodo)

        do {
            try context.save()
            dismiss()
        } catch {
            print("保存エラー: \(error)")
        }
    }

    @ViewBuilder
    private func colorButton(_ displayColor: Color, tag: Int, stroke: Color = .clear, checkmark: Color = .clear) -> some View {
        Button {
            color = tag
        } label: {
            Circle()
                .fill(displayColor)
                .frame(width: 28, height: 28)
                .overlay {
                    Circle()
                        .stroke(stroke, lineWidth: 1)
                }
                .overlay {
                    if color == tag {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundColor(checkmark)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddTodoSheetView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
