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
    @Binding var showAuthority: Bool
    
    @ViewBuilder
    func mainView() -> some View{
        switch launchManager.launchType {
        case .main:
            MainView(showIsAuthority: $showAuthority)
                .onAppear {
                    gotoRequestAuthorization()
                    ScreenLockManager.update()
                }
                .onReceive(launchManager.$updateAuthority) { bool in
                    gotoRequestAuthorization()
                }
                .onReceive(center.$authorizationStatus) { status in
                    showAuthority = status == .approved
                }
            
        case .password:
            PasswordView(showPassword: .constant(true), manager: launchManager.passManager)
            
        case .note:
            NoteListView()
        }
    }
    
    func gotoRequestAuthorization() {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
            } catch {
                showAuthority = false
            }
        }
    }
}
