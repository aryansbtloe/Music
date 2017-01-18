//
//  Paginator.swift
//  Application
//
//  Created by Alok Singh on 01/07/16.
//  Copyright © 2016 Swan Music. All rights reserved.
//


import Foundation

enum PaginatorMode {

}

class Paginator: AKSPaginator   {
    var paginationFor : PaginatorMode?
    var userInfo : NSDictionary?
    override func fetchPage(_ page:NSInteger){
    }
}


