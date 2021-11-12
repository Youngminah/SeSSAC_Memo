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
    
    func setDate(data: Memo, text: String?) {
        if let text = text {
            if let title = data.title {
                let attributedTitle = NSMutableAttributedString(string: title)
                attributedTitle.addAttribute(.foregroundColor, value: UIColor.orange, range: (title as NSString).range(of: text))
                titleLabel.attributedText = attributedTitle
            }
            
            let attributedContent = NSMutableAttributedString(string: data.content)
            attributedContent.addAttribute(.foregroundColor, value: UIColor.orange, range: (data.content as NSString).range(of: text))
            contentLabel.attributedText = attributedContent
            
            dateLabel.text = Date.from(date: data.insertDate)
            return
        }
        titleLabel.text = data.title
        contentLabel.text = data.content
        dateLabel.text = Date.from(date: data.insertDate)
    }
}
