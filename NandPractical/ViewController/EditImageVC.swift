    //
    //  EditImageVC.swift
    //  NandPractical
    //
    //  Created by SOTSYS115 on 11/30/18.
    //  Copyright © 2018 SOTSYS115. All rights reserved.
    //
    
    import UIKit
    import CoreData
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext = appDelegate.persistentContainer.viewContext
    
    
    class EditImageVC: UIViewController,UITextFieldDelegate {
        
        //MARK:- Variables
        var imgProject : UIImage?
        var tmpProject  : UIImage?
        
        //MARK: - IB-Action Methods
        @IBOutlet var imgEditImage: UIImageView!
        @IBOutlet var sliderImgScale: UISlider!
        @IBOutlet var txtEditImageText: UITextField!
        
        
        //MARK:- ViewLifeCycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            
            self.tmpProject = imgProject
            self.configureView()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(true)
            self.txtEditImageText.resignFirstResponder()
        }
        
        func configureView(){
            
            if (imgProject != nil){
                self.imgEditImage.image = imgProject
            }
        }
        
        //MARK:- TextField Delegate Method
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.txtEditImageText.isHidden = true
            self.imgEditImage.image = self.createImageWithLabelOverlay(label: self.createLabelWithText(strText: self.txtEditImageText.text), imageSize: self.imgEditImage.frame.size, image: self.imgEditImage.image!)
            self.imgEditImage.contentMode = .scaleToFill
            
            self.txtEditImageText.resignFirstResponder()
            return true
        }
        
        //MARK:- IB-Action Methods
        @IBAction func btnBackClicked(_ sender: Any) {
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        @IBAction func btnEditDoneClicked(_ sender: UIButton) {
            self.txtEditImageText.resignFirstResponder()
            self.storeImageInDocDir(img: self.imgEditImage.image!)
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        @IBAction func btnAddTextClicked(_ sender: UIButton) {
            print("Add TextClicked")
            self.txtEditImageText.becomeFirstResponder()
            self.txtEditImageText.isHidden = false
        }
        
        //MARK:- SliderChange
        @IBAction func sliderImgScaleValueChanged(_ sender: UISlider) {
            print("slider changed \(sliderImgScale.value)")
        }
        
        
        //MARK:- CreateLabel
        func createLabelWithText(strText : String?) -> UILabel {
            let myLabel = UILabel()
            myLabel.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
            myLabel.center = CGPoint(x: self.imgEditImage.frame.size.width/2, y: self.imgEditImage.frame.size.height/2)
            myLabel.textAlignment = .center
            myLabel.text = strText
            myLabel.numberOfLines = 0
            myLabel.lineBreakMode = .byWordWrapping
            myLabel.font = UIFont.systemFont(ofSize: 25.0)
            myLabel.textColor = UIColor.blue
            return myLabel
        }
        //MARK:- Add Label To Image
        func createImageWithLabelOverlay(label: UILabel,imageSize: CGSize, image: UIImage) -> UIImage {
            //https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
            UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize.width, height: imageSize.height), false, 2.0)
            let currentView = UIView.init(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
            let currentImage = UIImageView.init(image: image)
            currentImage.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            currentView.addSubview(currentImage)
            currentView.addSubview(label)
            currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img!
        }
        
        //MARK:- storeImage In Document Directory
        func storeImageInDocDir(img : UIImage){
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // choose a name for your image
            
            let timestamp = Date.init(timeIntervalSinceNow: 1)
            
            
            let fileName = "image.jpg" + "\(timestamp)"
            // create the destination file url to save your image
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            print("file name \(fileURL)")
            
            // get your UIImage jpeg data representation and check if the destination file url already exists
            let imgFileData = UIImageJPEGRepresentation(img, 0.5)
            
            //let imgFileData = img.jpegData(compressionQuality: 0.5)
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent(fileName) {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    print("FILE AVAILABLE")
                } else {
                    print("FILE NOT AVAILABLE")
                    
                    do {
                        try imgFileData?.write(to: fileURL)
                        
                        var dict = [String :String]()
                        dict["title"] = path
                        dict["url"] = path
                        
                        self.storeImageNameInCoreData(imgName: fileName)
                    } catch {
                        print("Erro in writing file")
                    }
                }
            } else {
                print("FILE PATH NOT AVAILABLE")
            }
            
        }
        
        func storeImageNameInCoreData(imgName : String){
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "ProjectData", in: managedContext)
            let newImage = NSManagedObject(entity: entityDescription!, insertInto: managedContext)
            
            newImage.setValue(imgName, forKey: "imgName")
            
            print("==== Save ====")
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        }
    }
