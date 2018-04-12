//
//  DriveManager.swift
//  GoogleDriveFilePicker
//
//  Created by Federico Monti on 30/03/2018.
//  Copyright © 2018 Federico Monti. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn

private let kKeychainItemName = "Drive API"

class DriveManager: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {
    typealias SignInCompletion = () -> Void
    
    private let scopes = [kGTLRAuthScopeDriveReadonly]
    
    private let service = GTLRDriveService()
    let signInButton = GIDSignInButton()
    
    /** if No, shows 'my files'. Default is NO **/
    var isSharedWithMe = false
    /** initially 'root'. Ignored if sharedWithMe is selected **/
    var folderId = "root"
    /** Default is NO **/
    var canShowTrash = false
    /** Default is 1000 **/
    var maxResults: Int = 1000
    var signInCompletion: SignInCompletion?

    
    override init () {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "1057115321591-fibe7ih7unc4eeb6r5k3qe19bd1g21r9.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes = scopes

    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            self.signInCompletion?()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {}
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {}
    
    func forceSignIn(_ completion: @escaping () -> Void) {
        if self.service.authorizer == nil {
            self.signInCompletion = completion
            DispatchQueue.main.async(execute: {() -> Void in
                GIDSignIn.sharedInstance().signIn()
            })
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
    }
    
    // List drive files
    func fetchFiles(withCompletionHandler handler: @escaping (_ ticket: GTLRServiceTicket, _ fileList: Any?, _ error: Error?) -> Void) {
        service.shouldFetchNextPages = true
        let query = GTLRDriveQuery_FilesList.query()
        query.q = self.query()
        query.fields = "files(id,kind,mimeType,name,size,iconLink)"
        query.pageSize = maxResults
        service.executeQuery(query, completionHandler: handler)
    }
    
    // MARK: file listing
    func query() -> String? {
        var query = "'\(folderId)' in parents"
        if isSharedWithMe {
            query = "sharedWithMe"
        }
        if !canShowTrash {
            query = query + (" and trashed = false")
        }
        return query
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        //present(alert, animated: true, completion: nil)
    }
    
}
