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
        viewController: PageHistoryViewController,
        didSelectItem backForwardListItem: WKBackForwardListItem)
    
}

internal final class PageHistoryViewController: UIViewController {
    
    internal weak var delegate: PageHistoryViewControllerDelegate?
    
    private var backForwardListItems = [WKBackForwardListItem]()
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    internal convenience init(backForwardListItem: [WKBackForwardListItem]) {
        self.init()
        self.backForwardListItems = backForwardListItem
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func didTapCloseButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView(frame: view.bounds)
        
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[tableView]-0-|",
            options: [],
            metrics: nil,
            views: ["tableView" : tableView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[tableView]-0-|",
            options: [],
            metrics: nil,
            views: ["tableView" : tableView]))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Done,
            target: self,
            action: "didTapCloseButton:")
    }

}


extension PageHistoryViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backForwardListItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let backForwardItem = backForwardListItems[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ??
            UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = backForwardItem.title
        cell.detailTextLabel?.text = backForwardItem.URL.absoluteString
        
        return cell
    }
    
}


extension PageHistoryViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let backForwardItem = backForwardListItems[indexPath.row]
        delegate?.pageHistoryViewController(self, didSelectItem: backForwardItem)
    }
    
}