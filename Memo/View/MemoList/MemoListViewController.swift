//
//  MemoListViewController.swift
//  Memo
//
//  Created by meng on 2021/11/09.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MemoListViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!

    var viewModel = MemoViewModel()
    let disposeBag = DisposeBag()
    
    let dataSource: RxTableViewSectionedAnimatedDataSource<MemoSectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<MemoSectionModel>(configureCell: { (dataSource, tableView, indexPath, memo) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MemoListCell", for: indexPath) as! MemoListCell
            cell.setDate(data: memo)
            return cell
        }, titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        })
        ds.canEditRowAtIndexPath = { _, _ in return true }
        return ds
    }()
    
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
        
        self.tableView.rx.setDelegate(self)
                    .disposed(by: disposeBag)
        
        self.viewModel.memoList
            .bind(to: tableView.rx.items(dataSource:  self.dataSource))
            .disposed(by: disposeBag)
        
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
        print("텍스트 입력됨")
    }
}

extension MemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath:IndexPath) -> UISwipeActionsConfiguration? {
        var shareAction = UIContextualAction()

        if indexPath.section == 0 {
            shareAction = UIContextualAction(style: .normal,
                                                 title:  nil ) { [weak self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("고정해제 \(indexPath.section)")
                self?.viewModel.updateFixToUnfix(at: indexPath.row)
            }
            shareAction.image = UIImage(systemName: "pin.slash.fill")
        } else {
            shareAction = UIContextualAction(style: .normal,
                                                 title:  nil ) { [weak self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("고정 \(indexPath.section)")
                self?.viewModel.updateUnfixToFix(at: indexPath.row)
            }
            shareAction.image = UIImage(systemName: "pin.fill")
        }
        shareAction.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions:[shareAction])
    }
}

