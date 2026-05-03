//
//  AudioConfig.swift
//  loopwitch
//
//  Created by APE on 03/05/2026.
//
import SwiftUI
import AudioKit


class oscGenerator {
    let engine = AudioEngine()
    let osc = PlaygroundOscillator()
    
    var initialised : Bool = false
    
    func initialise(){
        if !initialised {initialised = true
            osc.amplitude = 0.25
            osc.frequency = 200
            
            engine.output = osc
            
            try! engine.start()
        }
    }
    func togglesound(){
        initialise()
        osc.isStarted ? osc.stop() : osc.start()
    }
}

struct TestView: View {
    let oscillator = oscGenerator()
    var body: some View{
        Button("play sound"){
            oscillator.togglesound()
        }
    }
}
#Preview {
    TestView()
}
