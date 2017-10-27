//
//  TagsViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/25.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import RealmSwift

class TagsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var category = ""
    var categoryId = 0
    
    var tagsArray:[String] = []
    
    @IBOutlet weak var tagsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tagsTableView.delegate = self
        tagsTableView.dataSource = self

        // realmから辞書を読み込み
        let realm = try! Realm()
        let dicEntryArray = realm.objects(DicEntry.self)
        
        var allTags:[String] = []
        for dicEntry in dicEntryArray {
            if dicEntry.bunrui1.contains(category) || dicEntry.bunrui2.contains(category) || dicEntry.bunrui3.contains(category) {
                allTags += dicEntry.tags.components(separatedBy: ",")
                
            }
        }

        if !allTags.isEmpty {
            //allItem内の重複する要素を取り除く
            let orderedSet = NSOrderedSet(array: allTags)
            tagsArray = orderedSet.array as! [String]
        }
    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagsArray.count + 1
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath)

        if indexPath.row == 0 {
            
            cell.textLabel?.text = "\(categoryId) : " + category
            cell.textLabel?.textColor = UIColor.lightGray
            cell.backgroundColor = UIColor.white
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            cell.textLabel!.font = UIFont(name: "Arial", size: 14)
            cell.textLabel?.text = "\(indexPath.row) : " + tagsArray[indexPath.row - 1]
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 {
            return nil
        } else {
            return indexPath
        }
    }

    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "tagsCellSegue",sender: nil)
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let selectedDataViewController:SelectedDataViewController = segue.destination as! SelectedDataViewController
        
        if segue.identifier == "tagsCellSegue" {
            let indexPath = self.tagsTableView.indexPathForSelectedRow
            selectedDataViewController.category = category
            selectedDataViewController.tag = tagsArray[indexPath!.row - 1]
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
