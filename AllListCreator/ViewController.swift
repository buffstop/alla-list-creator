//
//  ViewController.swift
//  AllListCreator
//
//  Created by Andreas Buff on 28/09/16.
//  Copyright © 2016 Andreas Buff. All rights reserved.
//

import Cocoa
import CSwiftV

class ViewController: NSViewController {
    let wantedCollumns = ["OS-Ort", "Besch.St.", "MDB-Nr.", "Anrede", "Name", "Vorname", "Geb.Datum", "Straße", "PLZ", "Wohnort", "Austritt", "Eintritt"]

    //MARK - 
    
    func openFile() -> URL{
        let myFileDialog: NSOpenPanel = NSOpenPanel()
        myFileDialog.runModal()
        let url = (myFileDialog.url)!

        return url
    }
  
     //MARK - 
    
    func rowUserHasLeftTheBuildingLongAgo(forRow row: [(key: String, value: String)]) -> Bool {
        let austrittsDateDictArray = row.filter {
            let key = $0.key
            if key == "Austritt" {
                return true
            } else {
                return false
            }
        }

        var isLongLeft = false
        if !austrittsDateDictArray.isEmpty {
            let austrittsDateString = austrittsDateDictArray.first?.value
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy" //"30.09.2012"
            let autrittsDate = dateFormatter.date(from: austrittsDateString!)
            let today = Date()
            
            let calendar = NSCalendar.current

            let autrittYear = calendar.component(Calendar.Component.year, from: autrittsDate!)
            let thisYear = calendar.component(Calendar.Component.year, from: today)
            
            if  autrittYear < thisYear {
                return true
            }
        }

        return false
    }
    
    func removeUnwanted(fromKeyedRows keyedRows:[[String:String]]) -> [[(key: String, value: String)]] {
        // remove unwanted collumns
        let onlyWantedCollumns = keyedRows.map {
            $0.filter {
                let key = $0.key
                return wantedCollumns.contains(key)
            }
        }
        
        // remove ausgetreten vor >= 1 Jahr
        let withoutLongGoneUsers = onlyWantedCollumns.filter {
            return !rowUserHasLeftTheBuildingLongAgo(forRow: $0)
        }
        
        return withoutLongGoneUsers
    }

    // sortr collumns to final order
    func sortCollums(keyedRows: [ [(key: String, value: String)] ]) -> [[(key: String, value: String)]] {
        return keyedRows.map {
            let row = $0
            var sortedRow = [(key: String, value: String)]()
            for wantedCollum in wantedCollumns {
                for entryDict in row {
                    if entryDict.key == wantedCollum {
                        sortedRow.append(entryDict)
                    }
                }
            }
            return sortedRow
        }
    }
    
    //MARK -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = openFile()
        do {
            let csvString = try String(contentsOf: url, encoding:String.Encoding.isoLatin1)
            let csv = CSwiftV(with: csvString, separator: ";", headers: nil)
            let headers = csv.headers
            var keyedRows = csv.keyedRows
            //remove unwanted collumns
            let wantedKeyedRows = removeUnwanted(fromKeyedRows: keyedRows!)
            let sortedCollumnsKeydRows = sortCollums(keyedRows: wantedKeyedRows)
            
            
            
            print("sortedCollumnsKeydRows: \(sortedCollumnsKeydRows)")
        } catch {
            fatalError("Somthing went wrong")
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

