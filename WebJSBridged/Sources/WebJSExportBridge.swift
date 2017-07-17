//
//  WebJSExportBridge.swift
//  WebJSBridged
//
//  Created by VictorZhang on 13/07/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

import Foundation
import JavaScriptCore

/**
 * All methods that Javascript can call that should be declared here, it's only a declaration
 **/
@objc protocol WebJSExportBridge: JSExport {
    
    /**
     * First Scenario
     * Only one method that JavaScript calls Swift method and gives a json string
     **/
    static func dispatchMessage(_ jsonStr: String)
    
    
    
    /**
     * Second Scenario
     * Many JavaScript methods and Swift methods
     **/
//    var app_key: String { get set }
//    var app_secret: String { get set }
//    var app_authenticated: Bool { get set }
    
    static func webJSModifyTitle(_ title: String?)
    
    static func webJSChooseImage()

    func webJSTakePhoto()

    func webJSGetWiFiInfo()
}



public class WebJSExportBridgeNotification {
    
    static let webJSDispatchMessage = "NotificationWebJSDispatchMessage"
    
    static let webJSModifyTitle = "NotificationWebJSModifyTitle"
    
    static let webJSChooseImage = "NotificationWebJSChooseImage"
    
    static let webJSTakePhoto = "NotificationWebJSTakePhoto"
    
    static let webJSGetWiFiInfo = "NotificationWebJSGetWiFiInfo"
}


