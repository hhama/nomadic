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
import FirebaseStorage
import RealmSwift
import Reachability
import SwiftyJSON
import SVProgressHUD
import SSZipArchive

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
        
        if (reachability?.isReachable)!  {
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

                        self.downloadMessageLabel.text = "New version is available."
                        self.showAlert(firebaseTime: firebaseTime)
                        
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
            title: "New version is available.",
            message: "Update?",
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
                
                DispatchQueue.main.async {
                    print("DEBUG_PRINT: main queue!")
                    SVProgressHUD.show(withStatus: "Updating")
                    
                    // UITabBarのボタンを押せなくする
                    self.tabBarItemONE.isEnabled = false
                    self.tabBarItemTWO.isEnabled = false
                    self.tabBarItemTHREE.isEnabled = false
                    self.tabBarItemFOUR.isEnabled = false
                }
                self.readingDictionaryAndZip()
            }
         }))

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            print("Noが押された")
            SVProgressHUD.dismiss()
            //self.activityIndicator.stopAnimating() // クルクルストップ
            self.grayView.removeFromSuperview()
        }))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
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
        clearDocumentDirectory()
        
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
                    print("解凍できませんでした...")
                } else {
                    // show result
                    print(self.documentDirectory.path)
                    print("解凍終了！")
                }
                
                // Zipファイルの削除
                let manager = FileManager()
                try! manager.removeItem(atPath: zipFilePath)
            }
            
            print("DEBUG_PRINT: inDL 辞書読み込み時、ここでクルクルストップ!")
            SVProgressHUD.dismiss()
            //self.activityIndicator.stopAnimating() // クルクルストップ
            self.grayView.removeFromSuperview()
            
            // UITabBarのボタンを押せるようにする
            print("DEBUG_PRINT: inDL 辞書読み込み時、ここでTabボタンが押せるようになる!")
            self.tabBarItemONE.isEnabled = true
            self.tabBarItemTWO.isEnabled = true
            self.tabBarItemTHREE.isEnabled = true
            self.tabBarItemFOUR.isEnabled = true
            
            self.downloadMessageLabel.text = "This is the latest version."
        }
    }

    // documentDirectory's url
    private let documentDirectory:URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    // clear all files in documentDirectory
    private func clearDocumentDirectory(){
        do{
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
            
            for url in fileURLs{
                try FileManager.default.removeItem(at: url)
            }
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
                
                print("DEBUG_PRINT: inDL 辞書読み込み時、ここでクルクルストップ!")
                SVProgressHUD.dismiss()
                //self.activityIndicator.stopAnimating() // クルクルストップ
                self.grayView.removeFromSuperview()
                
                // UITabBarのボタンを押せるようにする
                print("DEBUG_PRINT: inDL 辞書読み込み時、ここでTabボタンが押せるようになる!")
                self.tabBarItemONE.isEnabled = true
                self.tabBarItemTWO.isEnabled = true
                self.tabBarItemTHREE.isEnabled = true
                self.tabBarItemFOUR.isEnabled = true
                
                self.downloadMessageLabel.text = "This is the latest version."
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
    func loadingIndicatorSetup(){
        // 薄い灰色のViewをかぶせる
        grayView = UIView()
        grayView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        grayView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        grayView.center = view.center
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
