//
//  MemoStorage.swift
//  Memo
//
//  Created by meng on 2021/11/09.
//

import Foundation

final class MemoryStorage {
    
    static let shared = MemoryStorage()
    
    let memoList: [Memo] = [
        Memo(title: "장 보기", content: "배추 2포기, 고등어, 사탕 3개, 다이소 들려서 생필품 구입하기 \n 그다음뭐하지?", insertDate: Date()),
        Memo(title: "동해물과 백두산이 마르고 닳도록", content: "", insertDate: Date()),
        Memo(title: "달이 익어가니 서둘러 젊은 피야 민들레 한송이 들고 사랑이 어지러이", content: "날아가 사뿐히 이루렴 팽팽한 어둠사이로 여행을", insertDate: Date())
    ]
}
