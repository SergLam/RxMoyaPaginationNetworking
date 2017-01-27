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
import MBProgressHUD

class RepoTableViewController: UIViewController {

    var refreshControl : UIRefreshControl?
    
    var tableView: UITableView!
    var searchBar:UISearchBar!
    
    let disposeBag = DisposeBag()
    var repositoryNetworkModel:RepositoryNetworkModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Demo:Rxswift+Moya+Pagination"
        tableView = UITableView(frame: UIScreen.main.bounds)
        self.view = tableView
        setupRx()
    }

    func setupRx() {
        
        self.refreshControl = UIRefreshControl()
        
        if let refreshControl = self.refreshControl {
            
            self.view.addSubview(refreshControl)
            
        }
        
        repositoryNetworkModel = RepositoryNetworkModel(provider: githubProvider)
        repositoryNetworkModel.elements.asObservable()
            .bindTo(self.tableView.rx.items) { (tableView, row, item) in
                let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "reuseIdentifier")
                cell.textLabel?.text = item.full_name
                return cell
        }.addDisposableTo(disposeBag)
        
        
        rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .bindTo(repositoryNetworkModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        tableView.rx_reachedBottom
            .bindTo(repositoryNetworkModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)
        
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .bindTo(repositoryNetworkModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        repositoryNetworkModel.loading.asDriver()
             .filter { !$0 && self.refreshControl?.isRefreshing == true }
             .drive(onNext: { _ in
                self.refreshControl?.endRefreshing()
             }).addDisposableTo(disposeBag)
        
    
    }
}

func isLoading(for view: UIView) -> AnyObserver<Bool> {
    return UIBindingObserver(UIElement: view, binding: { (hud, isLoading) in
        switch isLoading {
        case true:
            MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        case false:
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            break
        }
        
    }).asObserver()
}


