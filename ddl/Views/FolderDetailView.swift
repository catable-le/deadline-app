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
                    Text("\(viewModel.countTasksInFolder(folder))")
                        .font(.title)
                        .bold()
                        .foregroundColor(folder.color)
                }
                .padding(.horizontal)

                // Tasks list
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.tasksForFolder(folder)) { task in
                        TaskRowView(
                            task: task,
                            folder: folder,
                            isSelected: selectedTaskID == task.id,
                            onToggle: {
                                viewModel.toggleTask(task)
                            },
                            onSelect: { taskID in
                                if selectedTaskID == taskID {
                                    selectedTaskID = nil
                                } else {
                                    selectedTaskID = taskID
                                }
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
