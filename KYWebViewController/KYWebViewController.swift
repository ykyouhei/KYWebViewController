//
//  KYWebViewController.swift
//  KYWebViewController
//
//  Created by 山口　恭兵 on 2015/12/30.
//  Copyright © 2015年 kyo__hei. All rights reserved.
//

import UIKit
import WebKit
import KYNavigationProgress

public final class KYWebViewController: UIViewController {
    
    /* ====================================================================== */
    // MARK: - Types
    /* ====================================================================== */
    
    private struct KVOKeyPath {
        static let estimatedProgress = "estimatedProgress"
        static let canGoBack         = "canGoBack"
        static let canGoForward      = "canGoForward"
    }
    
    /* ====================================================================== */
    // MARK: - Properties
    /* ====================================================================== */
    
    public let wkWebView: WKWebView = WKWebView()
    
    private var HTMLString: String?
    
    private var request: NSURLRequest?
    
    private var URL: NSURL?
    
    
    /* ====================================================================== */
    // MARK: - Outlet
    /* ====================================================================== */
    
    @IBOutlet private(set) weak var backBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private(set) weak var forwardBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private(set) weak var reloadBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private weak var toolBar: UIToolbar!
    
    
    /* ====================================================================== */
    // MARK: - Action
    /* ====================================================================== */
    
    @IBAction private func didTapBackButton(sender: UIBarButtonItem) {
        wkWebView.goBack()
    }
    
    @IBAction private func didTapForwardButton(sender: UIBarButtonItem) {
        wkWebView.goForward()
    }
    
    @IBAction private func didTapReloadButton(sender: UIBarButtonItem) {
        wkWebView.reload()
    }
    
    
    
    /* ====================================================================== */
    // MARK: - initializer
    /* ====================================================================== */
    
    public convenience init() {
        let bundle = NSBundle(forClass: KYWebViewController.self)
        self.init(nibName: "KYWebViewController", bundle: bundle)
    }
    
    public convenience init(HTMLString: String) {
        self.init()
        self.HTMLString = HTMLString
    }
    
    public convenience init(request: NSURLRequest) {
        self.init()
        self.request = request
    }
    
    public convenience init(URL: NSURL) {
        self.init()
        self.URL = URL
    }
    
    
    /* ====================================================================== */
    // MARK: - View Life Cycle
    /* ====================================================================== */

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        defer {
            backBarButtonItem.enabled = wkWebView.canGoBack
            forwardBarButtonItem.enabled = wkWebView.canGoForward
        }
        
        wkWebView.frame = view.bounds
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(wkWebView, atIndex: 0)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[wkWebView]-0-|",
            options: [],
            metrics: nil,
            views: ["wkWebView" : wkWebView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[wkWebView]-0-|",
            options: [],
            metrics: nil,
            views: ["wkWebView" : wkWebView]))
        
        addObservers()
        
        if let HTMLString = HTMLString {
            wkWebView.loadHTMLString(HTMLString, baseURL: nil)
            return
        }
        
        if let request = request {
            wkWebView.loadRequest(request)
            return
        }
        
        if let URL = URL {
            let request = NSURLRequest(URL: URL)
            wkWebView.loadRequest(request)
            return
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let _ = toolBar.superview {
            wkWebView.scrollView.scrollIndicatorInsets.bottom = toolBar.frame.height
            wkWebView.scrollView.contentInset.bottom = toolBar.frame.height
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
    }
    
    
    /* ====================================================================== */
    // MARK: - KVO
    /* ====================================================================== */
    
    public override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>)
    {
        guard let keyPath = keyPath else { return }
        
        switch keyPath {
        case KVOKeyPath.estimatedProgress:
            guard navigationController?.progress < 1.0 else {
                navigationController?.finishProgress()
                return
            }
            navigationController?.setProgress(Float(wkWebView.estimatedProgress), animated: true)
            
        case KVOKeyPath.canGoBack:
            backBarButtonItem.enabled = wkWebView.canGoBack
            
        case KVOKeyPath.canGoForward:
            forwardBarButtonItem.enabled = wkWebView.canGoForward
            
        default:
            break
        }
    }

    
    /* ====================================================================== */
    // MARK: - Private Method
    /* ====================================================================== */
    
    private func addObservers() {
        wkWebView.addObserver(self,
            forKeyPath: KVOKeyPath.estimatedProgress,
            options: .New,
            context: nil)
        wkWebView.addObserver(self,
            forKeyPath: KVOKeyPath.canGoBack,
            options: .New,
            context: nil)
        wkWebView.addObserver(self,
            forKeyPath: KVOKeyPath.canGoForward,
            options: .New,
            context: nil)
    }
    
    private func removeObservers() {
        wkWebView.removeObserver(self, forKeyPath: KVOKeyPath.estimatedProgress)
        wkWebView.removeObserver(self, forKeyPath: KVOKeyPath.canGoBack)
        wkWebView.removeObserver(self, forKeyPath: KVOKeyPath.canGoForward)
    }
    
}