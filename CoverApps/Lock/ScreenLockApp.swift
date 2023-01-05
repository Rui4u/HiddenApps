//
//  ScreenLockApp.swift
//  ScreenLock
//
//  Created by sharui on 2022/12/27.
//

import SwiftUI
import FamilyControls
import DeviceActivity
import BackgroundTasks

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneWillEnterForeground(_ scene: UIScene) {
        LaunchManager.shared.updateAuthority = true;
    }
    
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // ...
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        LaunchManager.shared.showPasswordView = LaunchManager.shared.passManager.setPassword.maxCount == LaunchManager.shared.passManager.locationPassword.count
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
        BGTaskScheduler.shared.cancelAllTaskRequests()
            scheduleAppRefresh()
    }
    // ...
}

class AppDelegate:NSObject,UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        LaunchManager.shared.showPasswordView = LaunchManager.shared.passManager.setPassword.maxCount == LaunchManager.shared.passManager.locationPassword.count
        
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
        scheduleAppRefresh()
    }
    

    
    func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new refresh task.
        scheduleAppRefresh()
        
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

func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.hiddenApps.refresh")
    // Fetch no earlier than 15 minutes from now.
    request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)

    do {
        try BGTaskScheduler.shared.submit(request)
    } catch {
        print("Could not schedule app refresh: \(error)")
    }
}


@main
struct ScreenLockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @ObservedObject var center = AuthorizationCenter.shared
    let deviceActivityCenter = DeviceActivityCenter()
    @ObservedObject var launchManager = LaunchManager.shared
    @State var showAuthority = true
    var factory = MainViewFactory()
    
    var body: some Scene {
        
        WindowGroup {
            if (LaunchManager.shared.showPasswordView) {
                PasswordView(showPassword: $launchManager.showPasswordView, manager: launchManager.passManager)
            } else {
                if (LaunchManager.shared.type == .main) {
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
                    
                } else {
                    NoteListView()
                }
            }
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


