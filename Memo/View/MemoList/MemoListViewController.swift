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

    var viewModel = MemoViewModel(dataManager: MemoryStorage())
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
        
        self.viewModel.data
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items) { memo, row, data in
                let index = IndexPath(row: row, section: 0)
                let cell = memo.dequeueReusableCell(withIdentifier: "MemoListCell", for: index) as! MemoListCell
                cell.setDate(data: data)
                return cell
            }
            .disposed(by: self.disposeBag)
        
        self.tableView.rx
            .itemSelected
            .do(onNext: { [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: false)
            })
            .flatMap { [unowned self] indexPath -> Observable<Memo> in
                return self.viewModel.data.map {
                    $0[indexPath.row]
                }
            }
            .subscribe (onNext: { [weak self] memo in
                guard let vc = UIStoryboard(name: "Compose", bundle: nil)
                        .instantiateViewController(withIdentifier: "MemoComposeViewController") as? MemoComposeViewController else { return }
                vc.memo = memo
                self?.navigationController?.pushViewController(vc, animated: true)
            })
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
    }
}


