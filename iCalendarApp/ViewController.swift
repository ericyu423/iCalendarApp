//
//  ViewController.swift
//  iCalendarApp
//
//  Created by eric yu on 10/12/17.
//  Copyright © 2017 eric yu. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    let eventStore = EKEventStore()
    
    let test = ["a","b","c","d","e"]
    let reservationCode = "xxxyyzzz"
    let mykey = "xyz"
    let badkey = "abc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkEventStoreAccessForCalendar()

        //error only because createNewCalendar runs before we can grant access
        //this will not happen in a real app after first granting subsequent
        //runs will have no problems
        
        createNewCalender(reservationCode: reservationCode)
   
    }
    
   
}

extension ViewController {
    

    func deleteWithID(reservationCode:String){
        
        let event = eventStore.event(withIdentifier: reservationCode)

        do{
            try eventStore.remove(event!, span: .thisEvent)
        }catch {
            print("event couldn't be saved \(error.localizedDescription)")
        }

    }
    
    
    private func removeCalendar(withReservationCode code : String){
        if let id = UserDefaults.standard.value(forKey: code) as? String{
            if let newCalendar =  eventStore.calendar(withIdentifier: id)
            {
                do {
                    try eventStore.removeCalendar(newCalendar, commit: true)
                    print("succesfully removed "+code)
                }catch{
                     print("calendar can't be remove \(error.localizedDescription)")
                }
            }
        }
    }

    
    func createNewCalender(reservationCode: String){

        //remove old calendar and it's events using reservation code
        removeCalendar(withReservationCode: reservationCode)
       
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = "trip("+reservationCode+")"
 
        newCalendar.source = eventStore.sources.filter {
                $0.sourceType == .local || $0.sourceType == .calDAV
        }.first!
     

        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            print("succesfully save calendar with id"+newCalendar.calendarIdentifier)
             UserDefaults.standard.set(newCalendar.calendarIdentifier,forKey:reservationCode)
        } catch {

            let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func editEvent(){
        //edit not add event
        /*  let pred = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [c])*/
        
        //let pred = eventStore
        
    }
    
   
    func addEvent(a: String){
        
        
        //eventStore.eventStoreIdentifier(get only)
        
       // let newEvent = eventStore.event(withIdentifier: "test1")
        
       var newEvent:EKEvent = EKEvent(eventStore: eventStore)
    
        
        
     
        
        
        //let calendarForEvent = eventStore.defaultCalendarForNewEvents
        let calendarForEvent = eventStore.calendar(withIdentifier: "test1")
      //  let calendarForEvent = eventStore.defaultCalendarForNewEvents.
        //on mac, each color represent an calendar
        //when you write something it will default to one of the calendars
        //that is what default means, default is set in setting
        //you can always save to different caldendar by selection.
        
        
     
        newEvent.calendar = calendarForEvent
        newEvent.title = a
       
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
            dismiss(animated: true, completion: nil);
            
            
     
            
        } catch {
            print("event couldn't be saved \(error.localizedDescription)")
        }
 
        
        
    }

    
}

//checking calendar acess
//make sure Privacy - Calendars Usage Description in plist
extension ViewController {
    func checkEventStoreAccessForCalendar(){
        let status = EKEventStore.authorizationStatus(for: .event)
        if(status == .notDetermined){
            requestCalendarAccess()
        }
    }
    
    func requestCalendarAccess(){
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted{
                print("Access Granted to Calendar ...")
            }
        }
    }
}
    

