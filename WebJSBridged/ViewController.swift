//
//  ViewController.swift
//  WebJSBridged
//
//  Created by VictorZhang on 11/07/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        let rect = self.view.frame
        
        let btnRect = CGRect(x: 5, y: (rect.size.height - 45) / 2, width: rect.size.width - 10, height: 45)
        self.createButton(title: "Start JS calls Swift methods each other", frame: btnRect, selector: #selector(ViewController.onStartJSCallsSwiftMethods))
    }
    
    func createButton(title: String, frame: CGRect, selector: Selector) {
        let button : UIButton = UIButton(frame: frame)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.addTarget(self, action: selector, for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func onStartJSCallsSwiftMethods() {
        let jsweb = WebJSViewController()
        let nav = UINavigationController(rootViewController: jsweb)
        self.present(nav, animated: true, completion: nil)
    }
    
    func onStartSwiftCallsJSMethods() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

