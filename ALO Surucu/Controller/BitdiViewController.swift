//
//  BitdiViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 25.04.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit

class BitdiViewController: UIViewController {

    @IBOutlet weak var qiymetLabel: UILabel!
    @IBOutlet weak var qozlemeLabel: UILabel!
    @IBOutlet weak var umumiLabel: UILabel!

    var order: Order?

    override func viewDidLoad() {
        super.viewDidLoad()

         NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)

        qiymetLabel.text = "\(order?.price ?? "-") azn"
        qozlemeLabel.text = "\(String(format: "%.2f", order?.cerime ?? -1.0)) azn"
        umumiLabel.text = "\(String(format: "%.2f", (order?.cerime ?? -1.0) + (Double(order?.price ?? "-3.0") ?? -23.0))) azn"

        saveToUserDefaults(.bitdi)

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TamamlaViewController {
            destination.order = order
        }
    }


}
