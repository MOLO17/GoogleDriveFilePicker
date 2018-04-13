//
//  DrivePicker.swift
//  GoogleDriveFilePicker
//
//  Created by Federico Monti on 30/03/2018.
//  Copyright © 2018 Federico Monti. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn

class GoogleDriveFilePicker: UINavigationController {
    var viewer: DriveFileViewer?
    
    class func handle(_ url: URL?, _ sourceApp: String?, _ annotation: Any?) -> Bool {
        if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApp, annotation: annotation) {
            return true
        }
        return false
    }
    
    init() {
        let viewer = DriveFileViewer()
        viewer.initController()
        super.init(rootViewController: viewer)
        modalPresentationStyle = .pageSheet
        self.viewer = viewer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func pick(from vc: UIViewController?, withCompletion completion: @escaping (_ manager: DriveManager, _ file: GTLRDrive_File?) -> Void) {
        viewer?.completion = completion
        vc?.present(self, animated: true) {() -> Void in }
    }

}

