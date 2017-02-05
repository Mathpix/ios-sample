//
//  ApplicationController.swift
//  MathPix
//
//  Created by Sergey Glushchenko on 7/11/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

import UIKit

final class ApplicationController {
    
    fileprivate static let applicationUserDefaults = UserDefaults.standard
    
    fileprivate static let syncKey = "syncKey"
    fileprivate static let syncEnabledKey = "syncEnabledKey"
    fileprivate static let autoCaptureEnabledKey = "autoCaptureEnabledKey"
    
    class var syncId: String? {
        set {
            applicationUserDefaults.set(newValue, forKey: syncKey)
            applicationUserDefaults.synchronize()
        }
        get {
            return applicationUserDefaults.object(forKey: syncKey) as? String
        }
    }
    
    class var syncEnabled: Bool {
        set {
            applicationUserDefaults.set(newValue, forKey: syncEnabledKey)
            applicationUserDefaults.synchronize()
        }
        get {
            return applicationUserDefaults.bool(forKey: syncEnabledKey)
        }
    }
    
    class var autoCaptureEnabled: Bool {
        set {
            applicationUserDefaults.set(newValue, forKey: autoCaptureEnabledKey)
            applicationUserDefaults.synchronize()
        }
        get {
            return applicationUserDefaults.bool(forKey: autoCaptureEnabledKey)
        }
    }

}
