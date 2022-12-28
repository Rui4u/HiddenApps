//
//  ScreenLockApp.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/27.
//

import SwiftUI
import FamilyControls
import DeviceActivity

extension DeviceActivityName{
    static let activity = Self("activity")
}
@main
struct ScreenLockApp: App {
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
                _ = ScreenLockManager.group()
            }
        }
    }
}



