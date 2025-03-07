import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var selectedFolderID: UUID
    @State private var deadline = Date()

    init(viewModel: TodoViewModel) {
        self.viewModel = viewModel
        // 初始化时设置第一个文件夹为默认选择
        _selectedFolderID = State(initialValue: viewModel.folders.first?.id ?? UUID())
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
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
                        "Select Date", selection: $deadline,
                        displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addTask(
                            title: title,
                            description: description,
                            deadline: deadline,
                            folderID: selectedFolderID
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || viewModel.folders.isEmpty)
                }
            }
        }
    }
}
