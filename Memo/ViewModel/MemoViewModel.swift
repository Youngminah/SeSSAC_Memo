//
//  MemoViewModel.swift
//  Memo
//
//  Created by meng on 2021/11/11.
//

import Foundation
import RxSwift
import RxCocoa


final class MemoViewModel {
    
   // private var dataManager: MemoryStorage?
    
    private var list: [Memo] = [
        Memo(title: "장 보기", content: "배추 2포기, 고등어, 사탕 3개, 다이소 들려서 생필품 구입하기 \n 그다음뭐하지?", insertDate: Date()),
        Memo(title: "동해물과 백두산이 마르고 닳도록", content: "", insertDate: Date()),
        Memo(title: "달이 익어가니 서둘러 젊은 피야 민들레 한송이 들고 사랑이 어지러이", content: "날아가 사뿐히 이루렴 팽팽한 어둠사이로 여행을", insertDate: Date())
    ]
    
    // input
    let save = PublishRelay<Void>()
    
    // output
    //let title: Driver<String>
    private lazy var data = BehaviorSubject<[Memo]>(value: self.list)
    
    var memoList: Observable<[Memo]> {
        return data
    }
    
    @discardableResult
    func createMemo(title: String?, content: String, date: Date) -> Observable<Memo> {
        let memo = Memo(title: title, content: content, insertDate: date)
        list.insert(memo, at: 0)
        data.onNext(list)
        return Observable.just(memo)
    }
    
    @discardableResult
    func update(memo: Memo, title: String?, content: String, date: Date) -> Observable<Memo> {
        let updated = Memo(original: memo, updateTitle: title, updateContent: content, updateDate: date)
        if let index = list.firstIndex(where: { $0 == memo }){
            list.remove(at: index)
            list.insert(updated, at: index)
        }
        data.onNext(list)
        return Observable.just(updated)
    }
    
    @discardableResult
    func delete(memo: Memo) -> Observable<Memo> {
        if let index = list.firstIndex(where: {$0 == memo}){
            list.remove(at: index)
        }
        data.onNext(list)
        return Observable.just(memo)
    }
}


