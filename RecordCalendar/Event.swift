//
//  Event.swift
//  RecordCalendar
//
//  Created by 桑原望 on 2020/03/14.
//  Copyright © 2020 MySwift. All rights reserved.
//

import Foundation
import RealmSwift

class Event: Object {
    
    @objc dynamic var date: String = ""
    @objc dynamic var event: String = ""
    
}
