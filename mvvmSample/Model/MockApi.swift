//
//  MockApi.swift
//  mvvmSample
//
//  Created by KAWASAKITAKAFUMI on 2018/09/03.
//  Copyright © 2018年 kawasaki. All rights reserved.
//

import Foundation

import RxSwift

class MockApi {
    
    static let shared = MockApi()
    
    
    func testApi() -> Single<[Item]> {
        
        return Single<[Item]>.create { observer in
            
            DispatchQueue(label: "test").asyncAfter(deadline: .now() + 1.0, execute: {
                
                let array = [Item(id: 1, name: "item1"),
                             Item(id: 2, name: "item2"),
                             Item(id: 3, name: "item3"),
                             Item(id: 4, name: "item4"),
                             Item(id: 5, name: "item5"),
                             Item(id: 6, name: "item6"),
                             Item(id: 7, name: "item7"),
                             Item(id: 8, name: "item8"),
                             Item(id: 9, name: "item9"),
                             Item(id: 10, name: "item10")]
                observer(.success(array))
            })
            
            
            return Disposables.create()
        }
    }
}
