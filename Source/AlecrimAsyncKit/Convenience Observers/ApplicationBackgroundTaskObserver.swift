//
//  ApplicationBackgroundTaskObserver.swift
//  AlecrimAsyncKit
//
//  Created by Vanderlei Martinelli on 2015-09-06.
//  Copyright © 2015 Alecrim. All rights reserved.
//

#if os(iOS)

import Foundation

/// A task observer that will automatically begin and end a *background task* if the application transitions to the background.
public final class ApplicationBackgroundTaskObserver: TaskObserver {
    
    private let application: UIApplication
    private var isInBackground = false
    private var identifier = UIBackgroundTaskInvalid

    /// Initializes a task observer that will automatically begin and end a *background task* if the application transitions to the background.
    ///
    /// - parameter application: The application instance.
    ///
    /// - returns: A task observer that will automatically begin and end a *background task* if the application transitions to the background.
    ///
    /// - note: Usually you will pass `UIApplication.sharedApplication()` as parameter. This is needed because the framework is marked to allow app extension API only.
    /// - note: The *"background task"* term as used here is in the context of of `UIApplication`. In this observer it will be related but it is not the same as `Task<V>` or `NonFailableTask<V>`.
    public init(application: UIApplication) {
        //
        self.application = application
        
        //
        super.init()
        
        // We need to know when the application moves to/from the background.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
     
        //
        self.isInBackground = self.application.applicationState == .Background
        
        // If we're in the background already, immediately begin the *background task*.
        if self.isInBackground {
            self.startBackgroundTask()
        }

        //
        self.didFinish { [unowned self] _ in
            self.endBackgroundTask()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    private func startBackgroundTask() {
        if self.identifier == UIBackgroundTaskInvalid {
            self.identifier = self.application.beginBackgroundTaskWithName("AAK.ABTO." + NSUUID().UUIDString, expirationHandler: {
                self.endBackgroundTask()
            })
        }
    }
    
    private func endBackgroundTask() {
        if self.identifier != UIBackgroundTaskInvalid {
            self.application.endBackgroundTask(self.identifier)
            self.identifier = UIBackgroundTaskInvalid
        }
    }
    
    @objc private func didEnterBackground(notification: NSNotification) {
        if !self.isInBackground {
            self.isInBackground = true
            self.startBackgroundTask()
        }
    }
    
    @objc private func didBecomeActive(notification: NSNotification) {
        if self.isInBackground {
            self.isInBackground = false
            self.endBackgroundTask()
        }
    }

}

#endif