//
//  OnBoardingViewController.swift
//  Memo
//
//  Created by meng on 2021/11/10.
//

import UIKit

class OnBoardingViewController: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    private func attribute() {
        titleLabel.text = "처음 오셨군요!\n환영합니다:)"
        contentLabel.text = "당신만의 메모를\n작성하고 관리해보세요!"
        alertView.layer.cornerRadius = 20
        confirmButton.layer.cornerRadius = 15
    }
}
