//
//  Logger.swift
//  SampleLocation
//
//  Created by Rajan Maheshwari on 25/07/17.
//  Copyright © 2017 Rajan Maheshwari. All rights reserved.
//

import Foundation
class Logger {
    
    class func write(text: String, to fileNamed: String, folder: String = kLogsDirectory) {
        let textToBeAppended = "\(Date()) "+text+"\n"
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return }
        print(writePath.absoluteString)
        let file = writePath.appendingPathComponent(fileNamed + ".txt")
        
        if let fileHandle = FileHandle(forWritingAtPath: file.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(textToBeAppended.data(using: .utf8)!)
        } else {
            print("File doesn't exists")
            try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
            try? textToBeAppended.write(to: file, atomically: false, encoding: String.Encoding.utf8)
        }
    }
}
