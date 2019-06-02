//
//  RANKINGViewController.swift
//  Thanks
//
//  Created by 岩男高史 on 2019/02/24.
//  Copyright © 2019 岩男高史. All rights reserved.
//

import UIKit
import FirebaseUI

class RANKINGViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
  weak var activityIndicator1 : UIActivityIndicatorView!
  
  //参照を作る
  var ref: DatabaseReference!
  var namearray:[String] = []
  var timearray:[String] = []
  var imagearray:[Data] = []
  var list:[String:Any] = [:]
//tableview接続
  @IBOutlet weak var tableview: UITableView!
  override func viewDidLoad() {
        super.viewDidLoad()
    //リフレッシュコントロールを作る
    let refreshControll = UIRefreshControl()
    refreshControll.addTarget(self, action: #selector(reloadranking), for: .valueChanged)
    self.tableview.refreshControl = refreshControll
//    self.tableview.refreshControl?.attributedTitle = NSAttributedString(string: "下げて更新")
    
    //大きいインジケータを作成
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    self.activityIndicator1 = activityIndicator
    activityIndicator1.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    activityIndicator1.layer.cornerRadius = 5
    activityIndicator1.frame.size = CGSize(width: 100, height: 100)
    activityIndicator1.center = self.view.center
    activityIndicator1.hidesWhenStopped = true
    self.view.addSubview(activityIndicator1)
//    self.reloadranking()
    
    //背景色変える
      self.view.backgroundColor = UIColor.orange
    //navigatiionbarの線を消す
      self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
      self.navigationController?.navigationBar.shadowImage = UIImage()
    //tableviewの背景色を変える
      tableview.backgroundColor = UIColor.orange
    //tableviewにcellを登録する
      self.tableview.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell1")
    
      self.ref = Database.database().reference()

      self.reloadranking()
 
    
//    print("\(array)")
        // Do any additional setup after loading the view.
    }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return namearray.count
  
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //cell作成
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1") as! CustomTableViewCell
  

//    cell.rankingimage.image = UIImage(data: data! as? Data)
    cell.rankingname.text = namearray[indexPath.row]
    cell.rankingtime.text = timearray[indexPath.row]
    cell.rankingimage.image = UIImage(data: imagearray[indexPath.row])
    
    cell.rankinglabel.text = "\((indexPath.row) + 1)"
    
    cell.backgroundColor = UIColor.orange
    
//    cell.rankingtime.text = timearray![indexPath.row]
    
    return cell
  }
  
  @objc func reloadranking() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    self.activityIndicator1.startAnimating()
    self.namearray = []
    self.timearray = []
    self.imagearray = []
    self.ref = Database.database().reference()
    self.ref.child("urers").queryOrdered(byChild: "time").observe(.childAdded) { (snapshot) in
      guard let dic = snapshot.value as? [String: Any] else { return }
    
      let name = dic["name"] as? String
      self.namearray.append(name!)
      var time = dic["time"] as? String
      time = time?.replacingOccurrences(of: "-", with: "")
      self.timearray.append(time!)
    print(time!)
      let string = dic["url"] as? String 
      let image = URL(string: string!)
      let data = NSData(contentsOf: image!)
      let dat = data! as Data
      self.imagearray.append(dat)
      
      //      let url = URL(string: string)
      //      let data = NSData(contentsOf: url!)
      
      DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activityIndicator1.stopAnimating()
        self.tableview.refreshControl?.endRefreshing()
      }
      
      self.tableview.reloadData()
    }
  }
  
  @IBAction func tapvideo(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "撮影しますか？", message: "7秒動画を投稿できます", preferredStyle: UIAlertController.Style.alert)
    
    let efault = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) -> Void in
      let next = self.storyboard!.instantiateViewController(withIdentifier: "video")
      self.present(next, animated: true,completion: nil)
    })
    let cancel = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler: nil)
    
    alert.addAction(efault)
    alert.addAction(cancel)
    
    present(alert, animated: true, completion: nil)
    
    
  }
  
  @objc func govideo() {
    let next = storyboard!.instantiateViewController(withIdentifier: "video")
    present(next, animated: true, completion: nil)
  }
  
  
}
