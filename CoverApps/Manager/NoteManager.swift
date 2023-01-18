//
//  NoteManager.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/30.
//

import Foundation

struct NoteModel: Identifiable, Codable, Hashable{
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
    @Published var dataSource = [NoteModel]()
    
    private let key = "note_key"
    
    static func save(note: NoteModel) {
        var list = LocationManager.find([NoteModel].self, key: shared.key) ?? [NoteModel]()
        if let index = list.firstIndex(where: {$0.id == note.id}) {
            list[index] = note
        } else {
            list.append(note)
        }
        LocationManager.save(list, key: shared.key)
        update()
    }
    
    static func update() {
        let list = LocationManager.find([NoteModel].self, key: shared.key) ?? [NoteModel]()
        shared.dataSource  = list.reversed()
    }
    
    static func delete(note: NoteModel) {
        
        var list = LocationManager.find([NoteModel].self, key: shared.key) ?? [NoteModel]()
        list = list.filter({$0.id != note.id})
        LocationManager.save(list, key: shared.key)
        update()
    }
}
