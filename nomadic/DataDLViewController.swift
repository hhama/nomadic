//
//  DataDLViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/11/08.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RealmSwift
import ReachabilitySwift

class DataDLViewController: UIViewController {

    @IBOutlet weak var downloadMessageLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView!
    var grayView: UIView!
    var dataReadLabel: UILabel!
    
    var dataLength = 0; // Firebaseから読み込むデータの長さ
    
    var tabBarItemONE: UITabBarItem = UITabBarItem()
    var tabBarItemTWO: UITabBarItem = UITabBarItem()
    var tabBarItemTHREE: UITabBarItem = UITabBarItem()
    var tabBarItemFOUR: UITabBarItem = UITabBarItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // タブボタンのitemを取得
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let arrayOfTabBarItems = tabBarControllerItems as AnyObject as? NSArray{
            self.tabBarItemONE = arrayOfTabBarItems[0] as! UITabBarItem
            self.tabBarItemTWO = arrayOfTabBarItems[1] as! UITabBarItem
            self.tabBarItemTHREE = arrayOfTabBarItems[2] as! UITabBarItem
            self.tabBarItemFOUR = arrayOfTabBarItems[3] as! UITabBarItem
        }
        
        dataCheck()
    }
    
    func dataCheck(){
        // 通信できるかどうかのチェック
        let reachability = Reachability()
        
        let checkRef = Database.database().reference().child(Const.UpdatePath)
        
        if (reachability?.currentReachabilityString != "No Connection")  {
            print("DEBUG_PRINT: DataDL Connected!")
            
            
            // データベース側のUpdate時間を取得
            checkRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in
            
                if let firebaseTime = snapshot.value as? Int {
                
                    let realm = try! Realm()
                    let updateTimeArray = realm.objects(UpdateTime.self)
                
                    if !updateTimeArray.isEmpty {
                        print("Firebase: \(firebaseTime) <--> Realm: \(updateTimeArray[0].updateTime)")
                    }
                    
                    if firebaseTime > updateTimeArray[0].updateTime {

                        self.loadingIndicatorSetup()

                        self.downloadMessageLabel.text = "新しい辞書があります。"
                        self.showAlert(firebaseTime: firebaseTime)
                        
                    } else {
                        // 辞書を読み込む必要なし
                        
                        /*
                        print("DEBUG_PRINT: 辞書を読み込まない時、ここでクルクルストップ!")
                        self.activityIndicator.stopAnimating() // クルクルストップ
                        self.grayView.removeFromSuperview()
                        
                        // UITabBarのボタンを押せるようにする
                        print("DEBUG_PRINT: 辞書を読み込まない時、ここでTabボタンが押せるようになる!")
                        self.tabBarItemONE.isEnabled = true
                        self.tabBarItemTWO.isEnabled = true
                        self.tabBarItemTHREE.isEnabled = true
                        self.tabBarItemFOUR.isEnabled = true
                         */
                    }
                }
            })
            
        } else {
            print("DEBUG_PRINT: Others!")
        }
        
    }

    func showAlert(firebaseTime: Int) {
        
        // アラートを作成
        let alert = UIAlertController(
            title: "新しい辞書があります。",
            message: "辞書を更新しますか？",
            preferredStyle: .alert)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            print("Yesが押された")

            let realm = try! Realm()
            let updateTimeArray = realm.objects(UpdateTime.self)

            // realm側の更新時刻をFirebase側の時刻で更新
            if let realmTime = updateTimeArray.first {
                // UpdateTimeの更新
                try! realm.write {
                    realmTime.updateTime = firebaseTime
                }
            }
            
            print("DEBUG_PRINT: 更新時間で辞書更新")
            // ダウンロードタブのボタンのバッジを消す
            self.tabBarItemFOUR.badgeValue = nil
            
            DispatchQueue.global().async {
                print("DEBUG_PRINT: global queue!")
                self.readingDictionary()
                
                DispatchQueue.main.async {
                    print("DEBUG_PRINT: main queue!")
                    self.activityIndicator.startAnimating() // クルクルスタート
                    
                    // UITabBarのボタンを押せなくする
                    self.tabBarItemONE.isEnabled = false
                    self.tabBarItemTWO.isEnabled = false
                    self.tabBarItemTHREE.isEnabled = false
                    self.tabBarItemFOUR.isEnabled = false
                }
            }
         }))

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            print("Noが押された")
            self.activityIndicator.stopAnimating() // クルクルストップ
            self.grayView.removeFromSuperview()
        }))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }

    // RealmにFirebaseの辞書と用語解説のURLデータを読み込む
    func readingDictionary(){
        
        // 現在持っている辞書の削除
        let realm = try! Realm()
        let dicEntryArray = realm.objects(DicEntry.self)
        if !dicEntryArray.isEmpty {
            for entry in dicEntryArray {
                try! realm.write {
                    realm.delete(entry)
                }
            }
        }
        
        // 現在持っているURLリストの削除
        let expUrlEntryArray = realm.objects(ExpUrl.self)
        if !expUrlEntryArray.isEmpty {
            for entry in expUrlEntryArray {
                try! realm.write {
                    realm.delete(entry)
                }
            }
        }
        
        print("DEBUG_PRINT: in readingDictionary()")
        // 辞書の読み込み
        let defaultPlace = Database.database().reference().child(Const.DataPath)
        defaultPlace.observeSingleEvent(of: .value, with: { snapshot in
            
            if let postDictArray = snapshot.value as? [NSDictionary] {
                
                for postDict in postDictArray {
                    // 追加するデータを用意
                    let dicEntry = DicEntry()
                    dicEntry.id = postDict["id"] as! String? ?? ""
                    dicEntry.jname = postDict["jname"] as! String? ?? ""
                    dicEntry.tname = postDict["tname"] as! String? ?? ""
                    dicEntry.wylie = postDict["wylie"] as! String? ?? ""
                    dicEntry.tags = postDict["tags"] as! String? ?? ""
                    dicEntry.image = postDict["image"] as! String? ?? ""
                    dicEntry.eng = postDict["eng"] as! String? ?? ""
                    dicEntry.chn = postDict["chn"] as! String? ?? ""
                    dicEntry.kata = postDict["kata"] as! String? ?? ""
                    dicEntry.pron = postDict["pron"] as! String? ?? ""
                    dicEntry.verb = postDict["verb"] as! String? ?? ""
                    dicEntry.exp = postDict["exp"] as! String? ?? ""
                    dicEntry.bunrui1 = postDict["bunrui1"] as! String? ?? ""
                    dicEntry.bunrui2 = postDict["bunrui2"] as! String? ?? ""
                    dicEntry.bunrui3 = postDict["bunrui3"] as! String? ?? ""
                    
                    // データを追加
                    let realm = try! Realm()
                    try! realm.write() {
                        realm.add(dicEntry)
                    }
                }
            }
        })
        
        // 用語解説のURLリストの読み込み
        let urlPlace = Database.database().reference().child(Const.ExpUrlPath)
        urlPlace.observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let expUrlArray = snapshot.value as? [NSDictionary] {
                
                for expUrl in expUrlArray {
                    // 追加するデータを用意
                    let entry = ExpUrl()
                    entry.url = expUrl["url"] as! String? ?? ""
                    entry.title = expUrl["title"] as! String? ?? ""
                    
                    // print("URL: \(entry.url), Title: \(entry.title)")
                    
                    // データを追加
                    let realm = try! Realm()
                    try! realm.write() {
                        realm.add(entry)
                    }
                }
            }
            
            print("DEBUG_PRINT: 辞書読み込み時、ここでクルクルストップ!")
            self.activityIndicator.stopAnimating() // クルクルストップ
            self.grayView.removeFromSuperview()
            
            // UITabBarのボタンを押せるようにする
            print("DEBUG_PRINT: 辞書読み込み時、ここでTabボタンが押せるようになる!")
            self.tabBarItemONE.isEnabled = true
            self.tabBarItemTWO.isEnabled = true
            self.tabBarItemTHREE.isEnabled = true
            self.tabBarItemFOUR.isEnabled = true
            
            self.downloadMessageLabel.text = "辞書は最新です。"
        })
    }
    
    func loadingIndicatorSetup(){
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
        dataReadLabel.text = "データ更新中"
        dataReadLabel.sizeToFit()
        dataReadLabel.center = view.center
        
        //Viewに追加
        grayView.addSubview(dataReadLabel)
        grayView.addSubview(activityIndicator)
        view.addSubview(grayView)
        
        view.bringSubview(toFront: grayView)
       
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
