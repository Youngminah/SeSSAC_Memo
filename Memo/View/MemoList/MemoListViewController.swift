//
//  MemoListViewController.swift
//  Memo
//
//  Created by meng on 2021/11/09.
//

import UIKit
import RxSwift
import RxCocoa

class MemoListViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!

    var viewModel = MemoViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let vc = UIStoryboard(name: "OnBoarding", bundle: nil)
                .instantiateViewController(withIdentifier: "OnBoardingViewController") as? OnBoardingViewController else { return }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        setupSearchController()
        bind()
    }
    
    @IBAction func ComposeButtonTapped(_ sender: UIBarButtonItem) {
        guard let vc = UIStoryboard(name: "Compose", bundle: nil)
                .instantiateViewController(withIdentifier: "MemoComposeViewController") as? MemoComposeViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func bind() {
        
        self.viewModel.memoList
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items) { memo, row, data in
                let index = IndexPath(row: row, section: 0)
                let cell = memo.dequeueReusableCell(withIdentifier: "MemoListCell", for: index) as! MemoListCell
                cell.setDate(data: data)
                return cell
            }
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(Memo.self)
            .subscribe(onNext: {  [weak self] memo in
                guard let vc = UIStoryboard(name: "Compose", bundle: nil)
                        .instantiateViewController(withIdentifier: "MemoComposeViewController") as? MemoComposeViewController else { return }
                vc.memo = memo
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: self.disposeBag)
                
                
        self.tableView.rx
            .modelDeleted(Memo.self)
            .subscribe {
                self.viewModel.delete(memo: $0)
            }
            .disposed(by: disposeBag)
            
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "0개의 메모"
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension MemoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // code
        print("텍스트")
    }
}


