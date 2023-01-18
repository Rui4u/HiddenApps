//
//  MainViewFactory.swift
//  CoverApps
//
//  Created by sharui on 2023/1/5.
//

import Foundation
import SwiftUI
import FamilyControls
import DeviceActivity

struct MainViewFactory {
    @ObservedObject var center = AuthorizationCenter.shared
    @ObservedObject var launchManager = LaunchManager.shared
    
    @ViewBuilder
    func mainView() -> some View{
        switch launchManager.launchType {
        case .main:
            MainView()
                .onAppear {
                    gotoRequestAuthorization()
                    ScreenLockManager.update()
                }
                .onReceive(launchManager.$updateAuthority) { bool in
                    gotoRequestAuthorization()
                }
                .onReceive(center.$authorizationStatus) { status in
                    launchManager.showAuthority = status == .approved
                }
            
        case .password:
            PasswordView(isShow: .constant(true), manager: launchManager.passManager)
            
        case .note:
            NoteListView()
        }
    }
    
    func gotoRequestAuthorization() {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
            } catch {
                launchManager.showAuthority = false
            }
        }
    }
}
