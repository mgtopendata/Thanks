//
//  VideoViewController.swift
//  Thanks
//
//  Created by 岩男高史 on 2019/02/24.
//  Copyright © 2019 岩男高史. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos
import FirebaseStorage
import Firebase

class VideoViewController: UIViewController,AVCaptureFileOutputRecordingDelegate {
    let fileoutput = AVCaptureMovieFileOutput()
    var recordButton:UIButton!
    var isrecording = false
    var database:DatabaseReference!
    var ref:DatabaseReference!
    var num:Int = 0
    @IBOutlet weak var progressView: UIProgressView!
    var progress:Float = 0.0
    var timer:Timer!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 6.0)
        self.database = Database.database().reference()
        let dataref = self.database.child("count")
        dataref.observe(DataEventType.value, with: { (snapshot) in
          if let count = snapshot.value as? NSDictionary {
            let num = count["count"] as! Int
            self.num = num
            print(num)
          } else {
            let num = 0
            self.num = num
          }
        })
      
        setuppreview()
        setupbutton()
    }
  
    func setuppreview() {
      let videodevice = AVCaptureDevice.default(for: AVMediaType.video)
      let audiodevice = AVCaptureDevice.default(for: AVMediaType.audio)
    
      do {
          if videodevice == nil || audiodevice == nil {
          throw NSError(domain: "device error", code: -1, userInfo: nil)
        }
          let capturesession = AVCaptureSession()
      
          let videoinput = try AVCaptureDeviceInput(device: videodevice!)
          capturesession.addInput(videoinput)
      
          let audioinput = try AVCaptureDeviceInput(device: audiodevice!)
          capturesession.addInput(audioinput)
      
          self.fileoutput.maxRecordedDuration = CMTimeMake(value: 10, timescale: 1)
          capturesession.addOutput(fileoutput)
      
          let videoplayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: capturesession)
          videoplayer.frame = self.view.bounds
          videoplayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
          self.view.layer.addSublayer(videoplayer)
      
          capturesession.startRunning()
      
      
        }catch{
            //error syori
        }
      }
  
      func setupbutton() {
        recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        recordButton.backgroundColor = UIColor.gray
        recordButton.layer.masksToBounds = true
        recordButton.setTitle("Start", for: UIControl.State.normal)
        recordButton.layer.cornerRadius = 20.0
        recordButton.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-50)
        recordButton.addTarget(self, action: #selector(VideoViewController.onclickrecordbutton(sender:)), for: .touchUpInside)
        
        self.view.addSubview(recordButton)
      }
  
  @objc func onclickrecordbutton(sender: UIButton) {
    if !isrecording {
      let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
      let documentdirectory = path[0] as String
      let filepath:String? = "\(documentdirectory)/temp.mp4"
      let fileurl:NSURL = NSURL(fileURLWithPath: filepath!)
      fileoutput.startRecording(to: fileurl as URL, recordingDelegate: self)
      //startして5秒後に止める
      isrecording = true
      recordButton.isEnabled = false
      changebuttoncolor(target: recordButton, color: UIColor.red)
      recordButton.setTitle("Recording", for: .normal)
      self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(timeupdate), userInfo: nil, repeats: true)
     
      print("\(fileurl)")
      
      
    } else {
      
      fileoutput.stopRecording()
      isrecording = false
      changebuttoncolor(target: recordButton, color: UIColor.gray)
      recordButton.setTitle("Start", for: .normal)
    }
  }
  
  
  func changebuttoncolor(target:UIButton, color:UIColor) {
    target.backgroundColor = color
  }

  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//    //firebaseに保存するための処理
    let storage = Storage.storage()
    let stref = storage.reference(forURL: "gs://thanks-2-f6797.appspot.com/")
//    guard let user = Auth.auth().currentUser else { return }
//    let uid = user.uid
    let num = self.num + 1
    print(num)
    let ref = stref.child("movies/movie.\(num)")
    let uploadtask = ref.putFile(from: outputFileURL, metadata: nil) { (metadata, error) in
//      self.ref = Database.database().reference()
//      self.ref.child("count").setValue(["count":num])
      ref.downloadURL(completion: { (url, error) in
//        let durl = url?.absoluteString ?? ""
//        let url = URL(string: durl!)
        self.ref = Database.database().reference()
//        var storage = Storage.storage()
        let image = self.createThumbnailOfVideoFromRemoteUrl(url: url!)
        let imagedata = image?.pngData()
        let uploadtask = stref.child("thumbnail/image.\(num)").putData(imagedata!, metadata: nil, completion: { (metadata, error) in
          stref.child("thumbnail/image.\(num)").downloadURL(completion: { (url, error) in
            self.ref.child("images").child("\(num)").setValue(["thumbnail":"\(url!)"])
          })
        })
        uploadtask.resume()
//        let urlstring = try! String(contentsOf: url!)
//        let image = self.createThumbnailOfVideoFromRemoteUrl(url: durl!)
//        let imagedata = image?.pngData()
//        let imgRef = stref.child("images2/image.\(num)")
//        imgRef.putData(imagedata!)
        
        self.ref.child("movies").child("\(num)").setValue(["url":"\(url!)"])
        self.ref.child("count").updateChildValues(["count":num])
      })
    }
    uploadtask.resume()
//    let next = storyboard!.instantiateViewController(withIdentifier: "home")
//    present(next, animated: true, completion: nil)
      performSegue(withIdentifier: "gohome", sender: nil)
    
  }
  
  func createThumbnailOfVideoFromRemoteUrl(url: URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
    assetImgGenerate.appliesPreferredTrackTransform = true
    var time = asset.duration
    time.value = min(0,0)
    var acutualtime = CMTime.zero
    //Can set this to improve performance if target size is known before hand
    //assetImgGenerate.maximumSize = CGSize(width,height)
    let time1 = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    //    let time:CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
    do {
      let img = try assetImgGenerate.copyCGImage(at: time1, actualTime: &acutualtime)
      print("こんにちは")
      print(img)
      var count = 0
      print("\(count)")
      count += 1
      let thumbnail = UIImage(cgImage: img)
      return thumbnail
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
  
  @objc func timeupdate() {
    progress = progress + 0.001
    if progress < 1.1 {
      progressView.setProgress(progress, animated: true)
    } else {
      timer.invalidate()
      fileoutput.stopRecording()
    }
    
  }
  
  

}
