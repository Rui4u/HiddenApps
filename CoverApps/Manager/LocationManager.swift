//
//  LocationManager.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/30.
//

import Foundation
import FMDB
import SQLite3

struct FMDBManager {
    let db: FMDatabase
    static func initTable(name: String) {
        NSHomeDirectory().append("Documents/userBase")
        db = FMDatabase(path: Path)
        let success = db.open(withFlags: :SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
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
