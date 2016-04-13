//
//  PreferenceManager.swift
//  iHosts
//
//  Created by Jason Zheng on 4/9/16.
//  Copyright © 2016 Toolinbox.net. All rights reserved.
//

import Foundation

class PreferenceManager {
  // Single instance
  static let sharedInstance = PreferenceManager()
  
  private init() {
    registerFactoryDefaults()
  }
  
  let userDefaults = NSUserDefaults.standardUserDefaults()
  
  private let initializedKey = "Initialized"
  private let tabViewSizesKey = "Preferences Tab View Sizes"
  
  private let defaultTabViewSizes = [String: SizeArchiver]()
  
  var initialized: Bool {
    get {
      return userDefaults.boolForKey(initializedKey)
    }
    
    set {
      userDefaults.setBool(newValue, forKey: initializedKey)
    }
  }
  
  var tabViewSizes: [String: SizeArchiver] {
    get {
      if let data = userDefaults.objectForKey(tabViewSizesKey) as? NSData {
        if let sizes = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: SizeArchiver] {
          return sizes
        }
      }
      
      return defaultTabViewSizes
    }
    
    set {
      let data = NSKeyedArchiver.archivedDataWithRootObject(newValue)
      userDefaults.setObject(data, forKey: tabViewSizesKey)
    }
  }
  
  func registerFactoryDefaults() {
    let factoryDefaults = [
      initializedKey: NSNumber(bool: false),
      tabViewSizesKey: defaultTabViewSizes,
    ]
    
    userDefaults.registerDefaults(factoryDefaults)
  }
  
  func synchronize() {
    userDefaults.synchronize()
  }
  
  func reset() {
    
  }
}
