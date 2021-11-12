//
//  MemoViewModel.swift
//  Memo
//
//  Created by meng on 2021/11/11.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

typealias MemoSectionModel = AnimatableSectionModel<String, Memo>

final class MemoViewModel: MemoStorageType {
    
    private var list = [Memo]()
    
    // input
    let save = PublishRelay<Void>()
    
    private var tasks: Results<UserMemo>!
    
    // output
    //let title: Driver<String>
    private lazy var sectionFixedModel = MemoSectionModel(model: "고정된 메모", items: list.filter { $0.isFixed == true })
    private lazy var sectionModel = MemoSectionModel(model: "메모", items: list.filter { $0.isFixed == false } )
    
    private lazy var data = BehaviorSubject<[MemoSectionModel]>(value: [sectionFixedModel, sectionModel])
    
    
    init() {
        let localRealm = try! Realm()
        print("Realm is located at:", localRealm.configuration.fileURL!)
        tasks = localRealm.objects(UserMemo.self).sorted(byKeyPath: "insertDate")
        tasks.forEach {
            list.append(Memo(title: $0.title, content: $0.content, insertDate: $0.insertDate, isFixed: $0.isFixed))
        }
    }
    
    var memoList: Observable<[MemoSectionModel]> {
        return data
    }
    
    var countFixedMemo: Int {
        return list.filter { $0.isFixed == true }.count
    }
    
    @discardableResult
    func createMemo(title: String?, content: String, date: Date) -> Observable<UserMemo> {
        let memo = Memo(title: title, content: content, insertDate: date)
        let realmMemo = UserMemo(value: ["title": memo.title ?? "", "content": memo.content, "insertDate": memo.insertDate, "isFixed": memo.isFixed])
        let realm = try! Realm()
        try! realm.write {
            realm.add(realmMemo)
        }
        reloadRealm()
        data.onNext([sectionFixedModel,sectionModel])
        return Observable.just(realmMemo)
    }
    
    @discardableResult
    func update(title: String?, content: String, date: Date, at indexPath: IndexPath) -> Observable<UserMemo> {
        var realmMemo = UserMemo()
        if indexPath.section == 0 {
            realmMemo = tasks.where { $0.isFixed == true }[indexPath.row]
        } else {
            realmMemo = tasks.where { $0.isFixed == false }[indexPath.row]
        }
        let realm = try! Realm()
        try! realm.write {
            realmMemo.title = title
            realmMemo.content = content
            realmMemo.insertDate = date
        }
        reloadRealm()
        data.onNext([sectionFixedModel, sectionModel])
        return Observable.just(realmMemo)
    }
    
    @discardableResult
    func delete(at indexPath: IndexPath) -> Observable<UserMemo> {
        var realmMemo = UserMemo()
        if indexPath.section == 0 {
            realmMemo = tasks.where { $0.isFixed == true }[indexPath.row]
        } else {
            realmMemo = tasks.where { $0.isFixed == false }[indexPath.row]
        }
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realmMemo)
        }
        reloadRealm()
        data.onNext([sectionFixedModel, sectionModel])
        return Observable.just(realmMemo)
    }
    
    func updateFixToUnfix(at index: Int){
        let realmMemo = tasks.where { $0.isFixed == true }[index]
        let realm = try! Realm()
        try! realm.write {
            realmMemo.isFixed = false
        }
        reloadRealm()
        data.onNext([sectionFixedModel, sectionModel])
    }
    
    func updateUnfixToFix(at index: Int){
        let realmMemo = tasks.where { $0.isFixed == false }[index]
        let realm = try! Realm()
        try! realm.write {
            realmMemo.isFixed = true
        }
        reloadRealm()
        data.onNext([sectionFixedModel, sectionModel])
    }
    
    func reloadRealm() {
        list.removeAll()
        tasks.forEach {
            list.append(Memo(title: $0.title, content: $0.content, insertDate: $0.insertDate, isFixed: $0.isFixed))
        }
        sectionFixedModel = MemoSectionModel(model: "고정된 메모", items: list.filter { $0.isFixed == true })
        sectionModel = MemoSectionModel(model: "메모", items: list.filter { $0.isFixed == false } )
    }
    
    func didUpdateSearchBarText(text: String) {
        let filterList = list.filter {
            $0.title?.contains(text) ?? false || $0.content.contains(text)
        }
        let sectionSearchModel = MemoSectionModel(model: "\(filterList.count)개찾음", items: filterList)
        data.onNext([sectionSearchModel])
    }
    
    func cancelSearchBarText(){
        data.onNext([sectionFixedModel, sectionModel])
    }
}


