//
//  ViewController.swift
//  demoCameraS
//
//  Created by Atal Bansal on 30/09/16.
//  Copyright © 2016 Atal Bansal. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController {

	let videoFileOutput = AVCaptureMovieFileOutput()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupCameraSession()
		// Do any additional setup after loading the view, typically from a nib.
	}
	// MARK: - camera code  setup
	lazy var cameraSession: AVCaptureSession = {
		let s = AVCaptureSession()
		// s.sessionPreset = AVCaptureSessionPresetLow
		// s.sessionPreset = AVCaptureSessionPresetMedium
		s.sessionPreset = AVCaptureSessionPresetHigh
		return s
	}()
	
	lazy var previewLayer: AVCaptureVideoPreviewLayer = {
		let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
		//preview.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
		preview.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
		preview.position = CGPoint(x: CGRectGetMidX(self.view.bounds), y: CGRectGetMidY(self.view.bounds))
		preview.videoGravity = AVLayerVideoGravityResize
		return preview
	}()
	
	/*
	@discussion     This methods is used for check capture device is available or not
	@paramters      NA
	@return			NA
	*/
	
	class func deviceWithMediaType(mediaType: String, preferringPosition:AVCaptureDevicePosition) -> AVCaptureDevice? {
		
		var devices = AVCaptureDevice.devicesWithMediaType(mediaType);
		
		if devices.isEmpty {
			print("This device has no camera. Probably the simulator.")
			return nil
		} else {
			var captureDevice: AVCaptureDevice = devices[0] as! AVCaptureDevice
			
			for device in devices {
				if device.position == preferringPosition {
					captureDevice = device as! AVCaptureDevice
					break
				}
			}
			return captureDevice
		}
	}
	/*
	@discussion     This methods is used for inital aetup of camera session for video recording
	@paramters      NA
	@return			NA
	*/
	
	func setupCameraSession() {
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
			//let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo ) as AVCaptureDevice
			var captureDevice: AVCaptureDevice
		
				captureDevice = ViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Back)!
			
			
			do {
				let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
				
				cameraSession.beginConfiguration()
				
				if (cameraSession.canAddInput(deviceInput) == true) {
					cameraSession.addInput(deviceInput)
				}
				let audioDevice: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
				do {
					let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
					cameraSession.addInput(audioInput)
					
				} catch {
					print("Unable to add audio device to the recording.")
				}
				let dataOutput = AVCaptureVideoDataOutput()
				dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(unsignedInt: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
				dataOutput.alwaysDiscardsLateVideoFrames = true
				
				if (cameraSession.canAddOutput(dataOutput) == true) {
					cameraSession.addOutput(dataOutput)
				}
				
				cameraSession.commitConfiguration()
				
			}
			catch let error as NSError {
				NSLog("\(error), \(error.localizedDescription)")
			}
		} else{
			print("Camera not available")
		}
		
	}
	/*
	@discussion     This methods is used for to stop camera Session after recording
	@paramters      NA
	@return			NA
	*/
	@IBAction func cameraStop(sender:UIButton){	//func cameraStop(){
		videoFileOutput.stopRecording()
		cameraSession.stopRunning()
		
	}
	
	/*
	@discussion     This methods is used to start camera without preview layer.
	@paramters      NA
	@return			NA
	*/
	
	@IBAction func cameraRecording(sender:UIButton){
		
			view.layer.addSublayer(previewLayer)
			
			cameraSession.startRunning()
			let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
			
			if cameraSession.canAddOutput(videoFileOutput) {
				cameraSession.beginConfiguration()
				cameraSession.addOutput(videoFileOutput)
				cameraSession.commitConfiguration()
			}
			//cameraSession.addOutput(videoFileOutput)
			
			let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
			let filePath = documentsURL.URLByAppendingPathComponent("temp11.mov")
			
			// Do recording and save the output to the `filePath`
			print(filePath)
			#if (arch(i386) || arch(x86_64)) && os(iOS)
			#else
				videoFileOutput.startRecordingToOutputFileURL(filePath, recordingDelegate: recordingDelegate);
//				NSTimer.scheduledTimerWithTimeInterval(13.0, target: self, selector: #selector(ViewController.cameraStop), userInfo: nil, repeats: false)
//				sender.userInteractionEnabled = false
				
			#endif
		
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}
extension ViewController:AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		// Here you collect each frame and process it
	}
	
	func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		// Here you can count how many frames are dopped
	}
	func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
		print("outputFileURL\(outputFileURL)")
		ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: nil)
		
		return
	}
	
	func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
		return
	}
}
