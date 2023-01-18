//
//  MainView.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/27.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity
import Foundation
import StoreKit
struct MainView: View {
    @EnvironmentObject var center : AuthorizationCenter
    @EnvironmentObject var launchManager : LaunchManager
    @State private var selection: Tab = .featured
    enum Tab {
        case featured
        case setting
    }
    
    var body: some View {
        if (launchManager.showAuthority) {
            TabView(selection: $selection) {
                HomePage()
                    .tabItem{
                        Label("应用程序" , systemImage: "apps.iphone.badge.plus")
                    }
                    .tag(Tab.featured)
                
                SettingPage()
                    .tabItem {
                        Label("设置" , systemImage: "gear")
                    }
                    .tag(Tab.setting)
            }
            .onAppear {
                UITabBar.appearance().backgroundColor = .white
            }
            .accentColor(.blue) //设置文字默认选中颜色
        } else {
            Text("请授权")
        }
    }
}


