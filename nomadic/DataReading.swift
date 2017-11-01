//
//  DataReading.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/31.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import Firebase
import FirebaseDatabase
import RealmSwift
import ReachabilitySwift

class DataReading: UIViewController {

    var rootRef: DatabaseReference!
    var activityIndicator: UIActivityIndicatorView!
    var grayView: UIView!
    var dataReadLabel: UILabel!
    
    func dataReading(view: UIView) {

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
            activityIndicator.color = UIColor.blue
            

            dataReadLabel = UILabel()
            dataReadLabel.text = "データ確認中"
            dataReadLabel.sizeToFit()
            dataReadLabel.center = view.center
            
            //Viewに追加
            grayView.addSubview(dataReadLabel)
            grayView.addSubview(activityIndicator)
            view.addSubview(grayView)
            
            view.bringSubview(toFront: grayView)
            
            DispatchQueue.global().async {
                self.activityIndicator.startAnimating() // クルクルスタート
                self.setupDictionary()
                
                DispatchQueue.main.async {
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
        
        rootRef = Database.database().reference()
        
        // データベース側のUpdate時間を取得
        rootRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in
            
            self.activityIndicator.stopAnimating() // クルクルストップ
            self.grayView.removeFromSuperview()
            
            if let postDict = snapshot.value as? NSDictionary {
                
                let firebaseTime = postDict[Const.UpdatePath] as! Int
                
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
                } else {
                    if firebaseTime > updateTimeArray[0].updateTime {
                        // realm側の更新時刻をFirebase側の時刻で更新
                        if let realmTime = updateTimeArray.first {
                            // UpdateTimeの更新
                            try! realm.write {
                                realmTime.updateTime = firebaseTime
                            }
                        }
                        
                        print("DEBUG_PRINT: 更新時間で辞書更新")
                        self.readingDictionary()
                    }
                }
            }
        })
    }
    
    // RealmにFirebaseの辞書を読み込む
    func readingDictionary(){
        
        // ラベルのテキストを変える
        self.dataReadLabel.text = "データ読込中"
        // dataReadLabel.sizeToFit()
        
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
        
        print("DEBUG_PRINT: in readingDictionary()")
        rootRef = Database.database().reference()
        for idx in 0..<Const.DataLength {
            let path = Const.DataPath + "/" + String(idx)
            let defaultPlace = rootRef.child(path)
            
            defaultPlace.observeSingleEvent(of: .value, with: { snapshot in
                
                
                if let postDict = snapshot.value as? NSDictionary {
                    
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
                //print("DEBUG_PRINT: \(String(describing: dicEntryArray.last?.id))")
            })
            
            // self.activityIndicator.stopAnimating() // クルクルストップ
            // self.grayView.removeFromSuperview()
        }
        // self.activityIndicator.stopAnimating() // クルクルストップ
        // self.grayView.removeFromSuperview()
    }
}
