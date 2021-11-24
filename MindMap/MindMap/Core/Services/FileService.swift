//
//  FileService.swift
//  MindMap
//
//

import Foundation
import RxSwift
import RxRelay

protocol FileService: AnyObject {
    func fetchFiles() -> Observable<[File]>
    func save(_ file: File)
    func delete(_ file: File)
    
    func availableFileName(for name: String) -> String
}

class DefaultFileService {
    
    private var documentsURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var filesRelay: BehaviorSubject<[File]> = .init(value: [])
    
    init() {
        getAllFiles()
    }
    
    private func mapFiles(_ urls: [URL]) -> [File] {
        return urls.compactMap { url -> File? in
            guard FileManager.default.fileExists(atPath: url.path) else {
                return nil
            }
            
            do {
                let data = try Data(contentsOf: url, options: [])
                let file = try JSONDecoder().decode(File.self, from: data)
                return file
            } catch {
                return nil
            }
        }
    }
    
    private func fileUrl(_ file: File) -> URL {
        return documentsURL.appendingPathComponent(file.title + ".json")
    }
    
    private func getAllFiles() {
        let files = (try? FileManager.default.contentsOfDirectory(at: documentsURL,
                                                                  includingPropertiesForKeys: nil,
                                                                  options: .producesRelativePathURLs)) ?? []
        DispatchQueue.main.async { [weak self] in
            let fileModels = self?.sortByDate(files: self?.mapFiles(files) ?? []) ?? []
            self?.filesRelay.onNext(fileModels)
        }
    }
    
    private func sortByDate(files: [File]) -> [File] {
        return files.sorted { lhs, rhs in
            return lhs > lhs
        }
    }
}

extension DefaultFileService: FileService {

    func save(_ file: File) {
        guard let data = try? JSONEncoder().encode(file) else {
            return
        }
        
        let url = fileUrl(file)
        do {
            try data.write(to: url)
            file.handleSave()
            var relayValue = try? filesRelay.value()
            guard relayValue != nil else {
                return
            }
            if let index = relayValue?.firstIndex(of: file) {
                relayValue?[index] = file
            } else {
                relayValue?.append(file)
            }
            filesRelay.onNext(sortByDate(files: relayValue ?? []))
        } catch {
            return
        }
        
    }
    
    func delete(_ file: File) {
        let url = fileUrl(file)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: url.path)
            
            var relayValue = try? filesRelay.value()
            guard relayValue != nil else {
                return
            }
            if let index = relayValue?.firstIndex(of: file) {
                relayValue?.remove(at: index)
            }
            filesRelay.onNext(sortByDate(files: relayValue ?? []))
        } catch {
            return
        }
    }
    
    func fetchFiles() -> Observable<[File]> {
        getAllFiles()
        return filesRelay.asObservable().distinctUntilChanged()
    }
    
    func availableFileName(for name: String) -> String {
        let fileUrls = (try? FileManager.default.contentsOfDirectory(at: documentsURL,
                                                                  includingPropertiesForKeys: nil,
                                                                  options: .producesRelativePathURLs)) ?? []
        let fileNames = fileUrls.map { $0.lastPathComponent.replacingOccurrences(of: ".json", with: "").removingPercentEncoding }
        
        if !fileNames.contains(name) {
            return name
        }
        var copyIndex = 0
        
        var newName = name
        while fileNames.contains(newName) {
            copyIndex += 1
            newName = name + " (\(copyIndex))"
        }
        
        return newName
    }
}
