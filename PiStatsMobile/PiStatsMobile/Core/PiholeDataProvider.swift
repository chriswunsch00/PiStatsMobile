//
//  piholeservice.swift
//  piholestats
//
//  Created by Fernando Bunn on 24/05/2020.
//  Copyright © 2020 Fernando Bunn. All rights reserved.
//

import Foundation
import SwiftHole
import SwiftUI



class PiholeDataProvider: ObservableObject, Identifiable {
    
    static func previewData() -> PiholeDataProvider {
        let provider =  PiholeDataProvider.init(piholes: [Pihole.previewData()])
        provider.totalQueries = "1245"
        provider.queriesBlocked = "1245"
        provider.percentBlocked = "12,3%"
        provider.domainsOnBlocklist = "12,345"
        provider.status = .allEnabled
        return provider
    }
    
    enum PiholeStatus {
        case allEnabled
        case allDisabled
        case enabledAndDisabled
    }
    
    enum PollingMode {
        case foreground
        case background
    }
    
    private(set) var pollingTimeInterval: TimeInterval = 3
    private var timer: Timer?
    private(set) var piholes: [Pihole]
    let id = UUID()
    
    @Published private(set) var totalQueries = ""
    @Published private(set) var queriesBlocked = ""
    @Published private(set) var percentBlocked = ""
    @Published private(set) var domainsOnBlocklist = ""
    @Published private(set) var hasErrorMessages = false
    @Published private(set) var status: PiholeStatus = .allDisabled
    @Published private(set) var name = ""
    @Published private(set) var pollingErrors = [String]()
    @Published private(set) var actionErrors = [String]()

     var canDisplayEnableDisableButton: Bool {
        return !piholes.allSatisfy {
            return $0.apiToken.isEmpty == true
        }
    }
    
    var changeStatusButtonTitle: String {
        if status != .allDisabled {
            return UIConstants.Strings.disableButton
        } else {
            return UIConstants.Strings.enableButton
        }
    }
    
    var statusColor: Color {
        if hasErrorMessages {
            return UIConstants.Colors.statusWarning
        }
        switch status {
        case .allDisabled:
            return UIConstants.Colors.statusOffline
        case .allEnabled:
            return UIConstants.Colors.statusOnline
        case .enabledAndDisabled:
            return UIConstants.Colors.statusWarning
        }
    }
    
    var statusText: String {
        if hasErrorMessages {
            return UIConstants.Strings.statusNeedsAttention
        }
          switch status {
          case .allDisabled:
            return UIConstants.Strings.statusDisabled
          case .allEnabled:
            return UIConstants.Strings.statusEnabled
          case .enabledAndDisabled:
              return UIConstants.Strings.statusEnabledAndDisabled
          }
      }
    
    private lazy var percentageFormatter: NumberFormatter = {
          let n = NumberFormatter()
          n.numberStyle = .percent
          n.minimumFractionDigits = 2
          n.maximumFractionDigits = 2
          return n
      }()
      
      private lazy var numberFormatter: NumberFormatter = {
          let n = NumberFormatter()
          n.numberStyle = .decimal
          n.maximumFractionDigits = 0
          return n
      }()
    
    init(piholes: [Pihole]) {
        self.piholes = piholes
        self.name = piholes.first?.host ?? ""
    }
    
    func updatePollingMode(_ pollingMode: PollingMode) {
        switch pollingMode {
        case .background:
            pollingTimeInterval = 10
        case .foreground:
            pollingTimeInterval = 3
        }
        startPolling()
    }
    
