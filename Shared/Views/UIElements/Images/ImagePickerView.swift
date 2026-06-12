//
//  ImagePickerView.swift
//  debtMe
//
//  Created by Misael Landero on 04/06/24.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import WebKit

#if canImport(ImagePlayground)
import ImagePlayground
#endif

struct ImagePickerView: View {
    @Binding var photoData: Data?
    @AppStorage("selectedQuality") private var selectedQuality: JPEGQuality = .lowest
    
    var imagename = ""

    /// When provided, enables icon helpers (SF Symbols) and uses this as the background when rendering icons.
    var iconBackgroundColor: Color? = nil
    /// Forces the expected square icon format (rounded rectangle).
    var isIconFormat: Bool = false

    var body: some View {
        UnifiedImagePickerView(
            photoData: $photoData,
            imagename: imagename,
            showsIncludeToggle: true,
            iconBackgroundColor: iconBackgroundColor,
            isIconFormat: isIconFormat
        )
    }
}

// MARK: - Unified image picker (Photos / Files / URL / Image Playground)

struct UnifiedImagePickerView: View {
    @Binding var photoData: Data?

    var imagename: String = ""
    var showsIncludeToggle: Bool = true
    var iconBackgroundColor: Color? = nil
    var isIconFormat: Bool = false

    @AppStorage("selectedQuality") private var selectedQuality: JPEGQuality = .lowest

    @State private var photoSelected: PhotosPickerItem?

    @State private var showFileImporter = false
    @State private var showURLSheet = false
    @State private var urlString = ""
    @State private var isDownloading = false
    @State private var downloadError: String?

    @State private var webSearchQuery = ""
    @State private var webSearchResults: [WebImageResult] = []
    @State private var isSearchingWeb = false
    @State private var downloadingWebImageURL: URL?
    @State private var webImageGridSlider: Double = 0.5

    @State private var showSFSymbolSheet = false
    @State private var sfSymbolName = ""
    @State private var sfSymbolError: String?

    @State private var showBrandIconsSheet = false
    @State private var brandQuery = ""
    @State private var brandResults: [String] = []
    @State private var isSearchingBrands = false
    @State private var applyingBrandIcon: String?
    @State private var brandError: String?
    @State private var brandGridDensity: Double = 0.5

    @State private var showCropSheet = false

    @State private var showImagePlayground = false
    @State private var playgroundPrompt = ""

    var body: some View {
        imageSection
        qualitySection
            .onAppear {
                if playgroundPrompt.isEmpty { playgroundPrompt = imagename }
            }
    }

