//
//  SkeletonViewController.swift
//  Instagram
//
//  Created by S M H  on 27/03/2025.
//

import UIKit

class SkeletonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var data : [String] = []
    
    private var tableView : UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 70
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}
