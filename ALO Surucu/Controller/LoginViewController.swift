//
//  LoginViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 29.05.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit
import SwiftyJSON
import CryptoSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)

        socket.event.message = { message in
            let data = (message as! String).data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                if response.url == "drivers/login" {
                    if response.state == true {
                        let token = response.token
                        let username = response.username

                        UserDefaults.standard.set(token, forKey: tokenKeyString)

                        let user: User = User(url: "", name: nil, surname: nil, status: nil, isBlocked: nil, balance: nil, transferAccess: nil, username: username)
                        saveToUserDefaults(user)

                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "tab") {
                            self.present(vc, animated: true)
                        }


                    } else {
                        let alert = UIAlertController(title: "Səhv", message: response.reason, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true)
                    }
                }
            } catch (let error) {
                print(error)
            }
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

    @IBAction func loginPressed() {
        let text = passwordTextField.text ?? ""
        let data = text.data(using: String.Encoding.ascii)
        let hash = data?.sha256()

        let request = ["url": "drivers/login", "username": usernameTextField.text ?? "", "password": hash?.toHexString()]
        socket.send(request.toJson())
    }
}



