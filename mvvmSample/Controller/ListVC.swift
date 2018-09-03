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
    
    private var disposeBag = DisposeBag()
    private let viewModel: ListViewModelType = ListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.outputs.showCoverView.subscribe(onNext: {[weak self] () in
            self?.coverView.isHidden = false
            self?.tableView.isHidden = true
        }).disposed(by: disposeBag)
        
        viewModel.outputs.hideCoverView.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] () in
            self?.coverView.isHidden = true
            self?.tableView.isHidden = false
        }).disposed(by: disposeBag)
        
        viewModel.outputs.itemList.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, element, cell in
            cell.textLabel?.text = element.name
        }.disposed(by: disposeBag)
        
        viewModel.outputs.showAlert.observeOn(MainScheduler.instance).subscribe { [weak self] (item) in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: "タップイベント",
                                          message: "\(item.element!.name)をタップした", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
            
            strongSelf.present(alert, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
                self?.viewModel.inputs.tablePushed(indexPath)
        }).disposed(by: disposeBag)
        
        viewModel.inputs.viewDidLoad()
    }

    @IBAction private func tappedRefreshButton(_ sender: UIBarButtonItem) {
        viewModel.inputs.refreshPushed()
    }
}
