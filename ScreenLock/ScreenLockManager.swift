//
//  ScreenLockManager.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/28.
//

import Foundation
import ManagedSettings


class ScreenLockGroup: Identifiable, ObservableObject {
    
    struct ScreenLockGroupStruct: Codable {
        var name: String
        var open: Bool
        var count: Int = 0
    }
    
    @Published var name: String
    @Published var open: Bool
    @Published var count: Int = 0
    var id: String {
        return self.name
    }
    init(name: String, open: Bool, count: Int = 0) {
        self.name = name
        self.open = open
        self.count = count
    }
    
    func toStruct() -> ScreenLockGroupStruct {
        ScreenLockGroupStruct(name: name, open: open, count: count)
    }
}

class ScreenLockManager: ObservableObject {
    static var manager = ScreenLockManager()
    @Published var dataSource : [ScreenLockGroup] = [ScreenLockGroup]()
    
    static func group() -> [ScreenLockGroup] {
        var list = find([ScreenLockGroup.ScreenLockGroupStruct].self, key: "group_key")
        manager.dataSource = list?.map({ScreenLockGroup(name: $0.name, open: $0.open, count: $0.count)}) ?? [ScreenLockGroup]()
        return manager.dataSource
    }
    
    static func delete(id: String) {
        manager.dataSource = manager.dataSource.filter({$0.id != id})
        var list = find([ScreenLockGroup.ScreenLockGroupStruct].self, key: "group_key") ?? [ScreenLockGroup.ScreenLockGroupStruct]()
        list = list.filter({$0.name != id})
        save(list, key: "group_key")
        ScreenLockManager.group()
    }
    

    
    static func save(_ value: Encodable, key:String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            let str = String(data: data, encoding: .utf8)!
            UserDefaults.standard.setValue(str, forKey: key)
        }
    }
    
    static func find<T: Decodable>(_ type: T.Type, key:String) -> T? {
        if let applicationToken = UserDefaults.standard.value(forKey: key) as? String {
            let jsonData = applicationToken.data(using: .utf8)
            let decoder = JSONDecoder()
            if let result = try? decoder.decode(type, from: jsonData!) {
                return result
            }
        }
        return nil
    }
    
    static func saveGroup(group: ScreenLockGroup) {
        var list = find([ScreenLockGroup.ScreenLockGroupStruct].self, key: "group_key") ?? [ScreenLockGroup.ScreenLockGroupStruct]()
        if let index = list.firstIndex(where: {$0.name == group.name}) {
            list[index] = group.toStruct()
        } else {
            list.append(group.toStruct())
        }
        save(list, key: "group_key")
        ScreenLockManager.group()
    }

}
