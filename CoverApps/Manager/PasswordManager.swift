//
//  PasswordManager.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/30.
//

import Foundation



class LaunchManager: ObservableObject {
    
    enum LaunchType {
        case main
        case note
        case password
    }
    @Published var updateAuthority: Bool = false
    @Published var isAuthority: Bool = true
    @Published var launchType : LaunchType = .main
    @Published var passManager = PasswordManager(type: .inputPassword)
    static let shared = LaunchManager()
    
    fileprivate init(type: LaunchType = .main, passManager: PasswordManager = PasswordManager(type: .inputPassword)) {
        self.launchType = type
        self.passManager = passManager
    }
    
    static func updatePassword() {
        if (shared.passManager.setPassword.maxCount == shared.passManager.locationPassword.count) {
            shared.launchType = .password
        }
    }
}

struct PasswordManager : Codable {
    struct SetPassword : Codable {
        enum Status:Codable {
            case first
            case second
            case error
            case inputError
            
            func title() -> String{
                switch self {
                case .first:
                    return "输入密码".myLocalizedString
                case .second:
                    return "确认密码".myLocalizedString
                case .error:
                    return "密码不一致，请重新输入".myLocalizedString
                case .inputError:
                    return "密码错误".myLocalizedString
                }
                
                
            }
        }
        var status: Status = .first
        var password1: String = ""
        var password2: String = ""
        var maxCount = 6
        func compair() -> Bool {
            return password1 == password2 && password1.count == maxCount
        }
    }
    
    enum ManagerType : Codable {
        case password
        case substitutePassword
        case inputPassword
    }
    var type : ManagerType
    var setPassword : SetPassword = SetPassword()
    var locationPassword: String {
        PasswordManager.loadLocatinPassword()
    }
    
    var locationSubstitutePassword: String {
        PasswordManager.loadLocatinSubstitutePassword()
    }
    
    
    static func loadLocatinPassword() -> String {
        if let locationPassword = LocationManager.find(String.self,key: "password") {
            return locationPassword
        }
        return ""
    }
    
    static func savePassword(_ password: String) {
        LocationManager.save(password, key: "password")
    }
    
    static func loadLocatinSubstitutePassword() -> String {
        if let locationPassword = LocationManager.find(String.self,key: "substitute_password") {
            return locationPassword
        }
        return ""
    }
    
    static func saveSubstitutePassword(_ password: String) {
        LocationManager.save(password, key: "substitute_password")
    }
    
    static func updatePasswordSwitch() -> (a: Bool, b:Bool) {
        let a = PasswordManager.loadLocatinPassword().count != 0
        var b = PasswordManager.loadLocatinSubstitutePassword().count != 0
        
        if !a {
            saveSubstitutePassword("")
            b = false
        }
        return (a, b)
    }
}
