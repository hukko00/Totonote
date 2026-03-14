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
    @State private var showSortSheet = false
    @State private var isCompleted = false

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red:255/255, green:255/255, blue:249/255)
                    .ignoresSafeArea()

                List {
                    if todos.isEmpty {
                        ContentUnavailableView(
                            "まだTodoがありません",
                            systemImage: "checklist",
                            description: Text("右下のボタンから追加してください")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(todos) { todo in
                            Button {
                                todo.isCompleted.toggle()

                                do {
                                    try context.save()
                                } catch {
                                    print("更新エラー: \(error)")
                                }
                            } label: {
                                HStack {
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
                            .listRowBackground(Color.clear)
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
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Totonote")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("ok,sort")
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
            .toolbarBackground(Color(red:255/255, green:255/255, blue:249/255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                ZStack {
                    Button {
                        showAddSheet = true
                    } label: {
                        ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 80, height: 80)
                                    .overlay {
                                        Circle()
                                            .stroke(.black, lineWidth: 4)
                                    }

                                Image(systemName: "plus")
                                    .font(.system(size: 38, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                    }

                    HStack {
                        Spacer()

                        Button {
                            let targets = todos.filter { $0.isCompleted == true }

                            for todo in targets {
                                context.delete(todo)
                            }

                            do {
                                try context.save()
                            } catch {
                                print("削除エラー: \(error)")
                            }
                        } label: {
                            ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 60, height: 60)
                                        .overlay {
                                            Circle()
                                                .stroke(.black, lineWidth: 3.5)
                                        }

                                    Image(systemName: "trash")
                                        .font(.system(size: 38))
                                        .foregroundStyle(.black)
                                }
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.vertical, 12)
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
                                .foregroundStyle(.secondary)

                            Picker("", selection: $priority) {
                                Text("I").tag(1)
                                Text("II").tag(2)
                                Text("III").tag(3)
                                Text("IV").tag(4)
                                Text("V").tag(5)
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
            .presentationDetents([.medium, .large])
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
            isCompleted = false
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
        .modelContainer(for: TodoItem.self, inMemory: true)
}
