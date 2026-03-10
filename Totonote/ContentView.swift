import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoItem.dueDate) private var todos: [TodoItem]

    @State private var title = ""
    @State private var detailText = ""
    @State private var dueDate = Date()
    @State private var priority = 1
    @State private var showAddSheet = false
    @State private var isCompleted = false

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                if todos.isEmpty{
                    ContentUnavailableView(
                                "保存がありません",
                                systemImage: "pencil",
                                description: Text("右上の＋ボタンからTodoを追加してください")
                            )
                } else {
                    ForEach(todos) { todo in
                        Button {
                            todo.isCompleted.toggle()
                            print("タップ: \(todo.title)")
                        } label: {
                            HStack{
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(todo.isCompleted ? .green : .gray)
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    
                                    Text(todo.title)
                                        .font(.headline)
                                    
                                    if !todo.detailText.isEmpty {
                                        Text(todo.detailText)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("削除", role: .destructive) {
                                deleteTodo(todo)
                            }
                            
                            Button("編集") {
                                print("編集: \(todo.title)")
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete(perform: deleteTodos)
                }
            }
            .navigationTitle("Totonote")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                Form {
                    Section("新しいTodoを追加") {
                        TextField("タイトル", text: $title)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("内容")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            ZStack(alignment: .topLeading) {
                                if detailText.isEmpty {
                                    Text("具体的な内容を入力")
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                }

                                TextEditor(text: $detailText)
                                    .frame(minHeight: 100)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("優先度")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Picker("", selection: $priority) {
                                ForEach(1...5, id: \.self) { number in
                                    Text("\(number)").tag(number)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }

                        DatePicker(
                            "期日",
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                    }
                }
                .navigationTitle("追加")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("閉じる") {
                            showAddSheet = false
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("保存") {
                            addTodo()
                            showAddSheet = false
                        }
                        .disabled(!canSave)
                        .tint(canSave ? .blue : .gray)
                    }
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private func addTodo() {
        let newTodo = TodoItem(
            title: title,
            detailText: detailText,
            dueDate: dueDate,
            priority: priority,
            isCompleted: isCompleted
        )

        context.insert(newTodo)

        do {
            try context.save()
            title = ""
            detailText = ""
            dueDate = Date()
            priority = 1
        } catch {
            print("保存エラー: \(error)")
        }
    }

    private func deleteTodo(_ todo: TodoItem) {
        context.delete(todo)

        do {
            try context.save()
        } catch {
            print("削除エラー: \(error)")
        }
    }

    private func deleteTodos(offsets: IndexSet) {
        for index in offsets {
            context.delete(todos[index])
        }

        do {
            try context.save()
        } catch {
            print("削除エラー: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
