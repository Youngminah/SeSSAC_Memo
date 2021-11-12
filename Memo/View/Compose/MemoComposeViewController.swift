//
//  MemoComposeViewController.swift
//  Memo
//
//  Created by meng on 2021/11/09.
//

import UIKit
import MobileCoreServices

class MemoComposeViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var delegate: MemoDelegate?
    private var updateflag: Bool = false
    private var memo: Memo?
    private var originalDate: Date?
    private var editFlag = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.font = .systemFont(ofSize: 17, weight: .bold)
        if updateflag {
            textView.text = "\(memo!.title ?? "")\n\(memo!.content)"
        } else {
            textView.becomeFirstResponder()
        }
        setNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
        if self.isMovingFromParent {
            if editFlag {
                saveText()
            }
        }
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
    
    func updateValue(updateflag: Bool, memo: Memo, originalDate: Date) {
        self.updateflag = updateflag
        self.memo = memo
        self.originalDate = originalDate
    }
    
    @objc private func didTapCompleteButton(){
        let alert = UIAlertController(title: "저장되었습니다.", message: nil, preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(defaultAction)
        self.present(alert,animated: true, completion: nil)
    }
    
    @objc private func didTapShareButton(){
        presentActivityViewController()
    }
    
    private func presentActivityViewController() {
        guard  let text = textView.text , text != "" else {
            print("텍스트를 쓰라는 알람창!!")
            return
        }
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    private func saveText() {
        guard let text = textView.text , text != "" else {
            return
        }
        let memoArray = text.pasringContectText
        if memoArray.count == 1{
            if updateflag {
                delegate?.updateMemo(title: nil, content: memoArray[0], date: Date(), originalDate: originalDate!)
            } else {
                delegate?.createMemo(title: nil, content: memoArray[0], date: Date())
            }
        } else {
            if updateflag {
                delegate?.updateMemo(title: memoArray[0], content: memoArray[1], date: Date(), originalDate: originalDate!)
            } else {
                delegate?.createMemo(title: memoArray[0], content: memoArray[1], date: Date())
            }
        }
    }
}

extension MemoComposeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        editFlag = true
    }
}
