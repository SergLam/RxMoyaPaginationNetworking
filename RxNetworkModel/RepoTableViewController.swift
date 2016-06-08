//
//  RepoTableViewController.swift
//  RxNetworkModel
//
//  Created by Leo on 2016/6/7.
//  Copyright © 2016年 Leo. All rights reserved.
//

import Moya
import Moya_ModelMapper
import UIKit
import RxCocoa
import RxSwift

class RepoTableViewController: UIViewController {

    var tableView: UITableView!
    var searchBar:UISearchBar!
    
    let disposeBag = DisposeBag()
    var provider: RxMoyaProvider<GitHub>!
    var repositoryNetworkModel:RepositoryNetworkModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Demo:Rxswift+Moya+Pagination"
        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        self.view = tableView
        setupRx()
    }

    func setupRx() {
        
        provider = RxMoyaProvider<GitHub>()
        repositoryNetworkModel = RepositoryNetworkModel(provider: provider)
        repositoryNetworkModel.elements.asDriver()
            .drive(tableView.rx_itemsWithCellFactory) { (tableView, row, item) in
                let cell = UITableViewCell(style: .Default, reuseIdentifier: "repositoryCell")
                cell.textLabel?.text = item.full_name
                return cell
            }.addDisposableTo(disposeBag)
    
        rx_sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .bindTo(repositoryNetworkModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        tableView.rx_reachedBottom
            .bindTo(repositoryNetworkModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)

    }
}