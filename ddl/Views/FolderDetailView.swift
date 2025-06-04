import SwiftUI

struct FolderDetailView: View {
    let folder: Folder
    @EnvironmentObject var viewModel: TodoViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTaskID: UUID? = nil

    init(folder: Folder) {
        self.folder = folder
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Folder header
                HStack {
                    Text(folder.name)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(folder.color)
                    Spacer()
                    let taskCount = viewModel.countTasksInFolder(folder)
                    Text("\(taskCount)")
                        .font(.title)
                        .bold()
                        .foregroundColor(folder.color)
                }
                .padding(.horizontal)

                // Tasks list
                VStack(alignment: .leading, spacing: 10) {
                    let folderTasks = viewModel.tasksForFolder(folder)
                    ForEach(folderTasks) { task in
                        TaskRowView(
                            task: task,
                            folder: folder,
                            isSelected: selectedTaskID == task.id,
                            onToggle: {
                                viewModel.toggleTask(task)
                            },
                            onSelect: { taskID in
                                selectedTaskID = (selectedTaskID == taskID) ? nil : taskID
                            },
                            onTaskUpdate: { updatedTask in
                                viewModel.updateTask(updatedTask, newFolderID: updatedTask.folderID)
                            }
                        )
                        .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
        }
    }
}
