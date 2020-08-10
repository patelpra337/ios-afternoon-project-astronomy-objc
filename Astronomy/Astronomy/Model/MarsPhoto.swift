//
//  MarsPhoto.swift
//  Astronomy
//
//  Created by patelpra on 8/10/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import Foundation

@objc(LSIMarsPhotoReference)
class MarsPhotoReference: NSObject {
    let id: Int
    let sol: Int
    let camera: Camera
    let earthDate: Date
    @objc let imageURL: URL
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    @objc init(id: Int, sol: Int, camera: Camera, earthDate: Date, imageURL: URL) {
        self.id = id
        self.sol = sol
        self.camera = camera
        self.earthDate = earthDate
        self.imageURL = imageURL
    }
    
    @objc(initWithDictionary:)
    init?(dictionary: [String:Any]) {
        guard let id = dictionary["id"] as? Int else { return nil }
        guard let sol = dictionary["sol"] as? Int else { return nil }
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "GMT")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        guard let earthDateString = dictionary["earth_date"] as? String else { return nil }
        guard let earthDate = dateFormatter.date(from: earthDateString) else { return nil }
        
        guard let imageURLString = dictionary["img_src"] as? String else { return nil }
        guard let imageURL = URL(string: imageURLString) else { return nil }
        
        guard let cameraDictionary = dictionary["camera"] as? [String:Any] else { return nil }
        guard let camera = Camera(dictionary: cameraDictionary) else { return nil }
        
        self.id = id
        self.sol = sol
        self.earthDate = earthDate
        self.imageURL = imageURL
        self.camera = camera
    }
}

