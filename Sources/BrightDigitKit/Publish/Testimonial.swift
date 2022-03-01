//
//  File.swift
//  
//
//  Created by Leo Dion on 3/1/22.
//

import Foundation
import Plot

public struct Testimonial {
  internal init(fullName: String, title: String, fullQuote: String, briefQuote: String? = nil, url: URLRepresentable? = nil) {
    self.fullName = fullName
    self.title = title
    self.fullQuote = fullQuote
    self.briefQuote = briefQuote ?? fullQuote
    self.url = url
  }
  
  let fullName : String
  let title : String
  let fullQuote : String
  let briefQuote : String
  let url : URLRepresentable?
}



