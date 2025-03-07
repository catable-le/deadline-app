import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()

    var body: some View {
        MainTabView()
            .environmentObject(viewModel)
    }
}

struct MainTabView: View {
    @EnvironmentObject var viewModel: TodoViewModel

    var body: some View {
        TabView {
            TodoListView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "checklist")
                    Text("待办")
                }

            HeatmapView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("热图")
                }

            ArchiveView()
                .tabItem {
                    Image(systemName: "archivebox.fill")
                    Text("存档")
                }
        }
        .accentColor(Color("AccentColor"))
    }
}

// 页面占位
struct HeatmapView: View { var body: some View { Text("热图") } }
struct ArchiveView: View { var body: some View { Text("存档") } }
