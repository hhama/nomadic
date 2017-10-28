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
import CopyableLabel

class DetailViewController: UIViewController, UIScrollViewDelegate {

    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 画面の大きさを取得
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        let screenWidth:CGFloat = myBoundSize.width;
        let screenHeight:CGFloat = myBoundSize.height

        // realmから辞書を読み込み
        let realm = try! Realm()
        let dicEntryArray = realm.objects(DicEntry.self)

        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.lightGray
        
        // 表示窓のサイズと位置を設定
        scrollView.frame.size = CGSize(width: screenWidth, height: screenHeight)
        scrollView.center = self.view.center

        // 新たなViewを作る
        let myView = UIView()
        myView.frame.size = CGSize(width: screenWidth, height: 1000)
        
        // 中身の大きさを設定
        scrollView.contentSize = CGSize(width: screenWidth, height: 1000)
        
        // スクロールの跳ね返り
        scrollView.bounces = true
        
        // スクロールバーの見た目と余白
        scrollView.indicatorStyle = .white
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Delegate を設定
        scrollView.delegate = self

        for entry in dicEntryArray {
            if entry.id == id {
                printEntry(entry: entry, scrollView: myView)
            }
        }
        
        scrollView.addSubview(myView)
        self.view.addSubview(scrollView)
    }
    
    // 画面を作る
    func printEntry(entry: DicEntry, scrollView: UIView){

        // チベット語名称
        let tnameLabel = UILabel()
        tnameLabel.text = "\(id): \(entry.tname)"
        tnameLabel.font = UIFont.systemFont(ofSize: 24)
        tnameLabel.numberOfLines = 0
        tnameLabel.copyable = true // コピー可能に
        scrollView.addSubview(tnameLabel)
        
        let screenSize = UIScreen.main.bounds.size
        let tnameSize = CGSize(width: screenSize.width - 40, height: 24)
        tnameLabel.autoSetDimensions(to: tnameSize)
        
        // tnameLabel.autoPinEdge(.top, to: .bottom, of: scrollView, withOffset: 10.0)
        tnameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 10.0)
        tnameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
        tnameLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)

        var preLabel: UILabel = tnameLabel
        
        // Wylie表記
        let wylieLabel = UILabel()
        // 発音表記があるなしで分岐
        if entry.pron.isEmpty {
            wylieLabel.text = entry.wylie
        } else {
            wylieLabel.text = "\(entry.wylie)  /\(entry.pron)/"
        }
        wylieLabel.numberOfLines = 0
        wylieLabel.copyable = true // コピー可能に
        scrollView.addSubview(wylieLabel)
        
        wylieLabel.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
        wylieLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
        wylieLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
        
        preLabel = wylieLabel
        
        // 品詞
        let verbLabel = UILabel()
        // 動詞かどうかで分岐
        if entry.verb == "1" {
            verbLabel.text = "v."
        } else {
            verbLabel.text = "n."
        }
        verbLabel.numberOfLines = 0
        verbLabel.copyable = true // コピー可能に
        verbLabel.font = UIFont(name: "TimesNewRomanPS-BoldItalicMT", size: 20)
        scrollView.addSubview(verbLabel)
        
        // verbLabel.autoSetDimension(.width, toSize: 30.0)
        verbLabel.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
        verbLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
        verbLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)

        preLabel = verbLabel
        
        // 日本語名称
        let jnameLabel = UILabel()
        jnameLabel.text = entry.jname
        jnameLabel.numberOfLines = 0
        jnameLabel.copyable = true // コピー可能に
        scrollView.addSubview(jnameLabel)
        
        jnameLabel.autoSetDimension(.width, toSize: screenSize.width - 60)
        jnameLabel.autoPinEdge(.top, to: .bottom, of: wylieLabel, withOffset: 10.0)
        //jnameLabel.autoPinEdge(.left, to: .right, of: verbLabel)
        //jnameLabel.autoPinEdge(.left, to: .right, of: verbLabel, withOffset: 10.0)
        //jnameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
        jnameLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)

        preLabel = jnameLabel

        // 英語名称があった場合
        if !entry.eng.isEmpty{
            let engLabel = UILabel()
            engLabel.text = entry.eng
            engLabel.numberOfLines = 0
            engLabel.copyable = true // コピー可能に
            scrollView.addSubview(engLabel)
            
            engLabel.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
            engLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            engLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)

            preLabel = engLabel
        }
        
        // 中国語名称があった場合
        if !entry.chn.isEmpty{
            let chnLabel = UILabel()
            chnLabel.text = entry.chn
            chnLabel.numberOfLines = 0
            chnLabel.copyable = true // コピー可能に
            scrollView.addSubview(chnLabel)
            
            chnLabel.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
            chnLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            chnLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
            
            preLabel = chnLabel
        }
        
        // 解説があった場合
        if !entry.exp.isEmpty{
            let expLabel = UILabel()

            // "{tib", "}"をすべて取り除く
            var explanation = entry.exp
            while true {
                if let range = explanation.range(of: "{tib "){
                    explanation.replaceSubrange(range, with: "")
                } else {
                    break
                }
            }
            while true {
                if let range = explanation.range(of: "}"){
                    explanation.replaceSubrange(range, with: "")
                } else {
                    break
                }
            }

            expLabel.text = "＊ \(explanation)"
            expLabel.copyable = true // コピー可能に
            expLabel.numberOfLines = 0
            scrollView.addSubview(expLabel)
            
            expLabel.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
            expLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            expLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
            
            preLabel = expLabel
        }
        
        // 画像があった場合
        var preImageView:UIImageView? = nil// ダミー
        if !entry.image.isEmpty {
            let image = UIImage(data: NSData(base64Encoded: entry.image, options: .ignoreUnknownCharacters)! as Data)

            // UIImageView 初期化
            let imageView = UIImageView(image:image)

            // UIImageviewを角丸にする
            imageView.clipsToBounds = true;
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.layer.cornerRadius = 10.0;
            
            // UIImageViewのインスタンスをビューに追加
            scrollView.addSubview(imageView)
            
            imageView.autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
            imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)

            preImageView = imageView // ダミー
        }
        
        // 画像があった場合(スクロールさせるためのダミー)
        if !entry.image.isEmpty {
            let image = UIImage(data: NSData(base64Encoded: entry.image, options: .ignoreUnknownCharacters)! as Data)
            
            // UIImageView 初期化
            let imageView = UIImageView(image:image)
            
            // UIImageviewを角丸にする
            imageView.clipsToBounds = true;
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.layer.cornerRadius = 10.0;
            
            // UIImageViewのインスタンスをビューに追加
            scrollView.addSubview(imageView)
            
            imageView.autoPinEdge(.top, to: .bottom, of: preImageView!, withOffset: 10.0)
            imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
        }
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* 以下は UIScrollViewDelegate のメソッド */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロール中の処理
        print("didScroll")
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // ドラッグ開始時の処理
        print("beginDragging")
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
