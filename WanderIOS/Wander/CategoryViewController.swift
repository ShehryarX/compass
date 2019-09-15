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
    
    static let COMMUNITY = Category(name: "Community", img: "community")
    static let EVENT = Category(name: "Event", img: "event")
    static let RESTAURANT = Category(name: "Restaurant", img: "restaurant")
    static let SHOP = Category(name: "Shop", img: "shops")

    static let ALL: [Category] = [Categories.COMMUNITY, Categories.EVENT, Categories.RESTAURANT, Categories.SHOP]
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

        cell.consume(Categories.ALL[indexPath.row], indexPath.row == Categories.ALL.firstIndex(where: { $0.name == DataManager.shared.selectedCategory})!)
        
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // use it
        DataManager.shared.selectedCategory = Categories.ALL[indexPath.row].name
        
    DataManager.shared.onSelectedCategory(Categories.ALL[indexPath.row].name)
        
        dismiss(animated: true, completion: nil)
    }
    
 
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

class CategoryTableCell: UITableViewCell {
    
    @IBOutlet var icon: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var checkmark: UIImageView!
    
    func consume(_ c : Category, _ isSelected: Bool) {
        name.text = c.name
        checkmark.isHidden = !isSelected
        icon.image = UIImage(named: c.img)
    }
}
