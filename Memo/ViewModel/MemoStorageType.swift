//
//  MemoStorageType.swift
//  Memo
//
//  Created by meng on 2021/11/11.
//

import Foundation
import RxSwift

protocol MemoStorageType {
    
    var memoList: Observable<[MemoSectionModel]> { get }
    
    @discardableResult //작업결과가 필요없는경우를 위해서
    func createMemo(title: String?, content: String, date: Date) -> Observable<UserMemo>
    
    @discardableResult
    func update(title: String?, content: String, date: Date, at indexPath: IndexPath) -> Observable<UserMemo>
    
    @discardableResult
    func delete(at indexPath: IndexPath) -> Observable<UserMemo>
}
