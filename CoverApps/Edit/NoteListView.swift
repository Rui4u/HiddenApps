//
//  NoteListView.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/30.
//

import SwiftUI


struct NoteDetailView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State var item : NoteListModel
    var body: some View {
        VStack {
            TextField("标题", text: $item.title)
                .padding(EdgeInsets(top: 0, leading: 17, bottom: 0, trailing: 17))
                .fontWeight(.bold)
                .font(.title2)
            TextEditingView(fullText: $item.content)
                .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
        }
        .toolbar {
            Button{
                NoteManager.save(note: item)
                coordinator.pop()
                
            } label: {
                Image(systemName: "checkmark")
            }
        }
    }
}


struct TextEditingView: View {
    @Binding var fullText: String
    
    var body: some View {
        TextEditor(text: $fullText)
            .foregroundColor(Color.black)
            .font(.custom("HelveticaNeue", size: 13))
            .lineSpacing(5)
    }
}


struct NoteListItem: View {
    var item: NoteListModel
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title)
                    .lineLimit(1)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .padding(EdgeInsets(top: 2, leading: 0, bottom: 4, trailing: 0))
                
                Text(item.content)
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button (role: .destructive){
                NoteManager.delete(note: item)
            } label: {
                Label("删除", systemImage: "delete")
            }
        }
    }
}

class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

struct NoteListView: View {
    @ObservedObject var manager = NoteManager.shared
    @ObservedObject var coordinator = Coordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            List(manager.dataSource) { source in
                NavigationLink(value: source) {
                    NoteListItem(item: source)
                }
            }
            .navigationDestination(for: NoteListModel.self) { data  in
                NoteDetailView(item: data)
            }
            .navigationTitle("我的笔记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    NoteManager.save(note: NoteListModel(title: "未命名", content: "新建文档", time: Date.now))
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .environmentObject(coordinator)
        .onAppear {
            NoteManager.update()
        }
    }
    
    
    func dateNowAsString(date nowDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = "MM-dd-HH:mm"
        
        let date = formatter.string(from: nowDate)
        return date.components(separatedBy: " ").first!
    }
}

struct NoteListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteListView()
    }
}

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func pop() {
        path.removeLast()
    }
}

