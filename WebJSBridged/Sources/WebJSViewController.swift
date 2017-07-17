//
//  WebJSViewController.swift
//  WebJSBridged
//
//  Created by VictorZhang on 11/07/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

import UIKit
import JavaScriptCore
import SystemConfiguration.CaptiveNetwork

class WebJSViewController: UIViewController, UIWebViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var _webView : UIWebView!
    private var _hasRegisteredContext : Bool = false
    var context : JSContext = JSContext()
    
    
    var _url : String?
    var _fileName : String?
    var _fileFormat : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createWebView()

        
        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSDispatchMessage), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSDispatchMessage), object: nil)
        

        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSModifyTitle), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSModifyTitle), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSChooseImage), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSChooseImage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSTakePhoto), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSTakePhoto), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSGetWiFiInfo), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSGetWiFiInfo), object: nil)
        
    }
    
    func createWebView() {
        _webView = UIWebView(frame: self.view.frame)
        _webView.delegate = self
    
        if _url != nil && (_url?.lengthOfBytes(using: String.Encoding.utf8))! > 0 {
            self.loadUrl()
        } else if (_fileName != nil && (_fileName?.lengthOfBytes(using: String.Encoding.utf8))! > 0 &&
            _fileFormat != nil && (_fileFormat?.lengthOfBytes(using: String.Encoding.utf8))! > 0) {
            self.loadLocalHtml(fileName: _fileName!, ofType: _fileFormat!)
        } else {
            self.loadLocalHtml(fileName: "Index", ofType: "html")
        }
    }
    
    func loadUrl() {
        let _baseUrl = URL(string: _url!)
        let _request = URLRequest(url: _baseUrl!)
        _webView.loadRequest(_request)
    }
    
    func loadLocalHtml(fileName: String, ofType: String) {
        let htmlpath = Bundle.main.path(forResource: fileName, ofType: ofType)
        var htmlcode : String = ""
        do {
            try htmlcode = String(contentsOfFile: htmlpath!, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
        let basePath = Bundle.main.bundlePath
        let baseURL = URL(fileURLWithPath: basePath)
        _webView.loadHTMLString(htmlcode, baseURL: baseURL)
        self.view.addSubview(_webView)
    }

    
    // UIWebViewDelegate Events
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if !_hasRegisteredContext {
            
            // 1. Get the context instance from JavaScript Execution Environment
            self.context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
            
            //
            let helloWorld: @convention(block) () ->() = {
                print("This is a block and its method called helloWorld()")
            }
            self.context.setObject(unsafeBitCast(helloWorld, to: AnyObject.self), forKeyedSubscript: "helloWorld" as NSCopying & NSObjectProtocol)
            
            // WebJSBridged is a contact object that we want to expose to JavaScript
            self.context.setObject(WebJSBridged.self, forKeyedSubscript: "WebJSBridgedContext" as NSCopying & NSObjectProtocol)
            
            // webJSInstance is an instance of WebJSBridged which is a contact object that we want to expose to JavaScript too
            let webJSInstance = WebJSBridged()
            self.context.setObject(unsafeBitCast(webJSInstance, to: AnyObject.self), forKeyedSubscript: "WebJSBridgedContextInstance" as NSCopying & NSObjectProtocol)
            
            
            
            _hasRegisteredContext = true
        }
    }
    
    
    /**
     * First Scenario
     **/
    func webJSDispatchMessage(noti: Notification?) {
        let userInfo = noti?.userInfo
        if userInfo != nil {
            let jsonAny = userInfo?["params"]
            let jsonStr = jsonAny as! String
            print("jsonStr=\(jsonStr)")
            
            let data = jsonStr.data(using: String.Encoding.utf8)!
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            let dict = json as! Dictionary<String, AnyObject>
            
            let api_name = dict["api_name"] as! String
            let appKey = dict["appKey"] as! String
            let appSecret = dict["appSecret"] as! String
            let callbackId = dict["callbackId"] as! String
            
            
            // To do some thing and corresponding actions
            
            // And next, given the response to JavaScript
            
            
            let res = "{\"callbackId\":\"\(callbackId)\"}"
            self.context.evaluateScript("window.wbjs.respondMessage(\(res))")
        }
    }
    

    /**
     * Second Scenario
     **/
    func webJSModifyTitle(noti: Notification?) {
        let userInfo = noti?.userInfo
        if userInfo != nil {
            self.navigationItem.title = userInfo!["title"] as? String
        }
    }
    
    func webJSChooseImage(noti: Notification?) {
        let imagePicker : UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func webJSTakePhoto(noti: Notification?) {
        let imagePicker : UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func webJSGetWiFiInfo(noti: Notification?) {
        guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
            print("this must be a simulator, no interfaces found")
            return
        }
        guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
            print("System error: did not come back as array of Strings")
            return
        }
        for interface in swiftInterfaces {
            print("Looking up SSID info for \(interface)") // en0
            guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface as CFString) else {
                print("System error: \(interface) has no information")
                return
            }
            guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: AnyObject] else {
                print("System error: interface information is not a string-keyed dictionary")
                return
            }
            
            let ssid = SSIDDict["SSID"]!
            let bssid = SSIDDict["BSSID"]!
            let ssiddata = SSIDDict["SSIDDATA"]!
            let ssiddatastr = NSString(data: ssiddata as! Data, encoding: String.Encoding.utf8.rawValue)
            
            let res = "{\"ssid\":\"\(ssid)\",\"bssid\":\"\(bssid)\",\"ssiddata\":\"\(String(describing: ssiddatastr))\"}"
            self.context.evaluateScript("window.WebJSCallbackHandlers.getWiFiInfoRespond(\(res))")
            
            return
        }
    }

    
    // UIImagePickerControllerDelegate events
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image : UIImage
        if picker.sourceType == UIImagePickerControllerSourceType.camera {
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        } else {
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        }
        
        let imageData : Data = UIImagePNGRepresentation(image)!
        var base64String = imageData.base64EncodedString()
            base64String = "data:image/png;base64," + base64String
        
        
        if picker.sourceType == UIImagePickerControllerSourceType.camera {
            self.context.evaluateScript("window.WebJSCallbackHandlers.takePhotoRespond(\"\(base64String)\")")
        } else {
            self.context.evaluateScript("window.WebJSCallbackHandlers.chooseImageRespond(\"\(base64String)\")")
        }
        
        picker .dismiss(animated: true, completion: nil)
    }
    
}
