//
//  ScreenLockApp.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/27.
//

import SwiftUI
import FamilyControls
import DeviceActivity

class AppDelegate:NSObject,UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        LaunchManager.shared.showPasswordView = LaunchManager.shared.passManager.setPassword.maxCount == LaunchManager.shared.passManager.locationPassword.count
        return true
    }
}


@main
struct ScreenLockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    let center = AuthorizationCenter.shared
    let deviceActivityCenter = DeviceActivityCenter()
    @ObservedObject var launchManager = LaunchManager.shared
    
    var body: some Scene {
        WindowGroup {
            if (LaunchManager.shared.showPasswordView) {
                PasswordView(showPassword: $launchManager.showPasswordView, manager: launchManager.passManager)
            } else {
                if (LaunchManager.shared.type == .main) {
                    MainView()
                        .onAppear {
                            Task {
                                do {
                                    try await center.requestAuthorization(for: .individual)
                                } catch {
                                    print(error)
                                }
                            }
                            ScreenLockManager.update()
                            
                        }
                } else {
                    Text("笔记")
                }
            }
        }
    }
}



