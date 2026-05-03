//
//  CameraViewController.swift
//  loopwitch
//
//  Created by APE on 06/11/2025.
//
import AVFoundation
import UIKit
import Vision

enum CameraErrors: Error {
      case unauthorized, setupError, visionError
}

final class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // Queue for processing video data.
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?

    //Vision Vars, these are used later
    var handPointsHandler: (([CGPoint]) -> Void)?

    // On loading, start the camera feed.
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            if cameraFeedSession == nil {
                try setupAVSession()
            }
            //Important: Call this line with DispatchQueue otherwise it will cause a crash
                DispatchQueue.global(qos: .userInteractive).async {
                    self.cameraFeedSession?.startRunning()
            }
        } catch {
            print(error.localizedDescription)
        }
    }


    // On disappearing, stop the camera feed.
    override func viewDidDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewDidDisappear(animated)
    }


    // Setting up the AV session.
    private func setupAVSession() throws {

        //Ask for Camera permission otherwise crash
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized{
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized{
                    fatalError("Camera Access is Required")
                }
            }
        }

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CameraErrors.setupError
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw CameraErrors.setupError
        }

        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high

        guard session.canAddInput(deviceInput) else {
            throw CameraErrors.setupError
        }

        session.addInput(deviceInput)

        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw CameraErrors.setupError
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
      

        session.commitConfiguration()
        cameraFeedSession = session
    }

}
// Extension to handle video data output and process it using Vision.
extension CameraViewController {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // Vision request to detect human hand poses.
        let handPoseRequest = VNDetectHumanHandPoseRequest()
         //Using one hand to make debugging easier, you can change this value if you'd like monitor more than 1 hand.
        handPoseRequest.maximumHandCount = 1

        var fingerTips: [CGPoint] = []

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])

        do {
            try handler.perform([handPoseRequest])
            guard let observations = handPoseRequest.results, !observations.isEmpty else {
                DispatchQueue.main.async {
                    self.handPointsHandler?([])
                }
                return
            }

            // Process the first detected hand
            guard let observation = observations.first else { return }

            // Get all hand points
            let points = try observation.recognizedPoints(.all)

            // Filter points with good confidence and convert coordinates
            let validPoints = points.filter { $0.value.confidence > 0.9 }
                .map { CGPoint(x: $0.value.location.x, y: 1 - $0.value.location.y) }

            DispatchQueue.main.async {
                self.handPointsHandler?(Array(validPoints))
            }


        } catch {
            cameraFeedSession?.stopRunning()
        }
    }
}

import Foundation
