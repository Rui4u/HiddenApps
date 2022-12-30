//
//  NoteManager.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/30.
//

import Foundation

class NoteListModel: ObservableObject,Identifiable, Codable{
    var title: String
    var content: String
    var time: Date
    var id : Date {
        return time
    }
    init(title: String, content: String, time: Date) {
        self.title = title
        self.content = content
        self.time = time
    }
}


class NoteManager: ObservableObject {
    static var shared = NoteManager()
    @Published var dataSource = [NoteListModel]()
    
    private let key = "note_key"
    
    static func save(note: NoteListModel) {
        var list = LocationManager.find([NoteListModel].self, key: shared.key) ?? [NoteListModel]()
        if let index = list.firstIndex(where: {$0.id == note.id}) {
            list[index] = note
        } else {
            list.append(note)
        }
        LocationManager.save(list, key: shared.key)
        update()
    }
    
    static func update() {
        let list = LocationManager.find([NoteListModel].self, key: shared.key) ?? [NoteListModel]()
        shared.dataSource  = list.reversed()
    }
    
    static func delete(note: NoteListModel) {
        
        var list = LocationManager.find([NoteListModel].self, key: shared.key) ?? [NoteListModel]()
        list = list.filter({$0.id != note.id})
        LocationManager.save(list, key: shared.key)
        update()
    }
}
