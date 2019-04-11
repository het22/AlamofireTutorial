//
//  ViewController.swift
//  AlamofireTutorial
//
//  Created by Het Song on 11/04/2019.
//  Copyright © 2019 Het Song. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet var takePictureButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet var tableView: UITableView!
    var tags: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.isHidden = true
        tableView.dataSource = self
    }

    @IBAction func takePicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 1. 이미지 선택
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("Info did not have the required UIImage for the Original Image")
            dismiss(animated: true)
            return
        }
        
        imageView.image = image
        
        imageView.alpha = 0.2
        takePictureButton.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        // 2. 이미지 업로드
        upload(image: image) { [weak self] tags in
            self?.imageView.alpha = 1.0
            self?.takePictureButton.isHidden = false
            self?.activityIndicatorView.isHidden = true
            self?.activityIndicatorView.stopAnimating()
            
            // 9. 태그값 업데이트하고 테이블뷰 리로드
            self?.tags = tags ?? []
            self?.tableView.reloadData()
        }
        
        dismiss(animated: true)
    }
    
}

extension ViewController {
    
    func upload(image: UIImage,
                completion: @escaping (_ tags: [String]?) -> Void) {
        // 3. 이미지를 데이터로 변환
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Could not get JPEG representation of UIImage")
            return
        }
        
        // 4. 업로드 요청
        Alamofire.upload(multipartFormData: { multipartFormData in
                            multipartFormData.append(imageData,
                                                     withName: "imagefile",
                                                     fileName: "image.jpg",
                                                     mimeType: "image/jpeg")
                        },
                         with: ImaggaRouter.content,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let request, _, _):
                                request
                                    .validate()
                                    .responseData { response in
                                        guard response.result.isSuccess, let data = response.data else {
                                            print("Error while uploading file: \(String(describing: response.result.error))")
                                            completion(nil)
                                            return
                                        }
                                        
                                        do {
                                            // 5. json을 Codable 객체로 디코드
                                            let json = try JSONDecoder().decode(UploadRes.self, from: data)
                                            // 6. 업로드 된 이미지의 id값으로 태그 다운로드 요청
                                            self.downloadTags(contentID: json.uploaded[0].id, completion: { completion($0) })
                                        } catch let err {
                                            print(err)
                                            completion(nil)
                                        }
                                    }
                            case .failure(let encodingError):
                                print(encodingError)
                                completion(nil)
                            }
        })
        
    }
    
    func downloadTags(contentID: String, completion: @escaping ([String]?)->Void) {
        
        // 7. 다운로드 요청
        Alamofire
            .request(ImaggaRouter.tags(contentID))
            .validate()
            .responseData { response in
                guard response.result.isSuccess, let data = response.data else {
                    print("Error while fetching tags: \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                
                do {
                    let json = try JSONDecoder().decode(TagResponse.self, from: data)
                    // 8. 태그 값 매핑해서 핸들러에 넘김
                    let tags = json.results[0].tags.compactMap({return $0.tag})
                    completion(tags)
                } catch let err {
                    print(err)
                    completion(nil)
                }
            }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = tags[indexPath.row]
        return cell
    }
}
