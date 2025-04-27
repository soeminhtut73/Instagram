//
//  SkeletonViewController.swift
//  Instagram
//
//  Created by S M H  on 27/03/2025.
//

import UIKit
import SkeletonView

class SkeletonViewController: UIViewController, SkeletonTableViewDataSource {
    
    var data : [String] = []
    
    private var tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 70
        tableView.estimatedRowHeight = 70
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
                    tableView.topAnchor.constraint(equalTo: view.topAnchor),
                    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.register(SkeletonTableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            
            for _ in 0..<30 {
                self?.data.append("New Data!")
            }
            
            self?.tableView.reloadData()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.isSkeletonable = true
//        tableView.showSkeleton(usingColor: .wetAsphalt, transition: .crossDissolve(0.25))
        tableView.showAnimatedSkeleton()
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cell"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Debug: data count : \(data.count)")
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SkeletonTableViewCell
        
        print("Debug: cell text : \(data[indexPath.row])")
        
        if !data.isEmpty {
            cell.profileImageView.image = UIImage(systemName: "person.circle")
            cell.usernameLabel.text = data[indexPath.row]
        }
        return cell
    }
}
