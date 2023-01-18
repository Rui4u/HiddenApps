//
//  NoteListView.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/30.
//

import SwiftUI

struct NoteListView: View {
    @ObservedObject var manager = NoteManager.shared
    @ObservedObject var coordinator = Coordinator()
    var router = Router()
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            List(manager.dataSource) { note in
                router.route(to: note)
            }
            .navigationDestination(for:  NoteModel.self) { data  in
                NoteDetailView(item: data)
            }
            .navigationTitle("我的笔记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    NoteManager.save(note:  NoteModel(title: "未命名", content: "新建文档", time: Date.now))
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



struct NoteListItem: View {
    var item:  NoteModel
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


