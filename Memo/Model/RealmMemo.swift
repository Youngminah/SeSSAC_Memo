//
//  RealmMemo.swift
//  Memo
//
//  Created by meng on 2021/11/12.
//

import Foundation
import RealmSwift
import RxDataSources

class UserMemo: Object {
    
    @Persisted var title: String?
    @Persisted var content: String
    @Persisted var insertDate: Date
    @Persisted var isFixed: Bool

    @Persisted(primaryKey: true) var _id: ObjectId
    
    convenience init(title: String?, content: String, insertDate: Date, isFixed: Bool = false) {
        self.init()
        self.title = title
        self.content = content
        self.insertDate = insertDate
        self.isFixed = isFixed
    }
}
