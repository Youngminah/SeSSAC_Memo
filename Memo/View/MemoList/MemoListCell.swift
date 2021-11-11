//
//  MemoListCell.swift
//  Memo
//
//  Created by meng on 2021/11/11.
//

import UIKit

class MemoListCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setDate(data: Memo) {
        titleLabel.text = data.title
        contentLabel.text = data.content
        dateLabel.text = Date.from(date: data.insertDate)
    }
}

extension Date {
    static func from(date: Date) -> String {
        let now = Date()
        let formatter = DateFormatter()
        //한국 시간으로 표시
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        //형태 변환
        formatter.dateFormat = "yyyy년 MM월 dd일\na hh:mm"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        
        return formatter.string(from: now)
    }
}
