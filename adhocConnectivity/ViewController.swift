//
//  ViewController.swift
//  adhocConnectivity
//
//  Created by divya srinivasan on 19.11.17.
//  Copyright © 2017 divya srinivasan. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate,MCSessionDelegate,UITextFieldDelegate {
    let serviceType = "LCOC-Chat"
    //MARK: Properties
    
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var chatView: UITextView!
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Called when a peer sends an NSData to us
        
        // This needs to run on the main queue
        DispatchQueue.main.async() {
            
            let msg = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            
            self.updateChat(text: msg! as String, fromPeer: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    

    //MARK: Properties
    
    //@IBOutlet weak var messageField: UITextField!
    //@IBOutlet weak var chatView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageField.delegate=self
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        self.browser = MCBrowserViewController(serviceType:serviceType,
                                               session:self.session)
        
        self.browser.delegate = self;
        
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType,
                                               discoveryInfo:nil, session:self.session)
        
        // tell the assistant to start advertising our fabulous chat
        self.assistant.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Actions
    func textFieldShouldReturn(_ messageField: UITextField) -> Bool {
        messageField.resignFirstResponder()
        return true;
    }
    func textFieldDidEndEditing(_ messageField: UITextField) {
        //messageField.text = textField.text
        //sendChat(<#UIButton#>);
    }
    @IBAction func showBrowser(_ sender: Any) {
        // Show the browser view controller
        self.present(self.browser, animated: true, completion: nil)
    }
    
    @IBAction func sendChat(_ sender: UIButton) {
        do{
            // Bundle up the text in the message field, and send it off to all
            // connected peers
            print("send chat")
            let msg = self.messageField.text?.data(using: String.Encoding.utf8,                                                   allowLossyConversion: false)
            
            print(msg);
            
            //  let error : NSError?
            //let msg;
            //msg!
            try self.session.send(msg!, toPeers: self.session.connectedPeers,with: MCSessionSendDataMode.reliable)
            
            /*if error != nil {
             print("Error sending data: \(error?.localizedDescription ?? "ERROR FOUND AND FAILED TO PRINT THAT TOO!!!")")
             }*/
            
            self.updateChat(text: self.messageField.text!, fromPeer: self.peerID)
            
            self.messageField.text = ""
        }
        catch {
            print("Error, Exception thrown")
        }
    }
    
   /* @IBAction func sendChat(_ sender: Any) throws{
        do{
        // Bundle up the text in the message field, and send it off to all
        // connected peers
        print("send chat")
        let msg = self.messageField.text?.data(using: String.Encoding.utf8,
                                                           allowLossyConversion: false)
        
            print(msg);
        
      //  let error : NSError?
            
        try self.session.send(msg!, toPeers: self.session.connectedPeers,
                          with: MCSessionSendDataMode.reliable)
            
        /*if error != nil {
            print("Error sending data: \(error?.localizedDescription ?? "ERROR FOUND AND FAILED TO PRINT THAT TOO!!!")")
        }*/
        
        self.updateChat(text: self.messageField.text!, fromPeer: self.peerID)
        
        self.messageField.text = ""
        }
        catch {
            print("Error, Exception thrown")
        }
    }*/
    func updateChat(text : String, fromPeer peerID: MCPeerID) {
        // Appends some text to the chat view
        print("Update chat")
        // If this peer ID is the local device's peer ID, then show the name
        // as "Me"
        var name : String
        
        switch peerID {
        case self.peerID:
            name = "Me"
        default:
            name = peerID.displayName
        }
        
        // Add the name to the message and display it
        let message = "\(name): \(text)\n"
        self.chatView.text = self.chatView.text + message
        print("Update chat finish")
    }
}

