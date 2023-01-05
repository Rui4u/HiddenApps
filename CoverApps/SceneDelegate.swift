//
//  SceneDelegate.swift
//  CoverApps
//
//  Created by sharui on 2023/1/5.
//

import UIKit
import BackgroundTasks

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneWillEnterForeground(_ scene: UIScene) {
        LaunchManager.shared.updateAuthority = true;
        LaunchManager.updatePassword()
    }
    
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // ...
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        LaunchManager.updatePassword()
        BGTaskScheduler.shared.cancelAllTaskRequests()
        BGAppRefreshTool.scheduleAppRefresh()
    }
}
