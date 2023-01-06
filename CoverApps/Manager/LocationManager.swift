//
//  LocationManager.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/30.
//

import Foundation
import FMDB
import SQLite3
import SwiftUI

class FMDBManager: NSObject {
    var db: FMDatabase? = nil
    func initTable(name: String) {
        let path = NSHomeDirectory().appending("/Documents/userBase/" + name + ".db")
        db = FMDatabase(path: path)
        guard let db = db  else {
            return
        }
        self.db = db
        var success = db.open(withFlags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
        
        let sql = "CREATE TABLE IF NOT EXISTS `note`(`title`, `text`, `time`, `author`, `group`)"
        success = db.executeUpdate(sql, withArgumentsIn: [String]())
        
        if !success {
            print("失败")
        }
        inset(table: name, title: "123", text: "123", time: "123", author: "123", group: "123")
        
    }
    
    func inset(table: String, title: String, text:String, time: String, author: String, group: String) {
        
        let sql = "INSERT INTO \(table) (`title`, `text`, `time`, `author`, `group`)VALUES(?,?,?,?,?)"
        guard let db = db else {
            return
        }
        let bool = db.executeUpdate(sql, withArgumentsIn: ["123","123","123","123","123"])
    }
}



struct LocationManager {
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
}
