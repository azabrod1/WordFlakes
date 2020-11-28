//
//  debugs.swift
//  Word Flakes
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
