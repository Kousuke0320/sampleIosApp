//
//  ViewController.swift
//  sapleiosApp
//
//  Created by 田中康介 on 2019/07/10.
//  Copyright © 2019 田中康介. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var locationManager: CLLocationManager!
    var lat: Double?
    var lon: Double?
    var tableViewArray = [UITableViewCell]()
    
    var articles: Article = Article()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCell()
        
        setupLocationManager()
        
        setUpTableView: do {
            tableView.frame = view.frame
            tableView.dataSource = self
            view.addSubview(tableView)
        }
        
        button.rx.tap.subscribe{ [unowned self] _ in
            let connectATabelog = ConnectToTabelog()
            //ワードで検索®
            connectATabelog.fetchArticle(name: self.textField.text, completion: { (articles) in
                guard let articleValue = articles else {
                    return
                }
                //なぜかnilがはいる
                self.articles = articleValue

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    //self.showAnimation()
                }

            })
            //緯度経度で検索
//            connectATabelog.fetchArticle(lat: self.lat, lon: self.lon, completion: { (articles) in
//                guard let articleValue = articles else {
//                    return
//                }
//                //なぜかnilがはいる
//                self.articles = articleValue
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    //self.showAnimation()
//                }
//            })
            
            }.disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .map {$0.description}
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
    
    func showAnimation() {
        let animationView = AnimationView(name: "Animation")
        animationView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1
        view.addSubview(animationView)
        
        animationView.play()
    }
    
    func setupLocationManager() {
        //位置情報取得インスタンス
        locationManager = CLLocationManager()
        
        guard let locationManager = locationManager else {
            return
        }
        //位置情報取得をリクエスト
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        // 使用時に位置情報を許可した時に実施
        if status == .authorizedWhenInUse {
            //viewController自身をdelegate(向先に設定する)
             locationManager.delegate = self
            //10m単位で位置情報を取得する
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        lat = location?.coordinate.latitude
        lon = location?.coordinate.longitude
     //   print("location\(lat)\(lon)")
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setUpCell() {
        self.tableView.register(UINib(nibName: "CustomCellTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCellTableViewCell")
//
//        guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "GroupCustomCellVIew") as? GroupCustomCellView else {
//            return
//        }
//
//        tableViewArray.append(tableViewCell)
    }
    
    //cellをセットする
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 //       let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellTableViewCell") as! CustomCellTableViewCell
        let article = articles
        let rest = article.rest?[indexPath.row]
        //cell.textLabel?.text = rest?.name
        cell.label.text = rest?.name
        
        guard let stringUrl = rest?.image_url?.shop_image1, !stringUrl.isEmpty else {
            return cell
        }
        
        let url = URL(string: stringUrl)
        do {
            let data = try Data(contentsOf: url!)
            let image = UIImage(data: data)
            //cell.imageView?.image = image
            cell.iamgeCell.image = image
        }catch let err {
            print("Error : \(err.localizedDescription)")
        }
        
        return cell
    }
    
    //cellの数をセットする
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.rest?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
