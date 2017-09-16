//
//  CreateFlightViewController.swift
//  AiR
//
//  Created by Brendon Warwick on 13/09/2017.
//  Copyright © 2017 lemoncello. All rights reserved.
//

import Foundation
import UIKit

class CreateFlight: UIViewController, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var parentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var parentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var createFlightTitle: UILabel!
    @IBOutlet weak var flightNoTextField: UITextField!
    @IBOutlet weak var flightTimePicker: UIDatePicker!
    @IBOutlet weak var createFlightParentView: UIView!
    @IBOutlet weak var createFlightButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var creatingView: UIView!
    
    var flightNo = ""
    var flightDate = Date()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Initialization
    override func viewDidLoad() {
        flightNoTextField.delegate = self
        initialStyle()
    }

    func initialStyle(){
        self.moveCard(direction: .Up)
        parentView.layer.cornerRadius = 16
        parentView.addShadow(intensity: .Weak)
        createFlightParentView.layer.cornerRadius = 8
        flightTimePicker.setValue(UIColor.white, forKeyPath: "textColor")
        creatingView.layer.cornerRadius = 8
        creatingView.addShadow(intensity: .Ehh)
    }

    // MARK: - Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        flightNo = textField.text!
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        flightNo = textField.text!
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    @IBAction func dateChanged(_ sender: Any) {
        flightDate = flightTimePicker.date
        print("New Date: \(flightDate)")
    }

    // MARK: - Actions
    enum Direction {
        case Up
        case Down
    }
    
    func moveCard(direction: Direction) {
        DispatchQueue.main.async {
            if self.sizeClass() == (.compact, .regular) {
                self.parentViewTopConstraint.constant = direction == .Up ? 55 : 600
                self.parentViewBottomConstraint.constant = direction == .Up ? -20 : 580
            } else {
                self.parentViewTopConstraint.constant = direction == .Up ? 200 : 765
                self.parentViewBottomConstraint.constant = direction == .Up ? -202 : 402
            }
            UIView.animate(withDuration: 1.4) { self.view.layoutIfNeeded() }
        }
    }

    @IBAction func createFlightClicked(_ sender: Any) {
        if map(regex: "([A-Z]{3})([0-9]{1,4})([A-Za-z]?)", to: flightNo) {
            Server.shared.CreateFlight(flightNumber: flightNo, flightTime: flightDate) { (success, payload) in
                self.moveCard(direction: .Down)
                if success {
                    print("Successfully created flight with ID \(String(describing: payload))")
                    DispatchQueue.main.async {
                        self.getData(withID: payload)
                    }
                } else {
                    self.moveCard(direction: .Up)
                    print("Could not create flight, error: \(String(describing: payload))")
                    createDialogue(title: "Could not create flight", message: payload, parentViewController: self, dismissOnCompletion: false)
                }
            }
        } else {
            self.moveCard(direction: .Up)
            createDialogue(title: "Could not create flight", message: "Please enter a valid flight number", parentViewController: self, dismissOnCompletion: false)
        }

//        let fixedDemoID = "_R_BwobGsF8iqTWD"
//        self.moveCard(direction: .Down)
//        self.getData(withID: fixedDemoID)
    }

    func getData(withID id : String){
        print("Requestinging with ID \(id)")
        Server.shared.FetchData(with: id) { (data, error) in
            guard error == nil else {
                self.moveCard(direction: .Up)
                createDialogue(title: "Error getting data for this flight", message: error!, parentViewController: self, dismissOnCompletion: false)
                return
            }

            //Persists the flightPath in the IDs
            if var existing = UserDefaults.standard.array(forKey: "flightPaths") {
                existing.append(id)
                UserDefaults.standard.set(existing, forKey: "flightPaths")
            } else {
                UserDefaults.standard.set([id], forKey: "flightPaths")
            }

            createDialogue(title: "Flight Successfully Created!", message: "Now you just have to launch AiR on the day of your flight.", parentViewController: self, dismissOnCompletion: true)
        }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
