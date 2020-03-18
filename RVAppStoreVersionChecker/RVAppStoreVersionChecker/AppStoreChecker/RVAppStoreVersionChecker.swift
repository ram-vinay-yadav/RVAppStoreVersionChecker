//
//  RVAppStoreVersionChecker.swift
//  RVAppStoreVersionChecker
//
//  Created by Ram Vinay on 17/03/20.
//  Copyright © 2020 Techugo. All rights reserved.
//

import UIKit

//MARK:- UIView class
open class RVAppStoreVersionChecker: UIView {

    @IBOutlet weak var popupContainerView: UIView!
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var updateMessageLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!

    var preViewImageList:[String]?
    
    private var updateMessage:String = "Update new version"
    private var updateButtonMessage:String = "Update"
    private var reminderButtonMessage:String = "Reminder me Later"
    private var newVersionAppTrackIdStr:String = ""
    
    //MARK:- create singolton class
    
    public static let instance = RVAppStoreVersionChecker()

    //MARK:- view initilization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("RVAppStoreVersionChecker", owner: self, options: nil)
        self.setUpViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- common setup here
    private func setUpViews() {
        
        parentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        parentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let bundle = Bundle(for: type(of: self))

        self.imageCollectionView.register(UINib(nibName: "RVAppStoreCheckImageCell", bundle: bundle), forCellWithReuseIdentifier: "RVAppStoreCheckImageCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: self.imageCollectionView.frame.size.width, height: self.imageCollectionView.frame.size.height)
        self.imageCollectionView.setCollectionViewLayout(layout, animated: true)


    }
    
    internal func showUpdateUI() {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.keyWindow?.addSubview(self.parentView)
            
            self.popupContainerView.layer.cornerRadius = 10
            self.popupContainerView.clipsToBounds = true
            
            self.updateButton.layer.cornerRadius = 10
            self.updateButton.clipsToBounds = true
            
            self.reminderButton.layer.cornerRadius = 10
            self.reminderButton.clipsToBounds = true
        }
    }
    
    internal func hideUpdateUI() {
        parentView.removeFromSuperview()
    }
}

//MARK:- add extra funcunality
extension RVAppStoreVersionChecker {
    
    public func showMessageIfUpdateAvailable(message:String?, updateBtnMessage:String?, reminderBtnMessage:String?, callback: @escaping (Bool, [String:Any])->Void) {
        
        //update client message
        if let newMessage = message {
            self.updateMessage = newMessage
        }
        
        if let newUpdateBtnMessage = updateBtnMessage {
            self.updateButtonMessage = newUpdateBtnMessage
        }
        
        if let newReminderBtnMessage = reminderBtnMessage {
            self.reminderButtonMessage = newReminderBtnMessage
        }
        
        RVAppStoreVersionChecker.instance.isUpdateAvailable() { hasUpdates, updatedJson  in
          
            if hasUpdates {
                debugPrint("is update available: \(hasUpdates)")
                DispatchQueue.main.async {
                    RVAppStoreVersionChecker.instance.showUpdateUI()
                    
                    let results = updatedJson?["results"] as? NSArray
                    let firstObject = results?.firstObject as? NSDictionary
                    self.preViewImageList = firstObject?["screenshotUrls"] as? [String]
                    self.imageCollectionView.reloadData()
                }
            } else {
                debugPrint("is update available: False")
                
            }
        }
    }
    
    private func isUpdateAvailable(callback: @escaping (Bool, [String:Any]?)->Void) {
        
        let bundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        
        
        let session = URLSession.shared
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)")!
        
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    debugPrint("RVAppStoreVersionChecker: error - ")
                    return
            }
            
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []) {
                
                if let json = jsonData as? [String:Any] {
                    
                    if let results = json["results"] as? NSArray,
                        let entry = results.firstObject as? NSDictionary,
                        let versionStore = entry["version"] as? String,
                        let versionLocal = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        
                        self.newVersionAppTrackIdStr = String(entry["trackId"] as? Int ?? 0)
                        
                        let arrayStore = versionStore.split(separator: ".")
                        let arrayLocal = versionLocal.split(separator: ".")
                        
                        if arrayLocal.count != arrayStore.count {
                            callback(true,json) // different versioning system
                        }
                        
                        // check each segment of the version
                        for (key, value) in arrayLocal.enumerated() {
                            if Int(value)! < Int(arrayStore[key])! {
                                callback(true, json)
                            }
                        }
                    }
                }
            }
            
            callback(false, nil) // no new version or failed to fetch app store version
            
        })
        task.resume()
        
    }
    
}

extension RVAppStoreVersionChecker {
    
    @IBAction func updateButtonAction(_ sender: Any) {
        
        DispatchQueue.main.async {
            RVAppStoreVersionChecker.instance.hideUpdateUI()
        }
        
        let urlStr = "itms-apps://itunes.apple.com/app/apple-store/id\(self.newVersionAppTrackIdStr)?mt=8"
         if #available(iOS 10.0, *) {
             UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)

         } else {
             UIApplication.shared.openURL(URL(string: urlStr)!)
         }

        
    }
    
    @IBAction func updateLaterButtonAction(_ sender: Any) {
        RVAppStoreVersionChecker.instance.hideUpdateUI()
    }
}

extension RVAppStoreVersionChecker : UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.preViewImageList?.count ?? 0
    }
    

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RVAppStoreCheckImageCell", for: indexPath) as! RVAppStoreCheckImageCell
        
        let urlStr = URL(string: self.preViewImageList?[indexPath.row] ?? "")
        self.downloadProfileImage(from: urlStr!, imageView: cell.storePreviewImageView)
        
        return cell
    }
    
}


extension RVAppStoreVersionChecker {
    
    
    static func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func downloadProfileImage(from url: URL, imageView:UIImageView) {
        RVAppStoreVersionChecker.getImageData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
}
