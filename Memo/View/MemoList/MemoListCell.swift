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
