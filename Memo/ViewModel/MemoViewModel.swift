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

typealias MemoSectionModel = AnimatableSectionModel<String, Memo>

final class MemoViewModel: MemoStorageType {
    
    
    private var list: [Memo] = [
        Memo(title: "여긴 고정된 메모야!!", content: "날아가 사뿐히 이루렴 팽팽한 어둠사이로 여행을", insertDate: Date(), isFixed: true),
        Memo(title: "장 보기", content: "배추 2포기, 고등어, 사탕 3개, 다이소 들려서 생필품 구입하기 \n 그다음뭐하지?", insertDate: Date()),
        Memo(title: "동해물과 백두산이 마르고 닳도록", content: "", insertDate: Date()),
        Memo(title: "달이 익어가니 서둘러 젊은 피야 민들레 한송이 들고 사랑이 어지러이", content: "날아가 사뿐히 이루렴 팽팽한 어둠사이로 여행을", insertDate: Date())
    ]
    
    // input
    let save = PublishRelay<Void>()
    
    // output
    //let title: Driver<String>
    private lazy var sectionFixedModel = MemoSectionModel(model: "고정된 메모", items: list.filter { $0.isFixed == true })
    private lazy var sectionModel = MemoSectionModel(model: "메모", items: list.filter { $0.isFixed == false } )
    
    private lazy var data = BehaviorSubject<[MemoSectionModel]>(value: [sectionFixedModel, sectionModel])
    
    
    var memoList: Observable<[MemoSectionModel]> {
        return data
    }
    
    @discardableResult
    func createMemo(title: String?, content: String, date: Date) -> Observable<Memo> {
        let memo = Memo(title: title, content: content, insertDate: date)
        sectionModel.items.insert(memo, at: 1)
        data.onNext([sectionModel])
        return Observable.just(memo)
    }
    
    @discardableResult
    func update(memo: Memo, title: String?, content: String, date: Date) -> Observable<Memo> {
        let updated = Memo(original: memo, updateTitle: title, updateContent: content, updateDate: date)

        if let index = sectionFixedModel.items.firstIndex(where: { $0 == memo }){
            sectionFixedModel.items.remove(at: index)
            sectionFixedModel.items.insert(updated, at: index)
        }
        
        if let index = sectionModel.items.firstIndex(where: { $0 == memo }){
            sectionModel.items.remove(at: index)
            sectionModel.items.insert(updated, at: index)
        }
        
        data.onNext([sectionFixedModel, sectionModel])
        return Observable.just(updated)
    }
    
    @discardableResult
    func delete(memo: Memo) -> Observable<Memo> {
        if let index = sectionModel.items.firstIndex(where: {$0 == memo}){
            sectionModel.items.remove(at: index)
        }
        if let index = sectionFixedModel.items.firstIndex(where: {$0 == memo}){
            sectionFixedModel.items.remove(at: index)
        }
        
        data.onNext([sectionFixedModel, sectionModel])
        return Observable.just(memo)
    }
}