    func startPolling() {
        self.fetchSummaryData()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: pollingTimeInterval, repeats: true) { _ in
            self.fetchSummaryData()
        }
    }
    
    func stopPolling() {
        timer?.invalidate()
    }
    
    func resetErrorMessage() {
        piholes.forEach { pihole in
            pihole.actionError = nil
            pihole.pollingError = nil
        }
        updateErrorMessageStatus()
    }
    
    func add(_ pihole: Pihole) {
        objectWillChange.send()
        piholes.append(pihole)
        updateStatus()
        updateErrorMessageStatus()

    }
    
    func remove(_ pihole: Pihole) {
        objectWillChange.send()
        if let index = piholes.firstIndex(of: pihole) {
            piholes.remove(at: index)
        }
        updateStatus()
        updateErrorMessageStatus()
    }
    
    func disablePiHole(seconds: Int = 0) {
        piholes.forEach { pihole in
            pihole.disablePiHole(seconds: seconds) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        pihole.actionError = nil
                        self.updateStatus()
                    case .failure(let error):
                        pihole.actionError = self.errorMessage(error)
                    }
                }
                self.updateErrorMessageStatus()

            }
        }
    }
    
    func enablePiHole() {
        piholes.forEach { pihole in
            pihole.enablePiHole { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        pihole.actionError = nil
                        self.updateStatus()
                    case .failure(let error):
                        pihole.actionError = self.errorMessage(error)
                    }
                    self.updateErrorMessageStatus()
                }
            }
        }
    }
    
    private func errorMessage(_ error: SwiftHoleError) -> String {
        switch error {
        case .malformedURL:
            return UIConstants.Strings.Error.invalidURL
        case .invalidDecode(let decodeError):
            return  "\(UIConstants.Strings.Error.decodeResponseError): \(decodeError.localizedDescription)"
        case .noAPITokenProvided:
            return  UIConstants.Strings.Error.noAPITokenProvided
        case .sessionError(let sessionError):
            return  "\(UIConstants.Strings.Error.sessionError): \(sessionError.localizedDescription)"
        case .invalidResponseCode(let responseCode):
            return  "\(UIConstants.Strings.Error.sessionError): \(responseCode)"
        case .invalidResponse:
            return  UIConstants.Strings.Error.invalidResponse
        case .invalidAPIToken:
            return  UIConstants.Strings.Error.invalidAPIToken
        }
    }
    
    private func fetchSummaryData() {
        piholes.forEach { pihole in
            pihole.updateSummary { error in
                DispatchQueue.main.async {
                    if let error = error {
                        pihole.pollingError = self.errorMessage(error)
                    } else {
                        pihole.pollingError = nil
                        self.updateData()
                    }
                    self.updateErrorMessageStatus()
                }
            }
        }
    }
    
    private func updateData() {
        let sumDNSQueries = piholes.compactMap { $0.summary }.reduce(0) { value, pihole in value + pihole.dnsQueriesToday }
        totalQueries = numberFormatter.string(from: NSNumber(value: sumDNSQueries)) ?? "-"
        
        let sumQueriesBlocked = piholes.compactMap { $0.summary }.reduce(0) { value, pihole in value + pihole.adsBlockedToday }
        queriesBlocked = numberFormatter.string(from: NSNumber(value: sumQueriesBlocked)) ?? "-"
        
        let sumDomainOnBlocklist = piholes.compactMap { $0.summary }.reduce(0) { value, pihole in value + pihole.domainsBeingBlocked }
        domainsOnBlocklist = numberFormatter.string(from: NSNumber(value: sumDomainOnBlocklist)) ?? "-"
        
        let percentage = Double(sumQueriesBlocked) / Double(sumDNSQueries)
        percentBlocked = percentageFormatter.string(from: NSNumber(value: percentage)) ?? "-"
        
        updateStatus()
        updateErrorMessageStatus()
    }
    
    private func updateStatus() {
        let allStatus = Set(piholes.map { $0.active })
        if allStatus.count > 1 {
            status = .enabledAndDisabled
        } else if allStatus.randomElement() == false {
            status = .allDisabled
        } else {
            status = .allEnabled
        }
    }
    
    private func updateErrorMessageStatus() {
        pollingErrors = piholes.compactMap{ $0.pollingError}
        actionErrors = piholes.compactMap{ $0.actionError}
        hasErrorMessages =  pollingErrors.count != 0 || actionErrors.count != 0
    }
}
