//
//  AboutViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/11/16.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import SVProgressHUD

class AboutViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var aboutWebView: UIWebView!

    var grayView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutWebView.delegate = self

        // 薄い灰色のViewをかぶせる
        grayView = UIView()
        grayView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        grayView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        grayView.center = view.center
        view.addSubview(grayView)
        
        SVProgressHUD.show(withStatus: "Loading...")

        let path: String = Bundle.main.path(forResource: "about", ofType: "html")!

        let url = URL(string: path)!
        
        // リクエストを生成する
        let urlRequest = URLRequest(url: url)
        
        // 指定したページを読み込む
        aboutWebView.loadRequest(urlRequest)
    }

    // 読み込み終了
    func webViewDidFinishLoad(_ webView: UIWebView){
        SVProgressHUD.dismiss() //クルクルストップ
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
