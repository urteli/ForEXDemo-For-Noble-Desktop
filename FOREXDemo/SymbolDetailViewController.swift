//
//  SymbolDetailViewController.swift
//  FOREXDemo
//
//  Created by n on 3/2/19.
//  Copyright © 2019 Noble Desktop. All rights reserved.
//

import UIKit
import Alamofire

struct CurrencyPair: Codable {
    var ask: Double
    var bid: Double
    var symbol: String
}



class SymbolDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    

    var symbols: [String] = []
    var currencyPairs: [CurrencyPair] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SymbolDetailTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "SymbolDetailTableHeaderView")
        
       // https://forex.1forge.com/1.0.3/quotes?pairs=EURUSD,GBPJPY,AUDUSD&api_key=YOUR_API_KEY
        print(symbols)

        let currencyPairsString = symbols.joined(separator: ",")
        let urlString = "https://forex.1forge.com/1.0.3/quotes?pairs=\(currencyPairsString)&api_key=scKdc5njprJwBjonYn417rDniGrve9aM"
        
        Alamofire.request(urlString).responseJSON { response in
            if let responseData = response.data {
                self.currencyPairs = (try? JSONDecoder().decode([CurrencyPair].self, from:  responseData)) ?? []
                self.tableView.reloadData()
            }
        }
    }
        
        
        
        
        
        // Do any additional setup after loading the view.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyPairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyPairTableViewCell") as! CurrencyPairTableViewCell
        let currencyPair = currencyPairs[indexPath.row]
        cell.currencyPairLabel.text = currencyPair.symbol
        cell.bidLabel.text = "\(currencyPair.bid)"
        cell.askLabel.text = "\(currencyPair.ask)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: "SymbolDetailTableHeaderView")!
        default:
            fatalError() //you've asked for a section which doesn't have a header
        }
    }
    
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


