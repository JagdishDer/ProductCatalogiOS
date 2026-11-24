# Product Catalog — iOS (SwiftUI)

A minimal native iOS product-catalog app built with SwiftUI, `URLSession`, `Codable`, and Swift `async/await`. It uses the public [DummyJSON](https://dummyjson.com/) API.

> **Assessment disclosure:** The Task 2 brief explicitly prohibits AI tools. The source files in this bundle were produced with AI assistance. Therefore, this bundle **must not be described as unaided work** and does **not comply with Task 2's no-AI rule** if submitted as-is. Use it only where disclosure and assistance are permitted.

## Features

- Login through `POST /auth/login`, with loading and error states
- Product list from `GET /products?limit=30&skip=0`, showing thumbnail, title, and category
- Swipe left on a product to request `DELETE /products/{id}`; remove the row only after the API confirms deletion
- Product details fetched separately via `GET /products/{id}` when the row is opened
- Loading, network error, retry, and empty states
- List remains consistent with simulated DummyJSON deletes during pull-to-refresh
- Simple separation of models, networking, view models, and SwiftUI views

## Requirements

- macOS with Xcode and an iOS Simulator
- Minimum deployment target: **iOS 16.0**
- Swift 5 language mode (compatible with modern Xcode toolchains)
- No external Swift packages

## Setup — Option A: Open as an XcodeGen project

The bundle contains `project.yml`. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) if necessary:

```bash
brew install xcodegen
cd iOS_ProductCatalog_Task2
xcodegen generate
open ProductCatalogSwift.xcodeproj
```

Then select the `ProductCatalogSwift` scheme and an iPhone simulator. Press **Cmd+R**.

If the bundle is extracted under another directory name, `cd` to that directory instead.

## Setup — Option B: Regular Xcode project (no XcodeGen)

1. In Xcode choose **File → New → Project → iOS → App**.
2. Name it `ProductCatalogSwift`, use **SwiftUI** as the interface and **Swift** as the language.
3. Set the deployment target to **iOS 16.0** or higher.
4. Remove the template's `ContentView.swift` and `...App.swift` from the new target (avoid duplicate `@main`).
5. Add all `.swift` files from the bundled `ProductCatalogSwift` directory; select **Copy items if needed** and check the app target in **Target Membership**.
6. Select a simulator and press **Cmd+R**.

If installing on a real device, set your signing team and an available bundle identifier in **Signing & Capabilities**.

## Demo credentials

- Username: `emilys`
- Password: `emilyspass`

These are public test credentials from DummyJSON documentation. The app does not store the password.

## Project structure

```
ProductCatalogSwift/
├── ProductCatalogSwiftApp.swift
├── Models/
│   ├── AuthModels.swift
│   └── Product.swift
├── Networking/
│   └── DummyJSONClient.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   └── ProductListViewModel.swift
└── Views/
    ├── LoginView.swift
    ├── ProductListView.swift
    └── ProductDetailView.swift
project.yml
README.md
```

## Networking and architecture

- `DummyJSONClient` is a small API client wrapping `URLSession.shared.data(for:)`, checking HTTP statuses, and decoding JSON with `Codable`.
- `AuthViewModel` handles input validation and login state.
- `ProductListViewModel` maintains remote products, deletion progress, and IDs deleted during the current session. It doesn't remove a row unless the delete response confirms `isDeleted`.
- `ProductDetailView` triggers its own request by product ID and has loading/error/retry states.
- All view models are `@MainActor` to keep SwiftUI state updates on the main actor.
- `NavigationStack` and `NavigationLink` handle detail navigation.

## API endpoints

| Purpose | Request |
|---|---|
| Login | `POST https://dummyjson.com/auth/login` |
| Products | `GET https://dummyjson.com/products?limit=30&skip=0` |
| Detail | `GET https://dummyjson.com/products/{id}` |
| Delete | `DELETE https://dummyjson.com/products/{id}` |

The access token is passed as a Bearer token on product requests. DummyJSON writes are simulated and do not persist on the server.

## How to verify

1. Build and launch on an iPhone simulator.
2. Enter an incorrect password: confirm a visible error appears and the app stays on login.
3. Sign in using `emilys / emilyspass`: confirm a loading indicator followed by a product list.
4. Confirm product rows show a thumbnail, title, and category.
5. Tap a row: verify the detail screen fetches the product by ID and shows title, image, category, description, and price.
6. Swipe left and press Delete: confirm the row disappears after API success.
7. Pull down to refresh: confirm the deleted row stays hidden during this session.
8. Disable simulator networking and try a request: confirm an error and retry path.
9. Log out and sign in again: session-only deletion state resets.

## Scope decisions and limitations

- No add/edit, filtering, camera, image annotation, or zoom. These are intentionally out of scope for iOS Task 2.
- Only the first 30 products are shown; pagination is not required for Task 2.
- Access token is kept **in memory**; the user logs in again after restarting the app. Persistent Keychain storage was not requested in Task 2.
- Images are loaded with SwiftUI `AsyncImage` and not manually cached.
- No unit tests are included; the assessment requires extensive tests neither here nor for this minimal task.
- SwiftUI code has **not been built with Xcode** in the generation environment. The Foundation-only networking and model files were type-checked with Swift 6.2 on Linux; you must confirm the real iOS build and tests on your Mac.
- No actual Xcode or simulator test results are asserted in this README.

## What to do next

- Add Keychain token persistence, refresh-token support and expiry handling.
- Add product pagination and more test coverage.
- Add a reusable image loader and comprehensive accessibility labels.

## Reference docs

- https://dummyjson.com/docs/auth
- https://dummyjson.com/docs/products
- https://developer.apple.com/documentation/swiftui
- https://developer.apple.com/documentation/foundation/urlsession
