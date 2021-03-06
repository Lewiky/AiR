//
//  ViewFlightsViewController.swift
//  AiR
//
//  Created by Brendon Warwick on 13/09/2017.
//  Copyright © 2017 lemoncello. All rights reserved.
//

import Foundation
import UIKit

class ViewFlights: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var flightsCard: UIView!
    @IBOutlet weak var flightsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    var allFlightPaths: [Path]!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        allFlightPaths = [Path]()
        styleView()
        loadFlights()
        flightsTableView.delegate = self
        flightsTableView.dataSource = self
    }
    
    func styleView() {
        flightsCard.layer.cornerRadius = 16
        flightsCard.addShadow(intensity: .Weak)
        flightsTableView.layer.cornerRadius = 8
    }
    
    func loadFlights() {
        var allFlights = [[String:Any]]()
        if let flightIDs = UserDefaults.standard.array(forKey: "flightPaths") as? [String] {
            for flightID in flightIDs {
                guard let data = Server.shared.getPersistedData(forID: flightID) else {
                    print("Error whilst trying to get persisted data")
                    continue
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                    allFlights.append(json)
                } catch {
                    print("Error whilst parsing JSON from persisted flights")
                }
            }
        }
        // Convert to all flight paths
        allFlights.forEach({allFlightPaths.append(Path(source: $0))})
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFlightPaths.count // number of flights
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let flight = allFlightPaths[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "flightCell", for: indexPath) as UITableViewCell
        let cellView = cell.viewWithTag(1)
        cellView?.layer.cornerRadius = 8
        let cellDestination = cell.viewWithTag(2) as? UILabel
        cellDestination?.text = "\(flight.originCode) to \(flight.destinationCode)"
        let cellDestTime = cell.viewWithTag(3) as? UILabel
        cellDestTime?.text = flight.date
        return cell
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
