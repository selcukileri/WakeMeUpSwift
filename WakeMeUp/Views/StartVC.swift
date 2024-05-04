//
//  StartVC.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 14.11.2023.
//

import UIKit
import MapKit
import AudioToolbox
import AVFoundation

class StartVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let mapView = MKMapView()
    let remainingDistanceLabel = UILabel()
    let stopButton = UIButton()
    let returnToLocation = UIButton()
    let navigateToSelectedLocation = UIButton()
    
    var locationManager = CLLocationManager()
    var annotationTitle2 = ""
    var annotationSubtitle2 = ""
    var annotationLatitude2 : Double = 0.0
    var annotationLongitude2 : Double = 0.0
    var selectedDistanceArray2 = [Int]()
    var selectedOptionArray2 = [String]()
    var selectedDistance = Int()
    var selectedOption = String()
    var isUserTrackingEnabled = true
    var alarmPlaying = false
    var audioPlayer: AVAudioPlayer?
    var selectedAlarmName: String = ""
    var distanceUpdateTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        previewAlert()
        configure()
        
    }
    
    private func configureUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        view.addSubview(remainingDistanceLabel)
        view.addSubview(stopButton)
        mapView.addSubview(returnToLocation)
        mapView.addSubview(navigateToSelectedLocation)
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        remainingDistanceLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(.label, for: .normal)
        stopButton.layer.cornerRadius = 10
        stopButton.addTarget(self, action: #selector(stopButtonClicked), for: .touchUpInside)
        
        stopButton.snp.makeConstraints { make in
            make.top.equalTo(remainingDistanceLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        returnToLocation.setImage(UIImage(systemName: "location.fill"), for: .normal)
        returnToLocation.addTarget(self, action: #selector(returnUserLocationTapped), for: .touchUpInside)
        returnToLocation.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        navigateToSelectedLocation.setImage(UIImage(systemName: "location.north.fill"), for: .normal)
        navigateToSelectedLocation.addTarget(self, action: #selector(navigateToSelectedLocationTapped), for: .touchUpInside)
        navigateToSelectedLocation.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(8)
        }
        
        
        
    }
    
    private func configure(){
        remainingDistanceLabel.text = "Kalan Mesafe Hesaplanıyor.."
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if isUserTrackingEnabled {
            mapView.setUserTrackingMode(.follow, animated: true)
        }
        checkDistance()
        distanceUpdateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateDistance), userInfo: nil, repeats: true)
        print("selectedalarmname: \(selectedAlarmName)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedAlarmName = ""
    }
    
    @objc func updateDistance(){
        checkDistance()
    }
    
    private func updateRemainingDistance(){
        guard let userLocation = mapView.userLocation.location else {
            return
        }
        let destinationLocation = CLLocation(latitude: annotationLatitude2, longitude: annotationLongitude2)
        let distance = Int(calculateDistance(from: userLocation, to: destinationLocation))
        remainingDistanceLabel.text = "Kalan Mesafe: \(distance)m"
    }
    
    func calculateDistance(from sourceLocation: CLLocation, to destinationLocation: CLLocation) -> CLLocationDistance{
        return sourceLocation.distance(from: destinationLocation)
    }
    
    func checkDistance(){
        guard let userLocation = mapView.userLocation.location else {
            return
        }
        let destinationLocation = CLLocation(latitude: annotationLatitude2, longitude: annotationLongitude2)
        let distance = calculateDistance(from: userLocation, to: destinationLocation)
        let selectedDistanceDouble = Double(selectedDistanceArray2.last ?? 0)
        
            if distance <= selectedDistanceDouble {
                print("selectedOption: \(selectedOption)")
                if selectedOption != "" {
                    if selectedOption == "Alarm" {
                        alarmAlert()
                        alarmPlaying = true
                        playSound(alarmOption: selectedAlarmName)
                        
                    } else if selectedOption == "Titreşim" {
                        alarmAlert()
                        alarmPlaying = true
                        vibratePhone()
                    } else if selectedOption == "Alarm ve Titreşim" {
                        alarmAlert()
                        alarmPlaying = true
                        playSound(alarmOption: selectedAlarmName)
                        vibratePhone()
                        //print("alarmın olmuş olması lazım")
                    }
                } else {
                    makeAlert(title: "Hata", message: "Selected Option BOSSSSSS")
                }
            } else {
                //previewAlert()
            }
        }
        
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateRemainingDistance()
    }
    
    private func previewAlert(){
        
        if let lastSelectedDistance = selectedDistanceArray2.last, let lastSelectedOption = selectedOptionArray2.last {
            selectedOption = lastSelectedOption
            selectedDistance = Int(lastSelectedDistance)
            

            let alertController = UIAlertController(title: "Bilgilendirme", message: "Seçtiğiniz Mesafe: \(lastSelectedDistance)m\n Seçtiğiniz Alarm Tipi: \(lastSelectedOption)\n Seçtiğiniz Alarm İsmi: \(selectedAlarmName)\n Değiştirmek için ayarlara gidiniz.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default) {_ in
                    //
                self.updateRemainingDistance()
                self.selectedAnnotation()
                }
                let settingsAction = UIAlertAction(title: "Ayarlara Git", style: UIAlertAction.Style.default) {_ in
                    let settingsVC = SettingsVC()
                    self.navigationController?.pushViewController(settingsVC, animated: true)
                }
                alertController.addAction(okAction)
                alertController.addAction(settingsAction)
                present(alertController, animated: true)
            
               
            
        }
    }
    
    @objc func stopButtonClicked() {
        
       // stopAlarm()
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @objc func returnUserLocationTapped() {
        if let userLocation = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            //print(userLocation.latitude,userLocation.longitude)
        }
    }
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    private func selectedAnnotation(){
        //print("button clicked")
        //print("selected coordinates: \(annotationLatitude2), \(annotationLongitude2)")
        let selectedCoordinates = CLLocationCoordinate2D(latitude: annotationLatitude2, longitude: annotationLongitude2)
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinates
        annotation.title = annotationTitle2
        annotation.subtitle = annotationSubtitle2
        mapView.addAnnotation(annotation)
    }
    
    @objc func navigateToSelectedLocationTapped() {
        
        print("button2 clicked")
        print("selected coordinates2: \(annotationLatitude2), \(annotationLongitude2)")
        selectedAnnotation()
        let selectedCoordinates2 = CLLocationCoordinate2D(latitude: annotationLatitude2, longitude: annotationLongitude2)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: selectedCoordinates2, span: span)
        print(selectedCoordinates2.latitude,selectedCoordinates2.longitude)
        mapView.setRegion(region, animated: true)
        mapView.layoutIfNeeded()
    }
    func vibratePhone(){
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func mapOptionToFileName(_ option: String) -> String {
        
        let mapping = [
            "iPhone Alarm": "iphone_alarm",
            "Pala Alarm": "pala_alarm",
            "iPhone Alarm2": "iphone_alarm2",
            "Perfect Alarm": "perfect_alarm",
            "Alarm": "alarm"
        ]

        return mapping[option] ?? "iphone_alarm"
    }
    
    func playSound(alarmOption: String){
        
        let filename = mapOptionToFileName(alarmOption) + ".mp3"
        
        print("Filename: \(filename)")
        print("alarmOption: \(alarmOption)")
        
        
        if let path = Bundle.main.path(forResource: alarmOption, ofType: "mp3", inDirectory: "mp3s") {
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                print("alarm calindi")
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        } else {
            print("Sound file not found for alarm option: \(alarmOption)")
        }
        
    }
    func alarmAlert(){
        let alarmAlert = UIAlertController(title: "Alarm", message: "Alarm Çalıyor!", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default) { _ in
            self.stopAlarm()
            self.dismiss(animated: true)
        }
        alarmAlert.addAction(okAction)
        
        distanceUpdateTimer?.invalidate()
        
        present(alarmAlert, animated: true) {
            self.alarmPlaying = true
        }
    }
    func stopAlarm(){
        if alarmPlaying {
            audioPlayer?.stop()
            alarmPlaying = false
        }
    }
}
