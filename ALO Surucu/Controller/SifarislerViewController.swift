//
//  SifarislerViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 21.04.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftyJSON
import UserNotifications

private let reuseIdentifier = "sifarisCell"

var orders: [Order] = []
var messages: [Message] = []

class SifarislerViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var dollarButton: UIButton!
    @IBOutlet weak var dollarView: UIViewX!

    @IBOutlet weak var carButton: UIButton!
    @IBOutlet weak var carView: UIView!

    @IBOutlet weak var wifiButton: UIButton!
    @IBOutlet weak var wifiView: UIView!

    @IBOutlet weak var plusButton: UIButtonX!

    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!


    var idTextField: UITextField?
    var amountTextField: UITextField?
    var locationManager = CLLocationManager()

    var selectedIndexOfOrder = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .refresh, object: nil)

        createLocationManager()
        locationManager.delegate = self
        assignNavigaionItems()
        downloadUser()

        fullnameLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.adjustsFontSizeToFitWidth = true

        let collectionLayout = SifarislerFlowLayout(numberOfColumns: 1)
        self.collectionView.setCollectionViewLayout(collectionLayout, animated: false)

        socket.event.message = { message in
            let data = (message as! String).data(using: .utf8)! 

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)

                switch response.url {

                case "orders/listDriver":
                    let response = try decoder.decode(OrdersListResponse.self, from: data)
                    orders = response.orders!
                    self.collectionView.reloadData()

                case "error":
                    let alert = UIAlertController(title: response.title, message: response.reason, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true)

                case "orders/new":
                    let order: Order = try decoder.decode(Order.self, from: data)
                    saveToUserDefaults(order)

                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "newOrder") as? NewOrderViewController {
                        vc.order = order
                        self.present(vc, animated: true)
                    }

                case "drivers/refresh":
                    downloadUser()
                    self.refresh()

                case "broadcast/listDriver":
                    let response = try decoder.decode(MessagesListResponse.self, from: data)
                    messages = response.data!
                    self.collectionView.reloadData()

                case "orders/notification":
                    if !(currentUser()?.isBlocked ?? false) && statusGLOBAL != .offline {
                        downloadOrders()
                        if #available(iOS 10.0, *) {
                            createNotification(title: response.title, body: response.body)
                        } else {
                            // Fallback on earlier versions
                        }
                    }

                case "orders/moved":
                    clearOrderDefaults()
                    let alert = UIAlertController(title: "Imtina", message: "Sifariş imtina olunub.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)

                case "orders/check":
                    switch response.state {
                    case true:
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "catdim") as? CatdimViewController {
                            let ordersModel = self.segmentControl.selectedSegmentIndex == 0 ? orders.filter({!($0.isPlanned ?? false)}) : orders.filter({$0.isPlanned ?? false})
                            vc.order = ordersModel[self.selectedIndexOfOrder]
                            self.present(vc, animated: true, completion: nil)
                        }
                    default: break
                    }

                case "drivers/info":
                    let user = try decoder.decode(User.self, from: data)
                    statusGLOBAL = returnStatus(user.status ?? "online")
                    if response.state == false {
                        removeUserFromUserDefaults()
                        clearUserDefaults()
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "login") {
                            self.present(vc, animated: true)
                            return
                        }
                    } else {
                        saveToUserDefaults(user)
                    }
                    self.refresh()

                default: break
                }
            } catch {}
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        downloadUser()
        downloadMessages()
        reachabilityChanged()
        segmentControl.isHidden = tabBarController?.selectedIndex == 1
    }

    func createLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.distanceFilter = 100
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        collectionView.reloadData()
    }

    @objc func refresh() {
        checkUserAccessibility()
        checkTransferAccess()
        assignNavigaionItems()
        setColorOfButtons()
        downloadOrders()
    }

    func assignNavigaionItems() {
        let name = currentUser()?.name ?? ""
        let surname = currentUser()?.surname ?? ""
        let id = currentUser()?.username ?? ""

        let leftTitle = name + " " + surname + " " + id

        let balance = String(format: "%.2f", Double((currentUser()?.balance ?? "-1.0"))!)
        let rightTitle = "Balans: \(balance)"

//        let rr = convertToPrice(price: (Double(currentUser()?.balance ?? "0.0") ?? 0.0), fontSize: 18)

        fullnameLabel.text = leftTitle
        balanceLabel.text = rightTitle
    }

    func checkTransferAccess() {
        dollarView.isHidden = !(currentUser()?.transferAccess ?? false)
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

    func checkUserAccessibility() {
        if currentUser()?.isBlocked ?? false {
            let alert = UIAlertController(title: "Səhv!", message: "Sizin sistemə girişiniz Administrasiya tərəfindən məhdudlaşdırılmısdır", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)

            tabBarController?.toolbarItems?.forEach({ (item) in
                item.isEnabled = false
            })

            collectionView.isHidden = true
        }
        setUIButtons(enabled: !(currentUser()?.isBlocked ?? false))
    }

    func setUIButtons(enabled: Bool) {
        dollarButton.isEnabled = enabled
        carButton.isEnabled = enabled
        wifiButton.isEnabled = enabled
        plusButton.isEnabled = enabled
    }

    @IBAction func dollarPressed() {
        let alert = UIAlertController(title: "Balansın yüklənilməsi", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: idTextField)
        alert.addTextField(configurationHandler: amountTextField)

        let cancel = UIAlertAction(title: "LƏĞV", style: .cancel)

        let sendAction = UIAlertAction(title: "GÖNDƏR", style: .default) { (action) in
            guard let token = currentToken() else {return}
            let request = ["url":"drivers/transfer", "username":currentUser()?.username ?? "no username", "token": token, "target": self.idTextField?.text ?? "-1", "value": self.amountTextField?.text ?? "0"]
            socket.send(request.toJson())
        }

        alert.addAction(cancel)
        alert.addAction(sendAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func carPressed() {
        if statusGLOBAL == .offline || statusGLOBAL == .online {
            statusGLOBAL = .inservice
        } else {
            statusGLOBAL = .online
        }

        collectionView.isHidden = statusGLOBAL == .offline

        guard let token = currentToken() else {return}
        let request = ["url": "drivers/status", "username": currentUser()?.username, "status": statusGLOBAL.rawValue, "token":token]
        socket.send(request.toJson())
        downloadOrders()
        setColorOfButtons()
    }

    @IBAction func wifiPressed() {
        if statusGLOBAL == .offline {
            statusGLOBAL = .online
        } else {
            statusGLOBAL = .offline
        }

        collectionView.isHidden = statusGLOBAL == .offline

        guard let token = currentToken() else {return}
        let request = ["url": "drivers/status", "username": currentUser()?.username, "status": statusGLOBAL.rawValue, "token":token]
        socket.send(request.toJson())
        downloadOrders()
        setColorOfButtons()
    }

    func setColorOfButtons() {
        switch statusGLOBAL {
        case .online:
            wifiButton.backgroundColor = .green
            wifiView.backgroundColor = wifiButton.backgroundColor
            carButton.backgroundColor = grayColor
            carView.backgroundColor = carButton.backgroundColor
        case .offline:
            wifiButton.backgroundColor = grayColor
            wifiView.backgroundColor = wifiButton.backgroundColor
            carButton.backgroundColor = grayColor
            carView.backgroundColor = carButton.backgroundColor
        case .inservice:
            wifiButton.backgroundColor = .green
            wifiView.backgroundColor = wifiButton.backgroundColor
            carButton.backgroundColor = .blue
            carView.backgroundColor = carButton.backgroundColor
        }
    }

    func idTextField(textField: UITextField) {
        idTextField = textField
        idTextField?.placeholder = "ID"
        idTextField?.keyboardType = .numberPad
    }

    func amountTextField(textField: UITextField) {
        amountTextField = textField
        amountTextField?.placeholder = "MİQDAR"
        amountTextField?.keyboardType = .numberPad
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CatdimViewController {
            switch self.tabBarController?.selectedIndex {
            case 0:
                destination.order = orders.filter({!$0.isPlanned!})[selectedIndexOfOrder]
            case 1:
                destination.order = orders.filter({$0.isPlanned!})[selectedIndexOfOrder]
            default: break
            }
        }
    }

}

extension SifarislerViewController: CLLocationManagerDelegate {

    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }

        //        print("locations = \(location.latitude) \(location.longitude)")
        guard let user = currentUser(), let token = currentToken() else {return}
        let request = "{\"url\":\"drivers/location\", \"token\":\"\(token)\", \"username\": \"\(user.username ?? "no user name")\", \"location\":\"\(location.latitude), \(location.longitude)\"}"
        if user.status != "offline" {
            socket.send(request)
        }
    }

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied, .notDetermined:
            print("Location is problem")
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "noGPS") as? ErrorViewController {
                vc.message = noGPSText
                self.present(vc, animated: true)
            }
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse: print("Location status is OK.")
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error in location:", error)
        //        createLocationManager()
    }
}