    private var imageSection: some View {
        Section {
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    if isIconFormat {
                        ServiceIconView(photoData: photoData, backgroundColor: iconBackgroundColor, cornerRadius: 22)
                            .frame(width: 180, height: 180)
                    } else {
                        ImageView(photoData: photoData, placeHolder: true, imagename: imagename)
                            .frame(height: 250)
                    }
                    Spacer()
                }

                imageActionButtons

                if isDownloading {
                    PickerLoadingView(message: "Downloading image")
                }

                if let downloadError {
                    Text(downloadError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            handleFileImportResult(result)
        }
        .sheet(isPresented: $showURLSheet) {
            urlInputSheet
        }
        .sheet(isPresented: $showSFSymbolSheet) {
            sfSymbolSheet
        }
        .sheet(isPresented: $showBrandIconsSheet) {
            brandIconsSheet
        }
        .sheet(isPresented: $showCropSheet) {
            cropSheet
        }
        #if canImport(ImagePlayground)
        .imagePlaygroundSheet(
            isPresented: $showImagePlayground,
            concept: playgroundPrompt.isEmpty ? "image" : playgroundPrompt,
            sourceImage: nil,
            onCompletion: { url in
                Task { await loadFromFileURL(url) }
            },
            onCancellation: nil
        )
        #endif
        .task(id: photoSelected) {
            await loadFromPhotosPicker()
        }
    }

    @ViewBuilder
    private var imageActionButtons: some View {
        let primaryTitleKey = photoData == nil ? "Add" : "Edit"
        let primaryTitle = paddedLocalizedActionTitle(primaryTitleKey, matching: "Remove")
        let removeTitle = paddedLocalizedActionTitle("Remove", matching: primaryTitleKey)

        #if os(iOS) || os(visionOS)
        VStack(spacing: 10) {
            imagePrimaryActionButton(primaryTitleKey: primaryTitleKey, primaryTitle: primaryTitle)
            imageRemoveButton(removeTitle: removeTitle)
        }
        .frame(maxWidth: .infinity)
        #else
        HStack {
            imagePrimaryActionButton(primaryTitleKey: primaryTitleKey, primaryTitle: primaryTitle)
            imageRemoveButton(removeTitle: removeTitle)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        #endif
    }

    private func imagePrimaryActionButton(primaryTitleKey: String, primaryTitle: String) -> some View {
        Menu {
            PhotosPicker(selection: $photoSelected, matching: .images, photoLibrary: .shared()) {
                Label("Photo Library", systemImage: "photo.on.rectangle")
            }

            Button {
                showFileImporter = true
            } label: {
                Label("Files", systemImage: "folder")
            }

            Button {
                urlString = ""
                downloadError = nil
                showURLSheet = true
            } label: {
                Label("Internet", systemImage: "link")
            }

            if isIconFormat {
                Button {
                    if sfSymbolName.isEmpty { sfSymbolName = "icloud" }
                    sfSymbolError = nil
                    showSFSymbolSheet = true
                } label: {
                    Label("SF Symbol", systemImage: "square.stack.3d.up")
                }

                Button {
                    if brandQuery.isEmpty { brandQuery = imagename }
                    showBrandIconsSheet = true
                } label: {
                    Label("Brands", systemImage: "building.2.crop.circle")
                }
            }

            #if canImport(ImagePlayground)
            Button {
                if playgroundPrompt.isEmpty { playgroundPrompt = imagename }
                showImagePlayground = true
            } label: {
                Label("Generate", systemImage: "sparkles")
            }
            #endif

            if isIconFormat, photoData != nil {
                Button {
                    showCropSheet = true
                } label: {
                    Label("Crop", systemImage: "crop")
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: photoData == nil ? "plus.circle.fill" : AppIcons.edit)
                    .imageScale(.medium)
                Text(primaryTitle)
            }
            .appToolbarLabel()
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.accentColor)
        #if os(iOS) || os(visionOS)
        .frame(maxWidth: .infinity)
        #else
        .fixedSize(horizontal: true, vertical: false)
        #endif
        .accessibilityLabel(Text(String(localized: String.LocalizationValue(primaryTitleKey))))
    }

    private func imageRemoveButton(removeTitle: String) -> some View {
        Button(role: .destructive) {
            photoData = nil
            photoSelected = nil
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .imageScale(.medium)
                Text(removeTitle)
            }
            .appToolbarLabel()
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .tint(.red)
        #if os(iOS) || os(visionOS)
        .frame(maxWidth: .infinity)
        #else
        .fixedSize(horizontal: true, vertical: false)
        #endif
        .disabled(photoData == nil)
        .accessibilityLabel(Text(String(localized: "Remove")))
    }

    private func paddedLocalizedActionTitle(_ titleKey: String, matching otherTitleKey: String) -> String {
        let title = String(localized: String.LocalizationValue(titleKey))
        let otherTitle = String(localized: String.LocalizationValue(otherTitleKey))
        let paddingCount = max(0, otherTitle.count - title.count)
        guard paddingCount > 0 else { return title }
        return title + String(repeating: "\u{00A0}", count: paddingCount)
    }

    private var qualitySection: some View {
        Section {
            Picker("Quality", selection: $selectedQuality) {
                ForEach(JPEGQuality.allCases) { quality in
                    Text(quality.description).tag(quality)
                }
            }

            Text(photoData?.count.formatted(.byteCount(style: .memory)) ?? "0 MB")
                .foregroundStyle(.secondary)
        }
        .task(id: selectedQuality) {
            await reencodeSelectedIfNeeded()
        }
    }

    private var sfSymbolSheet: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("SF Symbol name (e.g. icloud)", text: $sfSymbolName)
                    .textFieldStyle(.roundedBorder)
                    #if os(iOS) || os(visionOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .onChange(of: sfSymbolName) { _, _ in
                        sfSymbolError = nil
                    }

                VStack(spacing: 12) {
                    let bg = iconBackgroundColor ?? Color.accentColor
                    let iconStyle = contrastingStyle(for: bg)
                    let trimmedName = sfSymbolName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let previewName = sfSymbolExists(trimmedName) ? trimmedName : "questionmark"

                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(bg)
                            .frame(width: 180, height: 180)

                        Image(systemName: previewName)
                            .font(.system(size: 74, weight: .semibold, design: .rounded))
                            .foregroundStyle(iconStyle)
                            .padding(.horizontal, 25)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )

                    if let sfSymbolError {
                        Text(sfSymbolError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    } else if !trimmedName.isEmpty && !sfSymbolExists(trimmedName) {
                        Text("Symbol not found")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .navigationTitle("SF Symbols")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showSFSymbolSheet = false }
                        .appSheetCancelButtonStyle()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Use") {
                        Task { await applySFSymbolIcon() }
                    }
                    .disabled(!sfSymbolExists(sfSymbolName.trimmingCharacters(in: .whitespacesAndNewlines)))
                    .appSheetPrimaryButtonStyle()
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .presentationDetents([.medium])
        #elseif os(macOS)
        .macOSFixedSheet(width: 520, height: 480)
        #endif
    }

