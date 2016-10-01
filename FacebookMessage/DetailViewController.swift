//
//  DetailViewController.swift
//  FacebookMessage
//
//  Created by Swarup_Pattnaik on 26/09/16.
//  Copyright © 2016 Swarup_Pattnaik. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class DetailViewController: JSQMessagesViewController, UIViewControllerTransitioningDelegate {
    var messages = [JSQMessage]()
    let defaults = NSUserDefaults.standardUserDefaults()
    var conversation: Conversation?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var userDetails: AnyObject? = nil
    private var displayName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Setup navigation
//        setupBackButton()

        /**
         *  Override point:
         *
         *  Example of how to cusomize the bubble appearence for incoming and outgoing messages.
         *  Based on the Settings of the user display two differnent type of bubbles.
         *
         */
        
//        if defaults.boolForKey(Setting.removeBubbleTails.rawValue) {
//            // Make taillessBubbles
//            incomingBubble = JSQMessagesBubbleImageFactory(bubbleImage: UIImage.jsq_bubbleCompactTaillessImage(), capInsets: UIEdgeInsetsZero, layoutDirection: UIApplication.sharedApplication().userInterfaceLayoutDirection).incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
//            outgoingBubble = JSQMessagesBubbleImageFactory(bubbleImage: UIImage.jsq_bubbleCompactTaillessImage(), capInsets: UIEdgeInsetsZero, layoutDirection: UIApplication.sharedApplication().userInterfaceLayoutDirection).outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
//        }
//        else {
            // Bubbles with tails
            incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
            outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
//        }
        
        /**
         *  Example on showing or removing Avatars based on user settings.
         */
        
