//
//  MemoComposeViewController.swift
//  Memo
//
//  Created by meng on 2021/11/09.
//

import UIKit

class MemoComposeViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var memo: Memo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.font = .systemFont(ofSize: 17, weight: .bold)
        if let memo = memo {
            textView.text = "\(memo.title ?? "")\n\(memo.content)"
        }
        setNavigationBar()
    }
    
    private func setNavigationBar() {
        let completed = UIBarButtonItem(title: "완료",
                                        style: .plain,
                                        target: self,
                                        action: #selector(didTapCompleteButton))
        let share = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                    style: .plain,
                                    target: self,
                                    action: #selector(didTapShareButton))

        self.navigationItem.rightBarButtonItems = [completed, share]
    }
    
    @objc private func didTapCompleteButton(){
        self.dismiss(animated: true) {
            print("완료됨")
        }
    }
    
    @objc private func didTapShareButton(){

    }
}
