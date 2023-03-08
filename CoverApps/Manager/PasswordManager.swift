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
    
    static let shared = LaunchManager()
    
    @Published var updateAuthority: Bool = false
    @Published var isAuthority: Bool = true
    @Published var launchType : LaunchType = .main
    @Published var passManager = PasswordManager(type: .inputPassword)
    @Published var showAuthority: Bool = false
    
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

class PasswordManager : ObservableObject {
    struct SetPassword : Codable {
        enum Status:Codable {
            case first
            case second
            case error
            case inputError
            
            func title() -> String{
                switch self {
                case .first:
                    return "输入密码"
                case .second:
                    return "确认密码"
                case .error:
                    return "密码不一致，请重新输入"
                case .inputError:
                    return "密码错误"
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
    
    @Published var password : String = ""
    @Published var isPresent = false
    @Published var attempts: Int = 0
    
    var type : ManagerType
    var setPassword : SetPassword = SetPassword()
    
    var locationPassword: String { PasswordManager.loadLocatinPassword() }
    var locationSubstitutePassword: String { PasswordManager.loadLocatinSubstitutePassword() }
    

    init(type: ManagerType) {
        self.type = type
    }
    
    func reset() {
        self.password = ""
        self.setPassword = SetPassword()
    }
   
    static func loadLocatinPassword() -> String {
        guard let locationPassword = LocationManager.find(String.self,key: "password") else {
            return ""
        }
        return locationPassword
    }
    
    static func savePassword(_ password: String) {
        LocationManager.save(password, key: "password")
    }
    
    static func loadLocatinSubstitutePassword() -> String {
        guard let locationPassword = LocationManager.find(String.self,key: "substitute_password") else {
            return ""
        }
        return locationPassword
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
    
    func passwordInputStatus(_ newValue: String) {
        if (newValue.count > 6) {
            password = String(newValue.dropFirst(0).prefix(6))
            return
        }
        
        if type == .substitutePassword || type == .password {
            if (newValue.count == 6 && setPassword.status == .first) {
                setPassword.password1 = newValue
                setPassword.status = .second
                password = ""
            } else if newValue.count == 6 && setPassword.status == .second {
                setPassword.password2 = newValue
                if (setPassword.compair()) {
                    if type == .password {
                        PasswordManager.savePassword(newValue)
                    } else if type == .substitutePassword {
                        PasswordManager.saveSubstitutePassword(newValue)
                    }
                    
                    isPresent = false
                } else {
                    attempts += 1
                    setPassword.status = .error
                    password = ""
                }
            } else if password.count > 0 && setPassword.status == .error {
                setPassword.status = .second
            }
        } else if type == .inputPassword {
            if (newValue.count == 6) {
                if newValue == locationPassword {
                    isPresent = false
                    password = ""
                    LaunchManager.shared.launchType = .main
                } else if newValue == locationSubstitutePassword {
                    isPresent = false
                    LaunchManager.shared.launchType = .note
                    password = ""
                } else {
                    attempts += 1
                    setPassword.status = .inputError
                    password = ""
                }
            } else if password.count > 0 && setPassword.status == .inputError  {
                setPassword.status = .first
            }
        }
    }
}
