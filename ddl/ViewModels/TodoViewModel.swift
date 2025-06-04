import Foundation
import SwiftUI

class TodoViewModel: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var tasks: [Task] = []
    @Published var selectedFolder: Folder?
    @Published var showingDeleteConfirmation = false
    @Published var folderToDelete: Folder?

    init() {
        // Add some sample data
        let healthFolder = Folder(name: "Health", colorHex: "#8B7FD4")
        let workFolder = Folder(name: "Work", colorHex: "#7FD4A1")
        let mentalFolder = Folder(name: "Mental Health", colorHex: "#D47FB6")
        let othersFolder = Folder(name: "Others", colorHex: "#A8A8A8")

        folders = [healthFolder, workFolder, mentalFolder, othersFolder]

        // Add sample tasks
        tasks = [
            Task(title: "Drink 8 glasses of water", folderID: healthFolder.id),
            Task(title: "Edit the PDF", folderID: workFolder.id),
            Task(title: "Write in a gratitude journal", folderID: mentalFolder.id),
            Task(title: "Get a notebook", folderID: othersFolder.id),
            Task(title: "Follow the youtube tutorial", folderID: othersFolder.id),
            Task(title: "Stretch everyday for 15 mins", folderID: healthFolder.id),
        ]
    }

    func addTask(title: String, description: String, deadline: Date, folderID: UUID) {
        let task = Task(
            title: title, description: description, deadline: deadline, folderID: folderID)
        tasks.append(task)
    }

    func addFolder(name: String, colorHex: String) {
        let folder = Folder(name: name, colorHex: colorHex)
        folders.append(folder)
    }

    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    func updateTask(_ updatedTask: Task, newFolderID: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            var taskToUpdate = updatedTask
            taskToUpdate.folderID = newFolderID
            tasks[index] = taskToUpdate
        }
    }

    func deleteFolder(_ folder: Folder) {
        // Remove all tasks in this folder
        tasks.removeAll { $0.folderID == folder.id }
        // Remove the folder
        folders.removeAll { $0.id == folder.id }
    }

    func folder(for task: Task) -> Folder {
        return folders.first { $0.id == task.folderID } ?? folders[0]
    }

    func tasksForFolder(_ folder: Folder) -> [Task] {
        return tasks.filter { $0.folderID == folder.id }
    }

    func countTasksInFolder(_ folder: Folder) -> Int {
        return tasks.filter { $0.folderID == folder.id && !$0.isCompleted }.count
    }
}
