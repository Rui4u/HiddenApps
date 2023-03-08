//
//  ScreenLockApp.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/27.
//

import SwiftUI
import FamilyControls
import DeviceActivity


@main
struct CoverApps: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @ObservedObject var center = AuthorizationCenter.shared
    @ObservedObject var launchManager = LaunchManager.shared
    var factory = MainViewFactory()
    var body: some Scene {
        WindowGroup {
            self.factory.mainView()
                .environmentObject(center)
                .environmentObject(launchManager)
                .onAppear {
                    
                  UINavigationController().navigationBar.backItem?.title = "Back"
                }
                .environment(\.locale, .init(identifier: "zh-Hans"))
//                .environment(\.locale, .init(identifier: "en"))
        }
        
    }
}


