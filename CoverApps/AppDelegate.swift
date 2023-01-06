//
//  AppDelegate.swift
//  CoverApps
//
//  Created by sharui on 2023/1/5.
//

import UIKit
import BackgroundTasks

class AppDelegate:NSObject,UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        LaunchManager.updatePassword()
        FMDBManager().initTable(name: "note")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.hiddenApps.refresh", using: DispatchQueue.main) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
                
        return true
    }
    
    func application(_ application: UIApplication,  configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self // 👈🏻
        return sceneConfig
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        BGAppRefreshTool.scheduleAppRefresh()
    }
    

    
    func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new refresh task.
        BGAppRefreshTool.scheduleAppRefresh()
        
        LocationManager.save("测试", key: "test")
        // Create an operation that performs the main part of the background task.
        //       let operation = RefreshAppContentsOperation()
        //
        //       // Provide the background task with an expiration handler that cancels the operation.
        //       task.expirationHandler = {
        //          operation.cancel()
        //       }
        //
        //       // Inform the system that the background task is complete
        //       // when the operation completes.
        //       operation.completionBlock = {
        //          task.setTaskCompleted(success: !operation.isCancelled)
        //       }
        //
        //       // Start the operation.
        //       operationQueue.addOperation(operation)
    }
}

