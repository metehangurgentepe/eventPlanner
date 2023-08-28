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
        if viewModel.requestList.count > 0 {
            VStack{
                ForEach(viewModel.requestList, id: \.self) { request in
                    if let associatedEvent = viewModel.eventList.first(where: { $0.id == request.eventId }) {
                        AllRequestView(event: associatedEvent, request: request)
                    }
                    if viewModel.requestList.count > 1{
                        Divider()
                    }
                }
                Spacer()
            }.onAppear{
                viewModel.getRequest()
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
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
    }
}

struct AllRequestView: View {
    @StateObject var viewModel = RequestViewModel()
    var event : Event
    var request : Request
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: event.eventPhoto)) { image in
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
                Text("\(viewModel.convertToDate(dateStr: event.eventStartTime ?? "")) \(viewModel.convertToTime(timeStr: event.eventStartTime ?? ""))")
                
            }
            Spacer()
            
            Button{
                viewModel.acceptRequest(requestId: request.id , eventId: request.eventId, sender: request.senderUser)
                viewModel.getRequest()
            } label:{
                Image(systemName: IconItemString.Event.tick.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width:UIScreen.main.bounds.width * 0.08)
                
            }
            
            Button{
                viewModel.rejectRequest(requestId: request.id)
                viewModel.getRequest()
            } label:{
                Image(systemName: IconItemString.Event.close.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width:UIScreen.main.bounds.width * 0.08)
            }
            
        }
    }
}
