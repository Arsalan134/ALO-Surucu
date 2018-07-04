//
//  SifarisElaveEtViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 21.04.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

enum Noqte {
    case gozleme, gedis
}

class SifarisElaveEtViewController: UIViewController {

    var order: Order?

    @IBOutlet weak var gozlemeNoqtesiTextField: UITextField!
    @IBOutlet weak var gedisNoqtesiTextField: UITextField!
    @IBOutlet weak var elaqeNomresiTextField: UITextField!

    @IBOutlet weak var elaveEtButton: UIButton!

    var selectedButton: Noqte = .gozleme

    let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: 40.297414, longitude: 49.760809), coordinate: CLLocationCoordinate2D(latitude: 40.431070, longitude: 49.903545))

    var placePicker: GMSPlacePickerViewController!
    let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)

        let config = GMSPlacePickerConfig(viewport: bounds)
        placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self

        setSignupButton(enabled: false)
    }

    @objc func reachabilityChanged() {
        switch socket.readyState {
        case .closed, .closing:
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "noInternet") as? NoInternetViewController {
                self.present(vc, animated: true)
            }
        default: break
        }
    }

    @IBAction func textFieldChanging() {
        let gozleme = gozlemeNoqtesiTextField.text
        let elaqeNomresi = elaqeNomresiTextField.text
        let formFilled = gozleme != "" && elaqeNomresi != ""
        setSignupButton(enabled: formFilled)
    }

    func setSignupButton(enabled:Bool) {
        if enabled {
            elaveEtButton.alpha = 1.0
            elaveEtButton.isEnabled = true
        } else {
            elaveEtButton.alpha = 0.5
            elaveEtButton.isEnabled = false
        }
    }

    @IBAction func gozlemeNoqtesiPressed() {
        selectedButton = .gozleme
        present(placePicker, animated: true, completion: nil)
    }
    
    @IBAction func gedisNoqtesiPressed() {
        selectedButton = .gedis
        present(placePicker, animated: true, completion: nil)
    }

    @IBAction func elaveEtPressed() {
        order = Order(url: "", id: nil, clientNumber: elaqeNomresiTextField.text ?? "0000", from:  gozlemeNoqtesiTextField.text ?? "no gozleme", to: gedisNoqtesiTextField.text ?? "", time: "", timestamp: nil, price: nil, cerime: nil, carNumber: nil, details: nil, isPlanned: nil, coordinator: nil)

        self.performSegue(withIdentifier: "showDispecer", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DispecerdenCavabController {
            destination.order = order
        }
    }
}

extension SifarisElaveEtViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case gozlemeNoqtesiTextField:
            gozlemeNoqtesiTextField.resignFirstResponder()
            gedisNoqtesiTextField.becomeFirstResponder()
        case gedisNoqtesiTextField:
            gedisNoqtesiTextField.resignFirstResponder()
            elaqeNomresiTextField.becomeFirstResponder()
        case elaqeNomresiTextField:
            elaqeNomresiTextField.resignFirstResponder()
        default: break
        }
        return true
    }
}

extension SifarisElaveEtViewController: GMSPlacePickerViewControllerDelegate {

    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        viewController.dismiss(animated: true, completion: nil)

        switch selectedButton {
        case .gozleme:
            gozlemeNoqtesiTextField.text = "\(place.name)"
        case .gedis:
            gedisNoqtesiTextField.text = "\(place.name)"
        }
    }

    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}



