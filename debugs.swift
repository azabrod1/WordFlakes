//
//  debugs.swift
//  Letterstorm
//


import Foundation



func p<T>(toPrint : T, description : String? = nil ){
    
    if description == nil{
        print("\(toPrint)")
    }
        
    else{
        print("\(String(describing: description)):  \(toPrint)")
        
    }
}
