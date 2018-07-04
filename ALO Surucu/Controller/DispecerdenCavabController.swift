//
//  DispecerdenCavabController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 24.04.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit

class DispecerdenCavabController: UIViewController {

    var response: Order?
    var order: Order?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)

        guard let token = currentToken() else {return}
        let request: [String : Any] = ["url":"orders/newOrder", "username": currentUser()?.username ?? "no name", "from": order?.from ?? "", "to": order?.to ?? "", "driver": currentUser()?.username ?? "no id", "token": token, "client": order?.clientNumber ?? "0000"]

        print(request.toJson())
        socket.send(request.toJson())

        socket.event.message = { message in
            let data = (message as! String).data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)

                switch response.url  {
                case "orders/setPrice":
                    self.order?.price = response.price
                    self.order?.id = response.id
                    self.performSegue(withIdentifier: "showPrice", sender: self)

                case "orders/incorrect":
                    let alert = UIAlertController(title: response.title, message: response.reason, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })

                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)

                case "orders/cancel":
                    let alert = UIAlertController(title: response.title, message: response.reason, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })

                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)

                case "orders/noBalance":
                    let alert = UIAlertController(title: response.title, message: response.reason, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true)

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AssignedPriceViewController {
            destination.order = order
        }
    }

}
