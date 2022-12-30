//
//  ScreenLockManager.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/28.
//

import Foundation
import ManagedSettings
import FamilyControls
import UIKit

class ScreenLockGroup: Identifiable, ObservableObject {
    @Published var name: String
    @Published var open: Bool {
        didSet {
            managedSettingsStore()
        }
    }
    @Published var count: Int = 0
    var updateCount: Int {
        applicationTokens.count + webDomainTokens.count + activityCategoryTokens.count
    }
    
    func managedSettingsStore() {
        if open {
            ManagedSettingsStore(named: ManagedSettingsStore.Name(name)).application.blockedApplications = Set(applicationTokens.map({Application(token: $0)}))
            ManagedSettingsStore(named: ManagedSettingsStore.Name(name)).shield.webDomains = webDomainTokens
        } else {
            ManagedSettingsStore(named: ManagedSettingsStore.Name(name)).clearAllSettings()
        }
    }
    
    var applicationTokens: Set<ApplicationToken>
    var webDomainTokens: Set<WebDomainToken>
    var activityCategoryTokens: Set<ActivityCategoryToken>
    
    var id: String {
        return self.name
    }
    
    init(name: String, open: Bool, count: Int, applicationTokens: Set<ApplicationToken>, webDomainTokens: Set<WebDomainToken>, activityCategoryTokens: Set<ActivityCategoryToken>) {
        self.name = name
        self.open = open
        self.count = count
        self.applicationTokens = applicationTokens
        self.webDomainTokens = webDomainTokens
        self.activityCategoryTokens = activityCategoryTokens
        managedSettingsStore()
    }
}

extension ScreenLockGroup {
    
    struct ScreenLockGroupStruct: Codable {
        var name: String
        var open: Bool
        var count: Int {
            applicationTokens.count + webDomainTokens.count + activityCategoryTokens.count
        }
        var applicationTokens: Set<ApplicationToken>
        var webDomainTokens: Set<WebDomainToken>
        var activityCategoryTokens: Set<ActivityCategoryToken>
    }
    
    func toStruct() -> ScreenLockGroupStruct {
        ScreenLockGroupStruct(name: name, open: open, applicationTokens: applicationTokens, webDomainTokens: webDomainTokens,activityCategoryTokens: activityCategoryTokens)
    }
}



class ScreenLockManager: ObservableObject {
    static var manager = ScreenLockManager()
    @Published var dataSource : [ScreenLockGroup] = [ScreenLockGroup]()
    
    static func update() {
        let list = LocationManager.find([ScreenLockGroup.ScreenLockGroupStruct].self, key: "group_key")
        manager.dataSource = list?.map({
            ScreenLockGroup(name: $0.name, open: $0.open, count: $0.count, applicationTokens: $0.applicationTokens, webDomainTokens: $0.webDomainTokens, activityCategoryTokens: $0.activityCategoryTokens)
        }) ?? [ScreenLockGroup]()
    }
    
    static func delete(id: String) {
        manager.dataSource = manager.dataSource.filter({$0.id != id})
        var list = LocationManager.find([ScreenLockGroup.ScreenLockGroupStruct].self, key: "group_key") ?? [ScreenLockGroup.ScreenLockGroupStruct]()
        list = list.filter({$0.name != id})
        LocationManager.save(list, key: "group_key")
        ScreenLockManager.update()
    }
    
    static func saveGroup(group: ScreenLockGroup) {
        var list = LocationManager.find([ScreenLockGroup.ScreenLockGroupStruct].self, key: "group_key") ?? [ScreenLockGroup.ScreenLockGroupStruct]()
        if let index = list.firstIndex(where: {$0.name == group.name}) {
            list[index] = group.toStruct()
        } else {
            list.append(group.toStruct())
        }
        LocationManager.save(list, key: "group_key")
        ScreenLockManager.update()
    }
    
    static func closeAllGroup() {
        var list = LocationManager.find([ScreenLockGroup.ScreenLockGroupStruct].self, key: "group_key") ?? [ScreenLockGroup.ScreenLockGroupStruct]()
        for index in 0..<list.count {
            list[index].open = false
        }
        LocationManager.save(list, key: "group_key")
        ScreenLockManager.update()
    }
    
    static func compare(selection : FamilyActivitySelection, group: ScreenLockGroup) -> Bool{
        var isSame = 0
        if (selection.categoryTokens == group.activityCategoryTokens) {
            isSame = isSame + 1
        }
        
        if (selection.applicationTokens == group.applicationTokens) {
            isSame = isSame + 1
        }
        
        if (selection.webDomainTokens == group.webDomainTokens) {
            isSame = isSame + 1
        }
        if isSame == 3 {
            return true
        }
        
        return false
    }
    
    static func loadLocatinData(selection : inout  FamilyActivitySelection, groupName:String){
        
        if let locationGroup = LocationManager.find([ScreenLockGroup.ScreenLockGroupStruct].self,key: "group_key")?.filter({$0.name == groupName }).first {
            selection.applicationTokens = locationGroup.applicationTokens
            selection.webDomainTokens = locationGroup.webDomainTokens
            selection.categoryTokens = locationGroup.activityCategoryTokens
        }
    }
}

struct IconManager {
    func changeIcon() {
        /// 获取当前所有的 AppIcon 集
        if let iconsDict = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String:Any] {
            if let alternateIcons = iconsDict["CFBundleAlternateIcons"] as? [String:Any] {
                debugPrint(alternateIcons.keys)
                alternateIcons.keys.forEach { item in
                    debugPrint(item)
                }
            }
        }

        /// 更换应用图标
        UIApplication.shared.setAlternateIconName("Test_AppIcon",completionHandler: { error in
            if error != nil {
                print("失败")
            }
        })

        /// 恢复默认应用图标
        UIApplication.shared.setAlternateIconName(nil, completionHandler: nil)

    }
}


