//
//  ViewController.swift
//  FOREXDemo
//
//  Created by n on 3/2/19.
//  Copyright © 2019 Noble Desktop. All rights reserved.
//

/*
 HomeWork for next week show two tabs on top show favorites symbols in second tab
*/

import UIKit
import Alamofire
import Firebase

class SymbolTableViewController: UIViewController, UITableViewDelegate, UISearchResultsUpdating, SymbolTableViewCellDelegate {
    
    
    //,UITableViewDataSource {

    
    lazy var db = Firestore.firestore()
    var favoritesData: [String: Bool] = [:]  //firebase requirements
//    var ref: DatabaseReference!
//    ref = Database.database().reference()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    var symbols: [String] = []
    var filterdSymbols: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search FX Pairs"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //db.collection("example-collection").addDocument(data:["Example2" : "1231231s]"])
        
 //       db.collection("favorites").addDocument(data: ["BCHDSH" : true, "USDCAD": false])
        
        //db.collection("favorites").addSnapshotListener { (snapshot, error) in
        //    self.favoritesData = snapshot?.documents ?? []
        
        db.collection("favorites").document("currentUser").addSnapshotListener {(snapshot, error) in
            self.favoritesData = snapshot?.data() as? [String:Bool] ?? [:]
            self.tableView.reloadData()
            
        }
        
        
// this breaks it tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SymbolTableViewCell")
        
        let urlString = "https://forex.1forge.com/1.0.3/symbols?api_key=scKdc5njprJwBjonYn417rDniGrve9aM"
        //"https://forex.1forge.com/1.0.3/quotes?pairs=EURUSD,GBPJPY,AUDUSD&api_key=scKdc5njprJwBjonYn417rDniGrve9aM"
        
        Alamofire.request(urlString).responseJSON{ response in
            if let responseData = response.data {
                self.symbols = (try? JSONDecoder().decode([String].self, from: responseData)) ?? []
                self.tableView.reloadData()
                print(response)
            }
            
        }// Do any additional setup after loading the view, typically from a nib.
    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return symbols.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SymbolTableViewCell")!
//        cell.textLabel?.text = symbols[indexPath.row]
//        return cell
//    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "SymbolTableViewController_to_SymbolDetailViewController":
            guard let destination = segue.destination as? SymbolDetailViewController else {
                fatalError() //you'e changed the class of the destination
            }
            for indexPath in tableView.indexPathsForSelectedRows ?? [] {
                destination.symbols.append(symbols[indexPath.row])
            }
        default:
            fatalError() // you've defined a segue without implementing prepare
        }
        
        
    }
    
    
    
    
    
}


extension SymbolTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isFiltering ? filterdSymbols.count : symbols.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymbolTableViewCell", for: indexPath) as! SymbolTableViewCell
        let symbol: String = searchController.isFiltering ? filterdSymbols[indexPath.row] : symbols[indexPath.row]
        cell.titleLabel.text = symbol
        cell.favoriteSwitch.isOn = favoritesData[symbol] ?? false
        cell.delegate = self
        //old cell.textLabel?.text = symbols[indexPath.row]
        //cell.titleLabel.text = searchController.isFiltering ? filterdSymbols[indexPath.row] : symbols[indexPath.row]
        cell.selectionStyle = .none
        let cellIsSelected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false
        cell.accessoryType = cellIsSelected ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableVieww:UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
            cell.accessoryType = .checkmark
        enableDoneButtonIfNecessary()
        }
        

    func tableView(_ tableView:UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
        enableDoneButtonIfNecessary()
    }
    
    func enableDoneButtonIfNecessary() {
        doneBarButtonItem.isEnabled = (tableView.indexPathsForSelectedRows?.count ?? 0) > 0
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filterdSymbols = symbols.filter({ (symbol) -> Bool in
            return symbol.contains(searchText.uppercased())
        })
        tableView.reloadData()
    }
    
    func symbolTableViewCellValueDidChange(_ cell: SymbolTableViewCell) {
        let symbol = cell.titleLabel.text!
        let value = cell.favoriteSwitch.isOn
        favoritesData[symbol] = value
        db.collection("favorites").document("currentUser").updateData(favoritesData)
        
    }
    
}

