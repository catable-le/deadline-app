import SwiftUI

struct FolderDetailView: View {
    let folder: Folder
    @ObservedObject var viewModel: TodoViewModel
    @Environment(\.dismiss) var dismiss

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
                            onToggle: {
                                viewModel.toggleTask(task)
                            }
                        )
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
