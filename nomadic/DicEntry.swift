//
//  DicEntry.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/24.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import RealmSwift

class DicEntry: Object {
    // 辞書エントリー番号
    dynamic var id = "0"
    
    // 日本語名称
    dynamic var jname = ""
    
    // チベット語名称
    dynamic var tname = ""
    
    // Wylie表記
    dynamic var wylie = ""
    
    // タグ
    dynamic var tags = ""

    // イメージファイル名
    dynamic var image = ""
    
    // 英語名称
    dynamic var eng = ""
    
    // 中国語名称
    dynamic var chn = ""
    
    // カタカナ表記
    dynamic var kata = ""
    
    // 発音表記
    dynamic var pron = ""
    
    // 動詞フラグ
    dynamic var verb = ""
    
    // 解説
    dynamic var exp = ""
    
    // 分類1
    dynamic var bunrui1 = ""
    
    // 分類2
    dynamic var bunrui2 = ""
    
    // 分類3
    dynamic var bunrui3 = ""
    
    //id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
