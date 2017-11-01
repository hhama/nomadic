//
//  UpdataTime.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/24.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import RealmSwift

class UpdateTime: Object {
    // 現在Realm内に入っている辞書のバージョン(UNIX時間)
    dynamic var updateTime = 0
}

