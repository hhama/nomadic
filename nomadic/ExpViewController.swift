//
//  ExpViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/11/03.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import RealmSwift

class ExpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var expTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        expTableView.delegate = self
        expTableView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let expUrlArray = realm.objects(ExpUrl.self)
        
        return expUrlArray.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpCell", for: indexPath)

        // RealmからExpUrlを読む
        let realm = try! Realm()
        let expUrlArray = realm.objects(ExpUrl.self)
        
        // マージンをなくす
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.textLabel!.font = UIFont(name: "Arial", size: 14)
        cell.textLabel?.text = "\(indexPath.row + 1) : " + expUrlArray[indexPath.row].title
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.backgroundColor = UIColor.white
        
        return cell
    }

    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "expCellSegue",sender: nil)
    }

    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let expDetailViewController:ExpDetailViewController = segue.destination as! ExpDetailViewController

        // RealmからExpUrlを読む
        let realm = try! Realm()
        let expUrlArray = realm.objects(ExpUrl.self)

        if segue.identifier == "expCellSegue" {
            let indexPath = self.expTableView.indexPathForSelectedRow
            expDetailViewController.expUrl = expUrlArray[indexPath!.row].url
            expDetailViewController.expTitle = expUrlArray[indexPath!.row].title
        }
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
