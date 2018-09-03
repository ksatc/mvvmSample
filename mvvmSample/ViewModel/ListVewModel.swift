//
//  ListVewModel.swift
//  mvvmSample
//
//  Created by KAWASAKITAKAFUMI on 2018/09/03.
//  Copyright © 2018年 kawasaki. All rights reserved.
//

import Foundation
import RxSwift

enum Status {
    case loading
    case complete
    case empty
    case error
}
protocol ListViewModelInputs {

    func viewDidLoad()

    func tablePushed(_ index: IndexPath)
    func refreshPushed()
}

protocol ListViewModelOutputs {

    var showCoverView: Observable<()> { get }
    var hideCoverView: Observable<()> { get }
    
    var itemList: Observable<[Item]> { get }
    
    var showAlert: Observable<Item> { get }
    
}

protocol ListViewModelType {
    var inputs: ListViewModelInputs { get }
    var outputs: ListViewModelOutputs { get }
}

final class ListViewModel: ListViewModelType, ListViewModelInputs, ListViewModelOutputs {

    var inputs: ListViewModelInputs { return self }
    var outputs: ListViewModelOutputs { return self }

    
    var showCoverView: Observable<()>
    var hideCoverView: Observable<()>
    var itemList: Observable<[Item]>
    var showAlert: Observable<Item>
    
    init() {
        
        let stateProperty = PublishSubject<Status>()
        
        let apiRequest = Observable.of(viewDidLoadProperty.map { _ in },
                                       refreshPushedProperty.withLatestFrom(stateProperty).filter { $0 != Status.loading }.map { _ in })
            .merge()
            .do(onNext: { (_) in
                stateProperty.onNext(.loading)
            }).flatMap {
                return MockApi.shared.testApi()
            }.do(onNext: { (_) in
                stateProperty.onNext(.complete)
            }, onError: { (_) in
                stateProperty.onNext(.error)
            }).share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        showCoverView = stateProperty.filter { $0 == Status.loading }.map { _ in () }
        hideCoverView = stateProperty.filter { $0 == Status.complete }.map { _ in () }
        itemList = apiRequest
        
        showAlert = tablePushedProperty.withLatestFrom(itemList,
                                                       resultSelector: { (indexPath, list) -> Item in
                                                        return list[indexPath.row]
                                                    })
    }
    
    private let viewDidLoadProperty = PublishSubject<()>()
    func viewDidLoad() {
        viewDidLoadProperty.onNext(())
    }
    
    private let tablePushedProperty = PublishSubject<IndexPath>()
    func tablePushed(_ index: IndexPath) {
        tablePushedProperty.onNext(index)
    }
    
    private let refreshPushedProperty = PublishSubject<()>()
    func refreshPushed() {
        refreshPushedProperty.onNext(())
    }

}
