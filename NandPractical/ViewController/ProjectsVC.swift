    //
    //  ProjectsVC.swift
    //  NandPractical
    //
    //  Created by SOTSYS115 on 11/30/18.
    //  Copyright © 2018 SOTSYS115. All rights reserved.
    //
    
    import UIKit
    import CoreData
    
    class CellProjects  : UITableViewCell {
        
        @IBOutlet var imgProject: UIImageView!
        @IBOutlet var lblProjectTitle: UILabel!
        @IBOutlet var btnEditImage: UIButton!
        
        override func awakeFromNib() {
            
        }
    }
    
    class ProjectsVC: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
        
        //MARK:- Variables
        var isPickerOpened : Bool = false
        
        //MARK:- IB-Outlets
        @IBOutlet var btnAddImage: UIButton!
        @IBOutlet var tblProjects: UITableView!
        
        
        //MARK:- ViewLifeCycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if(!isPickerOpened){
                appDelegate.arrProjectData.removeAll()
                self.fetchData()
            }
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            self.isPickerOpened = false
        }
        
        //MARK:- IB-Action Methods
        @IBAction func btnAddImageClicked(_ sender: UIButton) {
            print("open imagepicker")
            
            self.openImagePicker()
        }
        
        func openImagePicker(){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary//UIImagePickerController.sourceType.photoLibrary
            imagePickerController.allowsEditing = true
            
            self.present(imagePickerController, animated: true) {
                
            }
        }
        
        

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            self.isPickerOpened = true
            
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            dismiss(animated: true) {
                self.redirectToEditImageVC(selectedImage: image)
            }
        }
        
        
        
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//            guard let image = info[.originalImage] as? UIImage else { return }
//
//            dismiss(animated: true) {
//
//                self.redirectToEditImageVC(selectedImage: image)
//            }
//        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.isPickerOpened = true

            print("cancel called")
        }
        

        func redirectToEditImageVC(selectedImage: UIImage?){
            
            let objEditImageVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditImageVC") as? EditImageVC
            if(selectedImage != nil){
                objEditImageVC?.imgProject = selectedImage
            }
            self.navigationController?.pushViewController(objEditImageVC!, animated: true)
        }
        
    }
    
    extension ProjectsVC : UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return appDelegate.arrProjectData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellProjects", for: indexPath) as! CellProjects
            cell.btnEditImage.addTarget(self, action: #selector(btnEditImageClicked(_:)), for: .touchUpInside)
            
            if let title = appDelegate.arrProjectData[indexPath.row]["title"] {
                cell.lblProjectTitle.text = title
            }
            
            if let imgURL = appDelegate.arrProjectData[indexPath.row]["url"] {
                if let image  : UIImage  = UIImage(contentsOfFile: imgURL) {
                    cell.imgProject.image = image
                }
            }
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 180
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("indexpath is \(indexPath.row)")
            
            if let imgURL = appDelegate.arrProjectData[indexPath.row]["url"] {
                if let image  : UIImage  = UIImage(contentsOfFile: imgURL) {
                    self.redirectToEditImageVC(selectedImage: image)
                }
            }
        }
        
        @objc func btnEditImageClicked(_ sender: UIButton) {
            redirectToEditImageVC(selectedImage: nil)
        }
       
    }
    
    extension ProjectsVC {
        func fetchData(){

            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ProjectData")
            
            do {
                let results = try managedContext.fetch(fetchRequest)
                
                if ((results.count) > 0) {
                    print("result is \(results)")
                    
                    var intCounter  : Int = 0
                    for data in results as! [NSManagedObject] {
                        intCounter = intCounter + 1
                        let strImgName : String = data.value(forKey: "imgName") as! String
                        
                        var dict = [String :String]()
                        
                        dict["title"] = String(format: "Project %d", intCounter)
                        
                        dict["url"] = self.getFileUrlFromFileName(fName: strImgName)
                        
                        appDelegate.arrProjectData.append(dict)
                        self.tblProjects.reloadData()
                    }
                    
                }else{
                    print("No Image found")
                }
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
        }
        
        func getFileUrlFromFileName(fName : String) -> String{
            var strFileURL : String = ""
            let fileName = fName
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            print("file name \(fileURL)")
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent(fileName) {
                let filePath = pathComponent.path
                strFileURL = filePath
            }
            return strFileURL
        }
    }
