//
//  ListVC.swift
//  mvvmSample
//
//  Created by KAWASAKITAKAFUMI on 2018/09/03.
//  Copyright © 2018年 kawasaki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var coverView: UIView!
    @IBOutlet private weak var emptyLabel: UILabel!
    
    private var disposeBag = DisposeBag()
    private let viewModel: ListViewModelType = ListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.outputs.itemList.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, element, cell in
            cell.textLabel?.text = element.name
        }.disposed(by: disposeBag)
        
        viewModel.outputs.showDialog.observeOn(MainScheduler.instance).subscribe (onNext: { [weak self] (item) in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: "タップイベント",
                                          message: "\(item.name)をタップした", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
            
            strongSelf.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.state.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (status) in
            guard let strongSelf = self else { return }
            switch status {
            case .loading:
                strongSelf.coverView.isHidden = false
                strongSelf.tableView.isHidden = true
                strongSelf.emptyLabel.isHidden = true
            case .complete:
                strongSelf.coverView.isHidden = true
                strongSelf.tableView.isHidden = false
                strongSelf.emptyLabel.isHidden = true
            case .empty:
                strongSelf.coverView.isHidden = true
                strongSelf.tableView.isHidden = true
                strongSelf.emptyLabel.isHidden = false
            case .error:
                strongSelf.coverView.isHidden = true
                strongSelf.tableView.isHidden = true
                strongSelf.emptyLabel.isHidden = true
                strongSelf.showAlertError()
            }
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let strongSelf = self else { return }
            strongSelf.tableView.deselectRow(at: indexPath, animated: true)
            strongSelf.viewModel.inputs.tablePushed(indexPath)
        }).disposed(by: disposeBag)
        
        viewModel.inputs.viewDidLoad()
    }

    @IBAction private func tappedReloadButton(_ sender: UIBarButtonItem) {
        viewModel.inputs.reloadPushed()
    }
    
    private func showAlertError() {
        
        let alert = UIAlertController(title: "エラー",
                                      message: "通信エラーが発生しました。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "リロードする", style: .default, handler: {[weak self] (_) in
            self?.viewModel.inputs.reloadPushed()
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
