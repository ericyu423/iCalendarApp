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
    let reservationCode = "T9L228E3"
    let mykey = "xyz"
    let badkey = "abc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkEventStoreAccessForCalendar()
        createNewCalender(reservationCode:reservationCode)
      //  let dict:[String:String] = ["key":"Hello"]
      //  UserDefaults.standard.set(dict, forKey: "xyxz")
       /*
        if let myDict = UserDefaults.standard.value(forKey: "xyxzz") as? [String:String]{
            //if you find something you come in
            print("here")
        }*/
        
       /*
        
        for a in test {
              //addEvent(a)
      
        }*/
        
        
     
        
        
        
        //title,eventID
        
        
       
        
        if var myDict = UserDefaults.standard.value(forKey: "xyxz") as? [String:String]{
            
            myDict.updateValue("Hello",forKey: "key")
             UserDefaults.standard.set(myDict, forKey: "xyxz")
            
        }
      
       // let result = UserDefaults.standard.value(forKey: "dict")
        //print(result!)
    }
    
   
}

extension ViewController {
    
    func editEvent(){
        //edit not add event
       /*  let pred = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [c])*/
        
        //let pred = eventStore
        
    }
    
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
    
    func deleteWithID(reservationCode:String){
        
        let event = eventStore.event(withIdentifier: reservationCode)
        
      
        
        do{
            try eventStore.remove(event!, span: .thisEvent)
        }catch {
            print("event couldn't be saved \(error.localizedDescription)")
        }

    }
    
    func createNewCalender(reservationCode: String){
        //TODO: check reservationCode if exist delete it
        
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = reservationCode
        
        let sourcesInEventStore = eventStore.sources //return source objects
        //what does this mean
        newCalendar.source = sourcesInEventStore.filter{
            (source: EKSource) -> Bool in
            source.sourceType.rawValue == EKSourceType.local.rawValue
        }.first!
        
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            UserDefaults.standard.set(newCalendar.calendarIdentifier,forKey:"ReservationPrimaryCalendar")
            
        } catch {
            let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
        }
 
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

