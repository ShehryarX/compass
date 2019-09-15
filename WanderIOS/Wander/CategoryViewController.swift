//
//  CategoryViewController.swift
//  Wander
//
//  Created by Nigga on 2019-09-15.
//  Copyright © 2019 Shahbaz Momi. All rights reserved.
//

import Foundation
import UIKit

class Categories {
    
    static let COMMUNITY = Category(name: "Community", img: "pin")
    static let EVENTS = Category(name: "Events", img: "pin")
    static let RESTAURANTS = Category(name: "Restaurants", img: "pin")
    static let SHOPS = Category(name: "Shops", img: "pin")

    static let ALL: [Category] = [Categories.COMMUNITY, Categories.EVENTS, Categories.RESTAURANTS, Categories.SHOPS]
}

struct Category {
    
    let name: String
    let img: String
    
}

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // harcoded 4 sections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableCell

        cell.consume(Categories.ALL[indexPath.row])
        
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // TODO: category set
        // use it
    }
    
 
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

class CategoryTableCell: UITableViewCell {
    
    @IBOutlet var icon: UIImageView!
    @IBOutlet var name: UILabel!
    
    func consume(_ c : Category) {
        name.text = c.name
        
    }
}