    private var brandIconsSheet: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    TextField("Search brands (e.g. netflix, spotify, bbva)", text: $brandQuery)
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS) || os(visionOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .onSubmit { Task { await searchBrandIcons() } }

                    Button {
                        Task { await searchBrandIcons() }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .disabled(brandQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSearchingBrands || applyingBrandIcon != nil)
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if isSearchingBrands {
                    PickerLoadingView(message: "Loading icons")
                }

                if let brandError {
                    Text(brandError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                }
                
                AdaptiveGridDensitySlider(density: $brandGridDensity)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)

                ScrollView {
                    let bg = iconBackgroundColor ?? Color.accentColor
                    let iconHex = contrastingHexString(for: bg)
                    AdaptiveGrid(density: brandGridDensity, minCell: 140, maxCell: 240) { cellWidth, columns in
                        if !isSearchingBrands && brandResults.isEmpty {
                            PickerEmptyStateView(
                                title: brandQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Search for a brand" : "No icons found",
                                message: brandQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Use the search field to find a service icon." : "Try another brand name or use an SF Symbol."
                            )
                            .padding(.vertical, 24)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(brandResults, id: \.self) { icon in
                                    Button {
                                        Task { await applyBrandIcon(icon) }
                                    } label: {
                                        BrandIconPickerCell(
                                            icon: icon,
                                            backgroundColor: bg,
                                            tintHex: iconHex,
                                            isApplying: applyingBrandIcon == icon
                                        )
                                    }
                                    .disabled(applyingBrandIcon != nil)
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 18)
                            .animation(.easeInOut(duration: 0.22), value: brandGridDensity)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Brand Icons")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showBrandIconsSheet = false }
                        .appSheetCancelButtonStyle()
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .presentationDetents([.large])
        #elseif os(macOS)
        .macOSFixedSheet(width: 820, height: 700)
        #endif
    }

    private var cropSheet: some View {
        NavigationStack {
            IconCropperView(
                photoData: $photoData,
                backgroundColor: iconBackgroundColor ?? .accentColor,
                cornerRadius: 22
            )
            .navigationTitle("Crop")
        }
        #if os(iOS) || os(visionOS)
        .presentationDetents([.large])
        #elseif os(macOS)
        .macOSFixedSheet(width: 560, height: 520)
        #endif
    }

    private var urlInputSheet: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    TextField("Search images", text: $webSearchQuery)
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS) || os(visionOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .onSubmit { Task { await searchWebImages() } }

                    Button {
                        Task { await searchWebImages() }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .disabled(webSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSearchingWeb || isDownloading)
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if isSearchingWeb {
                    PickerLoadingView(message: "Loading images")
                }

                if isDownloading {
                    PickerLoadingView(message: "Downloading image")
                }

                if let downloadError {
                    Text(downloadError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                }

                AdaptiveGridDensitySlider(density: $webImageGridSlider)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)

                ScrollView {
                    AdaptiveGrid(density: webImageGridSlider) { cellWidth, columns in
                        if !isSearchingWeb && webSearchResults.isEmpty && downloadError == nil {
                            PickerEmptyStateView(
                                title: webSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Search for images" : "No images found",
                                message: webSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Use the search field to find an image." : "Try another search term."
                            )
                            .padding(.vertical, 24)
                        } else {
                            LazyVGrid(columns: columns, spacing: 18) {
                                ForEach(webSearchResults) { result in
                                    Button {
                                        Task { await downloadFromURL(result.fullImageURL) }
                                    } label: {
                                        WebImagePickerCell(
                                            result: result,
                                            isDownloading: downloadingWebImageURL == result.fullImageURL,
                                            cellSize: cellWidth
                                        )
                                    }
                                    .disabled(isDownloading)
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 18)
                            .animation(.easeInOut(duration: 0.22), value: webImageGridSlider)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Web Images")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showURLSheet = false }
                        .appSheetCancelButtonStyle()
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .presentationDetents([.medium])
        #elseif os(macOS)
        .macOSFixedSheet(width: 860, height: 720)
        #endif
    }

    @MainActor
    private func loadFromPhotosPicker() async {
        guard let photoSelected else { return }
        guard let data = try? await photoSelected.loadTransferable(type: Data.self) else { return }

        if selectedQuality == .original {
            photoData = data
        } else {
            photoData = reencodeImageData(data)
        }
    }

    @MainActor
    private func reencodeSelectedIfNeeded() async {
        guard selectedQuality != .original else { return }
        guard let data = photoData, !data.isEmpty else { return }
        photoData = reencodeImageData(data)
    }

    private func handleFileImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            Task { await loadFromFileURL(url) }
        case .failure(let error):
            downloadError = error.localizedDescription
        }
    }

    @MainActor
    private func loadFromFileURL(_ url: URL) async {
        downloadError = nil

        #if os(macOS)
        let needsSecurity = url.startAccessingSecurityScopedResource()
        defer { if needsSecurity { url.stopAccessingSecurityScopedResource() } }
        #endif

        do {
            let data = try Data(contentsOf: url)
            if selectedQuality == .original {
                photoData = data
            } else {
                photoData = reencodeImageData(data)
            }
        } catch {
            downloadError = error.localizedDescription
        }
    }

    @MainActor
    private func downloadFromURLString() async {
        downloadError = nil
        isDownloading = true
        defer { isDownloading = false }

        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed) else {
            downloadError = "Invalid URL"
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                downloadError = "Download failed (\(http.statusCode))"
                return
            }
            if selectedQuality == .original {
                photoData = data
            } else {
                photoData = reencodeImageData(data)
            }
            showURLSheet = false
        } catch {
            downloadError = error.localizedDescription
        }
    }

    @MainActor
    private func downloadFromURL(_ url: URL) async {
        downloadError = nil
        downloadingWebImageURL = url
        isDownloading = true
        defer {
            isDownloading = false
            downloadingWebImageURL = nil
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                downloadError = "Download failed (\(http.statusCode))"
                return
            }
            if selectedQuality == .original {
                photoData = data
            } else {
                photoData = reencodeImageData(data)
            }
            showURLSheet = false
        } catch {
            downloadError = error.localizedDescription
        }
    }

    private func reencodeImageData(_ data: Data) -> Data? {
        #if os(macOS)
        if let image = NSImage(data: data) {
            if image.hasAlpha, let pngData = image.pngData() {
                return pngData
            }
            return image.jpegData(quality: selectedQuality)
        }
        #else
        if let image = UIImage(data: data) {
            if image.hasAlpha, let pngData = image.pngData() {
                return pngData
            }
            return image.jpegData(quality: selectedQuality)
        }
        #endif
        return data
    }

    @MainActor
    private func applySFSymbolIcon() async {
        let name = sfSymbolName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        guard sfSymbolExists(name) else {
            sfSymbolError = "Symbol not found"
            return
        }
        downloadError = nil

        let bg = iconBackgroundColor ?? .accentColor
        let iconStyle = contrastingStyle(for: bg)
        let size: CGFloat = 512
        let cornerRadius: CGFloat = 110

        let view = ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(bg)
            Image(systemName: name)
                .font(.system(size: 210, weight: .semibold, design: .rounded))
                .foregroundStyle(iconStyle)
                .padding(.horizontal, 72)
        }
        .frame(width: size, height: size)

        if let rendered = renderPNG(from: view, size: CGSize(width: size, height: size)) {
            photoData = rendered
            showSFSymbolSheet = false
        } else {
            downloadError = "Couldn't render icon."
        }
    }

    @MainActor
    private func searchBrandIcons() async {
        let q = brandQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        brandError = nil
        brandResults = []
        isSearchingBrands = true
        defer { isSearchingBrands = false }

        do {
            brandResults = try await iconifySearch(query: q, prefix: "simple-icons", limit: 64)
        } catch {
            brandError = userFacingErrorMessage(for: error)
        }
    }

    @MainActor
    private func applyBrandIcon(_ icon: String) async {
        let bg = iconBackgroundColor ?? .accentColor
        applyingBrandIcon = icon
        defer { applyingBrandIcon = nil }

        do {
            let png = try await IconifyRasterizer.rasterizePNG(
                icon: icon,
                backgroundColorHex: hexString(for: bg),
                iconColorHex: contrastingHexString(for: bg),
                size: 512
            )
            photoData = png
            showBrandIconsSheet = false
        } catch {
            brandError = userFacingErrorMessage(for: error)
        }
    }
}

private struct WebImageResult: Identifiable, Decodable {
    let id: Int
    let title: String
    let thumbnailURL: URL?
    let fullImageURL: URL

    init(id: Int, title: String, thumbnailURL: URL?, fullImageURL: URL) {
        self.id = id
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.fullImageURL = fullImageURL
    }
}

private extension UnifiedImagePickerView {
    @MainActor
    func searchWebImages() async {
        let q = webSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        downloadError = nil
        webSearchResults = []
        isSearchingWeb = true
        defer { isSearchingWeb = false }

        do {
            // Prefer Openverse (usually better results), but fall back to Wikimedia if the host is unreachable.
            do {
                webSearchResults = try await searchOpenverseImages(query: q)
            } catch {
                webSearchResults = try await searchWikimediaImages(query: q)
            }
        } catch {
            downloadError = userFacingErrorMessage(for: error)
        }
    }

    func userFacingErrorMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection."
            case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                return "Couldn't reach the image server."
            case .timedOut:
                return "Request timed out. Please try again."
            default:
                return "Couldn't load images. Please try again."
            }
        }
        if error is DecodingError {
            return "Couldn't read image search results."
        }
        return "Couldn't load images. Please try again."
    }

    func searchOpenverseImages(query: String) async throws -> [WebImageResult] {
        var comps = URLComponents(string: "https://api.openverse.engineering/v1/images/")!
        comps.queryItems = [
            .init(name: "q", value: query),
            .init(name: "page_size", value: "60")
        ]
        guard let url = comps.url else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(OpenverseImageResponse.self, from: data)
        return decoded.results.compactMap { item in
            guard let fullURL = URL(string: item.url) else { return nil }
            let thumbURL = URL(string: item.thumbnail)
            return WebImageResult(id: item.id, title: item.title, thumbnailURL: thumbURL, fullImageURL: fullURL)
        }
    }

    func searchWikimediaImages(query: String) async throws -> [WebImageResult] {
        var comps = URLComponents(string: "https://commons.wikimedia.org/w/api.php")!
        comps.queryItems = [
            .init(name: "action", value: "query"),
            .init(name: "format", value: "json"),
            .init(name: "generator", value: "search"),
            .init(name: "gsrsearch", value: query),
            .init(name: "gsrlimit", value: "60"),
            .init(name: "gsrnamespace", value: "6"), // File:
            .init(name: "prop", value: "imageinfo"),
            .init(name: "iiprop", value: "url"),
            .init(name: "iiurlwidth", value: "256")
        ]
        guard let url = comps.url else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(WikimediaAPIResponse.self, from: data)
        let pages = Array(decoded.query?.pages.values ?? [:].values)
        return pages.compactMap { page in
            guard let info = page.imageinfo?.first,
                  let full = info.url,
                  let fullURL = URL(string: full) else { return nil }
            let thumbURL = info.thumburl.flatMap(URL.init(string:))
            return WebImageResult(id: page.pageid, title: page.title, thumbnailURL: thumbURL, fullImageURL: fullURL)
        }
    }

    func iconifySearch(query: String, prefix: String, limit: Int) async throws -> [String] {
        var comps = URLComponents(string: "https://api.iconify.design/search")!
        comps.queryItems = [
            .init(name: "query", value: query),
            .init(name: "prefix", value: prefix),
            .init(name: "limit", value: String(max(32, min(limit, 999))))
        ]
        guard let url = comps.url else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(IconifySearchResponse.self, from: data)
        return decoded.icons
    }
}

