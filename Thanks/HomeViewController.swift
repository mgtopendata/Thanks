//
//  HomeViewController.swift
//  Thanks
//
//  Created by 岩男高史 on 2019/02/23.
//  Copyright © 2019 岩男高史. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseStorage
import AVFoundation
import AssetsLibrary

//collectionviewに設定するcell
private let reuserIdentifer = "Cell"

class HomeViewController: UIViewController, FUIAuthDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
  //collectionview
  @IBOutlet weak var collectionview: UICollectionView!
//  weak var refresh:UIRefreshControl!
  
  //indicator作成
  weak var activityIndicator1 : UIActivityIndicatorView!
  //handle設定
  var handle:AuthStateDidChangeListenerHandle?
  //データベース
  var ref:DatabaseReference!
  //profileのurl
  var profile:URL?
  //配列url
  var urlarray:[String] = []
  var tumbnailarray:[Data] = []
  //cellのview処理
  enum Tag:Int {
    case image = 1
  }
  

  @IBOutlet weak var navigationbar: UINavigationItem!
  @IBOutlet weak var barbuttonitem: UIBarButtonItem!
  
  
  override func viewDidLoad() {
        super.viewDidLoad()
//    //refreshcontroll作成
//    let refreshcontroll = UIRefreshControl()
//    //actionにstorage処理
//    self.refresh = refreshcontroll
//    self.refresh.addTarget(self, action: #selector(reloadhome), for: .touchUpInside)
//
//    //collectionviewに登録
//    self.collectionview.refreshControl = self.refresh
    
    //user情報を得る
    guard let user = Auth.auth().currentUser else {
      print("何か違います")
      return
    }
    profile = user.photoURL
    
    //view背景色
    self.view.backgroundColor = UIColor.orange
    //navigationbar線設定
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    //collection背景色
    collectionview.backgroundColor = UIColor.orange
    //barbuttonitemのcostumviewに乗せるボタンを作る
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    //databasenの参照を得る
    self.ref = Database.database().reference()
    self.ref.child("urers").child("\(user.uid)").observe(DataEventType.value, with: { (snapshot) in
      if let dic = snapshot.value as? NSDictionary {
      let url = dic["url"] as? String
      if let stringurl = url {
        let ulr = URL(string: stringurl)
        let imagedata = NSData(contentsOf: ulr!)
        button.setImage(UIImage(data: imagedata! as Data), for: .normal)
        
      } else {
        print("存在しません")
        if let profile = self.profile {
          let data = NSData(contentsOf: profile)
          button.setImage(UIImage(data: data! as Data), for: .normal)
          self.ref.child("urers").child("\(user.uid)").setValue(["url": "\(profile)"])
        } else {
          button.setImage(UIImage(named: "noimage"), for: .normal)
        }

      }
        
      } else {
        if let profile = self.profile {
          let data = NSData(contentsOf: profile)
          button.setImage(UIImage(data: data! as Data), for: .normal)
        } else {
          button.setImage(UIImage(named: "noimage"), for: .normal)
        }
      }
    })
    
    //profile設定遷移用のボタン作成
    barbuttonitem.customView = button
    button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
    reloadhome()
  
    }
  
  
  
  
  @IBAction func tapSettings(_ sender: UIBarButtonItem) {
    print("tapped")
    let next = storyboard!.instantiateViewController(withIdentifier: "settings") 
    present(next, animated: true, completion: nil)
  }
  
  @IBAction func taplogout(_ sender: UIBarButtonItem) {
    //ログアウトのためのAUthUIをえる
    let fui = FUIAuth.defaultAuthUI()
    // logout
    do {
      try fui?.signOut()
      //画面遷移
      let next = storyboard!.instantiateViewController(withIdentifier: "sign")
      present(next, animated: true, completion: nil)
    } catch let error {
      print("\(error)")
    }
    
  }
  
  @objc func tap(_ sender: UIButton) {
    print("tapped")
    let next = storyboard!.instantiateViewController(withIdentifier: "settings")
    present(next, animated: true, completion: nil)
  }
  
  //cellに入れるurlをとりだす
  func reloadhome() {
    
    //urlをとりだす
    self.ref.child("movies").observe(.childAdded) { (snapshot, error) in
      if let data = snapshot.value as? NSDictionary {
        let url = data["url"] as! String
        self.urlarray.append(url)
      } else {
        let error = error!
        print(error.localizedCapitalized)
      }
      self.collectionview.reloadData()
    }
    
    self.ref.child("images").observe(.childAdded) { (snapshot, error) in
      if let data = snapshot.value as? NSDictionary {
        let url = data["thumbnail"] as? String
        let url1 = URL(string: url!)
        let nsdata = NSData(contentsOf: url1!)
        let data = nsdata as Data?
        self.tumbnailarray.append(data!)
      } else {
        let error = error!
        print(error.localizedCapitalized)
      }
      self.collectionview.reloadData()
    }
    
//    self.collectionview.reloadData()
  }
  
//  func reload() {
//    self.ref.child("movies").observeSingleEvent(of: .value, with: { (snapshot) in
//      if let data = snapshot.value as? NSDictionary {
//        let url = data["url"] as! String
//        self.urlarray.append(url)
//
//      }
//    })
//  }
  
//  func createThumbnailOfVideoFromRemoteUrl(url: String) -> UIImage? {
//    let asset = AVAsset(url: URL(string: url)!)
//    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
//    assetImgGenerate.appliesPreferredTrackTransform = true
//    var acutualtime = CMTime.zero
//
//    let time:CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
//    do {
//      let img = try assetImgGenerate.copyCGImage(at: time, actualTime: &acutualtime)
//      print("こんにちは")
//      print(img)
//      var count = 0
//      print("\(count)")
//      count += 1
//      let thumbnail = UIImage(cgImage: img)
//      return thumbnail
//    } catch {
//      print(error.localizedDescription)
//      return nil
//    }
//  }
  
  
  //セルの個数？
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //arrayの個数を返す
    //    print(urlarray)
    return tumbnailarray.count
  }
  //cellの設定
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //cellの登録
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuserIdentifer, for: indexPath)
    
    let thumbnail = self.tumbnailarray[indexPath.row]
    
    let imageview = cell.contentView.viewWithTag(1) as! UIImageView
    imageview.image = UIImage(data: thumbnail)
    
    return cell
  }

}

