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

protocol MemoDelegate: AnyObject {
    func createMemo(title: String?, content: String, date: Date)
    func updateMemo(title: String?, content: String, date: Date, at index: IndexPath)
}

class MemoListViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!

    var viewModel = MemoViewModel()
    let disposeBag = DisposeBag()
    var searchText : String?
    
    lazy var dataSource: RxTableViewSectionedAnimatedDataSource<MemoSectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<MemoSectionModel>(configureCell: { (dataSource, tableView, indexPath, memo) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MemoListCell", for: indexPath) as! MemoListCell
            cell.setDate(data: memo, text: self.searchText)
            return cell
        }, titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        })
        ds.canEditRowAtIndexPath = { _, _ in return true }
        return ds
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        bind()
        
        if !UserDefaults.standard.bool(forKey: "OnBoardingFlag") {
            UserDefaults.standard.set(true, forKey: "OnBoardingFlag")
            guard let vc = UIStoryboard(name: "OnBoarding", bundle: nil)
                    .instantiateViewController(withIdentifier: "OnBoardingViewController") as? OnBoardingViewController else { return }
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func ComposeButtonTapped(_ sender: UIBarButtonItem) {
        guard let vc = UIStoryboard(name: "Compose", bundle: nil)
                .instantiateViewController(withIdentifier: "MemoComposeViewController") as? MemoComposeViewController else { return }
        vc.delegate = self
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
        
        Observable.zip(tableView.rx.modelSelected(Memo.self), tableView.rx.itemSelected)
            .subscribe(onNext: { [unowned self] ( memo, indexPath) in
                guard let vc = UIStoryboard(name: "Compose", bundle: nil)
                        .instantiateViewController(withIdentifier: "MemoComposeViewController") as? MemoComposeViewController else { return }
                vc.delegate = self
                vc.updateValue(updateflag: true, memo: memo, indexPath: indexPath)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
                
//        self.tableView.rx.itemSelected
//            .subscribe(onNext: {  [weak self] indexPath in
//                guard let vc = UIStoryboard(name: "Compose", bundle: nil)
//                        .instantiateViewController(withIdentifier: "MemoComposeViewController") as? MemoComposeViewController else { return }
//                vc.delegate = self
//                vc.updateValue(updateflag: true, memo: self?.viewModel., indexPath: indexPath)
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }).disposed(by: self.disposeBag)
                
                
        self.tableView.rx
            .itemDeleted
            .subscribe (onNext: { [weak self] indexPath in
                let indexPath = indexPath
                let alert = UIAlertController(title: "삭제 하시겠습니까?", message: "복구는 불가능합니다.", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "취소", style: .default)
                let confirmAction = UIAlertAction(title: "확인", style: .destructive) {  _ in
                    self?.viewModel.delete(at: indexPath)
                }
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "0개의 메모"
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension MemoListViewController: MemoDelegate {
    func createMemo(title: String?, content: String, date: Date) {
        self.viewModel.createMemo(title: title, content: content, date: date)
    }
    
    func updateMemo(title: String?, content: String, date: Date, at index: IndexPath) {
        self.viewModel.update(title: title, content: content, date: date, at: index)
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
                    let defaultAction = UIAlertAction(title: "확인", style: .default)
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

extension MemoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, text != "" else {
            searchText = nil
            self.viewModel.cancelSearchBarText()
            return
        }
        searchText = text
        self.viewModel.didUpdateSearchBarText(text: text)
    }
}
