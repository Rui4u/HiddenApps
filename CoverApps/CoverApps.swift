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
    @State var showAuthority = true
    
    var body: some Scene {
        WindowGroup {
            MainViewFactory(showAuthority: $showAuthority).mainView()
                .onAppear {
                  UINavigationController().navigationBar.backItem?.title = "Back"
                }
                .environment(\.locale, .init(identifier: "zh-Hans"))
//                .environment(\.locale, .init(identifier: "en"))
        }
        
    }
}


