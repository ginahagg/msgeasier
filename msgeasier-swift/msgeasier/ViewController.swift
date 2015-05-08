//
//  ViewController.swift
//  msgeasier
//
//  Created by Gina Hagg on 4/1/15.
//  Copyright (c) 2015 Gina Hagg. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController, UIBubbleTableViewDataSource,WebSocketDelegate, UITextFieldDelegate {
    
    var msg: String? = "hello"{
        didSet{
            msgText?.text = msg
            writeToSocket()
        }
    }
    
    @IBOutlet weak var textView: UIView!
   
    // MARK: UITextField
    @IBOutlet weak var msgText: UITextField!{
        didSet{
            msgText.delegate = self
            msgText.text = msg
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("textFieldShouldReturn")
        if textField == msgText!{
            textField.resignFirstResponder()
            msg = textField.text
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        println("textFieldDidEndEditing")
        textField.resignFirstResponder()
    }
    
    
    @IBOutlet weak var bubbleTable: UIBubbleTableView!
    var bubbleData: NSMutableArray = NSMutableArray()
       //@IBOutlet var bubbleTable: UIBubbleTableView!
    
    var socket = WebSocket(url: NSURL(scheme: "ws", host: "localhost:8080", path: "/ws?user=marc")!, protocols: ["chat", "superchat"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
        socket.selfSignedSSL = false
        socket.connect()
        
        var heyBubble: NSBubbleData = NSBubbleData.dataWithText("Hey, nice arabesque dude!!", date: NSDate(),type: BubbleTypeMine) as! NSBubbleData
        
        heyBubble.avatar = UIImage(named:"11-2-09 016.jpg")
        
        
        /*var photoBubble: NSBubbleData = NSBubbleData.dataWithImage(UIImage(named: "avatar1") ,date: NSDate(), type:BubbleTypeSomeoneElse) as! NSBubbleData
        
        photoBubble.avatar = UIImage(named: "missingAvatar")*/
        
        var replyBubble: NSBubbleData = NSBubbleData.dataWithText("Wow.. Really cool picture out there. iPhone 5 has really nice camera, yeah?", date: NSDate(), type:BubbleTypeMine) as! NSBubbleData
        replyBubble.avatar =  UIImage(named:"11-2-09 016.jpg")
        
        bubbleData = [heyBubble, replyBubble]
        bubbleTable!.bubbleDataSource = self
        
        // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
        // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
        // Groups are delimited with header which contains date and time for the first message in the group.
        
        bubbleTable!.snapInterval = 120;
        
        // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
        // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
        
        bubbleTable!.showAvatars = true
        
        
        // Uncomment the line below to add "Now typing" bubble
        // Possible values are
        //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
        //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
        //    - NSBubbleTypingTypeNone - no "now typing" bubble
        
        bubbleTable!.typingBubble = NSBubbleTypingTypeSomebody
        
        bubbleTable!.reloadData()
        
        // Keyboard events
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:", name:UIKeyboardWillShowNotification , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillbeHidden:", name:UIKeyboardWillHideNotification , object: nil)
    }
    
    
    // MARK: Websocket Delegate Methods.
    
    func websocketDidConnect(ws: WebSocket) {
        println("websocket is connected")
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            println("websocket is disconnected: \(e.localizedDescription)")
        }
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        println("Received text: \(text)")
        var msgBubble: NSBubbleData = giveMeYouBubble(text)
        
        bubbleData.addObject(msgBubble)
        bubbleTable!.reloadData()
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        println("Received data: \(data.length)")
    }
    
    
    
    @IBAction func sendMessage(sender: UIButton) {
        //var msg:String = msgText.text
        println("from textbox : \(msg)")
        if self.msg == nil
        {
            socket.writeString("marc||gina||not working!")
        }
        else
        {
            socket.writeString("marc||gina||\(msg)")
        }

    }
   
    
    /*@IBAction func disconnect(sender: UIBarButtonItem) {
        if socket.isConnected {
            sender.title = "Connect"
            socket.disconnect()
        } else {
            sender.title = "Disconnect"
            socket.connect()
        }
    }*/
    
    // MARK: Keyboard methods
    func keyboardWillBeHidden(aNotification: NSNotification)
    {
        println("keyboardWillBeHidden")
        var info: NSDictionary = aNotification.userInfo!
        //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        //var kbSize: CGSize  = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGSizeValue()
        var kbheight = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size.height
        UIView.animateWithDuration(0.2 , animations:
            {
                
                var frame:CGRect  = self.textView!.frame
                frame.origin.y += kbheight!
                self.textView!.frame = frame
                
                frame = self.bubbleTable!.frame
                frame.size.height += kbheight!
                self.bubbleTable!.frame = frame
        })
    }
    
    func keyboardWillShow( aNotification: NSNotification)
    {
        println("keyboardWillShow")
        var info: NSDictionary = aNotification.userInfo!
        
        var kbheight = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size.height
        UIView.animateWithDuration(0.2 , animations:
            {
                var frame : CGRect = self.textView!.frame
                frame.origin.y -= kbheight!
                self.textView!.frame = frame
                
                frame = self.bubbleTable!.frame
                frame.size.height -= kbheight!
                self.bubbleTable!.frame = frame
        })
    }

    
    func rowsForBubbleTable( tableView : UIBubbleTableView)->(NSInteger)
    {
        println("bubbleData-count: \(bubbleData.count)")
        return bubbleData.count
    }
    
    func  bubbleTableView(tableView : UIBubbleTableView , dataForRow row: NSInteger)->NSBubbleData
    {
        println("dataforRow: \(row)")
        return bubbleData.objectAtIndex(row) as! NSBubbleData
    }
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.contentSize = bubbleTable.frame.size
        }
    }
    
    @IBAction func SayIt(sender: UIBarButtonItem) {
        
        println("Sayit clicked")
        
        //var msg:String = msgText.text
        println("from textbox : \(msg)")
        writeToSocket()
        
    }
    
    func writeToSocket(){
    
        if self.msg == nil
        {
            socket.writeString("marc||gina||not working!")
        }
        else
        {
            socket.writeString("marc||gina||\(msg)")
            bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
            var msgBubble: NSBubbleData = giveMeMeBubble(self.msg!)
    
            bubbleData.addObject(msgBubble)
            bubbleTable.reloadData()
    
            msgText.text = "";
    
        }
    }
    
    func giveMeMeBubble(msg: String)-> NSBubbleData {
        
        var heyBubble: NSBubbleData = NSBubbleData.dataWithText(msg, date: NSDate(),type: BubbleTypeMine) as! NSBubbleData
        
        heyBubble.avatar = UIImage(named:"11-2-09 016.jpg")
        
        return heyBubble

    }
    
    func giveMeYouBubble(msg: String)-> NSBubbleData {
        
        var heyBubble: NSBubbleData = NSBubbleData.dataWithText(msg, date: NSDate(),type: BubbleTypeSomeoneElse) as! NSBubbleData
        
        heyBubble.avatar = UIImage(named:"guy-beautiful-arabesque.jpg")
        
        return heyBubble
        
    }
    
    
}


