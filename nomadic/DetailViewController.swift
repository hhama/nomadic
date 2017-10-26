//
//  DetailViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/26.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import RealmSwift
import PureLayout

class DetailViewController: UIViewController {

    var id = ""
    
    @IBOutlet weak var tnameLabel: UILabel!
    @IBOutlet weak var wylieLabel: UILabel!
    @IBOutlet weak var jnameLabel: UILabel!

    @IBOutlet weak var verbLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // realmから辞書を読み込み
        let realm = try! Realm()
        let dicEntryArray = realm.objects(DicEntry.self)

        for entry in dicEntryArray {
            if entry.id == id {
                printEntry(entry: entry)
            }
        }
    }
    
    // 画面を作る
    func printEntry(entry: DicEntry){
        tnameLabel.text = "\(id): \(entry.tname)"

        // 発音表記がある場合
        if entry.pron.isEmpty {
            wylieLabel.text = entry.wylie
        } else {
            wylieLabel.text = "\(entry.wylie)  /\(entry.pron)/"
        }
        
        if entry.verb == "1" {
            verbLabel.text = "v."
        } else {
            verbLabel.text = "n."
        }
        
        jnameLabel.text = entry.jname
        

        var preLabel: UILabel = jnameLabel
        // 英語名称があった場合
        if !entry.eng.isEmpty{
            let engLabel = UILabel()
            engLabel.text = entry.eng
            engLabel.numberOfLines = 0
            view.addSubview(engLabel)
            
            engLabel.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
            engLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            engLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)

            preLabel = engLabel
        }
        
        // 中国語名称があった場合
        if !entry.chn.isEmpty{
            let chnLabel = UILabel()
            chnLabel.text = "entry.chn"
            chnLabel.numberOfLines = 0
            view.addSubview(chnLabel)
            
            chnLabel.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
            chnLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            chnLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
            
            preLabel = chnLabel
        }
        
        // 解説があった場合
        if !entry.exp.isEmpty{
            let expLabel = UILabel()
            expLabel.text = "＊ \(entry.exp)"
            expLabel.numberOfLines = 0
            view.addSubview(expLabel)
            
            expLabel.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
            expLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            expLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
            
            preLabel = expLabel
        }
        
        // 画像があった場合
        if !entry.image.isEmpty {
            let image = UIImage(data: NSData(base64Encoded: entry.image, options: .ignoreUnknownCharacters)! as Data)

            // UIImageView 初期化
            let imageView = UIImageView(image:image)

            // UIImageviewを角丸にする
            imageView.clipsToBounds = true;
            imageView.layer.cornerRadius = 10.0;

            // UIImageViewのインスタンスをビューに追加
            view.addSubview(imageView)
            
            imageView.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
            imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
        }
        
        
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
