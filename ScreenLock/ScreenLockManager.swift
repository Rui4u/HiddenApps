//
//  ScreenLockManager.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/28.
//

import Foundation
import ManagedSettings
import FamilyControls


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
    

    static func save(_ value: Encodable, groupType : GroupType, groupName: String) {
        let key = groupType.key(groupName)
        save(value, key: key)
    }
    
    private static func save(_ value: Encodable, key:String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            let str = String(data: data, encoding: .utf8)!
            UserDefaults.standard.setValue(str, forKey: key)
        }
    }
    
    private static func find<T: Decodable>(_ type: T.Type, key:String) -> T? {
        if let applicationToken = UserDefaults.standard.value(forKey: key) as? String {
            let jsonData = applicationToken.data(using: .utf8)
            let decoder = JSONDecoder()
            if let result = try? decoder.decode(type, from: jsonData!) {
                return result
            }
        }
        return nil
    }
    
    static func find<T: Decodable>(_ type: T.Type, groupType : GroupType, groupName: String) -> T? {
        let key = groupType.key(groupName)
        return find(type, key: key)
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
    
    static func compare(selection : FamilyActivitySelection, groupName:String) -> Bool{
        var isSame = 0
        if let find = ScreenLockManager.find(Set<ApplicationToken>.self, groupType: .applicationToken, groupName: groupName) {
            if selection.applicationTokens == find {
                isSame = isSame + 1
            }
            
        }
        
        if let find = ScreenLockManager.find(Set<WebDomainToken>.self,  groupType: .domainsToken, groupName: groupName) {
            if selection.webDomainTokens == find {
                isSame = isSame + 1
            }
        }
        
        if let find = ScreenLockManager.find(Set<ActivityCategoryToken>.self, groupType: .categoryTokens, groupName: groupName) {
            if selection.categoryTokens == find {
                isSame = isSame + 1
            }
        }
        if isSame == 3 {
            return true
        }
        
        return false
    }
    
    static func loadLocatinData(selection : inout  FamilyActivitySelection, groupName:String){
        
        if let find = ScreenLockManager.find(Set<ApplicationToken>.self, groupType: .applicationToken, groupName: groupName) {
            selection.applicationTokens = find
        }
        
        if let find = ScreenLockManager.find(Set<WebDomainToken>.self,  groupType: .domainsToken, groupName: groupName) {
            selection.webDomainTokens = find
        }
        
        if let find = ScreenLockManager.find(Set<ActivityCategoryToken>.self, groupType: .categoryTokens, groupName: groupName) {
            selection.categoryTokens = find
        }
    }
}



enum GroupType: String {
    case applicationToken
    case domainsToken
    case categoryTokens
    
    func key(_ groupName: String) -> String {
        switch self {
        case .applicationToken:
            return "applicationToken" + "_" + groupName
        case .domainsToken:
            return "domainsToken" + "_" + groupName
        case .categoryTokens:
            return  "categoryTokens" + "_" + groupName
        }
    }
}
