//
//  NewOrderViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 05.06.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit

class NewOrderViewController: UIViewController {

    var order: Order?

    @IBOutlet weak var gozlemeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)

        if order != nil {
            saveToUserDefaults(.newOrder)
        }

        gozlemeLabel.text = order?.from
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
                case "orders/acceptDriver":
                    if response.state ?? false {
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "catdim") as? CatdimViewController {
                            vc.order = self.order
                            self.present(vc, animated: true)
                        }
                    } else {
                        clearOrderDefaults()
                        self.dismiss(animated: true)
                    }
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

    @IBAction func imtina() {
        // present alert to ask user
        let alert = UIAlertController(title: nil, message: "Dəqiq imtina etmək istəyirsiniz?", preferredStyle: .alert)
        let beliAction = UIAlertAction(title: "Bəli", style: .default) { (action) in
            guard let token = currentToken() else {return}
            let request = ["url":"orders/cancelDriver", "username": currentUser()?.username ?? "", "id": self.order?.id ?? "no id of order", "token": token]
                socket.send(request.toJson())
                downloadUser()
                self.dismiss(animated: true)
        }
        let xeirAction = UIAlertAction(title: "Xeir", style: .cancel, handler: nil)
        alert.addAction(xeirAction)
        alert.addAction(beliAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func qebul() {
        guard let token = currentToken() else {return}
        let request = ["url":"orders/acceptDriver", "username": currentUser()?.username ?? "", "id": self.order?.id ?? "no id of order", "token": token]
        socket.send(request.toJson())
    }



}
