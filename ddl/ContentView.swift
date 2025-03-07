//
//  ContentView.swift
//  ddl
//
//  Created by catable on 7/3/2025.
//

import SwiftUI

@main
struct TodoDeadlineApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "hourglass")
                    Text("首页")
                }
            
            TodoListView()
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
        .accentColor(Color("AccentColor")) // 这里可以用莫兰迪色
    }
}

// 页面占位
struct HomeView: View { var body: some View { Text("首页") } }
//struct TodoListView: View { var body: some View { Text("待办列表") } }
struct HeatmapView: View { var body: some View { Text("热图") } }
struct ArchiveView: View { var body: some View { Text("存档") } }
