//
//  ExpDetailViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/11/04.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import Reachability
import Firebase
import FirebaseStorage

class ExpDetailViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var expDetailWebView: UIWebView!
    
    var expUrl:String = ""
    var expTitle:String = ""

    var activityIndicator: UIActivityIndicatorView!
    var grayView: UIView!
    var dataReadLabel: UILabel!
    
    var tabBarItemONE: UITabBarItem = UITabBarItem()
    var tabBarItemTWO: UITabBarItem = UITabBarItem()
    var tabBarItemTHREE: UITabBarItem = UITabBarItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expDetailWebView.delegate = self
        
        self.navigationItem.title = expTitle
        
        expDetailWebView.scrollView.bounces = false


        // 通信できるかどうかのチェック
        let reachability = Reachability()

        if !reachability!.isReachable {
            // Alertを出す
            showAlert()
        } else {
            // 薄い灰色のViewをかぶせる
            grayView = UIView()
            grayView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
            grayView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            grayView.center = view.center
            
            // ActivityIndicatorを作成＆中央に配置
            activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            activityIndicator.center = view.center
            
            // クルクルをストップした時に非表示する
            activityIndicator.hidesWhenStopped = true
            
            // 色・大きさを設定
            activityIndicator.activityIndicatorViewStyle = .whiteLarge
            activityIndicator.color = UIColor.white
            
            
            dataReadLabel = UILabel()
            dataReadLabel.text = "Loading..."
            dataReadLabel.sizeToFit()
            dataReadLabel.center = view.center
            
            //Viewに追加
            grayView.addSubview(dataReadLabel)
            grayView.addSubview(activityIndicator)
            view.addSubview(grayView)
            self.activityIndicator.startAnimating() // クルクルスタート
            
            // Create a reference to the file you want to download
            let storageRef = Storage.storage().reference()
            let fileRef = storageRef.child("html/\(self.expUrl)")
            
            // webView.delegate = self
            // Fetch the download URL
            fileRef.downloadURL { (url, error) -> Void in
                if (error != nil) {
                    print(error!)// Handle any errors
                } else {
                    // Get the download URL
                    let request: URLRequest = URLRequest(url: url!)
                    self.expDetailWebView.loadRequest(request)
                }
            }
        }
    }

    // アラート表示を出す
    func showAlert() {
        
        // アラートを作成
        let alert = UIAlertController(
            title: "Please connect to a mobile network.",
            message: "",
            preferredStyle: .alert)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    // 読み込み終了
    func webViewDidFinishLoad(_ webView: UIWebView){
        self.activityIndicator.stopAnimating() // クルクルストップ
        self.grayView.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
