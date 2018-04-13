//
//  GTLDriveFile.swift
//  GoogleDriveFilePicker
//
//  Created by Federico Monti on 30/03/2018.
//  Copyright © 2018 Federico Monti. All rights reserved.
//

import GoogleAPIClientForREST

extension GTLRDrive_File {
    func isFolder() -> Bool {
        return mimeType == "application/vnd.google-apps.folder"
    }
    
    open func toDownloadURL() -> String? {
        if (self.identifier?.isEmpty)! {
            return nil
        }
        
        return "https://drive.google.com/open?id=\(self.identifier ?? "")"
    }
}
