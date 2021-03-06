//
//  StatsItemType.swift
//  PiStatsMobile
//
//  Created by Fernando Bunn on 04/07/2020.
//

import SwiftUI

enum StatsItemType {
    case totalQueries
    case queriesBlocked
    case percentBlocked
    case domainsOnBlockList

    var imageName: String {
        switch self {
        case .domainsOnBlockList:
            return "list.bullet"
        case .totalQueries:
            return "globe"
        case .queriesBlocked:
            return "hand.raised"
        case .percentBlocked:
            return "chart.pie"
        }
    }
    
    var title: String {
        switch self {
        case .domainsOnBlockList:
            return UIConstants.Strings.blocklist
        case .totalQueries:
            return UIConstants.Strings.totalQueries
        case .queriesBlocked:
            return UIConstants.Strings.queriesBlocked
        case .percentBlocked:
            return UIConstants.Strings.percentBlocked
        }
    }
    
    var color: Color {
        switch self {
        case .domainsOnBlockList:
            return UIConstants.Colors.domainsOnBlocklist
        case .totalQueries:
            return UIConstants.Colors.totalQueries
        case .queriesBlocked:
            return UIConstants.Colors.queriesBlocked
        case .percentBlocked:
            return UIConstants.Colors.percentBlocked
        }
    }
}
