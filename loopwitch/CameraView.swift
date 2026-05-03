//
//  CameraView.swift
//  loopwitch
//
//  Created by APE on 06/11/2025.
//
import SwiftUI

// A SwiftUI view that represents a `CameraViewController`.
struct CameraView: UIViewControllerRepresentable {

    // A closure that processes an array of CGPoint values.
    var handPointsProcessor: (([CGPoint]) -> Void)

    // Initializer that accepts a closure
    init(_ processor: @escaping ([CGPoint]) -> Void) {
        self.handPointsProcessor = processor
    }

    // Create the associated `UIViewController` for this SwiftUI view.
    func makeUIViewController(context: Context) -> CameraViewController {
        let camViewController = CameraViewController()
        camViewController.handPointsHandler = handPointsProcessor
        return camViewController
    }


    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
}


import Foundation
