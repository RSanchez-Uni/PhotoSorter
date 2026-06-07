//
//  PhotoLibrary.swift
//  PhotoSorter
//

import Photos
import SwiftData
import SwiftUI

@MainActor
@Observable
final class PhotoLibrary: NSObject {
    var status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    private(set) var assets: PHFetchResult<PHAsset>?

    private let coordinator: FeatureExtractionCoordinator
    private let resolver: LocationResolver
    private var pipelineTask: Task<Void, Never>?

    init(container: ModelContainer) {
        self.coordinator = FeatureExtractionCoordinator(modelContainer: container)
        self.resolver = LocationResolver(modelContainer: container)
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
            startPipeline()
        }
    }

    private func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: .image, options: options)
    }

    private func startPipeline() {
        guard let assets else { return }
        let identifiers = (0..<assets.count).map { assets.object(at: $0).localIdentifier }
        let coordinator = self.coordinator
        let resolver = self.resolver
        pipelineTask?.cancel()
        pipelineTask = Task.detached(priority: .background) {
            await coordinator.extractFeatures(for: identifiers)
            let prioritized = await coordinator.collectGridKeyCounts(for: identifiers)
            await resolver.resolve(prioritizedGridKeys: prioritized)
        }
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
