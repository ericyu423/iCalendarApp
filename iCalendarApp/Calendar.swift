//
//  Calendar.swift
//  iCalendarApp
//
//  Created by eric yu on 10/16/17.
//  Copyright © 2017 eric yu. All rights reserved.
//

import Foundation
import EventKit

class EventWriter {
    
    var eventStore = EKEventStore()

    func createNewCalendarWithID(reservationCode code: String)->String{
        
        removeCalendar(withReservationCode: code)
        
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = "Trip( "+code+" )"
        
        let filteredSources = eventStore.sources.filter {
            $0.sourceType == .local }
        
        if let localSource = filteredSources.first {
            
            newCalendar.source = localSource
            
            do {
                try eventStore.saveCalendar(newCalendar, commit: true)
                UserDefaults.standard.set(newCalendar.calendarIdentifier,forKey:code)
                print("succesfully save calendar with id"+newCalendar.calendarIdentifier)
                
            } catch {
                print("save failed\(error.localizedDescription)")
            }
            
        }else{
            print("no local source found")
        }
        
        return newCalendar.calendarIdentifier
    }
    
    func checkEventStoreAccessForCalendar(){
        
        let status = EKEventStore.authorizationStatus(for: .event)
        if(status == .notDetermined){
            requestCalendarAccess()
        }
    }
    
    func editEvent(calendarID: String?,title: String){
        var calendarForThisEvent: EKCalendar!
        
        if calendarID != nil {
            
            calendarForThisEvent = eventStore.calendar(withIdentifier: calendarID!)
        }else {
            //if no id provided
            calendarForThisEvent = eventStore.defaultCalendarForNewEvents
        }
        
        let predicate =  eventStore.predicateForEvents(withStart: Date().addingTimeInterval(-5000), end: Date().addingTimeInterval(5000), calendars: [calendarForThisEvent])
        
        let list = eventStore.events(matching: predicate)
        
        
        let event = list.filter {
            $0.title == "a"   //can check for other attributes
            }.first!
        
        event.notes = "add this string in it"
        
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            //dismiss(animated: true, completion: nil);
            
        } catch {
            print("event couldn't be saved \(error.localizedDescription)")
        }
        
    }
    
    func addEvent(calendarID: String?,title: String){
        

        let calendars = eventStore.calendars(for: .event).filter {
            $0.calendarIdentifier == calendarID
            }
        
        if let calendarForThisEvent = calendars.first {
        
        
        let newEvent:EKEvent = EKEvent(eventStore: eventStore)
        
        newEvent.calendar = calendarForThisEvent
        newEvent.title = title
        newEvent.startDate = Date()
        newEvent.endDate = Date()
            
        
        /*
         var tripQuery = ""
         if let code = destinationHandler?.currentTrip?.reservationCode,
         let escapedName = code.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
         tripQuery = "&trip=\(escapedName)"
         }*/
        /* let timeQuery = Int64(excursion.timeSlot.start.timeIntervalSince1970)
         newEvent.url = URL(string: "\(ApplicationURLScheme)?q=\(timeQuery)\(tripQuery)")*/
        
        // Save the calendar using the Event Store instance
        
            do {
                try eventStore.save(newEvent, span: .thisEvent, commit: true)
            } catch {
                print("event couldn't be saved \(error.localizedDescription)")
            }
        }
  
        
    }

}

extension EventWriter {
    private func requestCalendarAccess(){
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted{
                print("Access Granted to Calendar ...")
                //get rid of warnning
            }
        }
    }
    
    private func removeCalendar(withReservationCode code : String){
        
        if let calendarID = UserDefaults.standard.value(forKey: code) as? String {
            
            /* eventStore.calendar(withIdentifier: calendarID) gaves types 3 from daemon: Error Domain=EKCADErrorDomain Code=1014 */
            let calendars = eventStore.calendars(for: .event).filter{
                $0.calendarIdentifier == calendarID
            }
            
            if let newCalendar = calendars.first {
                do {
                    try eventStore.removeCalendar(newCalendar, commit: true)
                    print("succesfully removed "+code)
                }catch{
                    print("calendar can't be removed \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    //code reserveation code to find calendar
    func getCurrentCalendar(withReservationCode code : String) -> EKCalendar?
    {
        
        if let calendarID = UserDefaults.standard.value(forKey: code) as? String {
            
            /* eventStore.calendar(withIdentifier: calendarID) gaves types 3 from daemon: Error Domain=EKCADErrorDomain Code=1014 */
            let calendar = eventStore.calendars(for: .event).filter{
                $0.calendarIdentifier == calendarID
            }.first
            
            return calendar
        }
        
        return nil

    }
    
}
