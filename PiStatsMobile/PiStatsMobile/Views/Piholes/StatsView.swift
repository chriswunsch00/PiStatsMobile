//
//  StatsView.swift
//  PiStatsMobile
//
//  Created by Fernando Bunn on 04/07/2020.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var dataProvider: PiholeDataProvider
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.Geometry.defaultPadding) {
            HStack {
                if dataProvider.hasErrorMessages {
                    Image(systemName: UIConstants.SystemImages.piholeStatusWarning)
                        .foregroundColor(UIConstants.Colors.statusWarning)
                        .font(.title2)
                } else if dataProvider.status == .allEnabled {
                    Image(systemName: UIConstants.SystemImages.piholeStatusOnline)
                        .foregroundColor(UIConstants.Colors.statusOnline)                        .font(.title2)
                } else {
                    Image(systemName: UIConstants.SystemImages.piholeStatusOffline)
                        .foregroundColor(UIConstants.Colors.statusOffline)                        .font(.title2)
                }
                
                Text(dataProvider.name)
                    .foregroundColor(.primary)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            VStack {
                ForEach(dataProvider.pollingErrors, id: \.self) { error in
                    Label {
                        Text(error)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: UIConstants.SystemImages.errorMessageWarning)
                            .foregroundColor(UIConstants.Colors.errorMessage)
                    }
                    .font(.subheadline)
                }
            }
            
            HStack {
                StatsItemView(type: .totalQueries, label: dataProvider.totalQueries)
                StatsItemView(type: .queriesBlocked, label: dataProvider.queriesBlocked)
            }
            HStack {
                StatsItemView(type: .percentBlocked, label: dataProvider.percentBlocked)
                StatsItemView(type: .domainsOnBlockList, label: dataProvider.domainsOnBlocklist)
            }
            
            if dataProvider.canDisplayEnableDisableButton {
                Divider()
                if dataProvider.status == .allDisabled {
                    enableButton()
                } else {
                    disableButton()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(UIConstants.Geometry.defaultCornerRadius)
        .shadow(radius: UIConstants.Geometry.shadowRadius)
        .padding()
    }
    
    private func disableButton() -> some View {
        Button(action: {
            dataProvider.disablePiHole()
        }, label: {
            HStack (spacing: 0) {
                Label(UIConstants.Strings.disableButton, systemImage: "stop.fill")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color(.systemBlue))
            .cornerRadius(UIConstants.Geometry.defaultCornerRadius)
        })
    }
    
    private func enableButton() -> some View {
        Button(action: {
            dataProvider.enablePiHole()
        }, label: {
            HStack (spacing: 0) {
                Label(UIConstants.Strings.enableButton, systemImage: "play.fill")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color(.systemBlue))
            .cornerRadius(UIConstants.Geometry.defaultCornerRadius)
        })
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(dataProvider: PiholeDataProvider.previewData())
    }
}
