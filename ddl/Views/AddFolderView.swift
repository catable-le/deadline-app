import SwiftUI

struct AddFolderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel

    @State private var name = ""
    @State private var selectedColor = Color.blue

    let colors: [Color] = [
        Color(hex: "#8B7FD4"),  // Purple
        Color(hex: "#7FD4A1"),  // Green
        Color(hex: "#D47FB6"),  // Pink
        Color(hex: "#7FB6D4"),  // Blue
        Color(hex: "#D4A17F"),  // Orange
        Color(hex: "#A8A8A8"),  // Gray
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Folder Details")) {
                    TextField("Name", text: $name)
                }

                Section(header: Text("Color")) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10
                    ) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            color == selectedColor ? Color.primary : Color.clear,
                                            lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        // Convert Color to hex string
                        let uiColor = UIColor(selectedColor)
                        var red: CGFloat = 0
                        var green: CGFloat = 0
                        var blue: CGFloat = 0
                        var alpha: CGFloat = 0
                        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                        let hex = String(
                            format: "#%02X%02X%02X",
                            Int(red * 255),
                            Int(green * 255),
                            Int(blue * 255)
                        )

                        viewModel.addFolder(name: name, colorHex: hex)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
