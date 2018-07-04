//
//  AssignedPriceViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 31.05.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit

class AssignedPriceViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!

    var order: Order?

    override func viewDidLoad() {
        super.viewDidLoad()

         NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)

        textLabel.text = "Sizin sifarişinizə qiymət təyin olundu.\n" + "Qiymət: \(order?.price ?? "-1") AZN"

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

                case "error":
                    let alert = UIAlertController(title: response.title, message: response.reason, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true)

                case "orders/acceptPrice":
                    self.order = try decoder.decode(Order.self, from: data)
                    self.performSegue(withIdentifier: "showOrderMain", sender: self)

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

    @IBAction func cancelPressed() {
        guard let token = currentToken() else {return}
        let request: [String: Any] = ["url":"orders/cancelPrice", "id": order?.id ?? "no id", "username": currentUser()?.username ?? "no user", "token": token]
        socket.send(request.toJson())
        self.performSegue(withIdentifier: "showTab", sender: self)
    }

    @IBAction func acceptPressed() {
        guard let token = currentToken() else {return}
        let request: [String: Any] = ["url":"orders/acceptPrice", "id": order?.id ?? "no id", "username": currentUser()?.username ?? "no user", "token": token]
        socket.send(request.toJson())
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CatdimViewController {
            destination.order = order
        }
    }
}







