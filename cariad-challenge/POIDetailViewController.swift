//
//  POIDetailViewController.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 04/03/2023.
//

import Foundation
import UIKit

class POIDetailViewController: UIViewController {
    
    struct CellInfo {
        let title: String
        let detail: String
    }
    
    private let station: ChargingStation
    private let dataSource: [CellInfo]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(station: ChargingStation) {
        self.station = station
        self.dataSource = [.init(title: "● Title", detail: station.addressInfo.title),
                           .init(title: "● Charging station address", detail: station.addressInfo.addressLine1),
                           .init(title: "● Number of charging points", detail: station.numberOfPoints?.description ?? "Not available.")]
        super.init(nibName: nil, bundle: nil)
    }
    
     override func viewDidLoad() {
         super.viewDidLoad()
         navigationItem.title = station.addressInfo.title
         tableView.dataSource = self
         view.addSubview(tableView)
         addTableViewConstraints()
     }
    
    private func addTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension POIDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let infoCell = dataSource[indexPath.row]
        var content = cell?.defaultContentConfiguration()
        
        content?.text = infoCell.title
        content?.secondaryText = infoCell.detail

        cell?.contentConfiguration = content
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}
