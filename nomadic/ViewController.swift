//
//  ViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/23.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        let dataReading = DataReading()
        dataReading.dataReading(view: self.view)
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

    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

