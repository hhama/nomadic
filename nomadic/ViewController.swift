//
//  ViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/23.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RealmSwift
import ReachabilitySwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let categories = [
        "営地と放牧地",
        "地形・天体・天候",
        "植物と動物",
        "家畜表現",
        "放牧作業",
        "個体管理",
        "屠畜・解体",
        "交尾・出産・去勢",
        "搾乳と乳加工",
        "食肉加工と部位名称",
        "糞",
        "毛と皮革",
        "役利用",
        "食文化",
        "服飾文化",
        "住文化",
        "日常の行為と道具",
        "暦と度量衡",
        "人間関係",
        "経済活動",
        "冠婚葬祭",
        "娯楽",
        "宗教的観念",
        "宗教的行為",
        "宗教的存在",
        "宝具と呪物",
        "宗教的な場所と建造物",
        "新しい政策・技術・道具",
    ]
    
    var activityIndicator: UIActivityIndicatorView!
    var grayView: UIView!
    var dataReadLabel: UILabel!
    
    var dataLength = 0; // Firebaseから読み込むデータの長さ
    
    var tabBarItemONE: UITabBarItem = UITabBarItem()
    var tabBarItemTWO: UITabBarItem = UITabBarItem()
    var tabBarItemTHREE: UITabBarItem = UITabBarItem()

    @IBOutlet weak var categoryTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // アプリがForegroundになった通知を受け取る
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.viewWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self

        dataReading()

    }
    
    func viewWillEnterForeground(_ notification: NSNotification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            dataReading()
        }
    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // マージンをなくす
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.textLabel!.font = UIFont(name: "Arial", size: 14)
        cell.textLabel?.text = "\(indexPath.row + 1) : " + categories[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.lightGray
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryCellSegue",sender: nil)
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let tagsViewController:TagsViewController = segue.destination as! TagsViewController
        
        if segue.identifier == "categoryCellSegue" {
            let indexPath = self.categoryTableView.indexPathForSelectedRow
            tagsViewController.category = categories[indexPath!.row]
            tagsViewController.categoryId = indexPath!.row + 1
        }
    }

    func dataReading() {
        
        // 通信できるかどうかのチェック
        let reachability = Reachability()
        // print("DEBUG_PRINT: \(String(describing: reachability?.currentReachabilityString))")
        
        // Realm内にデータが有るかどうかのチェック
        let realm = try! Realm()
        let updateTimeArray = realm.objects(UpdateTime.self)
        
        if updateTimeArray.isEmpty && reachability?.currentReachabilityString == "No Connection" {
            // Alertを出す
            showAlert()
            // print("DEBUG_PRINT: No Connection!")
        } else if (reachability?.currentReachabilityString != "No Connection")  {
            print("DEBUG_PRINT: Connected!")
            
            // FirebaseApp.configure()

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

            DispatchQueue.global().async {
                self.setupDictionary()
                
                DispatchQueue.main.async {

                    self.activityIndicator.startAnimating() // クルクルスタート
                    
                    // UITabBarのボタンを押せなくする
                    let tabBarControllerItems = self.tabBarController?.tabBar.items
                    
                    if let arrayOfTabBarItems = tabBarControllerItems as AnyObject as? NSArray{
                        self.tabBarItemONE = arrayOfTabBarItems[0] as! UITabBarItem
                        self.tabBarItemONE.isEnabled = false
                        
                        self.tabBarItemTWO = arrayOfTabBarItems[1] as! UITabBarItem
                        self.tabBarItemTWO.isEnabled = false
                        
                        self.tabBarItemTHREE = arrayOfTabBarItems[2] as! UITabBarItem
                        self.tabBarItemTHREE.isEnabled = false
                    }
                }
            }
        } else {
            print("DEBUG_PRINT: Others!")
        }
    }
    
    // アラート表示を出す
    func showAlert() {
        
        // アラートを作成
        let alert = UIAlertController(
            title: "通信できません。",
            message: "ホームボタンを押して、終了してください。",
            preferredStyle: .alert)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupDictionary() {
        // Database.database().isPersistenceEnabled = true
        
        let checkRef = Database.database().reference().child(Const.UpdatePath)
        
        // データベース側のUpdate時間を取得
        checkRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in
            
            //if let postDictArray = snapshot.value as? [NSDictionary] {
            if let firebaseTime = snapshot.value as? Int {
                
                //let firebaseTime = postDictArray[0]["update"] as! Int
                //print("DEBUG_PRINT: \(String(describing: firebaseTime))")
                
                let realm = try! Realm()
                let updateTimeArray = realm.objects(UpdateTime.self)
                
                if !updateTimeArray.isEmpty {
                    print("Firebase: \(firebaseTime) <--> Realm: \(updateTimeArray[0].updateTime)")
                }
                
                if updateTimeArray.isEmpty {
                    // 一番最初のアプリ起動時にRealmの更新時間を書き込む
                    
                    // realm側の更新時刻をFirebase側の時刻で更新
                    let realmTime = UpdateTime()
                    realmTime.updateTime = firebaseTime
                    
                    // UpdateTimeの書き込み
                    try! realm.write {
                        realm.add(realmTime)
                    }
                    print("DEBUG_PRINT: 辞書がなくて辞書更新")
                    self.readingDictionary()
                } else if firebaseTime > updateTimeArray[0].updateTime {
                    // realm側の更新時刻をFirebase側の時刻で更新
                    if let realmTime = updateTimeArray.first {
                        // UpdateTimeの更新
                        try! realm.write {
                            realmTime.updateTime = firebaseTime
                        }
                    }
                    
                    print("DEBUG_PRINT: 更新時間で辞書更新")
                    self.readingDictionary()
                } else {
                    // 辞書を読み込む必要なし

                    print("DEBUG_PRINT: 辞書を読み込まない時、ここでクルクルストップ!")
                    self.activityIndicator.stopAnimating() // クルクルストップ
                    self.grayView.removeFromSuperview()
                    
                    // UITabBarのボタンを押せるようにする
                    print("DEBUG_PRINT: 辞書を読み込まない時、ここでTabボタンが押せるようになる!")
                    self.tabBarItemONE.isEnabled = true
                    self.tabBarItemTWO.isEnabled = true
                    self.tabBarItemTHREE.isEnabled = true
                }
            }
        })
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

        })
    }

    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

