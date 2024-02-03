//
//  MapsVC.swift
//  WakeMeUp
//
//  Created by Selçuk İleri on 13.11.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var returnToLocation: UIButton!
    @IBOutlet weak var remainingDistance: UILabel!
    
    
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    var selectedTitle = ""
    var selectedTitleId : UUID?
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude : Double = 0.0
    var annotationLongitude : Double = 0.0
    var selectedDistanceArray = [Int]()
    var selectedOptionArray = [String]()
    var existingAnnotation: MKPointAnnotation?
    var selectedAlarmArray = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startButton.isHidden = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        let keyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(keyboardGestureRecognizer)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(longPressGestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        if selectedTitle != "" {
            returnToLocation.isHidden = true
            longPressGestureRecognizer.isEnabled = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleId!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                makeAlert(title: "Uyarı", message: error.localizedDescription)
            }
            
        } else {
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
            if annotationLatitude != 0.0 {
                let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
                CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                    if let placemark = placemarks {
                        if placemark.count>0 {
                            let newPlacemark = MKPlacemark(placemark: placemark[0])
                            let item = MKMapItem(placemark: newPlacemark)
                            item.name = self.annotationTitle
                            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                            item.openInMaps(launchOptions: launchOptions)
                        } else {
                            
                        }
                    }
                }
            } else {
                makeAlert(title: "Uyarı", message: "Doğru konum seçtiğinizden emin olunuz.")
            }
            
        }
    }
    
    
    @IBAction func returnToUserLocation(_ sender: Any) {
        if let userLocation = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc func chooseLocation(longPressGestureRecognizer: UILongPressGestureRecognizer){
        if longPressGestureRecognizer.state == .began {
            let touchedPoint = longPressGestureRecognizer.location(in: self.mapView)
            let touchedcoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedcoordinates.latitude
            chosenLongitude = touchedcoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedcoordinates
            if nameText.text == "" || commentText.text == "" {
                makeAlert(title: "Uyarı", message: "Lütfen isim/yorum giriniz!")
            } else {
                annotation.title = nameText.text
                annotation.subtitle = commentText.text
                if let existingAnnotation = existingAnnotation {
                    mapView.removeAnnotation(existingAnnotation)
                }
                self.mapView.addAnnotation(annotation)
                existingAnnotation = annotation
            }
            
            
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    

    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
        } else {
            saveButton.isHidden = true
            startButton.isHidden = false
        }
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        if nameText.text == "" {
            makeAlert(title: "Uyarı", message: "Lütfen isim giriniz!")
        } else if commentText.text == "" {
            makeAlert(title: "Uyarı", message: "Lütfen yorum giriniz!")
        } else if (chosenLatitude == 0.0 && chosenLongitude == 0.0) {
            makeAlert(title: "Uyarı", message: "Lütfen basılı tutarak konum seçiniz!")
        } else {
            newPlace.setValue(nameText.text, forKey: "title")
            newPlace.setValue(commentText.text, forKey: "subtitle")
            newPlace.setValue(chosenLatitude, forKey: "latitude")
            newPlace.setValue(chosenLongitude, forKey: "longitude")
            newPlace.setValue(UUID(), forKey: "id")
            do {
                try context.save()
            } catch {
                makeAlert(title: "Uyarı", message: error.localizedDescription)
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func startButtonClicked(_ sender: Any) {
        getDataFromOptions()
        
        if selectedDistanceArray.isEmpty || selectedOptionArray.isEmpty {
            showSettingsAlert()
        } else {
            performSegue(withIdentifier: "toStartVC", sender: nil)
        }
    }
    
    func showSettingsAlert(){
        let alertController = UIAlertController(title: "Uyarı", message: "Lütfen ayarlara gidip gerekli seçenekleri seçin.", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Ayarlar", style: .default) { _ in
                self.performSegue(withIdentifier: "mapViewToSettingsVC", sender: nil)
            }
            let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)

            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
    }
    func getDataFromOptions(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Options")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                self.selectedDistanceArray.removeAll(keepingCapacity: false)
                self.selectedOptionArray.removeAll(keepingCapacity: false)
                self.selectedAlarmArray.removeAll(keepingCapacity: false)
                for result in results as! [NSManagedObject] {
                    if let selectedDistance = result.value(forKey: "distance") as? Int {
                        self.selectedDistanceArray.append(selectedDistance)
                        //print("\(selectedDistance.nonzeroBitCount)")
                    }
                    if let selectedOption = result.value(forKey: "alertOption") as? String {
                        self.selectedOptionArray.append(selectedOption)
                        //print(selectedOption.count)
                    }
                    if let selectedAlertName = result.value(forKey: "alertName") as? String {
                        self.selectedAlarmArray.append(selectedAlertName)
                    }
                    
                }
            }
        } catch {
            makeAlert(title: "Uyarı", message: error.localizedDescription)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStartVC" {
            if let destinationVC = segue.destination as? StartVC {
                destinationVC.selectedDistanceArray2 = self.selectedDistanceArray
                destinationVC.selectedOptionArray2 = self.selectedOptionArray
                destinationVC.annotationLatitude2 = self.annotationLatitude
                destinationVC.annotationLongitude2 = self.annotationLongitude
                destinationVC.annotationTitle2 = self.annotationTitle
                destinationVC.annotationSubtitle2 = self.annotationSubtitle
                destinationVC.selectedAlarmName = self.selectedAlarmArray
            }
        }
    }
}
