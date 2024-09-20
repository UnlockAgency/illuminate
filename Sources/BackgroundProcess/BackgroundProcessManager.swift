//
//  BackgroundProcessManager.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import BackgroundTasks
import Combine
import UIKit
import Logging

private struct Task: Equatable {
    let identifier: String
    let interval: TimeInterval
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

public class BackgroundProcessManager: BackgroundProcessService {
    private var cancellables = Set<AnyCancellable>()
    private var tasks: [Task] = []
    private let logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
        #if targetEnvironment(simulator)
        logger.warning("Cannot boot BackgroundProcessManager, unavailable in simulator", metadata: [ "service": "background" ])
        #else
        logger.debug("Booting BackgroundProcessManager...", metadata: [ "service": "background" ])
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.submitBackgroundTasks(delay: 10)
            }.store(in: &cancellables)
        #endif
    }
    
    public func cancelBackgroundTask(identifier: String) {
        logger.info("Unregistered background task with identifier '\(identifier)'", metadata: [ "service": "background" ])
        tasks.removeAll { $0.identifier == identifier }
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
    }
    
    public func registerBackgroundTask(identifier: String, interval: TimeInterval = 3600, handler: @escaping @Sendable (@escaping @Sendable (Error?) -> Void) -> Void) {
        let newTask = Task(identifier: identifier, interval: interval)
        if tasks.contains(newTask) {
            logger.warning("Already registered background task with identifier '\(identifier)'", metadata: [ "service": "background" ])
            return
        }
        tasks.append(newTask)
        logger.debug("Registering background task with identifier '\(identifier)'", metadata: [ "service": "background" ])
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { [weak self] task in
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
                self?.submitBackgroundTask(task: newTask)
            }
            self?.logger.debug("Scheduled background task '\(identifier)'", metadata: [ "service": "background" ])
            
            handler { error in
                task.setTaskCompleted(success: error == nil)
                self?.submitBackgroundTask(task: newTask)
            }
        }
    }
    
    private func submitBackgroundTasks(delay: TimeInterval) {
        for task in tasks {
            submitBackgroundTask(task: Task(identifier: task.identifier, interval: delay))
        }
    }
    
    private func submitBackgroundTask(task: Task) {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: task.identifier)
        
        let refreshTask = BGAppRefreshTaskRequest(identifier: task.identifier)
        refreshTask.earliestBeginDate = Date(timeIntervalSinceNow: task.interval)
        
        do {
            try BGTaskScheduler.shared.submit(refreshTask)
            logger.info("Succesfully registered background task '\(task.identifier)'. Interval: \(task.interval)s", metadata: [ "service": "background" ])
        } catch {
            logger.error("Error submitting background task '\(task.identifier)': \(error)", metadata: [ "service": "background" ])
        }
    }
}
