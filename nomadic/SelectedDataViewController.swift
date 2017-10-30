//
//  SelectedDataViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/25.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import RealmSwift

class SelectedDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var selectedDataTableView: UITableView!
    
    var category = ""
    var tag = ""
    
    var allSelectedData:[DicEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDataTableView.delegate = self
        selectedDataTableView.dataSource = self

        // realmから辞書を読み込み
        let realm = try! Realm()
        let dicEntryArray = realm.objects(DicEntry.self)
        
        for entry in dicEntryArray {
            if (entry.bunrui1.contains(category) || entry.bunrui2.contains(category) || entry.bunrui3.contains(category)) && entry.tags.contains(tag) {
                allSelectedData.append(entry)
            }
        }
        //print("DEBUG_PRINT: category:\(category) tag:\(tag) ... data数:\(allSelectedData.count)")
        
    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSelectedData.count + 1
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedDataCell", for: indexPath)
        
        if indexPath.row == 0 {
            
            cell.textLabel?.text = tag
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.detailTextLabel?.text = ""
            //cell.textLabel?.textColor = UIColor.lightGray
            cell.backgroundColor = UIColor.white
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.textLabel!.font = UIFont(name: "Arial", size: 14)
            cell.textLabel?.text = "\(allSelectedData[indexPath.row - 1].id) : " + allSelectedData[indexPath.row - 1].tname
            cell.detailTextLabel?.text = allSelectedData[indexPath.row - 1].jname
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
        performSegue(withIdentifier: "detailCellSegue",sender: nil)
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let detailViewController:DetailViewController = segue.destination as! DetailViewController
        
        if segue.identifier == "detailCellSegue" {
            let indexPath = self.selectedDataTableView.indexPathForSelectedRow
            detailViewController.id = allSelectedData[indexPath!.row - 1].id
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
