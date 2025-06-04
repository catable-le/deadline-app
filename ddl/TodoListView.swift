//
//  TodoListView.swift
//  ddl
//
//  Created by catable on 7/3/2025.
//

import SwiftUI

struct TodoListView: View {
    
    @State private var isLayoutExpanded = true
    
    // layout 子任务数据
    @State private var subTasks: [SubTaskItem] = [
        SubTaskItem(title: "box modal", completed: false),
        SubTaskItem(title: "grids and containers", completed: true),
        SubTaskItem(title: "implicit grid", completed: true),
        SubTaskItem(title: "negative spaces", completed: false),
        SubTaskItem(title: "alignment", completed: true),
        SubTaskItem(title: "another task", completed: false)
    ]
    
    @State private var tasks: [TaskItem] = [
        TaskItem(title: "grids and containers", completed: true),
        TaskItem(title: "implicit grid", completed: true),
        TaskItem(title: "negative spaces", completed: false),
        TaskItem(title: "alignment", completed: true)
    ]
    
    @State private var showingAddOptions = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                // Figma 标题样式
                Text("tasked")
                    .font(.custom("TT Firs Neue Bold", size: 32))
                    .foregroundColor(Color(red: 0.31, green: 0.35, blue: 0.32))
                    .tracking(-0.41)
                    .padding(.bottom, 16)
                
                // 文件夹示例
                Section {
                    FolderRow(title: "typography")
                }
                
                // 可展开文件夹
                    ForEach($subTasks) { $subTask in
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.860, green: 0.866, blue: 0.841, opacity: 1))
                                .frame(height: 65.7)
                            
                            HStack {
                                Button(action: {
                                    subTask.completed.toggle()
                                }) {
                                    Image(systemName: subTask.completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(subTask.completed ? .green : .gray)
                                        .font(.title2)
                                }
                                
                                Text(subTask.title)
                                    .strikethrough(subTask.completed)
                                    .foregroundColor(subTask.completed ? .gray : .primary)
                                    .font(.system(size: 18))
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    .cornerRadius(12)
                    
                    FolderRow(title: "color")
                    FolderRow(title: "style")
                    
                    TaskRow(task: .constant(TaskItem(title: "get started", completed: true)))
                    
                    Spacer()
                    
                    // 加号按钮
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddOptions.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .padding()
                                .background(Color("HighlightColor"))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .padding()
                        .sheet(isPresented: $showingAddOptions) {
                            AddOptionsView()
                        }
                    }
                }
                .padding()
            }
        }
    }


// MARK: - 子组件

struct FolderRow: View {
    let title: String
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, minHeight: 65.7, maxHeight: 65.7) // 高度按 Figma，宽度让 VStack 自动撑开
            HStack {
                Image(systemName: "square")
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 4)
    }
}
struct TaskRow: View {
    @Binding var task: TaskItem
    var body: some View {
        HStack {
            Button(action: {
                task.completed.toggle()
            }) {
                Image(systemName: task.completed ? "todo" : "done")
                    .foregroundColor(task.completed ? .green : .gray)
            }
            TextField("任务", text: $task.title)
                .strikethrough(task.completed)
                .foregroundColor(task.completed ? .gray : .primary)
        }
        .padding(.vertical, 2)
    }
}

struct AddOptionsView: View {
    var body: some View {
        VStack {
            Text("添加文件夹或任务")
                .font(.title)
            // 这里可以继续扩展输入逻辑
        }
    }
}

// MARK: - 数据模型

struct TaskItem: Identifiable {
    var id = UUID()
    var title: String
    var completed: Bool
}

struct SubTaskItem: Identifiable {
    var id = UUID()
    var title: String
    var completed: Bool
}
