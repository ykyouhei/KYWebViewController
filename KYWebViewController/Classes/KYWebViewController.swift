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
    
    public var tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) {
        didSet { updateTintColors() }
    }
    
    public let historyNavigationController = UINavigationController()
    
    private var HTMLString: String?
    
    private var request: NSURLRequest?
    
    private var URL: NSURL?
    
    
    /* ====================================================================== */
    // MARK: - Outlet
    /* ====================================================================== */
    
    @IBOutlet private(set) weak var backButton: UIButton!
    
    @IBOutlet private(set) weak var forwardButton: UIButton!
    
    @IBOutlet private(set) weak var reloadBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private weak var toolBar: UIToolbar!
    
    
    /* ====================================================================== */
    // MARK: - Action
    /* ====================================================================== */
    
    @IBAction private func didTapBackButton(sender: UIButton) {
        wkWebView.goBack()
    }
    
    @IBAction private func didTapForwardButton(sender: UIButton) {
        wkWebView.goForward()
    }
    
    @IBAction private func didTapReloadButton(sender: UIBarButtonItem) {
        wkWebView.reload()
    }
    
    @IBAction private func handleRongPressGesture(sender: UILongPressGestureRecognizer) {
        guard let attachedView = sender.view where
            sender.state == .Began  else {
                return
        }
        
        var list = [WKBackForwardListItem]()
        
        switch attachedView {
        case backButton:    list = wkWebView.backForwardList.backList.reverse()
        case forwardButton: list = wkWebView.backForwardList.forwardList
        default:            return
        }
        
        let historyViewController = PageHistoryViewController()
        
        historyViewController.delegate = self
        historyViewController.backForwardListItems = list
        
        historyNavigationController.setViewControllers([historyViewController], animated: false)
        
        presentViewController(historyNavigationController, animated: true, completion: nil)
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
            backButton.enabled = wkWebView.canGoBack
            forwardButton.enabled = wkWebView.canGoForward
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
        wkWebView.stopLoading()
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
            backButton.enabled = wkWebView.canGoBack
            
        case KVOKeyPath.canGoForward:
            forwardButton.enabled = wkWebView.canGoForward
            
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
    
    private func updateTintColors() {
        view?.tintColor = tintColor
        
        backButton?.tintColor = tintColor
        forwardButton?.tintColor = tintColor
        reloadBarButtonItem?.tintColor = tintColor
        navigationController?.progressTintColor = tintColor
        navigationController?.navigationBar.tintColor = tintColor
        
        wkWebView.tintColor = tintColor
    }
    
}


extension KYWebViewController: PageHistoryViewControllerDelegate {
    
    func pageHistoryViewController(
        viewController: PageHistoryViewController,
        didSelectItem backForwardListItem: WKBackForwardListItem)
    {
        dismissViewControllerAnimated(true, completion: nil)
        
        let request = NSURLRequest(URL: backForwardListItem.URL)
        wkWebView.loadRequest(request)
    }
    
}
