//
//  SettingsViewController.swift
//  Thanks
//
//  Created by 岩男高史 on 2019/02/23.
//  Copyright © 2019 岩男高史. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseStorage
import SDWebImage

class SettingsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate,FUIAuthDelegate {
  
  
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var textfield: UITextField!
  @IBOutlet weak var setbutton: UIBarButtonItem!
  @IBOutlet weak var navigationbar: UINavigationBar!
  @IBOutlet var imagetapped: UITapGestureRecognizer!
  var ref: DatabaseReference!
  var count:String!
  var profile:URL?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      //user情報を得る
      guard let user1 = Auth.auth().currentUser else {
        print("何か違います")
        return
      }
      profile = user1.photoURL
      
      self.ref = Database.database().reference()
      self.ref.child("urers").child("\(user1.uid)").observe(DataEventType.value, with: { (snapshot) in
        if let dic = snapshot.value as? NSDictionary {
        let url = dic["url"] as? String
          if let name = dic["name"] as? String {
            self.textfield.text = name
          } else {
            self.textfield.text = user1.displayName ?? "username"
          }
        if let stringurl = url {
          let ulr = URL(string: stringurl)
          let imagedata = NSData(contentsOf: ulr!)
          self.image.image = UIImage(data: imagedata! as Data)
          
        } else {
          print("存在しません")
          if let profile = self.profile {
            let data = NSData(contentsOf: profile)
            self.image.image = UIImage(data: data! as Data)
          } else {
            self.image.image = UIImage(named: "noimage")
          }
        }
        
        } else {
          if let profile = self.profile {
            let data = NSData(contentsOf: profile)
            self.image.image = UIImage(data: data! as Data)
          } else {
            self.image.image = UIImage(named: "noimage")
          }
        }
      })
      
      image.layer.borderWidth = 1
      image.layer.masksToBounds = false
      image.layer.cornerRadius = image.frame.size.width/2
      image.clipsToBounds = true
      
      image.contentMode = .scaleAspectFit
      image.isUserInteractionEnabled = true
      image.addGestureRecognizer(imagetapped)
      
      self.navigationbar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
      self.navigationbar.shadowImage = UIImage()
      
      setbutton.isEnabled = false
      
      
      
      self.view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
      
    }
  
  @IBAction func tapset(_ sender: UIBarButtonItem) {
    
    let data = image.image?.pngData()
    
    let storage = Storage.storage()
    let storageRef = storage.reference(forURL: "gs://thanks-2-f6797.appspot.com/")
    //user情報を得る
    guard let user = Auth.auth().currentUser else {
      print("何か違います")
      return
    }
    let uid = user.uid
    let ref = storageRef.child("images/\(uid)/image")
    let uploadtask = ref.putData(data!, metadata: nil) { (metadata, error) in
//      guard let metadata = metadata else {
//        return
//      }
      
      ref.downloadURL(completion: { (url, error) in
        guard let url = url else {
          return
        }
        
        //realdatabaseに書き込む
        self.ref = Database.database().reference()
        self.ref.child("urers").child("\(user.uid)").updateChildValues(["uid":"\(user.uid)","url":"\(url)","name":self.textfield.text!])
      })
      
    }
    uploadtask.resume()
    
   setbutton.isEnabled = false
  
   dismiss(animated: true, completion: nil)
  }
  
  @IBAction func tapcancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func up(_ sender: UISwipeGestureRecognizer) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func down(_ sender: UISwipeGestureRecognizer) {
    dismiss(animated: true, completion: nil)
  }
  
  
  @IBAction func tapimageview(_ sender: UITapGestureRecognizer) {
    print("tap")
    choiceimage(buttonitem: sender, type: .photoLibrary)
  }
  
  func choiceimage(buttonitem:UITapGestureRecognizer, type:UIImagePickerController.SourceType) {
    if false == UIImagePickerController.isSourceTypeAvailable(type) {
      return
    }
    
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = type
    imagePickerController.delegate = self
    
    imagePickerController.modalPresentationStyle = .popover
    let popoverController = imagePickerController.popoverPresentationController!
    popoverController.delegate = self
    popoverController.permittedArrowDirections = .any
    
    
    self.present(imagePickerController, animated: true, completion: nil)
    
  }
  
  func countPhoto() -> String {
    let ud = UserDefaults.standard
    let count = ud.object(forKey: "count") as! Int
    ud.set(count + 1, forKey: "count")
    return String(count)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
    
    let resize = CGSize(width: 300.0, height: 300.0)
    self.image.image = image.reSizeImage(reSize: resize)
    self.setbutton.isEnabled = true
    
    picker.dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLayoutSubviews() {
    print("\(self.image.frame.size)")
  }
  
}


extension UIImage {
  // resize image
  func reSizeImage(reSize:CGSize)->UIImage {
    //UIGraphicsBeginImageContext(reSize);
    UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
    self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
    let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

}
