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
import FirebaseStorage
import RealmSwift
import Reachability
import FontAwesomeKit
import SwiftyJSON
import SVProgressHUD
import SSZipArchive

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
    
    var tabBarItemONE: UITabBarItem = UITabBarItem()
    var tabBarItemTWO: UITabBarItem = UITabBarItem()
    var tabBarItemTHREE: UITabBarItem = UITabBarItem()
    var tabBarItemFOUR: UITabBarItem = UITabBarItem()
    
    @IBOutlet weak var categoryTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タブバーのフォントをFontAwesomeから設定する。
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let arrayOfTabBarItems = tabBarControllerItems as AnyObject as? NSArray{
            self.tabBarItemONE = arrayOfTabBarItems[0] as! UITabBarItem
            tabBarItemONE.image = FAKFontAwesome.listIcon(withSize: 25).image(with: CGSize(width: 25.0, height: 25.0))
            self.tabBarItemTWO = arrayOfTabBarItems[1] as! UITabBarItem
            tabBarItemTWO.image = FAKFontAwesome.searchIcon(withSize: 25).image(with: CGSize(width: 25.0, height: 25.0))
            self.tabBarItemTHREE = arrayOfTabBarItems[2] as! UITabBarItem
            tabBarItemTHREE.image = FAKFontAwesome.newspaperOIcon(withSize: 25).image(with: CGSize(width: 25.0, height: 25.0))
            self.tabBarItemFOUR = arrayOfTabBarItems[3] as! UITabBarItem
            tabBarItemFOUR.image = FAKFontAwesome.downloadIcon(withSize: 25).image(with: CGSize(width: 25.0, height: 25.0))
        }

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
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
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
        
        // 薄い灰色のViewをかぶせる
        grayView = UIView()
        grayView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        grayView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        grayView.center = view.center
        view.addSubview(grayView)
        
        view.bringSubview(toFront: grayView)

        // Realm内にデータが有るかどうかのチェック
        let realm = try! Realm()
        let updateTimeArray = realm.objects(UpdateTime.self)
        
        if updateTimeArray.isEmpty {
            SVProgressHUD.show(withStatus: "Updating")
            // UITabBarのボタンを押せなくする
            self.tabBarItemONE.isEnabled = false
            self.tabBarItemTWO.isEnabled = false
            self.tabBarItemTHREE.isEnabled = false
            self.tabBarItemFOUR.isEnabled = false

            self.readingDefalultDictionaryAndZip()
        }
            
        // 通信できるかどうかのチェック
        let reachability = Reachability()
        print("DEBUG_PRINT: \(String(describing: reachability?.currentReachabilityString))")

        if (reachability?.isReachable)!  {
            print("DEBUG_PRINT: Connected!")
            
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    SVProgressHUD.show(withStatus: "Checking")
                    //self.activityIndicator.startAnimating() // クルクルスタート
                    
                    // UITabBarのボタンを押せなくする
                    self.tabBarItemONE.isEnabled = false
                    self.tabBarItemTWO.isEnabled = false
                    self.tabBarItemTHREE.isEnabled = false
                    self.tabBarItemFOUR.isEnabled = false
                }
                self.setupDownload()
            }
        } else {
            print("DEBUG_PRINT: Others!")
        }
    }
    
    // アラート表示を出す
    func showAlert() {
        
        // アラートを作成
        let alert = UIAlertController(
            title: "Please connect a mobile network to download contents.",
            message: "",
            preferredStyle: .alert)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupDownload() {

        
        let checkRef = Database.database().reference().child(Const.UpdatePath)
        
        // データベース側のUpdate時間を取得
        checkRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in
            
            //if let postDictArray = snapshot.value as? [NSDictionary] {
            if let firebaseTime = snapshot.value as? Int {
                
                let realm = try! Realm()
                let updateTimeArray = realm.objects(UpdateTime.self)
                
                if !updateTimeArray.isEmpty {
                    print("Firebase: \(firebaseTime) <--> Realm: \(updateTimeArray[0].updateTime)")
                }
                
                if firebaseTime > updateTimeArray[0].updateTime {
                    // ダウンロードタブのボタンにバッジをつける
                    self.tabBarItemFOUR.badgeValue = ""
                }

                // 辞書を読み込む必要なし

                print("DEBUG_PRINT: 辞書を読み込まない時、ここでクルクルストップ!")
                SVProgressHUD.dismiss()
                //self.activityIndicator.stopAnimating() // クルクルストップ
                self.grayView.removeFromSuperview()

                // UITabBarのボタンを押せるようにする
                print("DEBUG_PRINT: 辞書を読み込まない時、ここでTabボタンが押せるようになる!")
                self.tabBarItemONE.isEnabled = true
                self.tabBarItemTWO.isEnabled = true
                self.tabBarItemTHREE.isEnabled = true
                self.tabBarItemFOUR.isEnabled = true
            }
        })
    }
    
    // Realmにローカルにあるの辞書(JSON,用語解説のURLデータ,詳細表示用のHTML(zip)を読み込む
    func readingDefalultDictionaryAndZip(){
        print("DEBUG_PRINT: in readingDefaultDictionaryAndZip()")
        
        let checkRef = Database.database().reference().child(Const.UpdatePath)
        
        // データベース側のUpdate時間を取得
        checkRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in
            
            //if let postDictArray = snapshot.value as? [NSDictionary] {
            if let firebaseTime = snapshot.value as? Int {
                
                let realm = try! Realm()
                let updateTimeArray = realm.objects(UpdateTime.self)
                
                if !updateTimeArray.isEmpty {
                    print("Firebase: \(firebaseTime) <--> Realm: \(updateTimeArray[0].updateTime)")
                }
                
                // realm側の更新時刻をDefaultの時刻で更新
                let realmTime = UpdateTime()
                realmTime.updateTime = Const.DefaultDataTimeStamp
                print("DEBUG_PRINT: updateTimeArray is Empty! Firebase: \(firebaseTime)")
                    
                // UpdateTimeの書き込み
                do {
                    try realm.write {
                        realm.add(realmTime)
                    }
                } catch {
                    print(error)
                }
                    
                print("DEBUG_PRINT: 辞書がなくて辞書更新")
                //self.readingDictionaryAndZip()

                self.readJsonDictionary()
                self.readJsonExpUrl()
                self.extendZipFile()
        
                print("DEBUG_PRINT: defaultの辞書読み込み時、ここでクルクルストップ!")
                SVProgressHUD.dismiss()
                //self.activityIndicator.stopAnimating() // クルクルストップ
                self.grayView.removeFromSuperview()
        
                // UITabBarのボタンを押せるようにする
                print("DEBUG_PRINT: defaultの辞書読み込み時、ここでTabボタンが押せるようになる!")
                self.tabBarItemONE.isEnabled = true
                self.tabBarItemTWO.isEnabled = true
                self.tabBarItemTHREE.isEnabled = true
                self.tabBarItemFOUR.isEnabled = true
            }
        })
    }

    // ローカルにある辞書(JSON)をRealmに読み込む
    func readJsonDictionary(){
        let jsonFileName = Const.DataFileName.components(separatedBy: ".").first!
        let filepath = Bundle.main.path(forResource: "\(Const.DefaultDataPath)/\(jsonFileName)", ofType: "json")
        
        let fileHandle = FileHandle(forReadingAtPath: filepath!)
        let data = fileHandle?.readDataToEndOfFile()
        
        let json = try! JSON(data: data!)
        
        for (_,subJson):(String, JSON) in json {
            // 追加するデータを用意
            // print("index: \(index) , key: \(key) , data: \(subJson)")
            let dicEntry = DicEntry()
            dicEntry.id = subJson["id"].stringValue
            dicEntry.jname = subJson["jname"].stringValue
            dicEntry.tname = subJson["tname"].stringValue
            dicEntry.wylie = subJson["wylie"].stringValue
            dicEntry.tags = subJson["tags"].stringValue
            // dicEntry.image = subJson["image"].stringValue
            dicEntry.eng = subJson["eng"].stringValue
            dicEntry.chn = subJson["chn"].stringValue
            dicEntry.kata = subJson["kata"].stringValue
            dicEntry.pron = subJson["pron"].stringValue
            dicEntry.verb = subJson["verb"].stringValue
            dicEntry.exp = subJson["exp"].stringValue
            dicEntry.bunrui1 = subJson["bunrui1"].stringValue
            dicEntry.bunrui2 = subJson["bunrui2"].stringValue
            dicEntry.bunrui3 = subJson["bunrui3"].stringValue
            
            // データを追加
            let realm = try! Realm()
            try! realm.write() {
                realm.add(dicEntry)
            }
        }
    }

    // ローカルにある読み物のURL(JSON)をRealmに読み込む
    func readJsonExpUrl(){

        let jsonFileName = Const.ExpUrlFileName.components(separatedBy: ".").first!
        let filepath = Bundle.main.path(forResource: "\(Const.DefaultDataPath)/\(jsonFileName)", ofType: "json")
        
        let fileHandle = FileHandle(forReadingAtPath: filepath!)
        let data = fileHandle?.readDataToEndOfFile()
        
        let json = try! JSON(data: data!)
        
        for (_,subJson):(String, JSON) in json {
            // 追加するデータを用意
            let entry = ExpUrl()
            entry.url = subJson["url"].stringValue
            entry.title = subJson["title"].stringValue

            // データを追加
            let realm = try! Realm()
            try! realm.write() {
                realm.add(entry)
            }
        }
    }

    func extendZipFile(){
        // zipfile path
        let zipFileName = Const.ZipFileName.components(separatedBy: ".").first!
        let filepath = Bundle.main.path(forResource: "\(Const.DefaultDataPath)/\(zipFileName)", ofType: "zip")

        // destination path to unzip
        let unZipFilePath = self.documentDirectory.path
        
        // exec unzip
        if !SSZipArchive.unzipFile(atPath: filepath!, toDestination: unZipFilePath) {
            print("DEBUG_PRINT: 解凍できませんでした... in ViewController")
        } else {
            // show result
            print(self.documentDirectory.path)
            print("DEBUG_PRINT: 解凍終了！ in ViewController")
        }
    }

    // RealmにFirebase Storageの辞書,用語解説のURLデータ,詳細表示用のHTML(zip)を読み込む
    func readingDictionaryAndZip(){
        
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
        
        // Documentsディレクトリのファイルを消す
        clearHTMLDirectory()
        
        print("DEBUG_PRINT: in readingDictionaryAndZip()")
        
        // 辞書の読み込み
        // Create a reference to the JSON file
        let storageRef = Storage.storage().reference()
        var jsonRef = storageRef.child(Const.DataFileName)
        
        jsonRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                // Data for JSON-file is returned
                let json = try! JSON(data: data!)
                
                for (_,subJson):(String, JSON) in json {
                    // 追加するデータを用意
                    // print("index: \(index) , key: \(key) , data: \(subJson)")
                    let dicEntry = DicEntry()
                    dicEntry.id = subJson["id"].stringValue
                    dicEntry.jname = subJson["jname"].stringValue
                    dicEntry.tname = subJson["tname"].stringValue
                    dicEntry.wylie = subJson["wylie"].stringValue
                    dicEntry.tags = subJson["tags"].stringValue
                    // dicEntry.image = subJson["image"].stringValue
                    dicEntry.eng = subJson["eng"].stringValue
                    dicEntry.chn = subJson["chn"].stringValue
                    dicEntry.kata = subJson["kata"].stringValue
                    dicEntry.pron = subJson["pron"].stringValue
                    dicEntry.verb = subJson["verb"].stringValue
                    dicEntry.exp = subJson["exp"].stringValue
                    dicEntry.bunrui1 = subJson["bunrui1"].stringValue
                    dicEntry.bunrui2 = subJson["bunrui2"].stringValue
                    dicEntry.bunrui3 = subJson["bunrui3"].stringValue
                    
                    // データを追加
                    let realm = try! Realm()
                    try! realm.write() {
                        realm.add(dicEntry)
                    }
                }
            }
        }
        // 用語解説のURLリストの読み込み
        jsonRef = storageRef.child(Const.ExpUrlFileName)
        jsonRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                // Data for JSON-file is returned
                let json = try! JSON(data: data!)
                
                for (_,subJson):(String, JSON) in json {
                    
                    let entry = ExpUrl()
                    entry.url = subJson["url"].stringValue
                    entry.title = subJson["title"].stringValue
                    
                    // print("URL: \(entry.url), Title: \(entry.title)")
                    
                    // データを追加
                    let realm = try! Realm()
                    try! realm.write() {
                        realm.add(entry)
                    }
                }
            }
        }
        
        // Create a reference to the Zip file
        let zipRef = storageRef.child(Const.ZipFileName)
        
        // Create local filesystem URL
        let localURL = URL(string: "\(documentDirectory)/\(Const.ZipFileName)")
        
        // Download to the local filesystem
        zipRef.write(toFile: localURL!) { url, error in
            if let error = error {
                print(error)
            } else {
                print("DEBUG_PRINT: ZIP-file Download Success!")
                
                // zipfile path
                let zipFilePath = "\(self.documentDirectory.path)/\(Const.ZipFileName)"
                
                // destination path to unzip
                let unZipFilePath = self.documentDirectory.path
                
                // exec unzip
                if !SSZipArchive.unzipFile(atPath: zipFilePath, toDestination: unZipFilePath) {
                    print("DEBUG_PRINT: 解凍できませんでした... in ViewController")
                } else {
                    // show result
                    print(self.documentDirectory.path)
                    print("DEBUG_PRINT: 解凍終了！ in ViewController")
                }
                
                // Zipファイルの削除
                let manager = FileManager()
                try! manager.removeItem(atPath: zipFilePath)
            }
            
            print("DEBUG_PRINT: 辞書読み込み時、ここでクルクルストップ!")
            SVProgressHUD.dismiss()
            //self.activityIndicator.stopAnimating() // クルクルストップ
            self.grayView.removeFromSuperview()
            
            // UITabBarのボタンを押せるようにする
            print("DEBUG_PRINT: 辞書読み込み時、ここでTabボタンが押せるようになる!")
            self.tabBarItemONE.isEnabled = true
            self.tabBarItemTWO.isEnabled = true
            self.tabBarItemTHREE.isEnabled = true
            self.tabBarItemFOUR.isEnabled = true
        }
    }
    
    // documentDirectory's url
    private let documentDirectory:URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    // clear all files in documentDirectory
    private func clearHTMLDirectory(){
        do{
            let htmlDirName = Const.ZipFileName.components(separatedBy: ".").first!
            let filepath = "\(self.documentDirectory.path)/\(htmlDirName)"
            
            //print("DEBUG_PRINT: \(filepath)")
            //let url = URL(string: filepath)!
            
            try FileManager.default.removeItem(atPath: filepath)
        }catch(let ex){
            print(ex.localizedDescription)
        }
    }

    /*
    // RealmにFirebase Storageの辞書と用語解説のURLデータを読み込む
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
        // Create a reference to the JSON file
        let storageRef = Storage.storage().reference()
        var jsonRef = storageRef.child(Const.DataFileName)
        
        jsonRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                // Data for JSON-file is returned
                let json = try! JSON(data: data!)
                
                for (_,subJson):(String, JSON) in json {
                    // 追加するデータを用意
                    // print("index: \(index) , key: \(key) , data: \(subJson)")
                    let dicEntry = DicEntry()
                    dicEntry.id = subJson["id"].stringValue
                    dicEntry.jname = subJson["jname"].stringValue
                    dicEntry.tname = subJson["tname"].stringValue
                    dicEntry.wylie = subJson["wylie"].stringValue
                    dicEntry.tags = subJson["tags"].stringValue
                    dicEntry.image = subJson["image"].stringValue
                    dicEntry.eng = subJson["eng"].stringValue
                    dicEntry.chn = subJson["chn"].stringValue
                    dicEntry.kata = subJson["kata"].stringValue
                    dicEntry.pron = subJson["pron"].stringValue
                    dicEntry.verb = subJson["verb"].stringValue
                    dicEntry.exp = subJson["exp"].stringValue
                    dicEntry.bunrui1 = subJson["bunrui1"].stringValue
                    dicEntry.bunrui2 = subJson["bunrui2"].stringValue
                    dicEntry.bunrui3 = subJson["bunrui3"].stringValue
                    
                    // データを追加
                    let realm = try! Realm()
                    try! realm.write() {
                        realm.add(dicEntry)
                    }
                }

                print("DEBUG_PRINT: Initial 辞書読み込み時、ここでクルクルストップ!")
                SVProgressHUD.dismiss()
                //self.activityIndicator.stopAnimating() // クルクルストップ
                self.grayView.removeFromSuperview()
                
                // UITabBarのボタンを押せるようにする
                print("DEBUG_PRINT: Initial 辞書読み込み時、ここでTabボタンが押せるようになる!")
                self.tabBarItemONE.isEnabled = true
                self.tabBarItemTWO.isEnabled = true
                self.tabBarItemTHREE.isEnabled = true
                self.tabBarItemFOUR.isEnabled = true
            }
        }

        // 用語解説のURLリストの読み込み
        jsonRef = storageRef.child(Const.ExpUrlFileName)
        jsonRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                // Data for JSON-file is returned
                let json = try! JSON(data: data!)
                
                for (_,subJson):(String, JSON) in json {

                    let entry = ExpUrl()
                    entry.url = subJson["url"].stringValue
                    entry.title = subJson["title"].stringValue
                    
                    // print("URL: \(entry.url), Title: \(entry.title)")
                    
                    // データを追加
                    let realm = try! Realm()
                    try! realm.write() {
                        realm.add(entry)
                    }
                }
            }
        }

    }
*/
    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

