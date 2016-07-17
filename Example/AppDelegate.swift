//
//  AppDelegate.swift
//  Example
//
//  Created by 山口　恭兵 on 2015/12/30.
//  Copyright © 2015年 kyo__hei. All rights reserved.
//

import UIKit
import KYWebViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let st = "WebAPIを利用したアプリ開発をする場合、ApplicationIDやAPIKeyなどソースコードに記述したくない値をPlistに定義して利用することが多いかと思います。そんな時に便利なライブラリ [SwiftyConfiguration](https://github.com/ykyouhei/SwiftyConfiguration) を書いてみました。\n\n# 使い方\n### 1. インストール\nCarthage, Cocoapodsに対応\n（2016/07/10現在 Swift2.2, Xcode7.3.1）\n\n### 2. Plistを作成・プロジェクトに追加\n![スクリーンショット 2016-07-10 13.18.35.png](https://qiita-image-store.s3.amazonaws.com/0/33433/0860be88-6a5b-bd83-bd25-d3459d71009f.png \"スクリーンショット 2016-07-10 13.18.35.png\")\n\n### 3. PlistのKeyを定義\n`Keys`のExtensionとしてPlistの各Keyを定義\n\n```Swift\nimport SwiftyConfiguration\n\nextensino Keys {\n\tstatic let string = Key<String>(\"string\")\n\tstatic let int    = Key<Int>(\"int\")\n\tstatic let float  = Key<Float>(\"float\")\n}\n```\n\n対応しているPlistの値\n\n| Type | Plistでの型 |\n|:-----------|:------------|\n| String | String |\n| NSURL | String |\n| NSNumber | NSNumber |\n| Int | NSNumber |\n| Float | NSNumber |\n| Double | NSNumber |\n| Bool | Boolean |\n| NSDate | Date |\n| Array | Array |\n| Dictionary | Dictionary |\n\n\n\n### 4. Configurationオブジェクトを生成してPlistの値を取得\nPlistのパスを指定してConfigrationオブジェクトを作成、`get`で値を取得\nGenericsメソッドとして定義しているので利用側は安全に利用可能\n\n```Swift\nimport SwiftyConfiguration\n\nlet plistPath = NSBundle.mainBundle().pathForResource(\"Configuration\", ofType: \"plist\")!\nlet config = Configuration(plistPath: plistPath)!\n\nlet stringValue = config.get(.string)!\t// \"Hoge\"\nlet intValue    = config.get(.int)!\t\t// 1\nlet floatValue  = config.get(.float)!\t// 3.14\n```\n\n### その他\nキーを`.`で区切ることで、Array・Dictionaryのネストした値も取得することができます。Debug, ReleaseでAPIKeyなどを分けたい時に便利です。\n\n![スクリーンショット 2016-07-10 13.50.51.png](https://qiita-image-store.s3.amazonaws.com/0/33433/7b2717bb-98d7-e1e4-799b-b5df6990f92b.png \"スクリーンショット 2016-07-10 13.50.51.png\")\n\n\n```Swift\nimport SwiftyConfiguration\n\nextension Keys {\n\t#if DEBUG\n        private static let prefix = \"Debug\"\n    #else\n        private static let prefix = \"Release\"\n    #endif\n    \n    static let apiKey = Key<String>(\"\\(prefix).apiKey\")\n}\n```\n\n\n# 宣伝\n他にもいくつかSwift製のUI系ライブラリなどを作成しているので、よければスター・プルリクエストお待ちしてます(ΦωΦ)\n\n* https://github.com/ykyouhei/KYDrawerController\n* https://github.com/ykyouhei/KYShutterButton\n* https://github.com/ykyouhei/KYNavigationProgress\n* https://github.com/ykyouhei/KYDigitalFontView\n* https://github.com/ykyouhei/KYWheelTabController\n\n\n"
        let webViewController = KYWebViewController(initialContentsType: .Markdown(markdownString: st))
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = UINavigationController(rootViewController: webViewController)
        
        webViewController.tintColor = UIColor.greenColor()
        
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

