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
    func updateMemo(title: String?, content: String, date: Date, originalDate: Date)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchText = nil
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
            .debounce(RxTimeInterval.microseconds(10), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: tableView.rx.items(dataSource:  self.dataSource))
            .disposed(by: disposeBag)
        
        self.viewModel.memoList
            .map { modelList -> String in
                var count = 0
                modelList.forEach {
                    count += $0.items.count
                }
                return "\(count)".insertComma + "?????? ??????"
            }
            .asObservable()
            .bind(to: self.rx.title)
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.modelSelected(Memo.self), tableView.rx.itemSelected)
            .subscribe(onNext: { [unowned self] ( memo, indexPath) in
                guard let vc = UIStoryboard(name: "Compose", bundle: nil)
                        .instantiateViewController(withIdentifier: "MemoComposeViewController") as? MemoComposeViewController else { return }
                vc.delegate = self
                vc.updateValue(updateflag: true, memo: memo, originalDate: memo.insertDate)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
                
        self.tableView.rx
            .itemDeleted
            .subscribe (onNext: { [weak self] indexPath in
                let indexPath = indexPath
                let alert = UIAlertController(title: "?????? ???????????????????", message: "????????? ??????????????????.", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "??????", style: .default)
                let confirmAction = UIAlertAction(title: "??????", style: .destructive) {  _ in
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
        searchController.searchBar.placeholder = "??????"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "0?????? ??????"
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension MemoListViewController: MemoDelegate {
    func createMemo(title: String?, content: String, date: Date) {
        self.viewModel.createMemo(title: title, content: content, date: date)
    }
    
    func updateMemo(title: String?, content: String, date: Date, originalDate: Date) {
        self.viewModel.update(title: title, content: content, date: date, originalDate: originalDate)
    }
}

extension MemoListViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchText = nil
    }
}

extension MemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath:IndexPath) -> UISwipeActionsConfiguration? {
        var shareAction = UIContextualAction()
        guard let text = searchText else {
            if indexPath.section == 0 {
                shareAction = UIContextualAction(style: .normal,
                                                 title:  nil ) { [unowned self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    let memo = self.viewModel.fixedMemoList[indexPath.row]
                    self.viewModel.updatePin(date: memo.insertDate)
                }
                shareAction.image = UIImage(systemName: "pin.slash.fill")
            } else {
                shareAction = UIContextualAction(style: .normal,
                                                 title:  nil ) { [unowned self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    if self.viewModel.countFixedMemo > 4 {
                        let alert = UIAlertController(title: "??????", message: "?????? 5???????????? ?????? ???????????????.", preferredStyle: UIAlertController.Style.alert)
                        let defaultAction = UIAlertAction(title: "??????", style: .default)
                        alert.addAction(defaultAction)
                        present(alert,animated: true, completion: nil)
                        return
                    }
                    let memo = self.viewModel.unFixedMemoList[indexPath.row]
                    self.viewModel.updatePin(date: memo.insertDate)
                }
                shareAction.image = UIImage(systemName: "pin.fill")
            }
            shareAction.backgroundColor = .orange
            return UISwipeActionsConfiguration(actions:[shareAction])
        }
        let memo = self.viewModel.memos
            .filter {
                $0.title?.contains(text) ?? false || $0.content.contains(text)
            }.sorted(by: {
                $0.insertDate > $1.insertDate
            })[indexPath.row]
        shareAction = UIContextualAction(style: .normal,
                                         title:  nil ) { [unowned self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.viewModel.updatePin(date: memo.insertDate)
        }
        if memo.isFixed {
            shareAction.image = UIImage(systemName: "pin.slash.fill")
        } else {
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
