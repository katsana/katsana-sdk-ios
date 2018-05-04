//
//  KatsanaAPI+Log.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation
import XCGLogger

public extension KatsanaAPI{
    
    
    /// Setup logging for KatsanaAPI
    func setupLog() -> Void {
        // Create a logger object with no destinations
        self.log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
        
        // Create a destination for the system console log (via NSLog)
        let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
        
        // Optionally set some configuration options
        systemDestination.outputLevel = .info
        systemDestination.showLogIdentifier = false
        systemDestination.showFunctionName = false
        systemDestination.showThreadName = true
        systemDestination.showLevel = true
        systemDestination.showFileName = true
        systemDestination.showLineNumber = true
        systemDestination.showDate = true
        
        // Add the destination to the logger
        log.add(destination: systemDestination)
        
        let documentsPath : String = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask,true)[0]
        let path = documentsPath.appending("/KatsanaSDK.log")
        logPath = path
        
        let firstDateLogged = UserDefaults.standard.object(forKey: "KatsanaSDKFirstDateLogged") as? Date
        
        if (firstDateLogged != nil && Date().timeIntervalSince(firstDateLogged!) > 60*60*24*TimeInterval(logSavedDuration)) || firstDateLogged == nil{
            let fileManager = FileManager.default
            try? fileManager.removeItem(atPath: path)
            UserDefaults.standard.set(Date(), forKey: "KatsanaSDKFirstDateLogged")
        }
        
        // Create a file log destination
        let fileDestination = FileDestination(writeToFile: path, identifier: "advancedLogger.fileDestination", shouldAppend: true)
        
        // Optionally set some configuration options
        fileDestination.outputLevel = .debug
        fileDestination.showLogIdentifier = false
        fileDestination.showFunctionName = false
        fileDestination.showThreadName = true
        fileDestination.showLevel = true
        fileDestination.showFileName = true
        fileDestination.showLineNumber = true
        fileDestination.showDate = true
        
        // Process this destination in the background
        fileDestination.logQueue = XCGLogger.logQueue
        fileDestination.haveLoggedAppDetails = true
        
        // Add the destination to the logger
        log.add(destination: fileDestination)
        
        // Add basic app info, version info etc, to the start of the logs
        //log.logAppDetails()
    }
    
    public func clearLog() {
        if let path = logPath{
            let fileManager = FileManager.default
            try? fileManager.removeItem(atPath: path)
            UserDefaults.standard.set(Date(), forKey: "KatsanaSDKFirstDateLogged")
        }
    }
    
    func debug(_ text: String, identifier: String! = nil, duration: TimeInterval = 0, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        let date = Date().addingTimeInterval(duration)
        if let identifier = identifier, let idDate = identifierDicts[identifier], duration > 0{
            if Date().timeIntervalSince(idDate) > 0{
                self.log?.debug(text, functionName: functionName, fileName:fileName, lineNumber:lineNumber)
            }
        }else{
            self.log?.debug(text, functionName: functionName, fileName:fileName, lineNumber:lineNumber)
        }
        if identifier != nil{
            identifierDicts[identifier] = date
        }
    }
    
    func error(_ text: String, identifier: String! = nil, duration: TimeInterval = 0, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        let date = Date().addingTimeInterval(duration)
        if let identifier = identifier, let idDate = identifierDicts[identifier], duration > 0{
            if Date().timeIntervalSince(idDate) > 0{
                self.log?.error(text, functionName: functionName, fileName:fileName, lineNumber:lineNumber)
            }
        }else{
            self.log?.error(text, functionName: functionName, fileName:fileName, lineNumber:lineNumber)
        }
        if identifier != nil{
            identifierDicts[identifier] = date
        }
    }
}
