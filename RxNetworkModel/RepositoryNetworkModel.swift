//
//  RepositoryNetworkModel.swift
//  RxNetworkModel
//
//  Created by Leo on 2016/6/7.
//  Copyright © 2016年 Leo. All rights reserved.
//

import Foundation
import Moya
import Mapper
import Moya_ModelMapper
import RxOptional
import RxSwift

class RepositoryNetworkModel {
    
    let provider: RxMoyaProvider<GitHub>
    
    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()
    let loading = Variable<Bool>(false)
    let elements = Variable<[Repository]>([])
    var pageIndex:Int = 1
    let error = PublishSubject<Swift.Error>()

    private let disposeBag = DisposeBag()

    init(provider:RxMoyaProvider<GitHub>){
        self.provider = provider
       
        let refreshRequest = loading.asObservable()
            .sample(refreshTrigger)
            .flatMap { loading -> Observable<[Repository]> in
                if loading {
                    return Observable.empty()
                } else {
                    self.pageIndex = 1
                    return self.fetchRepository(keyword: "swift",page:self.pageIndex).filterNil()
                }
        }
        
        let nextPageRequest = loading.asObservable()
            .sample(loadNextPageTrigger)
            .flatMap { loading -> Observable<[Repository]> in
                if loading {
                    return Observable.empty()
                } else {
                    self.pageIndex = self.pageIndex + 1
                    return self.fetchRepository(keyword: "swift",page:self.pageIndex).filterNil()
                }
                
            }
        
        
        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .shareReplay(1)
        
        let response = request.flatMap { repositories -> Observable<[Repository]> in
            request
                .do(onError: { error in
                    self.error.onNext(error)
                }).catchError({ error -> Observable<[Repository]> in
                    Observable.empty()
                })
            }.shareReplay(1)
        
         Observable
             .combineLatest(request, response, elements.asObservable()) { request, response, elements in
                return self.pageIndex == 1 ? response : elements + response
        }
        .sample(response)
        .bindTo(elements)
        .addDisposableTo(disposeBag)

    Observable
            .of(request.map { _ in true },
                response.map { _ in false },
                error.map { _ in false }
            )
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)
      
    }
    
    func fetchRepository(keyword:String, page:Int) -> Observable<[Repository]?> {
        return self.provider
            .request(GitHub.FetchRepositorys(keyword:keyword,page:page))
          //  .debug()
            .mapArrayOptional(type: Repository.self, keyPath: "items")
    }
 
}
