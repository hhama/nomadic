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

class DetailViewController: UIViewController, UIWebViewDelegate {

    var id = ""
    
    @IBOutlet var detailWebView: UIWebView!
    
    var backButton: UIBarButtonItem!
    var nextButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 戻る・進むボタン
        // ボタン作成
        // barButtonSystemItemを変更すればいろいろなアイコンに変更できます
        backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.rewind, target: self, action: #selector(DetailViewController.clickBackButton))
        nextButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(DetailViewController.clickNextButton))
        
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
        let htmlDirName = Const.ZipFileName.components(separatedBy: ".").first!
        let filepath = "\(self.documentDirectory.path)/\(htmlDirName)/\(filename)"
        
        //print("DEBUG_PRINT: \(filepath)")
        
        let url = URL(string: filepath)!
        
        // リクエストを生成する
        let urlRequest = URLRequest(url: url)
        
        // 指定したページを読み込む
        detailWebView.loadRequest(urlRequest)

    }
    
    // 読み込み完了時に呼ばれる
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 前のページに戻れるかどうか
        self.backButton.isEnabled = self.detailWebView.canGoBack
        // 次のページに進めるかどうか
        self.nextButton.isEnabled = self.detailWebView.canGoForward
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
