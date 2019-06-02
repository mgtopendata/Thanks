//
//  ViewController.swift
//  Thanks
//
//  Created by 岩男高史 on 2019/02/21.
//  Copyright © 2019 岩男高史. All rights reserved.
//

import UIKit
import FirebaseUI

class ViewController: UIViewController,FUIAuthDelegate {
  
  @IBOutlet weak var imageview: UIImageView!
  @IBOutlet weak var button: UIButton!
  // 認証変化の受け取り用オブジェクト
  var handle: AuthStateDidChangeListenerHandle?
  override func viewDidLoad() {
    super.viewDidLoad()
    button.setTitleColor(UIColor.black, for: .normal)
    //imageviewに画像をセットする
    imageview.image = UIImage(named: "loginimage")
    self.view.backgroundColor = UIColor.orange
  }
  
  // 画面が表示された時
  override func viewDidAppear(_ animated: Bool) {
    
    // 認証の状況確認のための処理をクロージャで指定する
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in
      
      if user != nil {
        // User is signed in.
        print("サインインしている")
        
        // ログイン不要なので自動でアプリ画面まで進む
        
        // コードからセグエをたどる
        self.performSegue(withIdentifier: "app1", sender: self)
        
      } else {
        // No user is signed in.
        print("サインインしていない")
      }
    }
  }
  
  // 画面が非表示になるとき
  override func viewWillDisappear(_ animated: Bool) {
    // 認証の状況確認処理が呼ばれないように解除する
    Auth.auth().removeStateDidChangeListener(handle!)
  }

  @IBAction func tapSignInUp(_ sender: UIButton) {
    // 認証用のUIの初期化
    let authUI = FUIAuth.defaultAuthUI()!
    // 認証の状況を自分に伝えてもらう
    authUI.delegate = self
    
    // 認証方式は何も指定しないとメールなので、googleアカウントを追加する
    let providers: [FUIAuthProvider] = [FUIGoogleAuth(),FUIFacebookAuth()]
    authUI.providers = providers
    
    // アプリの利用規約などあれば出せる（例はダミーでサポートサイトのURL)
    let termsOfService = URL(string: "https")!
    authUI.tosurl = termsOfService
    // プライバシーポリシーもいれられる（例はダミーでサポートサイトのURL)
    authUI.privacyPolicyURL = termsOfService
    
    // authUIが作ってくれたビューコントローラーを取得
    let authViewController = authUI.authViewController()
    
    // ログイン選択画面、もしくはログイン画面を出す
    self.present(authViewController, animated: true, completion: nil)
  }
  
  // 認証UIデリゲート
  func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    // handle user and error as necessary
    
    if user != nil {
      // User is signed in.
      print("認証UIで認証できた")
      
      // 認証の状況が変わるのでaddStateDidChangeListenerのクロージャが呼ばれ画面遷移する
      
    } else {
      // No user is signed in.
      print("認証できなかった、理由は",error!.localizedDescription)
    }
  }
}

