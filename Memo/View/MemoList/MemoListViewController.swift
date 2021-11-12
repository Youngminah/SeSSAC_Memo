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
import YMLogoAlert

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
            .distinctUntilChanged()
            .bind(to: tableView.rx.items(dataSource:  self.dataSource))
            .disposed(by: disposeBag)
        
        self.viewModel.memoList
            .map { modelList -> String in
                var count = 0
                modelList.forEach {
                    count += $0.items.count
                }
                return "\(count)".insertComma + "개의 메모"
            }
            .asObservable()
            .bind(to: self.rx.title)
            .disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(Memo.self)
            .subscribe(onNext: {  [weak self] memo in
                guard let vc = UIStoryboard(name: "Compose", bundle: nil)
                        .instantiateViewController(withIdentifier: "MemoComposeViewController") as? MemoComposeViewController else { return }
                vc.memo = memo
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: self.disposeBag)
                
                
        self.tableView.rx
            .itemDeleted
            .subscribe {
                self.viewModel.delete(at: $0)
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
        guard let text = searchController.searchBar.text, text != "" else {
            self.viewModel.cancelSearchBarText()
            return
        }
        self.viewModel.didUpdateSearchBarText(text: text)
    }
}

extension MemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath:IndexPath) -> UISwipeActionsConfiguration? {
        var shareAction = UIContextualAction()

        if indexPath.section == 0 {
            shareAction = UIContextualAction(style: .normal,
                                                 title:  nil ) { [unowned self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("고정해제 \(indexPath.section)")
                self.viewModel.updateFixToUnfix(at: indexPath.row)
            }
            shareAction.image = UIImage(systemName: "pin.slash.fill")
        } else {
            shareAction = UIContextualAction(style: .normal,
                                                 title:  nil ) { [unowned self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("고정 \(indexPath.section)")
                if self.viewModel.countFixedMemo > 4 {
                    let alert = UIAlertController(title: "에러", message: "최대 5개까지만 고정 가능합니다.", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "확인", style: .destructive)
                    alert.addAction(defaultAction)
                    present(alert,animated: true, completion: nil)
                    return
                }
                self.viewModel.updateUnfixToFix(at: indexPath.row)
            }
            shareAction.image = UIImage(systemName: "pin.fill")
        }
        shareAction.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions:[shareAction])
    }
}

