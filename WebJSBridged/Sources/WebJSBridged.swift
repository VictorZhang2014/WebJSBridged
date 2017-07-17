//
//  WebJSBridged.swift
//  WebJSBridged
//
//  Created by VictorZhang on 11/07/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

import UIKit
import JavaScriptCore

/**
 * All JavaScript methods should be implemented here
 * Developer has to implement the details of the methods
 **/
@objc class WebJSBridged: NSObject, WebJSExportBridge {

    /**
     * First Scenario
     * Only one method that JavaScript calls Swift method and gives a json string
     **/
    static func dispatchMessage(_ jsonStr: String) {
        WebJSBridged.postNotification(parameter: [ "params": jsonStr ], notificationName: WebJSExportBridgeNotification.webJSDispatchMessage)
    }
    
    
    
    
    /**
     * Second Scenario
     * Many JavaScript methods and Swift methods
     **/
//    dynamic var app_key: String
//    dynamic var app_secret: String
//    dynamic var app_authenticated: Bool
    
    static func webJSModifyTitle(_ title: String?) {
        let dict = [ "title": title ]
        self.postNotification(parameter: dict, notificationName: WebJSExportBridgeNotification.webJSModifyTitle)
    }
    
    class func webJSChooseImage() {
        self.postNotification(parameter: nil, notificationName: WebJSExportBridgeNotification.webJSChooseImage)
    }
    
    func webJSTakePhoto() {
        WebJSBridged.postNotification(parameter: nil, notificationName: WebJSExportBridgeNotification.webJSTakePhoto)
    }

    func webJSGetWiFiInfo() {
        WebJSBridged.postNotification(parameter: nil, notificationName: WebJSExportBridgeNotification.webJSGetWiFiInfo)
    }
    
    
    private static func postNotification(parameter userInfo : Dictionary<String, String?>?, notificationName name : String) {
        if userInfo != nil {
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil, userInfo: userInfo!)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil)
        }
    }
}

