//
//  DetailViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/26.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
//import RealmSwift
//import PureLayout
//import CopyableLabel
import Darwin
import SVProgressHUD
import FontAwesomeKit
import FirebaseAnalytics

class DetailViewController: UIViewController, UIWebViewDelegate {

    var id = ""
    
    @IBOutlet var detailWebView: UIWebView!
    
    var backButton: UIBarButtonItem!
    var nextButton: UIBarButtonItem!

    var grayView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 薄い灰色のViewをかぶせる
        grayView = UIView()
        grayView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        grayView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        grayView.center = view.center
        view.addSubview(grayView)
        
        SVProgressHUD.show(withStatus: "Loading...")

        // 戻る・進むボタン
        // ボタン作成
        backButton = UIBarButtonItem(image: FAKFontAwesome.angleLeftIcon(withSize: 25).image(with: CGSize(width: 25.0, height: 25.0)), style: .plain, target: self, action: #selector(DetailViewController.clickBackButton))
        nextButton = UIBarButtonItem(image: FAKFontAwesome.angleRightIcon(withSize: 25).image(with: CGSize(width: 25.0, height: 25.0)), style: .plain, target: self, action: #selector(DetailViewController.clickNextButton))
        // barButtonSystemItemを変更すればいろいろなアイコンに変更できます
        //backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.rewind, target: self, action: #selector(DetailViewController.clickBackButton))
        //nextButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(DetailViewController.clickNextButton))

        //ナビゲーションバーの右側にボタン付与
        self.navigationItem.setRightBarButtonItems([nextButton, backButton], animated: true)
        
        // 前のページに戻れるかどうか
        backButton.isEnabled = self.detailWebView.canGoBack
        // 次のページに進めるかどうか
        nextButton.isEnabled = self.detailWebView.canGoForward
        
        // realmから辞書を読み込み
        // let realm = try! Realm()
        // let dicEntryArray = realm.objects(DicEntry.self)

        // UIWebViewのDelegate を設定
        detailWebView.delegate = self
        
        let filename = String(format:"%05d.html", atoll(id))
        let filepath = "\(self.documentDirectory.path)/\(Const.DicHtmlDirName)/\(filename)"
        
        //print("DEBUG_PRINT: \(filepath)")
        
        let url = URL(string: filepath)!
        
        // リクエストを生成する
        let urlRequest = URLRequest(url: url)
        
        // 指定したページを読み込む
        detailWebView.loadRequest(urlRequest)
        
        // 画像の拡大・縮小を可能に
        detailWebView.scalesPageToFit = true
        
        // 選ばれたHTMLの番号をログ
        Analytics.logEvent("DetailLook", parameters: [
            "id": id
            ])

    }
    
    // 読み込み完了時に呼ばれる
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 前のページに戻れるかどうか
        self.backButton.isEnabled = self.detailWebView.canGoBack
        // 次のページに進めるかどうか
        self.nextButton.isEnabled = self.detailWebView.canGoForward

        SVProgressHUD.dismiss() //クルクルストップ
        self.grayView.removeFromSuperview()
    }

    func clickBackButton(){
        self.detailWebView.goBack()
    }

    func clickNextButton(){
        self.detailWebView.goForward()
    }

    // documentDirectory's url
    private let documentDirectory:URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()

   /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
