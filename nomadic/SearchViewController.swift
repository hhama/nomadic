//
//  SearchViewController.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/10/26.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var allSearchBar: UISearchBar!
    @IBOutlet weak var searchedTableView: UITableView!
    
    var searchResult:[DicEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        allSearchBar.delegate = self
        searchedTableView.delegate = self
        searchedTableView.dataSource = self
        
        allSearchBar.placeholder = "日本語、チベット語、Wylie、英語"
        allSearchBar.autocapitalizationType = .none

        //何も入力されていなくてもReturnキーを押せるようにする。
        allSearchBar.enablesReturnKeyAutomatically = false


    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchedCell", for: indexPath) as! CustomTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        //cell.textLabel!.font = UIFont(name: "Arial", size: 14)
        cell.myTnameLabel?.text = "\(searchResult[indexPath.row].id) : \(searchResult[indexPath.row].tname)"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.myJnameLabel?.text = searchResult[indexPath.row].jname
        
        return cell
    }

    //サーチボタンクリック時(UISearchBarDelegateを関連づけておく必要があります）
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 検索結果配列を空にする
        searchResult.removeAll()
        
        if !(allSearchBar.text?.isEmpty)! {
            allSearch(searchWord: allSearchBar.text!)
        }
        
        // キーボードを消す
        view.endEditing(true);
        
        // テーブルを再読込
        searchedTableView.reloadData()
    }

    func allSearch(searchWord: String) {

        // realmから辞書を読み込み
        let realm = try! Realm()
        let dicEntryArray = realm.objects(DicEntry.self)
        
        // searchWordの分割
        let allSearchWord = searchWord.components(separatedBy: CharacterSet.whitespaces)

        var tmpSearchResult:[DicEntry] = []
        
        for entry in dicEntryArray {
            if entry.tname.contains(allSearchWord[0]) || entry.jname.contains(allSearchWord[0]) || entry.eng.contains(allSearchWord[0]) || entry.wylie.contains(allSearchWord[0]) || entry.exp.contains(allSearchWord[0]) || entry.chn.contains(allSearchWord[0]){
            tmpSearchResult.append(entry)
            }
        }
        
        if allSearchWord.count >= 2 {
            for entry in tmpSearchResult {
                if entry.tname.contains(allSearchWord[1]) || entry.jname.contains(allSearchWord[1]) || entry.eng.contains(allSearchWord[1]) || entry.wylie.contains(allSearchWord[1]) || entry.exp.contains(allSearchWord[1]) || entry.chn.contains(allSearchWord[1]) {
                    searchResult.append(entry)
                }
            }
        } else {
            searchResult = tmpSearchResult
        }
    }

    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "searchCellSegue",sender: nil)
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let detailViewController:DetailViewController = segue.destination as! DetailViewController
        
        if segue.identifier == "searchCellSegue" {
            let indexPath = self.searchedTableView.indexPathForSelectedRow
            detailViewController.id = searchResult[indexPath!.row].id
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
