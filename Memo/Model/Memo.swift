//
//  Memo.swift
//  Memo
//
//  Created by meng on 2021/11/09.
//

import Foundation
import RxDataSources

struct Memo: Equatable, IdentifiableType {
    
    var title: String?
    var content: String
    var insertDate: Date
    var identity: String
    var isFixed: Bool
    
    init(title: String?, content: String, insertDate: Date, isFixed: Bool = false) {
        self.title = title
        self.content = content
        self.insertDate = insertDate
        self.identity = UUID().uuidString
        self.isFixed = isFixed
    }
    
    init(original: Memo, updateTitle: String?, updateContent: String, updateDate: Date) {
        self = original
        self.title = updateTitle
        self.content = updateContent
        self.insertDate = updateDate
    }
}
