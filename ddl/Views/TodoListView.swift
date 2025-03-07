import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var showingAddSheet = false
    @State private var addType: AddType = .task

    enum AddType {
        case task
        case folder
    }

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Today's date header
                        HStack {
                            Text("Today")
                                .font(.largeTitle)
                                .bold()
                            Text(Date(), style: .date)
                                .font(.title2)
                                .foregroundColor(.gray)
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
                                    folder: folder, count: viewModel.countTasksInFolder(folder),
                                    viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)

                        // Tasks list
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.tasks) { task in
                                TaskRowView(
                                    task: task,
                                    folder: viewModel.folder(for: task),
                                    onToggle: {
                                        viewModel.toggleTask(task)
                                    })
                            }
                        }
                        .padding(.horizontal)
                    }
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            addType = .task
                            showingAddSheet = true
                        }) {
                            Label("Add Task", systemImage: "checklist")
                        }

                        Button(action: {
                            addType = .folder
                            showingAddSheet = true
                        }) {
                            Label("Add Folder", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                if addType == .task {
                    AddTaskView(viewModel: viewModel)
                } else {
                    AddFolderView(viewModel: viewModel)
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
    @ObservedObject var viewModel: TodoViewModel
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
                                // Show trash can when dragging
                                viewModel.folderToDelete = folder
                            }
                        }
                        .onEnded { gesture in
                            dragOffset = .zero
                            // Check if dragged to trash can position
                            if gesture.translation.height > 100 {
                                viewModel.showingDeleteConfirmation = true
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
                FolderDetailView(folder: folder, viewModel: viewModel)
            }
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let folder: Folder
    let onToggle: () -> Void
    @State private var isShowingDetail = false
    @State private var isSelected = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                        .onTapGesture {
                            isSelected.toggle()
                        }

                    if isSelected && !task.description.isEmpty {
                        Text(task.description)
                            .font(.caption)
                            .foregroundColor(.black)
                    }

                    HStack(spacing: 8) {
                        Text(folder.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(folder.color.opacity(0.1))
                            .foregroundColor(folder.color)
                            .cornerRadius(4)

                        if task.deadline != Date() {
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

                Button(action: {
                    isShowingDetail = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $isShowingDetail) {
            TaskDetailView(task: task, folder: folder)
        }
    }
}

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var editedTask: Task
    @State private var selectedFolderID: UUID

    init(task: Task, folder: Folder) {
        _editedTask = State(initialValue: task)
        _selectedFolderID = State(initialValue: folder.id)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Description", text: $editedTask.description)
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
                        viewModel.updateTask(editedTask, newFolderID: selectedFolderID)
                        dismiss()
                    }
                }
            }
        }
    }
}
