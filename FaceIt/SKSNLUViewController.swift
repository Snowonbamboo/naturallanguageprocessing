//
//  SKSNLUViewController.swift
//  SpeechKitSample
//
//  This Controller is built to demonstrate how to perform NLU (Natural Language Understanding).
//
//  This Controller is very similar to SKSASRViewController. Much of the code is duplicated for clarity.
//
//  NLU is the transformation of text into meaning.
//
//  When performing speech recognition with SpeechKit, you have a variety of options. Here we demonstrate
//  Detection Type and Language.
//
//  The Context Tag is assigned in the system configuration upon deployment of an NLU model.
//  Combined with the App ID, it will be used to find the correct NLU version to query.
//
//  Languages can also be configured. Supported languages can be found here:
//  http://dragonmobile.nuancemobiledeveloper.com/public/index.php?task=supportedLanguages
//
//  Copyright (c) 2015 Nuance Communications. All rights reserved.
//

import UIKit
import SpeechKit

class SKSNLUViewController : UIViewController, UITextFieldDelegate, SKTransactionDelegate {
    
    // State Logic: IDLE -> LISTENING -> PROCESSING -> repeat
    enum SKSState {
        case SKSIdle
        case SKSListening
        case SKSProcessing
    }
    
    // User interface
    
    @IBOutlet var startbutton: UIButton!
    
    @IBAction func startload(sender: AnyObject) {
        
        switch state {
        case .SKSIdle:
            recognize()
        case .SKSListening:
            stopRecording()
        case .SKSProcessing:
            cancel()
        }
    }
    
    func recognize() {
        // Start listening to the user.
        skTransaction = skSession!.recognizeWithService(contextTag,
                                                        detection: endpointer,
                                                        language: language,
                                                        data: nil,
                                                        delegate: self)
    }
    
    func stopRecording() {
        // Stop recording the user.
        skTransaction!.stopRecording()
        
        // Disable the button until we received notification that the transaction is completed.
       
    }
    

    
    @IBOutlet var languageTextView: UITextView!

    
    // Settings
    var language: String!
    var contextTag: String!
    var endpointer: SKTransactionEndOfSpeechDetection!
    
    var skSession:SKSession?
    var skTransaction:SKTransaction?
    
    var state = SKSState.SKSIdle
    
    var volumePollTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        endpointer = .Short
        language = LANGUAGE
        self.languageTextView!.text = language
        contextTag = SKSNLUContextTag
        
        
        state = .SKSIdle
        skTransaction = nil
        
        // Create a session
        skSession = SKSession(URL: NSURL(string: SKSServerUrl), appToken: SKSAppKey)
        
        if (skSession == nil) {
            let alertView = UIAlertController(title: "SpeechKit", message: "Failed to initialize SpeechKit session.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alertView.addAction(defaultAction)
            presentViewController(alertView, animated: true, completion: nil)
            return
        }
        
        //loadEarcons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - ASR Actions
    
       func cancel() {
        // Cancel the Reco transaction.
        // This will only cancel if we have not received a response from the server yet.
        skTransaction!.cancel()
    }
    
    // MARK: - SKTransactionDelegate
    
    func transactionDidBeginRecording(transaction: SKTransaction!) {
        
        state = .SKSListening
        
    }
    
    func transactionDidFinishRecording(transaction: SKTransaction!) {
        
        state = .SKSProcessing
        
        
    }
    
    func transaction(transaction: SKTransaction!, didReceiveRecognition recognition: SKRecognition!) {
        
        
        languageTextView.text = recognition.text
        state = .SKSIdle
    }
    
    func transaction(transaction: SKTransaction!, didReceiveServiceResponse response: [NSObject : AnyObject]!) {
        
        
        state = .SKSIdle
      
    }
    
    func transaction(transaction: SKTransaction!, didReceiveInterpretation interpretation: SKInterpretation!) {
        
        
        state = .SKSIdle
        
        var interp = interpretation.result["interpretations"]![0]
        var concepts = interp["concepts"]!!
        var emotion = concepts["emotion"]!![0]
        var value = emotion["value"]!!
        print(value);
        
        if value as! String == "sad"{
            
            print("I am sorry to hear that")
        }
        
        else if value as! String == "angry"{
            print("I am sorry to hear that")
            
        }
        
        
        
       
    }
    
    func transaction(transaction: SKTransaction!, didFinishWithSuggestion suggestion: String) {
        
    }
    
    func transaction(transaction: SKTransaction!, didFailWithError error: NSError!, suggestion: String) {
        
        
        // Something went wrong. Ensure that your credentials are correct.
        // The user could also be offline, so be sure to handle this case appropriately.
        
        state = .SKSIdle
   
    }
    
    // MARK: - Other Actions
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = event?.allTouches()?.first
        if (languageTextView!.isFirstResponder() && touch!.view != languageTextView) {
            languageTextView!.resignFirstResponder()
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func selectEndpointerType(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if(index == 0){
            endpointer! = .Long
        } else if (index == 1){
            endpointer! = .Short
        } else if (index == 2){
            endpointer! = .None
        }
    }
    
       // MARK: - Volume level
    
    
    
    //MARK - Helpers
    
    
    func loadEarcons() {
        let startEarconPath = NSBundle.mainBundle().pathForResource("sk_start", ofType: "pcm")
        let stopEarconPath = NSBundle.mainBundle().pathForResource("sk_stop", ofType: "pcm")
        let errorEarconPath = NSBundle.mainBundle().pathForResource("sk_error", ofType: "pcm")
        let audioFormat = SKPCMFormat()
        audioFormat.sampleFormat = .SignedLinear16
        audioFormat.sampleRate = 16000
        audioFormat.channels = 1
        
        skSession!.startEarcon = SKAudioFile(URL: NSURL(fileURLWithPath: startEarconPath!), pcmFormat: audioFormat)
        skSession!.endEarcon = SKAudioFile(URL: NSURL(fileURLWithPath: stopEarconPath!), pcmFormat: audioFormat)
        skSession!.errorEarcon = SKAudioFile(URL: NSURL(fileURLWithPath: errorEarconPath!), pcmFormat: audioFormat)
    }
    
}