//        if defaults.boolForKey(Setting.removeAvatar.rawValue) {
//            collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
//            collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
//        } else {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
//        }
        
        // Show Button to simulate incoming messages
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.jsq_defaultTypingIndicatorImage(), style: .Plain, target: self, action: #selector(receiveMessagePressed))
        
        // This is a beta feature that mostly works but to make things more stable it is diabled.
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
    }
    
    func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    func backButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func receiveMessagePressed(sender: UIBarButtonItem) {
        /**
         *  Show the typing indicator to be shown
         */
        self.showTypingIndicator = !self.showTypingIndicator
        
        /**
         *  Scroll to actually view the indicator
         */
        self.scrollToBottomAnimated(true)
        
        /**
         *  Copy last sent message, this will be the new "received" message
         */
        var copyMessage = self.messages.last?.copy()
        
        let contactAvatarID = userDetails!.valueForKey("avatarID") as? String
        let contactDisplayName = userDetails!.valueForKey("displayName") as? String

        if (copyMessage == nil) {
            copyMessage = JSQMessage(senderId: contactAvatarID!, displayName: contactDisplayName!, text: "First received!")
        }
        
        var newMessage:JSQMessage!
        var newMediaData:JSQMessageMediaData!
        var newMediaAttachmentCopy:AnyObject?
        
        if copyMessage!.isMediaMessage() {
            /**
             *  Last message was a media message
             */
            let copyMediaData = copyMessage!.media
            
            switch copyMediaData {
            case is JSQPhotoMediaItem:
                let photoItemCopy = (copyMediaData as! JSQPhotoMediaItem).copy() as! JSQPhotoMediaItem
                photoItemCopy.appliesMediaViewMaskAsOutgoing = false
                
                newMediaAttachmentCopy = UIImage(CGImage: photoItemCopy.image!.CGImage!)
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view5017
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy
            case is JSQLocationMediaItem:
                let locationItemCopy = (copyMediaData as! JSQLocationMediaItem).copy() as! JSQLocationMediaItem
                locationItemCopy.appliesMediaViewMaskAsOutgoing = false
                newMediaAttachmentCopy = locationItemCopy.location!.copy()
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                locationItemCopy.location = nil;
                
                newMediaData = locationItemCopy;
            case is JSQVideoMediaItem:
                let videoItemCopy = (copyMediaData as! JSQVideoMediaItem).copy() as! JSQVideoMediaItem
                videoItemCopy.appliesMediaViewMaskAsOutgoing = false
                newMediaAttachmentCopy = videoItemCopy.fileURL!.copy()
                
                /**
                 *  Reset video item to simulate "downloading" the video
                 */
                videoItemCopy.fileURL = nil;
                videoItemCopy.isReadyToPlay = false;
                
                newMediaData = videoItemCopy;
            case is JSQAudioMediaItem:
                let audioItemCopy = (copyMediaData as! JSQAudioMediaItem).copy() as! JSQAudioMediaItem
                audioItemCopy.appliesMediaViewMaskAsOutgoing = false
                newMediaAttachmentCopy = audioItemCopy.audioData!.copy()
                
                /**
                 *  Reset audio item to simulate "downloading" the audio
                 */
                audioItemCopy.audioData = nil;
                
                newMediaData = audioItemCopy;
            default:
                assertionFailure("Error: This Media type was not recognised")
            }
            
            newMessage = JSQMessage(senderId: contactAvatarID!, displayName: contactDisplayName!, media: newMediaData)
        }
        else {
            /**
             *  Last message was a text message
             */
            
            newMessage = JSQMessage(senderId: contactAvatarID!, displayName: contactDisplayName!, text: copyMessage!.text)
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new JSQMessageData object to your data source
         *  3. Call `finishReceivingMessage`
         */
        
        self.messages.append(newMessage)
        self.finishReceivingMessageAnimated(true)
        if (self.automaticallyScrollsToMostRecentMessage) {
            self.scrollToBottomAnimated(true)
        }

        if newMessage.isMediaMessage {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                switch newMediaData {
                case is JSQPhotoMediaItem:
                    (newMediaData as! JSQPhotoMediaItem).image = newMediaAttachmentCopy as? UIImage
                    self.collectionView!.reloadData()
                case is JSQLocationMediaItem:
                    (newMediaData as! JSQLocationMediaItem).setLocation(newMediaAttachmentCopy as? CLLocation, withCompletionHandler: {
                        self.collectionView!.reloadData()
                    })
                case is JSQVideoMediaItem:
                    (newMediaData as! JSQVideoMediaItem).fileURL = newMediaAttachmentCopy as? NSURL
                    (newMediaData as! JSQVideoMediaItem).isReadyToPlay = true
                    self.collectionView!.reloadData()
                case is JSQAudioMediaItem:
                    (newMediaData as! JSQAudioMediaItem).audioData = newMediaAttachmentCopy as? NSData
                    self.collectionView!.reloadData()
                default:
                    assertionFailure("Error: This Media type was not recognised")
                }
            }
        }
    }
    
    // MARK: JSQMessagesViewController method overrides
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(message)
        self.finishSendingMessageAnimated(true)
        if (self.automaticallyScrollsToMostRecentMessage) {
            self.scrollToBottomAnimated(true)
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton)
    {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .ActionSheet)

        let photoAction = UIAlertAction(title: "Send photo/ smiley", style: .Default) { (action) in
            /**
             *  Create UIImagePicker to send photo
             */
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let pvc = storyboard.instantiateViewControllerWithIdentifier("Smiley Collection View Controller") as! SmileyCollectionViewController
            
            //        Load Images
            for i in 1...50
            {
                let image = UIImage.init(named: "\(i).jpg")
                pvc.images.addObject(image!)
            }
            
            pvc.modalPresentationStyle = UIModalPresentationStyle.Custom
            pvc.transitioningDelegate = self
            pvc.view.backgroundColor = UIColor.redColor()
            pvc.detailViewController = self
            self.presentViewController(pvc, animated: true, completion: nil)
        }

        let locationAction = UIAlertAction(title: "Send location", style: .Default) { (action) in

            //  Add fake location
            let locationItem = self.buildLocationItem()

            self.addMedia(locationItem)
        }

        let videoAction = UIAlertAction(title: "Send video", style: .Default) { (action) in
            //  Add fake video
            let videoItem = self.buildVideoItem()

            self.addMedia(videoItem)
        }

        let audioAction = UIAlertAction(title: "Send audio", style: .Default) { (action) in
             //  Add fake audio
            let audioItem = self.buildAudioItem()

            self.addMedia(audioItem)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        sheet.addAction(photoAction)
        sheet.addAction(locationAction)
        sheet.addAction(videoAction)
        sheet.addAction(audioAction)
        sheet.addAction(cancelAction)
        
        self.presentViewController(sheet, animated: true, completion: nil)

}
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presentingViewController: self)
    }
    
    func buildVideoItem() -> JSQVideoMediaItem {
        let videoURL = NSURL(fileURLWithPath: "file://")
        
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        
        return videoItem
    }
    
    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = NSBundle.mainBundle().pathForResource("jsq_messages_sample", ofType: "m4a")
        let audioData = NSData(contentsOfFile: sample!)
        
        let audioItem = JSQAudioMediaItem(data: audioData)
        
        return audioItem
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId(), displayName: self.senderDisplayName(), media: media)
        self.messages.append(message)
        self.finishSendingMessageAnimated(true)
        if (self.automaticallyScrollsToMostRecentMessage) {
            self.scrollToBottomAnimated(true)
        }

    }
    
    
    //MARK: JSQMessages CollectionView DataSource
    
    override func senderId() -> String {
        return "309-41802-1990"
    }
    
    override func senderDisplayName() -> String {
        return "Swarup Pattnaik"
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {
        
        return messages[indexPath.item].senderId == self.senderId() ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = messages[indexPath.item]
        return getAvatar(message.senderDisplayName)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        // Displaying names above messages
        //Mark: Removing Sender Display Name
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         */
//        if defaults.boolForKey(Setting.removeSenderDisplayName.rawValue) {
//            return nil
//        }
        
        if message.senderId == self.senderId() {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         */
//        if defaults.boolForKey(Setting.removeSenderDisplayName.rawValue) {
//            return 0.0
//        }
        
        /**
         *  iOS7-style sender name labels
         */
        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId() {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    //MARK:- Helper Method for getting an avatar for a specific User.
    func getAvatar(user: String) -> JSQMessagesAvatarImage{
        
        // derive initials from a name
        let string  = NSString(string:user)
        print(string)
        
        let array = string.componentsSeparatedByString(" ")
        let subString1 = array.first?.stringByTrimmingCharactersInSet(NSCharacterSet.lowercaseLetterCharacterSet())
        let subString2 = array.last?.stringByTrimmingCharactersInSet(NSCharacterSet.lowercaseLetterCharacterSet())
        let intials = String("\(subString1!)\(subString2!)")
        
        print(intials)
        let avatar = JSQMessagesAvatarImageFactory().avatarImageWithUserInitials(intials, backgroundColor: UIColor.jsq_messageBubbleGreenColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12))
        return avatar
    }

}

