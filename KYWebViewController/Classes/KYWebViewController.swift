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
import MarkedView

public protocol KYWebViewControllerDelegate: class {
    
    func webViewController(
        _ webViewController: KYWebViewController,
        updatedEstimatedProgress progress: Double)
    
    func webViewController(
        _ webViewController: KYWebViewController,
        didChangeLoading loading: Bool)
    
}

open class KYWebViewController: UIViewController {
    
    /* ====================================================================== */
    // MARK: - Types
    /* ====================================================================== */
    
    public enum ContentsType {
        case html(htmlString: String)
        case request(request: URLRequest)
        case url(url: Foundation.URL)
        case markdown(markdownString: String)
    }
    
    fileprivate struct KVOKeyPath {
        static let estimatedProgress = "estimatedProgress"
        static let loading           = "loading"
        static let canGoBack         = "canGoBack"
        static let canGoForward      = "canGoForward"
    }
    
    /* ==============================s======================================== */
    // MARK: - Properties
    /* ====================================================================== */
    
    fileprivate let wkMarkedView: WKMarkedView = {
        return WKMarkedView()
    }()
    
    private var initialContentsType: ContentsType
    
    open var wkWebView: WKWebView {
        return self.wkMarkedView.subviews
            .filter { $0 is WKWebView }
            .first! as! WKWebView
    }
    
    public weak var delegate: KYWebViewControllerDelegate?
    
    public var navigationProgressEnabled = true
    
    public var shouldShowHistoryViewController = true
    
    public var tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) {
        didSet { updateTintColors() }
    }
    
    public let historyNavigationController = UINavigationController()
    
    private var HTMLString: String?
    
    private var request: URLRequest?
    
    private var URL: Foundation.URL?
    
    
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
    
    @IBAction private func didTapBackButton(_ sender: UIButton) {
        wkWebView.goBack()
    }
    
    @IBAction private func didTapForwardButton(_ sender: UIButton) {
        wkWebView.goForward()
    }
    
    @IBAction private func didTapReloadButton(_ sender: UIBarButtonItem) {
        wkWebView.reload()
    }
    
    @IBAction private func handleRongPressGesture(_ sender: UILongPressGestureRecognizer) {
        guard shouldShowHistoryViewController else { return }
        
        guard let attachedView = sender.view ,
            sender.state == .began  else {
                return
        }
        
        var list = [WKBackForwardListItem]()
        
        switch attachedView {
        case backButton:    list = wkWebView.backForwardList.backList.reversed()
        case forwardButton: list = wkWebView.backForwardList.forwardList
        default:            return
        }
        
        let historyViewController = PageHistoryViewController()
        
        historyViewController.delegate = self
        historyViewController.backForwardListItems = list
        
        historyNavigationController.setViewControllers([historyViewController], animated: false)
        
        present(historyNavigationController, animated: true, completion: nil)
    }
    
    
    /* ====================================================================== */
    // MARK: - initializer
    /* ====================================================================== */
    
    public init(initialContentsType: ContentsType) {
        let bundle = Bundle(for: KYWebViewController.self)
        self.initialContentsType = initialContentsType
        super.init(nibName: "KYWebViewController", bundle: bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /* ====================================================================== */
    // MARK: - View Life Cycle
    /* ====================================================================== */

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        
        defer {
            backButton.isEnabled = wkWebView.canGoBack
            forwardButton.isEnabled = wkWebView.canGoForward
        }
        
        wkMarkedView.frame = view.bounds
        wkMarkedView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(wkMarkedView, at: 0)
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[wkMarkedView]-0-|",
            options: [],
            metrics: nil,
            views: ["wkMarkedView" : wkMarkedView]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[wkMarkedView]-0-|",
            options: [],
            metrics: nil,
            views: ["wkMarkedView" : wkMarkedView]))
        
        switch initialContentsType {
        case .html(let HTMLString):
            wkWebView.loadHTMLString(HTMLString, baseURL: nil)
        
        case .request(let request):
            wkWebView.load(request)
            
        case .url(let NSURL):
            let request = URLRequest(url: NSURL)
            wkWebView.load(request)
            
        case .markdown(let markdownString):
            wkMarkedView.textToMark(markdownString)
        }
        
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let _ = toolBar.superview {
            wkWebView.scrollView.scrollIndicatorInsets.bottom = toolBar.frame.height
            wkWebView.scrollView.contentInset.bottom = toolBar.frame.height
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        wkWebView.stopLoading()
    }
    
    deinit {
        removeObservers()
    }
    
    
    /* ====================================================================== */
    // MARK: - KVO
    /* ====================================================================== */
    
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?)
    {
        guard let keyPath = keyPath else { return }
        
        switch keyPath {
        case KVOKeyPath.estimatedProgress:
            self.delegate?.webViewController(self, updatedEstimatedProgress: wkWebView.estimatedProgress)
            
            if navigationProgressEnabled {
                navigationController?.setProgress(Float(wkWebView.estimatedProgress), animated: true)
            }
        
        case KVOKeyPath.loading:
            guard !wkWebView.isLoading else { return }
            
            self.delegate?.webViewController(self, didChangeLoading: wkWebView.isLoading)
            
            if navigationProgressEnabled  {
                navigationController?.finishProgress()
            }
            
        case KVOKeyPath.canGoBack:
            backButton.isEnabled = wkWebView.canGoBack
            
        case KVOKeyPath.canGoForward:
            forwardButton.isEnabled = wkWebView.canGoForward
            
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
            options: .new,
            context: nil)
        wkWebView.addObserver(self,
            forKeyPath: KVOKeyPath.loading,
            options: .new,
            context: nil)
        wkWebView.addObserver(self,
            forKeyPath: KVOKeyPath.canGoBack,
            options: .new,
            context: nil)
        wkWebView.addObserver(self,
            forKeyPath: KVOKeyPath.canGoForward,
            options: .new,
            context: nil)
    }
    
    private func removeObservers() {
        wkWebView.removeObserver(self, forKeyPath: KVOKeyPath.estimatedProgress)
        wkWebView.removeObserver(self, forKeyPath: KVOKeyPath.loading)
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
        _ viewController: PageHistoryViewController,
        didSelectItem backForwardListItem: WKBackForwardListItem)
    {
        dismiss(animated: true, completion: nil)
        
        let request = URLRequest(url: backForwardListItem.url)
        wkWebView.load(request)
    }
    
}
