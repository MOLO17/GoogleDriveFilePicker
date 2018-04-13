//
//  DriveFileViewer.swift
//  GoogleDriveFilePicker
//
//  Created by Federico Monti on 30/03/2018.
//  Copyright © 2018 Federico Monti. All rights reserved.
//
import Foundation
import UIKit
import GoogleAPIClientForREST
import SDWebImage
import GoogleSignIn
import PureLayout

class DriveFileViewer: UIViewController, UITableViewDataSource, UITableViewDelegate {
    typealias GDriveFileViewerCompletionBlock = (_ manager: DriveManager, _ file: GTLRDrive_File?) -> Void
    
    @IBOutlet var output: UILabel!
    var manager: DriveManager!
    @IBOutlet var table: UITableView!
    @IBOutlet var toolbar: UIToolbar!
    var fileList: GTLRDrive_FileList!
    @IBOutlet var blankImage: UIImage!
    @IBOutlet var upItem: UIBarButtonItem!
    @IBOutlet var segmentedControlButtonItem: UIBarButtonItem!
    var folderTrail = [AnyHashable]()
    var isShowShared = false
    var completion: GDriveFileViewerCompletionBlock!
    let spinner = UIActivityIndicatorView()
    
    func initController() {
        title = "Google Drive"
        modalPresentationStyle = .pageSheet
        UIGraphicsBeginImageContext(CGSize(width: 20, height: 20))
        UIGraphicsGetCurrentContext()?.addRect(CGRect(x: 0, y: 0, width: 20, height: 20))
        blankImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        folderTrail = ["root"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = DriveManager()
        
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = UIColor.white
        // Create a UITextView to display output.
        let output = UILabel(frame: CGRect(x: 40, y: 100, width: view.bounds.size.width - 80, height: 40))
        output.numberOfLines = 0
        output.textAlignment = .center
        output.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        view.addSubview(output)
        self.output = output
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.toolbar = toolbar
        view.addSubview(toolbar)
        
        view.addSubview(loadingProgressView)
        loadingProgressView.autoMatch(.width, to: .width, of: view, withMultiplier: 0.25)
        loadingProgressView.autoMatch(.height, to: .width, of: loadingProgressView)
        loadingProgressView.autoAlignAxis(.vertical, toSameAxisOf: view)
        loadingProgressView.autoAlignAxis(.horizontal, toSameAxisOf: view)
        
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        table = tableView
        let views = ["toolbar": toolbar, "tableView": tableView] as [String : Any]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[toolbar]|", options: .directionLeftToRight, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: .directionLeftToRight, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[toolbar(44)][tableView]|", options: .directionLeftToRight, metrics: nil, views: views))
        showSpinner()
        setupButtons()
        updateButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        manager?.forceSignIn() {() -> Void in
            self.showSpinner()
            self.getFiles()
            self.updateRightButton()
        }
    }
    
    func updateRightButton() {
        let signOutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(signOut))
        navigationItem.rightBarButtonItem = signOutButton
    }

    @objc func signOut() {
        manager?.signOut()
        dismiss(animated: true) {() -> Void in }
    }
    
    func authFailed() {
        dismiss(animated: true) {() -> Void in }
    }
    
    @objc func cancel() {
        dismiss(animated: true) {() -> Void in }
    }

    func getFiles() {
        manager?.isSharedWithMe = self.isShowShared
        updateButtons()
        manager?.fetchFiles(withCompletionHandler: {(_ ticket: GTLRServiceTicket, _ fileList: Any?, _ error: Error?) -> Void in
            if error != nil {
                let message = "Error: \(error?.localizedDescription ?? "")"
                self.output?.text = message
                self.table?.isHidden = true
            } else {
                self.fileList = fileList as? GTLRDrive_FileList
                self.updateDisplay()
            }
            self.hideSpinner()
        })
    }

    func updateDisplay() {
        updateButtons()
        if ((fileList?.files?.count) != nil) {
            table?.isHidden = false
            table?.reloadData()
        } else {
            output?.text = "Cartella vuota"
            table?.isHidden = true
        }
    }

    func setupButtons() {
        let segItemsArray = ["Miei", "Condivisi"]
        let segmentedControl = UISegmentedControl(items: segItemsArray)
        segmentedControl.addTarget(self, action: #selector(mineSharedChanged), for: .valueChanged)
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        self.segmentedControlButtonItem = UIBarButtonItem(customView: segmentedControl)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        upItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(up))
        navigationItem.setLeftBarButton(doneItem, animated: true)
    }

    func updateButtons() {
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        if folderTrail.count > 1 && !self.isShowShared {
            toolbar?.setItems([upItem, flex, segmentedControlButtonItem], animated: true)
        } else {
            toolbar?.setItems([flex, segmentedControlButtonItem], animated: true)
        }
    }
    
    // MARK: searching
    @objc func mineSharedChanged(_ sender: UISegmentedControl?) {
        isShowShared = sender?.selectedSegmentIndex == 1
        getFiles()
    }

    @objc func up() {
        if folderTrail.count > 1 {
            showSpinner()
            folderTrail.removeLast()
            manager?.folderId = folderTrail.last as? String ?? "root"
            getFiles()
        }
    }
    
    func openFolder(_ file: GTLRDrive_File?) {
        let folderId = file?.identifier
        let currentFolder = folderTrail.last as? String
        if (folderId == currentFolder) {
            return
        } else {
            showSpinner()
            if let anId = folderId {
                folderTrail.append(anId)
            }
            manager?.folderId = file?.identifier ?? "root"
            getFiles()
        }
    }
    
    // MARK: table
    
    func file(for indexPath: IndexPath) -> GTLRDrive_File? {
        return fileList.files?[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList?.files?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DriveFileViewer"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        let file: GTLRDrive_File? = self.file(for: indexPath)
        cell?.textLabel?.text = file?.name
        cell?.imageView?.sd_setImage(with: URL(string: file?.iconLink ?? ""), placeholderImage: blankImage)
        cell?.imageView?.resizeImage()
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile: GTLRDrive_File? = self.file(for: indexPath)
        let isFolder = selectedFile?.isFolder() ?? false
        if isFolder {
            openFolder(selectedFile)
        } else {
            dismiss(animated: true, completion: {() -> Void in
                self.completion(self.manager, selectedFile)
            })
        }
    }
    
    fileprivate lazy var loadingProgressView: UIActivityIndicatorView =  {
        let spinner = UIActivityIndicatorView.newAutoLayout()
        spinner.activityIndicatorViewStyle = .gray
        spinner.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        spinner.startAnimating()
        return spinner
    }()
    
    private func showSpinner() {
        table.isHidden = true
        loadingProgressView.isHidden = false
    }
    
    private func hideSpinner() {
        loadingProgressView.isHidden = true
        table.isHidden = false
    }

}
