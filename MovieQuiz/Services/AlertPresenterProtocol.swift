//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by SERGEY SHLYAKHIN on 10.11.2022.
//

import UIKit

protocol AlertPresenterProtocol {
    func displayResult(_ model: AlertModel, over vc: UIViewController)
}