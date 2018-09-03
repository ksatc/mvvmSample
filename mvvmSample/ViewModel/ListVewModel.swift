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
    func reloadPushed()
}

protocol ListViewModelOutputs {
    var itemList: Observable<[Item]> { get }
    var showDialog: Observable<Item> { get }
    var state:  Observable<Status> { get }
}

protocol ListViewModelType {
    var inputs: ListViewModelInputs { get }
    var outputs: ListViewModelOutputs { get }
}

final class ListViewModel: ListViewModelType, ListViewModelInputs, ListViewModelOutputs {

    var inputs: ListViewModelInputs { return self }
    var outputs: ListViewModelOutputs { return self }

    var itemList: Observable<[Item]>
    var showDialog: Observable<Item>
    var state:  Observable<Status>
    
    init() {
        
        let stateProperty = PublishSubject<Status>()
        
        let apiRequest = Observable.of(viewDidLoadProperty.map { _ in },
                                       reloadPushedProperty.withLatestFrom(stateProperty).filter { $0 != Status.loading }.map { _ in })
            .merge()
            .do(onNext: { (_) in
                stateProperty.onNext(.loading)
            }).flatMapLatest({
                return MockApi.shared.testApi()
                    .do(onSuccess: { (result) in
                        if result.isEmpty {
                            stateProperty.onNext(.empty)
                        } else {
                            stateProperty.onNext(.complete)
                        }
                    }, onError: { (_) in
                        stateProperty.onNext(.error)
                    }).catchErrorJustReturn([])
            }).share(replay: 1, scope: .forever)
        
        state = stateProperty
        itemList = apiRequest
        
        showDialog = tablePushedProperty.withLatestFrom(itemList,
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
    
    private let reloadPushedProperty = PublishSubject<()>()
    func reloadPushed() {
        reloadPushedProperty.onNext(())
    }

}
