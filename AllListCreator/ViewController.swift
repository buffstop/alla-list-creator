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
    let tagetFileName = "zz_processed_mitglieder.csv"
    let wantedCollumns = ["OS-Ort", "Besch.Stelle", "MDB-Nr.", "Anrede", "Name", "Vorname", "Geburtsdatum", "FSTRASSE", "FPLZ", "FORT"/*, "Austritt"*/, "Eintrittsdatum"]
    var rootUrl: URL?

    //MARK - 
    
    func openFile() -> URL{
        let fileDialog = NSOpenPanel()
        fileDialog.runModal()
        let url = (fileDialog.url)!

        return url
    }
  
     //MARK - 
    
    func removeUnwanted(fromKeyedRows keyedRows:[[String:String]]) -> [[(key: String, value: String)]] {
        // remove unwanted collumns
        let onlyWantedCollumns = keyedRows.map {
            $0.filter {
                let key = $0.key
                return wantedCollumns.contains(key)
            }
        }
        return onlyWantedCollumns
    }

    // sortr collumns to final order
    func sortCollums(keyedRows: [[(key: String, value: String)]]) -> [[(key: String, value: String)]] {
        return keyedRows.map {
            let row = $0
            var sortedRow = [(key: String, value: String)]()
            for wantedCollum in wantedCollumns {
                var foundEntry: (key: String, value: String)?
                for entryDict in row {
                    if entryDict.key == wantedCollum {
                        foundEntry = entryDict
                    }
                }
                if foundEntry != nil {
                    sortedRow.append(foundEntry!)
                } else {
                    sortedRow.append((wantedCollum, ""))
                }
            }
            return sortedRow
        }
    }
    
    func sortByOrtsgruppeAndName(keyedRows: [[(key: String, value: String)]]) -> [[(key: String, value: String)]] {
        return keyedRows.sorted {
            let leftOrtsgruppe = $0.filter {
                return $0.key == "OS-Ort"
                }.first
            
            let rightOrtsgruppe = $1.filter {
                return $0.key == "OS-Ort"
                }.first
            
            if leftOrtsgruppe?.value.caseInsensitiveCompare((rightOrtsgruppe?.value)!) == ComparisonResult.orderedSame {
                let leftName = $0.filter {
                    return $0.key == "Name"
                    }.first
                
                let rightName = $1.filter {
                    return $0.key == "Name"
                    }.first
                
                if leftName?.value.caseInsensitiveCompare((rightName?.value)!) == ComparisonResult.orderedSame {
                    let leftFirstName = $0.filter {
                        return $0.key == "Vorname"
                        }.first
                    
                    let rightFirstName = $1.filter {
                        return $0.key == "Vorname"
                        }.first
                    return leftFirstName!.value < rightFirstName!.value
                } else {
                    return leftName!.value < rightName!.value
                }
            } else {
                return leftOrtsgruppe!.value < rightOrtsgruppe!.value
            }
        }
    }
    
    func toCsvString(keyedRows: [[(key: String, value: String)]]) -> String {
        var csvString = ""
        
        for i in 0 ..< wantedCollumns.count {
            let collumnName = wantedCollumns[i]
            csvString += "\"" + collumnName + "\""
            if i < wantedCollumns.count - 1 {
                csvString += ";"
            }
        }
        
        csvString += "\n"
        
        for keyedRow in keyedRows {
            var rowCsvString = ""
            for i in 0 ..< keyedRow.count {
                let entry = keyedRow[i]
                rowCsvString += "\"" + entry.value + "\""
                if i < keyedRow.count - 1 {
                    rowCsvString += ";"
                }
            }
            csvString += rowCsvString
            csvString += "\n"
        }
        
        return csvString
    }
    
    //MARK -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootUrl = openFile()
        do {
            let csvString = try String(contentsOf: rootUrl!, encoding:String.Encoding.isoLatin1)
            let csv = CSwiftV(with: csvString, separator: ";", headers: nil)
            let keyedRows = csv.keyedRows
            let wantedKeyedRows = removeUnwanted(fromKeyedRows: keyedRows!)
            let sortedCollumnsKeydRows = sortCollums(keyedRows: wantedKeyedRows)
            let sortedByOrtsgruppeAndName = sortByOrtsgruppeAndName(keyedRows: sortedCollumnsKeydRows)
            let finalCsvString = toCsvString(keyedRows: sortedByOrtsgruppeAndName)
            
            var targetUrl = rootUrl
            targetUrl?.deleteLastPathComponent()
            targetUrl?.appendPathComponent(tagetFileName)
            try finalCsvString.write(to: targetUrl!, atomically: true, encoding: String.Encoding.isoLatin1)
//            print("finalCsvString: \n\(finalCsvString)")
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

