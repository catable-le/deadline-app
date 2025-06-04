import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var showingAddSheet = false
    @State private var addType: AddType = .task
    @State private var selectedTaskID: UUID? = nil  // 全局选择状态

    enum AddType {
        case task
        case folder
    }

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Today's date header with add button
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Today")
                                    .font(.largeTitle)
                                    .bold()
                                Text(Date(), style: .date)
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Menu {
                                Button("Add Task") {
                                    addType = .task
                                    showingAddSheet = true
                                }

                                Button("Add Folder") {
                                    addType = .folder
                                    showingAddSheet = true
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                            }
                        }
                        .padding(.horizontal)

                        // Folders grid
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ], spacing: 15
                        ) {
                            ForEach(viewModel.folders) { folder in
                                FolderView(
                                    folder: folder, count: viewModel.countTasksInFolder(folder)
                                )
                                .environmentObject(viewModel)
                            }
                        }
                        .padding(.horizontal)

                        // Tasks list
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.tasks) { task in
                                TaskRowView(
                                    task: task,
                                    folder: viewModel.folder(for: task),
                                    isSelected: selectedTaskID == task.id,
                                    onToggle: {
                                        viewModel.toggleTask(task)
                                    },
                                    onSelect: { taskID in
                                        selectedTaskID = (selectedTaskID == taskID) ? nil : taskID
                                    },
                                    onTaskUpdate: { updatedTask in
                                        viewModel.updateTask(
                                            updatedTask, newFolderID: updatedTask.folderID)
                                    }
                                )
                                .environmentObject(viewModel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .onTapGesture {
                    // 点击空白处取消选择
                    selectedTaskID = nil
                }

                // Trash can overlay
                if viewModel.folderToDelete != nil {
                    VStack {
                        Spacer()
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSheet) {
                if addType == .task {
                    AddTaskView(viewModel: viewModel)
                        .environmentObject(viewModel)
                } else if addType == .folder {
                    AddFolderView(viewModel: viewModel)
                        .environmentObject(viewModel)
                }
            }
            .alert("Delete Folder", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.folderToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let folder = viewModel.folderToDelete {
                        viewModel.deleteFolder(folder)
                    }
                    viewModel.folderToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this folder and all its tasks?")
            }
        }
    }
}

struct FolderView: View {
    let folder: Folder
    let count: Int
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var isShowingDetail = false
    @State private var dragOffset = CGSize.zero
    @GestureState private var isLongPressed = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(count)")
                    .font(.title)
                    .bold()
                Spacer()
                Image(systemName: "folder.fill")
            }
            .foregroundColor(folder.color)

            Text(folder.name)
                .font(.headline)
        }
        .padding()
        .background(folder.color.opacity(0.1))
        .cornerRadius(12)
        .offset(dragOffset)
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($isLongPressed) { value, state, _ in
                    state = value
                }
                .simultaneously(
                    with: DragGesture()
                        .onChanged { gesture in
                            if isLongPressed {
                                dragOffset = gesture.translation
                                viewModel.folderToDelete = folder
                            }
                        }
                        .onEnded { gesture in
                            dragOffset = .zero
                            if abs(gesture.translation.width) > 50
                                || abs(gesture.translation.height) > 50
                            {
                                if viewModel.folderToDelete != nil {
                                    viewModel.showingDeleteConfirmation = true
                                }
                            } else {
                                viewModel.folderToDelete = nil
                            }
                        })
        )
        .onTapGesture {
            isShowingDetail = true
        }
        .sheet(isPresented: $isShowingDetail) {
            NavigationView {
                FolderDetailView(folder: folder)
                    .environmentObject(viewModel)
            }
        }
    }
}

struct TaskRowView: View {
    @State var task: Task
    let folder: Folder
    let isSelected: Bool
    let onToggle: () -> Void
    let onSelect: (UUID) -> Void
    let onTaskUpdate: (Task) -> Void
    @EnvironmentObject var viewModel: TodoViewModel

    @State private var isShowingDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Task completion button
                Button(action: {
                    onToggle()
                    // 立即更新本地状态以提供视觉反馈
                    task.isCompleted.toggle()
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                        .font(.system(size: 20))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                        .onTapGesture {
                            onSelect(task.id)
                        }

                    if isSelected && !task.description.isEmpty {
                        Text(task.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 8) {
                        Text(folder.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(folder.color.opacity(0.1))
                            .foregroundColor(folder.color)
                            .cornerRadius(4)

                        if task.deadline.timeIntervalSince1970 > Date().timeIntervalSince1970 {
                            Text(task.deadline, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(task.deadline, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Spacer()

                if isSelected {
                    Button(action: {
                        isShowingDetail = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $isShowingDetail) {
            NavigationView {
                TaskDetailView(
                    task: task,
                    initialFolderId: task.folderID,
                    onSave: { updatedTask in
                        onTaskUpdate(updatedTask)
                        // 更新本地task
                        task = updatedTask
                    }
                )
                .environmentObject(viewModel)
            }
        }
    }
}

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TodoViewModel

    @State var editedTask: Task
    @State var selectedFolderID: UUID

    private var initialTaskState: Task
    private var initialSelectedFolderID: UUID
    let onSave: (Task) -> Void

    init(task: Task, initialFolderId: UUID, onSave: @escaping (Task) -> Void) {
        _editedTask = State(initialValue: task)
        _selectedFolderID = State(initialValue: initialFolderId)
        self.initialTaskState = task
        self.initialSelectedFolderID = initialFolderId
        self.onSave = onSave
    }

    var hasChanges: Bool {
        return editedTask.description != initialTaskState.description
            || editedTask.deadline != initialTaskState.deadline
            || selectedFolderID != initialSelectedFolderID
            || editedTask.title != initialTaskState.title
    }

    var body: some View {
        Form {
            Section(header: Text("Task Title")) {
                TextField("Title", text: $editedTask.title)
            }
            Section(header: Text("Task Details")) {
                TextField("Description", text: $editedTask.description, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section(header: Text("Folder")) {
                Picker("Select Folder", selection: $selectedFolderID) {
                    ForEach(viewModel.folders) { folder in
                        Text(folder.name)
                            .tag(folder.id)
                    }
                }
            }

            Section(header: Text("Deadline")) {
                DatePicker(
                    "Select Date",
                    selection: $editedTask.deadline,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        }
        .navigationTitle("Edit Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    // 确保所有更改都被保存
                    var taskToUpdate = editedTask
                    taskToUpdate.folderID = selectedFolderID
                    onSave(taskToUpdate)
                    dismiss()
                }
                .disabled(!hasChanges)
            }
        }
    }
}