private struct IconifySearchResponse: Decodable {
    let icons: [String]
}

private struct PickerLoadingView: View {
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

private struct PickerEmptyStateView: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: 10) {
            Image(.pig)
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
                .opacity(0.85)

            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }
}

private struct BrandIconPickerCell: View {
    let icon: String
    let backgroundColor: Color
    let tintHex: String
    let isApplying: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )

            IconifyIconPreview(
                icon: icon,
                tintHex: tintHex,
                size: 72
            )
            .padding(.horizontal, 18)
            .padding(.vertical, 12)

            if isApplying {
                CellLoadingOverlay(message: "Applying")
            }
        }
        .aspectRatio(1.15, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct WebImagePickerCell: View {
    let result: WebImageResult
    let isDownloading: Bool
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.secondary.opacity(0.08))

            AsyncImage(url: result.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    CellLoadingOverlay(message: "Loading")
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                case .failure:
                    VStack(spacing: 6) {
                        Image(systemName: "photo")
                            .font(.title3)
                        Text("Image unavailable")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: cellSize, height: cellSize * 0.78)
            .clipped()

            if isDownloading {
                CellLoadingOverlay(message: "Downloading")
            }
        }
        .frame(width: cellSize, height: cellSize * 0.78)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct CellLoadingOverlay: View {
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: 6) {
            ProgressView()
            Text(message)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

// MARK: - Iconify preview + rasterizer

private struct IconifyIconPreview: View {
    let icon: String
    let tintHex: String
    let size: Int
    @State private var isLoading = true

    var body: some View {
        ZStack {
            IconifyWebView(html: IconifyHTML.iconHTML(icon: icon, iconColorHex: tintHex, size: size))
                .allowsHitTesting(false)
                .background(Color.clear)

            if isLoading {
                ProgressView()
            }
        }
        .task(id: icon) {
            isLoading = true
            try? await Task.sleep(for: .milliseconds(700))
            isLoading = false
        }
    }
}

private enum IconifyHTML {
    static func iconHTML(icon: String, iconColorHex: String, size: Int) -> String {
        // Iconify API path uses "prefix/name.svg" format.
        let parts = icon.split(separator: ":", maxSplits: 1).map(String.init)
        let prefix = parts.first ?? "simple-icons"
        let name = parts.count > 1 ? parts[1] : ""
        let svgURL = "https://api.iconify.design/\(prefix)/\(name).svg?color=%23\(iconColorHex)&width=\(size)&height=\(size)"

        return """
        <!doctype html>
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              html, body { margin: 0; padding: 0; background: transparent; width: 100%; height: 100%; }
              body { display: flex; align-items: center; justify-content: center; }
              img { width: 100%; height: 100%; object-fit: contain; }
            </style>
          </head>
          <body>
            <img src="\(svgURL)" />
          </body>
        </html>
        """
    }

    static func rasterHTML(icon: String, backgroundColorHex: String, iconColorHex: String, size: Int) -> String {
        let parts = icon.split(separator: ":", maxSplits: 1).map(String.init)
        let prefix = parts.first ?? "simple-icons"
        let name = parts.count > 1 ? parts[1] : ""
        let svgSize = Int(Double(size) * 0.58)
        let svgURL = "https://api.iconify.design/\(prefix)/\(name).svg?color=%23\(iconColorHex)&width=\(svgSize)&height=\(svgSize)"
        return """
        <!doctype html>
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              html, body { margin: 0; padding: 0; width: \(size)px; height: \(size)px; background: #\(backgroundColorHex); }
              body { display: flex; align-items: center; justify-content: center; }
              img { width: \(svgSize)px; height: \(svgSize)px; object-fit: contain; }
            </style>
          </head>
          <body>
            <img src="\(svgURL)" />
          </body>
        </html>
        """
    }
}

private struct IconifyWebView: View {
    let html: String
    var body: some View {
        _IconifyWebView(html: html)
    }
}

#if os(macOS)
private struct _IconifyWebView: NSViewRepresentable {
    let html: String
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.setValue(false, forKey: "drawsBackground")
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(html, baseURL: nil)
    }
}
#else
private struct _IconifyWebView: UIViewRepresentable {
    let html: String
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)
    }
}
#endif

