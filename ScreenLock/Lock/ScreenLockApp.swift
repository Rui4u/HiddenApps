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
        print("I am back")
        return true
    }
}


@main
struct ScreenLockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    let center = AuthorizationCenter.shared
    let deviceActivityCenter = DeviceActivityCenter()
    var body: some Scene {
        WindowGroup {
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
        }
    }
}


