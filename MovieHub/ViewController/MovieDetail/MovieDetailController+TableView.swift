//
//  MovieDetailController+TableView.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension MovieDetailController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DictionaryCell.self)) as! DictionaryCell
        
        let dictionary = tableViewData[indexPath.row]
        
        if let (key, value) = dictionary.first {
            cell.leftLabel.text = key
            
            if value is Int {
                cell.rightLabel.text = (value as! Int).toCurrencyString()
            } else {
                cell.rightLabel.text = value as? String ?? ""
            }
        }
        
        return cell
    }
    
    
}