@MainActor
private enum IconifyRasterizer {
    static func rasterizePNG(icon: String, backgroundColorHex: String, iconColorHex: String, size: Int) async throws -> Data {
        let html = IconifyHTML.rasterHTML(
            icon: icon,
            backgroundColorHex: backgroundColorHex,
            iconColorHex: iconColorHex,
            size: size
        )

        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        #if os(iOS) || os(visionOS)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        #else
        webView.setValue(false, forKey: "drawsBackground")
        #endif

        let delegate = NavigationFinishDelegate()
        webView.navigationDelegate = delegate
        webView.loadHTMLString(html, baseURL: nil)
        try await delegate.wait()

        let config = WKSnapshotConfiguration()
        config.rect = CGRect(x: 0, y: 0, width: size, height: size)

        return try await withCheckedThrowingContinuation { cont in
            webView.takeSnapshot(with: config) { image, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                #if os(macOS)
                guard let image else { cont.resume(throwing: URLError(.cannotDecodeContentData)); return }
                guard let tiff = image.tiffRepresentation,
                      let rep = NSBitmapImageRep(data: tiff),
                      let png = rep.representation(using: .png, properties: [:]) else {
                    cont.resume(throwing: URLError(.cannotDecodeContentData))
                    return
                }
                cont.resume(returning: png)
                #else
                guard let png = image?.pngData() else {
                    cont.resume(throwing: URLError(.cannotDecodeContentData))
                    return
                }
                cont.resume(returning: png)
                #endif
            }
        }
    }
}

