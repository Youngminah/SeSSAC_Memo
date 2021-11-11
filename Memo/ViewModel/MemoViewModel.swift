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
    
    private var dataManager: MemoryStorage?
    
    // input
    let save = PublishRelay<Void>()
    
    // output
    //let title: Driver<String>
    
    let data = BehaviorRelay<[Memo]>(value: [.init(title: "장 보기",
                                                        content: "배추 2포기, 고등어, 사탕 3개, 다이소 들려서 생필품 구입하기 \n 그다음뭐하지?",
                                                        insertDate: Date())])
    
    let disposeBag = DisposeBag()
    
    
    init(dataManager: MemoryStorage) {
        self.dataManager = dataManager
    }
    
//    func dateToString(at index: Int) -> String {
//        return Date.from(date: memoList[index].insertDate)
//    }
    
}


