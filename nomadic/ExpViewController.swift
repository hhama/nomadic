//
//  ExpViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/11/03.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit

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
        return Const.ExpUrl.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpCell", for: indexPath)
        
        // マージンをなくす
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.textLabel!.font = UIFont(name: "Arial", size: 14)
        cell.textLabel?.text = "\(indexPath.row + 1) : " + Const.ExpTitle[indexPath.row]
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
        
        if segue.identifier == "expCellSegue" {
            let indexPath = self.expTableView.indexPathForSelectedRow
            expDetailViewController.expUrl = Const.ExpUrl[indexPath!.row]
            expDetailViewController.expTitle = Const.ExpTitle[indexPath!.row]
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