@MainActor
private final class NavigationFinishDelegate: NSObject, WKNavigationDelegate {
    private var continuation: CheckedContinuation<Void, Error>?

    func wait() async throws {
        try await withCheckedThrowingContinuation { cont in
            continuation = cont
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        continuation?.resume(returning: ())
        continuation = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

private func hexString(for color: Color) -> String {
    let components = rgbComponents(for: color)
    return String(format: "%02X%02X%02X", components.r, components.g, components.b)
}

private func contrastingHexString(for color: Color) -> String {
    relativeLuminance(for: color) > 0.55 ? "111111" : "FFFFFF"
}

private func contrastingStyle(for color: Color) -> Color {
    relativeLuminance(for: color) > 0.55 ? .black : .white
}

private func relativeLuminance(for color: Color) -> Double {
    let components = rgbComponents(for: color)
    let r = Double(components.r) / 255
    let g = Double(components.g) / 255
    let b = Double(components.b) / 255
    return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
}

private func rgbComponents(for color: Color) -> (r: Int, g: Int, b: Int) {
    #if os(macOS)
    let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? .black
    let r = Int(round(nsColor.redComponent * 255))
    let g = Int(round(nsColor.greenComponent * 255))
    let b = Int(round(nsColor.blueComponent * 255))
    #else
    let uiColor = UIColor(color)
    var rr: CGFloat = 0
    var gg: CGFloat = 0
    var bb: CGFloat = 0
    var aa: CGFloat = 0
    uiColor.getRed(&rr, green: &gg, blue: &bb, alpha: &aa)
    let r = Int(round(rr * 255))
    let g = Int(round(gg * 255))
    let b = Int(round(bb * 255))
    #endif
    return (r, g, b)
}

private func sfSymbolExists(_ name: String) -> Bool {
    guard !name.isEmpty else { return false }
    #if os(macOS)
    return NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil
    #else
    return UIImage(systemName: name) != nil
    #endif
}

private struct OpenverseImageResponse: Decodable {
    let results: [OpenverseImageItem]
}

private struct OpenverseImageItem: Decodable {
    let id: Int
    let title: String
    let url: String
    let thumbnail: String
}

private struct WikimediaAPIResponse: Decodable {
    let query: Query?
    struct Query: Decodable {
        let pages: [String: Page]
    }
    struct Page: Decodable {
        let pageid: Int
        let title: String
        let imageinfo: [ImageInfo]?
    }
    struct ImageInfo: Decodable {
        let url: String?
        let thumburl: String?
    }
}

#Preview {
    ImagePickerView(photoData: .constant(nil))
        .frame(width: 200, height: 200)
}

// MARK: - Icon Cropper (square w/ rounded corners)

private struct IconCropperView: View {
    private let previewSize: CGFloat = 260
    private let outputSize: CGFloat = 512

    @Binding var photoData: Data?
    let backgroundColor: Color
    let cornerRadius: CGFloat

    @Environment(\.dismiss) private var dismiss

    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor.opacity(0.18))

                if let photoData, let image = platformImage(from: photoData) {
                    GeometryReader { proxy in
                        iconImage(image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .scaleEffect(currentScale * finalScale)
                            .offset(
                                x: currentOffset.width + finalOffset.width,
                                y: currentOffset.height + finalOffset.height
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in currentScale = value }
                                    .onEnded { _ in
                                        finalScale *= currentScale
                                        currentScale = 1.0
                                    }
                                    .simultaneously(with:
                                        DragGesture()
                                            .onChanged { value in currentOffset = value.translation }
                                            .onEnded { value in
                                                finalOffset.width += value.translation.width
                                                finalOffset.height += value.translation.height
                                                currentOffset = .zero
                                            }
                                    )
                            )
                    }
                    .contentShape(Rectangle())
                } else {
                    Text("No image")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: previewSize, height: previewSize)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )

        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .appSheetCancelButtonStyle()
            }

            ToolbarItem(placement: .automatic) {
                Button("Reset") {
                    resetCrop()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    applyCrop()
                }
                .disabled(photoData == nil)
                .appSheetPrimaryButtonStyle()
            }
        }
    }

    private func resetCrop() {
        currentScale = 1.0
        finalScale = 1.0
        currentOffset = .zero
        finalOffset = .zero
    }

    private func applyCrop() {
        guard let photoData, let image = platformImage(from: photoData) else { return }

        let outputScale = outputSize / previewSize
        let view = ZStack {
            RoundedRectangle(cornerRadius: cornerRadius * outputScale, style: .continuous)
                .fill(backgroundColor.opacity(0.18))
            iconImage(image)
                .resizable()
                .scaledToFit()
                .frame(width: outputSize, height: outputSize)
                .scaleEffect(currentScale * finalScale)
                .offset(
                    x: (currentOffset.width + finalOffset.width) * outputScale,
                    y: (currentOffset.height + finalOffset.height) * outputScale
                )
        }
        .frame(width: outputSize, height: outputSize)

        Task { @MainActor in
            if let rendered = renderPNG(from: view, size: CGSize(width: outputSize, height: outputSize)) {
                self.photoData = rendered
                dismiss()
            }
        }
    }

    @ViewBuilder
    private func iconImage(_ image: PlatformImage) -> Image {
        #if os(macOS)
        Image(nsImage: image)
        #else
        Image(uiImage: image)
        #endif
    }
}

