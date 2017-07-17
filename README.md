# WebJSBridged
A project that provides the interaction between Swift and JavaScript methods with an easily way

We see two figures in advance.
<br/>
![WebJSBridged Figure Photo 1](https://github.com/VictorZhang2014/WebJSBridged/blob/master/Images/WebJSBridged_Figure_1.gif "WebJSBridged_Figure_1")
![WebJSBridged Figure Photo 2](https://github.com/VictorZhang2014/WebJSBridged/blob/master/Images/WebJSBridged_Figure_2.jpg "WebJSBridged_Figure_2")


## Target
```
1. JavaScript methods call Swift methods
2. Swift methods call JavaScript Methods
```

## JavaScriptCore Brief
This narration is covering JavaScriptCore.framework, and it's based on How to call JavaScript methods in Swift or How to call Swift methods in JavaScript？

#### JSVirtualMachine
A JSVirtualMachine is the self-contained environment within which your JavaScript code executes. It has two purposes.

>1. To allow you to run code in separate threads concurrently 
>2. To allow you to clean up memory you allocate when bridging between Objective-C/Swift and JavaScript.

Eveything you do in JavaScript ultimately executes in a JSVirtualMachine. When you need to create separate threads, you also need to create a new JSVirtualMachine for each thread. Because the JavaScriptCore.framework is thread safe, any attempts to access code running in a JSVirtualMachine from a separate thread will wait util the initial thread is finished. If you had created a background thread for this purpose, you would not get the results you expected.

As for memory issues — the second purpose — the JSVirtualMachine gives you a mechanism to free memory when you are done with an object. You will create a retain cycle anytime you export a Swift/Objective C object to JavaScript and store the value, which is bad news. You also can get a retain cycle when storing JavaScript values in native objects (Swift/Objective C). Retain cycles can occur because a JSValue maintains a strong reference in order to access the underlying JavaScript value on the native side. Similarly, a JSContext maintains a strong reference to any Swift/Objective C object you pass to JavaScript. Therefore, you need to use JSVirtualMachine’s removeManagedReference:withOwner method to clean up memory when you’re done with your objects. In addition, you should use a JSManagedValue object when you need to conditionally store a JSValue on the native side. The JavaScript garbage collector will only clean up objects after you remove references to all managed objects.

#### JSContext
A JSContext is your JavaScript execution environment, and it is very similar to the window object for a web browser. Everything that you add to this context is accessible by any other object in the same context. This, essentially, is your sandbox for controlling the scope of your JavaScript variables, functions, and objects. You can evaluate scripts written in JavaScript or Objective C/Swift, access values in the JavaScript environment, or send values and objects to JavaScript from Objective C/Swift using the JSContext.

#### JSValue
A JSValue is the wrapper to an underlying JavaScript value. Its the bridge that allows you to pass or share data between JavaScript and Objective C/Swift. A JSValue has a strong reference to the JSContext to which it belongs. As a word of caution, you need to remember that you can cause a retain cycle if you store the JSValue in Swift/Objective C object. In addition to accessing underlying JavaScript objects, you can use a JSValue to create JavaScript objects that are wrappers to native objects in Swift/Objective C. You can also use them to create JavaScript functions that are written in Objective C/Swift.

#### JSManagedValue
A JSManagedValue is a JSValue with additional logic to allow a native object to store the underlying JavaScript value without causing a retain cycle. There is built in memory management to automatically release objects when they lose scope, which is similar to how ARC works for Objective C. A JSManagedValue will live on under two conditions: 1) its value is still part of the underlying JavaScript object graph or 2) It’s been added to the JSVirtualMachine using `addManagedReference:withOwner` method and has not been removed using the `removeManagedReference:withOwner` method. Otherwise, the JSManagedValue gets set to nil, releasing the JSValue, and is free to be garbage-collected on the JavaScript side.

