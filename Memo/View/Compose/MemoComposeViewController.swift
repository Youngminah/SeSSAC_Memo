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
    
    var viewModel = MemoViewModel()
    var updateflag: Bool = false
    var memo: Memo?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            saveText()
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
            if let indexPath = indexPath {
                viewModel.update(title: nil, content: memoArray[0], date: Date(), at: indexPath)
            } else {
                viewModel.createMemo(title: nil, content: memoArray[0], date: Date())
            }
        } else {
            if let indexPath = indexPath {
                viewModel.update(title: memoArray[0], content: memoArray[1], date: Date(), at: indexPath)
            } else {
                viewModel.createMemo(title: memoArray[0], content: memoArray[1], date: Date())
            }
        }
    }
}
