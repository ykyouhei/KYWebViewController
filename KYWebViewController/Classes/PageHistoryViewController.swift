//
//  PageHistoryViewController.swift
//  KYWebViewController
//
//  Created by 山口　恭兵 on 2015/12/30.
//  Copyright © 2015年 kyo__hei. All rights reserved.
//

import UIKit
import WebKit

internal protocol PageHistoryViewControllerDelegate: NSObjectProtocol {
    
    func pageHistoryViewController(
        _ viewController: PageHistoryViewController,
        didSelectItem backForwardListItem: WKBackForwardListItem)
    
}

internal final class PageHistoryViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds)
        tableView.dataSource = self
        tableView.delegate   = self
        return tableView
    }()
    
    internal weak var delegate: PageHistoryViewControllerDelegate?
    
    internal var backForwardListItems = [WKBackForwardListItem]() {
        didSet {
            guard isViewLoaded else { return }
            tableView.reloadData()
        }
    }
    
    internal func didTapCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[tableView]-0-|",
            options: [],
            metrics: nil,
            views: ["tableView" : tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[tableView]-0-|",
            options: [],
            metrics: nil,
            views: ["tableView" : tableView]))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(PageHistoryViewController.didTapCloseButton(_:)))
    }

}


extension PageHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backForwardListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let backForwardItem = backForwardListItems[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = backForwardItem.title
        cell.detailTextLabel?.text = backForwardItem.url.absoluteString
        
        return cell
    }
    
}


extension PageHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let backForwardItem = backForwardListItems[(indexPath as NSIndexPath).row]
        delegate?.pageHistoryViewController(self, didSelectItem: backForwardItem)
    }
    
}
