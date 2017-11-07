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
        scrollView.backgroundColor = UIColor.white
        
        // 表示窓のサイズと位置を設定
        scrollView.frame.size = CGSize(width: screenWidth, height: screenHeight)
        scrollView.center = self.view.center

        // 新たなViewを作る
        let myView = UIView()
        
        // 中身の大きさを設定
        
        // スクロールの跳ね返り
        scrollView.bounces = true
        
        // スクロールバーの見た目と余白
        scrollView.indicatorStyle = .default
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        // Delegate を設定
        scrollView.delegate = self

        var allHeight: CGFloat = 0.0
        for entry in dicEntryArray {
            if entry.id == id {
                allHeight = printEntry(entry: entry, scrollView: myView)
            }
        }
        
        scrollView.contentSize = CGSize(width: screenWidth, height: allHeight)
        myView.frame.size = CGSize(width: screenWidth, height: allHeight)
        
        scrollView.addSubview(myView)
        self.view.addSubview(scrollView)
   }
    
    // 画面を作る
    func printEntry(entry: DicEntry, scrollView: UIView) -> CGFloat {

        // 全要素の高さの和を求める
        var allHeight:CGFloat = 0.0
        
        // チベット語名称
        let tnameLabel = UILabel()
        tnameLabel.text = "\(id): \(entry.tname)"
        tnameLabel.font = UIFont.systemFont(ofSize: 24)
        tnameLabel.numberOfLines = 0
        tnameLabel.copyable = true // コピー可能に
        scrollView.addSubview(tnameLabel)
        
        let screenSize = UIScreen.main.bounds.size
        // let tnameSize = CGSize(width: screenSize.width - 40, height: 24)
        // tnameLabel.autoSetDimensions(to: tnameSize)
        
        // tnameLabel.autoPinEdge(.top, to: .bottom, of: scrollView, withOffset: 10.0)
        tnameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 10.0)
        tnameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
        tnameLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
        
        tnameLabel.sizeToFit()
        var labelHeight = tnameLabel.sizeThatFits(CGSize(width: screenSize.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
        allHeight += labelHeight + 10.0 // 10.0はInset
        
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
        
        wylieLabel.sizeToFit()
        labelHeight = wylieLabel.sizeThatFits(CGSize(width: screenSize.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
        allHeight += labelHeight + 10.0 // 10.0はInset

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
        // verbLabel.font = UIFont.italicSystemFont(ofSize: 20)
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

        jnameLabel.sizeToFit()
        labelHeight = jnameLabel.sizeThatFits(CGSize(width: screenSize.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
        allHeight += labelHeight + 10.0 // 10.0はInset
        
        
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

            engLabel.sizeToFit()
            labelHeight = engLabel.sizeThatFits(CGSize(width: screenSize.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
            allHeight += labelHeight + 10.0 // 10.0はInset
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

            chnLabel.sizeToFit()
            labelHeight = chnLabel.sizeThatFits(CGSize(width: screenSize.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
            allHeight += labelHeight + 10.0 // 10.0はInset
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
            
            expLabel.sizeToFit()
            labelHeight = expLabel.sizeThatFits(CGSize(width: screenSize.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
            allHeight += labelHeight + 10.0 // 10.0はInset
            //print("DEBUG_PRINT: expLabel: \(labelHeight)")

        }
        
        // 画像があった場合
        var preImageView:UIImageView?
        var imageViewArray:[UIImageView] = []
        if !entry.image.isEmpty {
            
            let imageDataArray = entry.image.components(separatedBy: ",")
            
            for idx in 0..<imageDataArray.count {
                let image = UIImage(data: NSData(base64Encoded: imageDataArray[idx], options: .ignoreUnknownCharacters)! as Data)
                // print("DEBUG_PRINT(イメージの大きさ): \(String(describing: image?.size.width)) x \(String(describing: image?.size.height))")
                
                // UIImageViewの幅・高さ・Insetを求める。
                var viewWidth:CGFloat = 0.0
                var viewHeight:CGFloat = 0.0
                var viewInset:CGFloat = 0.0
                
                let imageWidth = image?.size.width
                let imageHeight = image?.size.height
                if Double(imageWidth!) > Double(imageHeight!) {
                    viewInset = view.frame.width * 0.05
                    viewWidth = view.frame.width - viewInset * 2
                    viewHeight = imageHeight! * viewWidth / imageWidth!
                } else {
                    viewInset = view.frame.width * 0.15
                    viewWidth = view.frame.width - viewInset * 2
                    viewHeight = imageHeight! * viewWidth / imageWidth!
                }
                
                // UIImageView 初期化
                imageViewArray.append(UIImageView(image:image))
                
                // UIImageviewを角丸にする
                imageViewArray[idx].clipsToBounds = true;
                imageViewArray[idx].contentMode = UIViewContentMode.scaleAspectFill
                imageViewArray[idx].layer.cornerRadius = 10.0;
                
                // UIImageViewのインスタンスをビューに追加
                scrollView.addSubview(imageViewArray[idx])

                if idx == 0 {
                    imageViewArray[idx].autoPinEdge(.top, to: .bottom, of: preLabel, withOffset: 10.0)
                } else {
                    imageViewArray[idx].autoPinEdge(.top, to: .bottom, of: preImageView!, withOffset: 10.0)
                }
                imageViewArray[idx].autoSetDimension(.width, toSize: viewWidth)
                imageViewArray[idx].autoSetDimension(.height, toSize: viewHeight)
                imageViewArray[idx].autoPinEdge(toSuperviewEdge: .left, withInset: viewInset)
                imageViewArray[idx].autoPinEdge(toSuperviewEdge: .right, withInset: viewInset)
                
                preImageView = imageViewArray[idx]
                
                imageViewArray[idx].sizeToFit()
                allHeight += viewHeight + 10.0 // 10.0はInset
            }
        }
        
        // bottomの位置を表示
        // print("DEBUG_PRINT: allHeight: \(allHeight)")
        // return allHeight + (self.navigationController?.navigationBar.frame.size.height)!;
        return allHeight;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutBlueRect()
        self.layoutRedRect()
    }
     */
    
    /* 以下は UIScrollViewDelegate のメソッド */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロール中の処理
        // print("didScroll")
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // ドラッグ開始時の処理
        // print("beginDragging")
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