extension SifarislerViewController: UICollectionViewDelegate, UICollectionViewDataSource  {

    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !allowedToDownload() {
            return 0
        } else {
            switch self.tabBarController?.selectedIndex {
            case 0:
                return segmentControl.selectedSegmentIndex == 0 ? orders.filter({!($0.isPlanned ?? false)}).count : orders.filter({$0.isPlanned ?? false}).count
            case 1:
                return messages.count
            default:
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SifarisCell

        if tabBarController?.selectedIndex == 0 {
            let ordersModel = segmentControl.selectedSegmentIndex == 0 ? orders.filter({!($0.isPlanned ?? false)}) : orders.filter({$0.isPlanned ?? false})
            cell.titleLabel.text = "Gözləmə: " + (ordersModel[indexPath.row].from ?? "")
            cell.dateLabel.text = ordersModel[indexPath.row].timestamp
            cell.timeLabel.text = ordersModel[indexPath.row].time
        } else {
            cell.titleLabel.text = messages[indexPath.row].message
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch self.tabBarController?.selectedIndex {
        case 0:
            let ordersModel = segmentControl.selectedSegmentIndex == 0 ? orders.filter({!($0.isPlanned ?? false)}) : orders.filter({$0.isPlanned ?? false})
            // present alert to ask user
            let alert = UIAlertController(title: nil, message: "Dəqiq qəbul etmək istəyirsiniz ?", preferredStyle: .alert)
            selectedIndexOfOrder = indexPath.row
            let beliAction = UIAlertAction(title: "Bəli", style: .default) { (action) in
                guard let token = currentToken() else {return}
                let request = ["url":"orders/check", "username": currentUser()?.username ?? "", "id": ordersModel[indexPath.row].id, "token": token]
                socket.send(request.toJson())
            }

            let xeirAction = UIAlertAction(title: "Xeir", style: .cancel, handler: nil)

            alert.addAction(xeirAction)
            alert.addAction(beliAction)

            self.present(alert, animated: true, completion: nil)

        default: break
        }
    }

}


