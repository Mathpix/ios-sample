//
//  WebViewController.swift
//  MathPix
//
//  Created by Michael Lee on 4/3/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

import UIKit
import JavaScriptCore


class PreviewWebViewController: UIViewController {
    
    var jsonString: String? {
        didSet {
            if (isLoaded == true) && (isViewLoaded){
                updateLatexFromJSONString(jsonString)
            }
        }
    }
    
    var isLoaded: Bool = false
    var jsContext : JSContext!
    let webView = UIWebView()
    
    fileprivate func url() -> URL {
        var urlPath = "www/latex.html"
        
        let bundle = Bundle.main
        if let bundlePath = bundle.path(forResource: urlPath, ofType: nil) {
            urlPath = bundlePath
        }
        return URL(string: urlPath)!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    
    // MARK: - Setup Methods
    
    fileprivate func setupView() {
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        view.addSubview(webView)
        webView.autoPinEdge(.leading, to: .leading, of: self.view)
        webView.autoPinEdge(.trailing, to: .trailing, of: self.view)
        webView.autoPin(toTopLayoutGuideOf: self, withInset: 0)
        webView.autoPin(toBottomLayoutGuideOf: self, withInset: 0)
        webView.backgroundColor = UIColor.white
        webView.delegate = self
        
        let requestObj = URLRequest(url: self.url())
        webView.loadRequest(requestObj)
        
        // enable javascript logging to console
        jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        setupCallbackFunctions()
    }
    
    
    fileprivate func setupCallbackFunctions() {
        let logFunction : @convention(block) (String) -> Void =
            {
                (msg: String) in
                NSLog("Console: %@", msg)
        }
        jsContext.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self), forKeyedSubscript: "log" as (NSCopying & NSObjectProtocol)!)
    }
    
    // MARK: - JS Methods
    
    
    func updateLatexFromJSONString(_ jsonString: String?) {
        var methodInvocation: String
        if let jsonString = jsonString {
            methodInvocation = "\(JSMethodInvocation.addResultJson(jsonString))"
            webView.stringByEvaluatingJavaScript(from: methodInvocation)
            NSLog(methodInvocation)
        }
    }
    
}

// MARK: - UIWebViewDelegate

extension PreviewWebViewController : UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        isLoaded = true
        updateLatexFromJSONString(jsonString)
    }
    
}

























