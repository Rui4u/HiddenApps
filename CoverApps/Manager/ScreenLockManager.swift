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

class AppGroup: Identifiable, ObservableObject {
    @Published var name: String
    @Published var count: Int = 0
    @Published var open: Bool {
        didSet {
            managedSettingsStore()
        }
    }
    var creatTime: TimeInterval
    var locationStoreName: String {
        name + "\(creatTime)"
    }
    var updateCount: Int {
        applicationTokens.count + webDomainTokens.count + activityCategoryTokens.count
    }
    
    func managedSettingsStore() {
        if open {
            ManagedSettingsStore(named: ManagedSettingsStore.Name(locationStoreName)).application.blockedApplications = Set(applicationTokens.map({Application(token: $0)}))
            ManagedSettingsStore(named: ManagedSettingsStore.Name(locationStoreName)).shield.webDomains = webDomainTokens
        } else {
            ManagedSettingsStore(named: ManagedSettingsStore.Name(locationStoreName)).clearAllSettings()
        }
    }
    
    var applicationTokens: Set<ApplicationToken>
    var webDomainTokens: Set<WebDomainToken>
    var activityCategoryTokens: Set<ActivityCategoryToken>
    
    var id: TimeInterval {
        return self.creatTime
    }
    
    init(name: String,
         open: Bool,
         count: Int,
         creatTime: TimeInterval,
         applicationTokens: Set<ApplicationToken> = Set<ApplicationToken>(),
         webDomainTokens: Set<WebDomainToken> = Set<WebDomainToken>(),
         activityCategoryTokens: Set<ActivityCategoryToken> = Set<ActivityCategoryToken>()) {
        self.name = name
        self.open = open
        self.count = count
        self.creatTime = creatTime
        self.applicationTokens = applicationTokens
        self.webDomainTokens = webDomainTokens
        self.activityCategoryTokens = activityCategoryTokens
        managedSettingsStore()
    }
}
extension AppGroup {
    
    struct Location: Codable {
        var name: String
        var open: Bool
        var creatTime: TimeInterval
        
        var applicationTokens: Set<ApplicationToken>
        var webDomainTokens: Set<WebDomainToken>
        var activityCategoryTokens: Set<ActivityCategoryToken>
        
        var count: Int {
            applicationTokens.count + webDomainTokens.count + activityCategoryTokens.count
        }
        var id: TimeInterval {
            return creatTime
        }
    }
    
    func toStruct() -> Location {
        Location(name: name,
                 open: open,
                 creatTime: creatTime,
                 applicationTokens: applicationTokens,
                 webDomainTokens: webDomainTokens,
                 activityCategoryTokens: activityCategoryTokens)
    }
}



class ScreenLockManager: ObservableObject {
    static var manager = ScreenLockManager()
    
    @Published var authorization: Bool = false
    @Published var dataSource : [AppGroup] = [AppGroup]()
    
    static func update() {
        let list = LocationManager.find([AppGroup.Location].self, key: "group_key")
        manager.dataSource = list?.map({
            AppGroup(name: $0.name, open: $0.open, count: $0.count,creatTime: $0.creatTime , applicationTokens: $0.applicationTokens, webDomainTokens: $0.webDomainTokens, activityCategoryTokens: $0.activityCategoryTokens)
        }) ?? [AppGroup]()
    }
    
    static func delete(id: TimeInterval) {
        let restoreList = manager.dataSource.filter({$0.id == id})
        if restoreList.count > 0 {
            for index in 0..<restoreList.count {
                restoreList[index].open = false
            }
        }
        manager.dataSource = manager.dataSource.filter({$0.id != id})
        let list = LocationManager.find([AppGroup.Location].self, key: "group_key") ?? [AppGroup.Location]()
        let saveList = list.filter({$0.id != id})
        LocationManager.save(saveList, key: "group_key")
        ScreenLockManager.update()
    }
    
    static func save(group: AppGroup) {
        var list = LocationManager.find([AppGroup.Location].self, key: "group_key") ?? [AppGroup.Location]()
        if let index = list.firstIndex(where: {$0.id == group.id}) {
            list[index] = group.toStruct()
        } else {
            list.append(group.toStruct())
        }
        LocationManager.save(list, key: "group_key")
        ScreenLockManager.update()
    }
    
    static func closeAll() {
        var list = LocationManager.find([AppGroup.Location].self, key: "group_key") ?? [AppGroup.Location]()
        for index in 0..<list.count {
            list[index].open = false
        }
        LocationManager.save(list, key: "group_key")
        ScreenLockManager.update()
    }
    
    static func compare(selection : FamilyActivitySelection, group: AppGroup) -> Bool{
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
        
        if let locationGroup = LocationManager.find([AppGroup.Location].self,key: "group_key")?.filter({$0.name == groupName }).first {
            selection.applicationTokens = locationGroup.applicationTokens
            selection.webDomainTokens = locationGroup.webDomainTokens
            selection.categoryTokens = locationGroup.activityCategoryTokens
        }
    }
}

struct IconManager {
    static func changeIcon(icon: String) {
        /// 获取当前所有的 AppIcon 集
        guard let iconsDict = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String:Any] else {
            return
        }
        guard let icons = iconsDict["CFBundleAlternateIcons"] as? [String:Any] else {
            return
        }

        guard let iconName = icons.keys.filter({
            $0.contains(icon)
        }).first else {
            defaultIcon()
            return
        }
       
        /// 更换应用图标
        UIApplication.shared.setAlternateIconName(iconName,completionHandler: { error in
            if error != nil {
                print("失败")
            }
        })
        
        
        /// 恢复默认应用图标
    }
    static func defaultIcon() {
        UIApplication.shared.setAlternateIconName(nil, completionHandler: nil)
    }
}