#### JSExport 
A JSValue can represent and convert all of the JavaScript builtin types to Objective C/Swift and can convert them in the other direction to JavaScript types. However, a JSValue can’t convert Objective C/Swift classes to JavaScript objects without help. The JSExport protocol provides a way to convert Swift/Objective C classes and their underlying instance methods, class functions, and properties into JavaScript objects.
By default when using JSValues, JavascriptCore will convert a Swift/Objective C class into JavaScript object but will not populate instance methods, class functions, or properties. You have to choose which of these you want to expose to JavaScript in your JSExport protocol definition.

#### JavaScriptCore in Practice
Now that we have described each of the classes and protocols in the JavaScriptCore library, its time to put them to use with some examples.

#### Setup
Our first step is to create a JSVirtualMachine instance along with a JSContext instance. If you don’t intend to use concurrent operations via threading, you can skip creating a JSVirtualMachine and just create a JSContext with an empty constructor so a JSVirtualMachine will be created for you. Otherwise, you should create and save a JSVirtualMachine instance and pass that as an argument when creating your JSContext instances.
```
let virtualMachine = JSVirtualMachine()
let context = JSContext(virtualMachine: virtualMachine)
```

#### Calling Functions and Evaluating Scripts
In a UIWebView, you loaded a url, no mater it's local url or remote.

1.How to call Swift methods in JavaScript？
The answer is that you have to get a JSContext instance, for example, in this method of 
`func webViewDidFinishLoad(_ webView: UIWebView)`, 
you have to 
`self.context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext`;
And now, `self.context` is referring to the JS environment, and you can use this to evaluate js code or give a instance to JavaScript environment.

Then, you did this `self.context.setObject(WebJSBridged.self, forKeyedSubscript: "WebJSBridgedContext" as NSCopying & NSObjectProtocol)` which means you can use `WebJSBridgedContext` to call static Swift methods and properties in the JavaScript environment.

Then, you did this `let webJSInstance = WebJSBridged()
            self.context.setObject(unsafeBitCast(webJSInstance, to: AnyObject.self), forKeyedSubscript: "WebJSBridgedContextInstance" as NSCopying & NSObjectProtocol)` which means you can use `WebJSBridgedContextInstance` to call Swift instance methods and properties in the JavaScript environment.

2.How to call JavaScript methods in Swift
The answer is that using `evaluateScript`, for example, you have to respond to JavaScript callback
, so the snippet code is 
`let res = "{\"callbackId\":\"\(callbackId)\"}"
            self.context.evaluateScript("window.wbjs.respondMessage(\(res))")`
Amongest, `wbjs` is an object that injects in JavaScript, method `respondMessage` is the JavaScript Method that Swift to call.


#### The properties or methods you want to expose to JavaScript
First, you have to create a contact object and a JSExports protocol that outlines what we want exposing to JavaScript. After that we need to use the `setObject` method of our JSContext to make our contact object accessible in JavaScript. The above has been described.

Here is the code of this project, I gave two scenario to you. First is that you're implementing the logic code just within one Swift method; Second is that you're implementing the logic method in Swift and JavaScript, if you're confused, let's see it below.


This is the methods you want to expose to JavaScript,
```
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
```

This the implemented class of JSExport protocol. Every time it received a request and push the parameters to another Controller to handle it.
```
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
```

In the `viewDidLoad()` observing this Notifications
```
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSDispatchMessage), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSDispatchMessage), object: nil)
        

        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSModifyTitle), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSModifyTitle), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSChooseImage), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSChooseImage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSTakePhoto), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSTakePhoto), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WebJSViewController.webJSGetWiFiInfo), name: Notification.Name(rawValue: WebJSExportBridgeNotification.webJSGetWiFiInfo), object: nil)
    }
```

Take `webJSDispatchMessage` for example, below is the code.
We received this request and parameters, via analyzing and checking, we responded to JavaScript is snippet code is `self.context.evaluateScript("window.wbjs.respondMessage(\(res))")`, `respondMessage` is a JavaScript method which handles its callback.

```
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
```

For more details of using JavaScriptCore, please follow this project and download , run it in your Xcode, you will find it's easy to use than you thought.

<br/>
<br/>
Reference Link 1: https://medium.com/swift-programming/from-swift-to-javascript-and-back-fd1f6a7a9f46
Reference Link 2: http://nshipster.com/javascriptcore/
