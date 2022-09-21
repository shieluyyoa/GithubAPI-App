//
//  ErrorMessage.swift
//  GithubFollowers
//
//  Created by Oscar Lui on 4/8/2022.
//

import Foundation

enum GFError: String, Error {
    
    case invalidUsername = "This username created an invalid request. Please try again."
    case unableToComplete = "Unable to complete your reuqest. Please check your internet connection"
    case invalidResponse = "Invalid response from the server. Please  try again."
    case invalidData = "The data received from the server are invalid. Please try again."
    case unableToFavourite = "Having Error favouriting this user. "
    case duplicateFavourite = "You have already favourited this user."
    
}
