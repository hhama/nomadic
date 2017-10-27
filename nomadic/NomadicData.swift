//
//  NomadicData.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/23.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NomadicData: NSObject {
    var id: String?
    var jname: String?
    var tname: String?
    var wylie: String?
    var tags: String?
    var image: String?
    var eng: String?
    var chn: String?
    var kata: String?
    var pron: String?
    var verb: String?
    var exp: String?
    var bunrui1: String?
    var bunrui2: String?
    var bunrui3: String?
    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.jname = valueDictionary["jname"] as? String
        self.tname = valueDictionary["tname"] as? String
        self.wylie = valueDictionary["wylie"] as? String
        self.tags = valueDictionary["tags"] as? String
        self.image = valueDictionary["image"] as? String
        self.eng = valueDictionary["eng"] as? String
        self.chn = valueDictionary["chn"] as? String
        self.kata = valueDictionary["kata"] as? String
        self.pron = valueDictionary["pron"] as? String
        self.verb = valueDictionary["verb"] as? String
        self.exp = valueDictionary["exp"] as? String
        self.bunrui1 = valueDictionary["bunrui1"] as? String
        self.bunrui2 = valueDictionary["bunrui2"] as? String
        self.bunrui3 = valueDictionary["bunrui3"] as? String
    }
    
    

}
