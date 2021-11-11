//
//  Memo.swift
//  Memo
//
//  Created by meng on 2021/11/09.
//

import Foundation

struct Memo: Equatable {
    var title: String?
    var content: String
    var insertDate: Date
    
    init(title: String?, content: String, insertDate: Date) {
        self.title = title
        self.content = content
        self.insertDate = insertDate
    }
    
    init(original: Memo, updateTitle: String?, updateContent: String, updateDate: Date) {
        self = original
        self.title = updateTitle
        self.content = updateContent
        self.insertDate = updateDate
    }
}
