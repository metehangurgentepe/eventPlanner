//
//  RequestView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 16.08.2023.
//

import SwiftUI

struct RequestView: View {
    @StateObject var viewModel = RequestViewModel()
    
    var body: some View {
        VStack{
            if viewModel.requestList.count > 0 {
                VStack{
                    ForEach(viewModel.requestList) { request in
                        if let associatedEvent = viewModel.eventList.first {
                            HStack {
                                AsyncImage(url: URL(string: associatedEvent.eventPhoto)) { image in
                                    image
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(12)
                                        .frame(maxWidth:UIScreen.main.bounds.width * 0.24,maxHeight: UIScreen.main.bounds.height * 0.1)
                                    
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .frame(maxWidth:UIScreen.main.bounds.width * 0.24,maxHeight: UIScreen.main.bounds.height * 0.1)
                                }
                                Spacer()
                                VStack{
                                    Text(request.senderUser)
                                        .font(.footnote)
                                    
                                    Text(request.eventName)
                                        .fontWeight(.black)
                                        .font(.subheadline)
                                    Text("\(viewModel.convertToDate(dateStr: associatedEvent.eventStartTime )) \(viewModel.convertToTime(timeStr: associatedEvent.eventStartTime ))")
                                    
                                }
                                Spacer()
                                
                                Button{
                                    Task{
                                        try await viewModel.acceptRequest(request: request)
                                        try await viewModel.getAllRequest()
                                        AnalyticsManager.shared.logEvent(name: "RquestEventView_AcceptButtonClicked")
                                    }
                                } label:{
                                    Image(systemName: IconItemString.Event.tick.rawValue)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.08)
                                }
                                
                                Button{
                                    Task{
                                        try await viewModel.rejectRequest(request: request)
                                        try await viewModel.getAllRequest()
                                        AnalyticsManager.shared.logEvent(name: "RquestEventView_DeclineButtonClicked")
                                    }
                                } label:{
                                    Image(systemName: IconItemString.Event.close.rawValue)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.08)
                                }
                                
                            }
                        }
                        if viewModel.requestList.count > 1{
                            Divider()
                        }
                    }.onReceive(viewModel.$requestList) { newEventList in
                      //  viewModel.convertAllEvents(requestIdList: viewModel.requestList)
                    }
                    Spacer()
                }
                // .frame(maxHeight:UIScreen.main.bounds.height * 0.3)
                .padding()
                
            } else{
                VStack{
                    Image("request")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width * 0.7)
                        .padding(.all)
                    Text(LocaleKeys.Event.noRequest.rawValue.locale())
                        .font(.headline)
                        .frame(alignment: .center)
                        .padding(.top)
                }.padding(.all)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(LocaleKeys.EditEvent.error.rawValue.locale()),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text(LocaleKeys.EditEvent.okButton.rawValue.locale())){
                    viewModel.showAlert = false
                }
            )
        }
        .onAppear{
            Task{
                try await viewModel.getAllRequest()
                try await viewModel.convertAllEvents(requestIdList: viewModel.requestList.map({ request in
                    print(request.id)
                    print(request.eventId)
                    return request.eventId
                   
                }))
            }
        }
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
    }
}

/*struct AllRequestView: View {
 var viewModel: RequestViewModel
 var event : EventDatabase
 var request : Request
 var body: some View {
 
 }
 } */
