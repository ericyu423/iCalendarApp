//
//  ViewController.swift
//  iCalendarApp
//
//  Created by eric yu on 10/12/17.
//  Copyright © 2017 eric yu. All rights reserved.
//

import UIKit
//import EventKit

class ViewController: UIViewController {

    let eventWriter = EventWriter()
    
    let test = ["a","b","c","d","e"]
    let reservationCode = "xxxyyzzz"
   
    
    @IBAction func importToCalendar(_ sender: UIButton) {
        
        let calednarID = eventWriter.createNewCalendarWithID(reservationCode: reservationCode)
 
        for t in test {
            
            eventWriter.addEvent(calendarID: calednarID, title: t)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventWriter.checkEventStoreAccessForCalendar()

    }
    
   
}
/*
extension ViewController {
    
    
    //don't use this unless EKCADErrorDomain Code=1014 keep happening again
    private func removeCalendar2(withReservationCode code : String){
        
        if let id = UserDefaults.standard.value(forKey: code) as? String {
            
            let calendars = eventStore.calendars(for: .event).filter{
                $0.calendarIdentifier == id
            }
            
            if let newCalendar = calendars.first {
                do {
                    try eventStore.removeCalendar(newCalendar, commit: true)
                    print("succesfully removed "+code)
                }catch{
                    print("calendar can't be remove \(error.localizedDescription)")
                }
            }else{
                //
            }
        }

    }
 
    //this one is better if we can get rid of EKCADError
    
    private func removeCalendar(withReservationCode code : String){
        /* eventStore.calendar(withIdentifier: <#T##String#>)
         this throws and annoying  [EventKit] Error getting shared calendar invitations for entity types 3 from daemon: Error Domain=EKCADErrorDomain Code=1014 "
         doesn't seem like it affect the write but is annoying
         */
        
       
  
 
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

    //create and return calendar ID
    func createNewCalendar(reservationCode: String)->String{

        //remove old calendar and it's events using reservation code
        removeCalendar(withReservationCode: reservationCode)
       
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = "trip("+reservationCode+")"
 
        let filteredSources = eventStore.sources.filter {
                $0.sourceType == .local }  // for icloud  $0.sourceType == .calDAV
            
        
        if let localSource = filteredSources.first {
             newCalendar.source = localSource
            
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
            
        }else{
            //no local source, nothing will be written
        }
        
 

        return newCalendar.calendarIdentifier
    }
    
  
    //remove from selected calendar
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
            dismiss(animated: true, completion: nil);
            
        } catch {
            print("event couldn't be saved \(error.localizedDescription)")
        }
 
    }
    
   
    func addEvent(calendarID: String?,title: String){
        var calendarForThisEvent: EKCalendar!
        
        /* calendar(withIdentifier: calendarID!) causing problem here too
        if calendarID != nil {
            calendarForThisEvent = eventStore.calendar(withIdentifier: calendarID!)
        }else {
            //if no id provided
            calendarForThisEvent = eventStore.defaultCalendarForNewEvents
        }*/
        
        // it happens when you don't have any shared calendar in your device. Here is a link About shared iCloud calendars
        

        
        calendarForThisEvent = eventStore.calendars(for: .event).filter {
            $0.calendarIdentifier == calendarID
        }.first!  //might be nil unless you call remove calendar first
        
     
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
                //get rid of warnning
            }
        }
    }
}
    
*/
