import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var deadline: Date
    var isCompleted: Bool
    var folderID: UUID
    var createdAt: Date

    init(
        title: String, description: String = "", deadline: Date = Date(), isCompleted: Bool = false,
        folderID: UUID
    ) {
        self.title = title
        self.description = description
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.folderID = folderID
        self.createdAt = Date()
    }
}
