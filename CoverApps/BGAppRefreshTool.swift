//
//  BGAppRefreshTool.swift
//  CoverApps
//
//  Created by sharui on 2023/1/5.
//

import UIKit
import BackgroundTasks
class BGAppRefreshTool: NSObject {
    static func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.hiddenApps.refresh")
        // Fetch no earlier than 15 minutes from now.
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
