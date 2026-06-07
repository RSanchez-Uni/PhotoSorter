//
//  PhotoLibrary.swift
//  PhotoSorter
//

import Photos
import SwiftUI

@MainActor
@Observable
final class PhotoLibrary: NSObject {
    var status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    private(set) var assets: PHFetchResult<PHAsset>?

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    var isAuthorized: Bool {
        status == .authorized || status == .limited
    }

    func requestAccess() async {
        if status == .notDetermined {
            status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        }
        if isAuthorized {
            fetchAssets()
        }
    }

    private func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: .image, options: options)
    }
}

extension PhotoLibrary: PHPhotoLibraryChangeObserver {
    nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            guard let current = assets,
                  let details = changeInstance.changeDetails(for: current) else { return }
            assets = details.fetchResultAfterChanges
        }
    }
}
