//
//  ViewController.swift
//  FOREXDemo
//
//  Created by n on 3/2/19.
//  Copyright © 2019 Noble Desktop. All rights reserved.
//

import UIKit
import Alamofire

class SymbolTableViewController: UIViewController, UITableViewDelegate, UISearchResultsUpdating {
    
    
    
    //,UITableViewDataSource {
    
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SymbolTableViewCell")
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymbolTableViewCell")!
        //old cell.textLabel?.text = symbols[indexPath.row]
        cell.textLabel?.text = searchController.isFiltering ? filterdSymbols[indexPath.row] : symbols[indexPath.row]
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
    
}

