//
//  TamamlaViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 01.06.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit

class TamamlaViewController: UIViewController {

    @IBOutlet weak var gedisTextField: UITextField!
    @IBOutlet weak var carTextField: UITextField!
    @IBOutlet weak var tamamlaButton: UIButton!

    var order: Order?

    override func viewDidLoad() {
        super.viewDidLoad()

        gedisTextField.text = order?.to
        carTextField.text = order?.carNumber
        setTamamlaButton(enabled: false)
        textFieldChanging()

        saveToUserDefaults(.tamamla)

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)

        socket.event.message = { message in
            let data = (message as! String).data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                switch response.url  {
                case "orders/moved":
                    clearOrderDefaults()
                    let alert = UIAlertController(title: "Imtina", message: "Sifariş imtina olunub.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "showTab", sender: self)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                default: break
                }
            } catch {}
        }
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

    override func viewDidDisappear(_ animated: Bool) {
        clearOrderDefaults()
    }

    @IBAction func textFieldChanging() {
        let gedis = gedisTextField.text
        let car = carTextField.text
        let formFilled = gedis != "" && car != ""
        setTamamlaButton(enabled: formFilled)
    }

    func setTamamlaButton(enabled: Bool) {
        if enabled {
            tamamlaButton.alpha = 1.0
            tamamlaButton.isEnabled = true
        } else {
            tamamlaButton.alpha = 0.5
            tamamlaButton.isEnabled = false
        }
    }

    @IBAction func tamamlaPressed() {
        let total: Double = (order?.cerime ?? 0.0) + (Double(order?.price ?? "asd") ?? -100.0)
        guard let token = currentToken(), order != nil else {return}

        let request: [String: Any] = ["url": "orders/finishDriver", "username": currentUser()?.username ?? "no username", "id": order?.id ?? "no identification", "token": token, "cerime": order?.cerime ?? -1.0, "total": "\(total)", "carNumber": carTextField.text ?? "no car number", "to": gedisTextField.text ?? "qedis noqtesi teyin olunmayib"]

        print(request.toJson())
        socket.send(request.toJson())

        if let vc = storyboard?.instantiateViewController(withIdentifier: "tab") {
            self.present(vc, animated: true)
        }
    }

}