@MainActor
private func renderPNG<V: View>(from view: V, size: CGSize) -> Data? {
    let renderer = ImageRenderer(content: view)
    renderer.proposedSize = ProposedViewSize(size)
    renderer.scale = 2

    #if os(macOS)
    guard let nsImage = renderer.nsImage else { return nil }
    guard let tiff = nsImage.tiffRepresentation else { return nil }
    guard let rep = NSBitmapImageRep(data: tiff) else { return nil }
    return rep.representation(using: .png, properties: [:])
    #else
    return renderer.uiImage?.pngData()
    #endif
}

private func platformImage(from data: Data) -> PlatformImage? {
    #if os(macOS)
    return NSImage(data: data)
    #else
    return UIImage(data: data)
    #endif
}

#if os(macOS)
private typealias PlatformImage = NSImage

private extension NSImage {
    var hasAlpha: Bool {
        representations.contains { $0.hasAlpha }
    }

    func pngData() -> Data? {
        guard let tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmapImage.representation(using: .png, properties: [:])
    }
}
#else
private typealias PlatformImage = UIImage

private extension UIImage {
    var hasAlpha: Bool {
        guard let alphaInfo = cgImage?.alphaInfo else { return false }
        switch alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return true
        default:
            return false
        }
    }
}
#endif
