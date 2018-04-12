//
//  ImageExtensions.swift
//  IMK-ERP
//
//  Created by Federico Monti on 05/04/2018.
//  Copyright © 2018 MOLO17 Srl. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func resizeImage() {
        let itemSize: CGSize = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect: CGRect = CGRect(x:0, y:0, width:itemSize.width, height: itemSize.height)
        self.image?.draw(in: imageRect)
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
