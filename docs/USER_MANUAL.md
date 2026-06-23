# Zytama Data — User Manual

**Version:** 1.2.0  
**Last Updated:** June 2026  
**Platform:** Android & iOS

---

## Table of Contents

1. [Overview](#1-overview)
2. [Getting Started](#2-getting-started)
3. [Splash Screen](#3-splash-screen)
4. [Login](#4-login)
5. [Dashboard](#5-dashboard)
6. [Scanning a Barcode](#6-scanning-a-barcode)
7. [Capturing Product Images](#7-capturing-product-images)
8. [Reviewing & Submitting](#8-reviewing--submitting)
9. [All Scans](#9-all-scans)
10. [Notifications](#10-notifications)
11. [Offline Mode](#11-offline-mode)
12. [Logging Out](#12-logging-out)
13. [Privacy Policy](#13-privacy-policy)
14. [Troubleshooting](#14-troubleshooting)

---

## 1. Overview

Zytama Data is a mobile app designed for field agents to collect product data. The core workflow is simple:

1. **Scan** a product barcode
2. **Capture** 3 photos (product front, ingredients label, nutrition facts)
3. **Review** and **submit** the data to the Zytama backend

The app supports offline mode — if you're in an area without internet, your submissions are saved locally and automatically uploaded when connectivity is restored.

---

## 2. Getting Started

### Requirements
- Android 6.0+ or iOS 13.0+
- Camera permission (required for barcode scanning and photo capture)
- Internet connection (optional — the app works offline)

### Installation
Install the app via the link provided by your administrator. On first launch, you'll need your agent credentials (email and password) to log in.

---

## 3. Splash Screen

When you open the app, a splash screen appears with the Zytama logo while the app checks your login status.

- **If previously logged in:** You're taken directly to the Dashboard.
- **If not logged in:** You're redirected to the Login screen.

> [Screenshot: Splash screen showing Zytama logo centered on a branded background]

---

## 4. Login

### Screen Layout
The login screen features the Zytama logo at the top, a welcome message ("Hey, Welcome Back!"), and a white card containing the login form.

> [Screenshot: Login screen showing email field, password field, "Trust This Device" checkbox, and Login button]

### How to Log In

1. **Enter your email** in the Email field (e.g., `agent@zytama.com`).
2. **Enter your password** in the Password field (minimum 6 characters).
3. **Optionally check** "Trust This Device for 30 Days" to stay logged in.
4. **Tap the Login button** (teal button with arrow icon).

The button shows a loading spinner while authenticating. On success, you're taken to the Dashboard.

### Password Visibility
Tap the **lock icon** on the right side of the password field to toggle between hidden and visible password.

### Error Handling
If login fails (wrong credentials, network issue), an error dialog appears with a descriptive message. Tap **OK** and try again.

### Don't Have an Account?
Tap **"Contact Administrator"** at the bottom to see instructions. Agent accounts are created by your administrator — you cannot self-register in the app.

### Privacy Policy
Tap **"Privacy Policy"** at the bottom to view Zytama's privacy policy in an in-app browser.

> [Screenshot: Login error dialog showing an error message with OK button]

---

## 5. Dashboard

The Dashboard is the main hub of the app. It shows your activity summary and recent scans.

> [Screenshot: Full dashboard screen showing header, summary cards, New Scan button, and recent scans list]

### Header
- **Agent avatar** (circle with your initial) and **greeting** ("Hello, [Name]") on the left.
- **Logout button** (circle with logout icon) on the top right.

### Today Summary
Three summary cards showing:

| Card | Description |
|------|-------------|
| **Products Scanned** | Total number of products you've scanned |
| **Successfully Captured** | Number of successful uploads |
| **Offline Sync** | Number of products pending upload (saved offline) |

> [Screenshot: Three summary cards showing Products Scanned, Successfully Captured, and Offline Sync counts]

### New Scan Button
A large teal banner button with a scanner icon. Tap it to open the barcode scanner.

- When a scan or upload is in progress, the button changes to **"Processing…"** with a loading spinner and becomes disabled.

> [Screenshot: New Scan button in both idle and processing states]

### Recent Scans
A list showing your 5 most recent scans. Each card shows:
- **Product thumbnail** (or a placeholder icon if no image is available)
- **Product name** (or barcode number if name is not yet available)
- **Barcode number** and **time ago** (e.g., "5m ago", "2h ago")
- **Status badge** — color-coded:
  - 🟢 **Approved** (green)
  - 🟡 **Pending** (orange)
  - 🔴 **Rejected** (red)
  - ⚪ **Failed** (grey)
  - 🔵 **Captured** (blue)

Tap **"View All"** to see all scans with search and filters (see [Section 9](#9-all-scans)).

> [Screenshot: Recent scans list with multiple product cards showing different status badges]

### Checking Overlay
When a barcode is being verified against the server, a centered overlay appears with a spinner and the text "Checking product…" along with the barcode number.

> [Screenshot: Checking product overlay with spinner and barcode number]

---

## 6. Scanning a Barcode

The barcode scanner opens automatically when you enter the Dashboard, and can be reopened by tapping the **New Scan** button or the center barcode icon in the bottom navigation bar.

> [Screenshot: Barcode scanner screen with green scan frame and instruction text]

### How to Scan

1. **Point your camera** at the product's barcode.
2. **Align the barcode** within the green square frame in the center of the screen.
3. The app **detects the barcode automatically** — no need to tap a button.
4. A "Checking product…" overlay appears briefly.

### Scanner Controls
- **Flash toggle** (lightning icon) — in the top-right action bar, tap to turn the flashlight on/off for low-light scanning.
- **Camera flip** (camera switch icon) — tap to switch between front and rear camera.
- **Back button** — tap the back arrow to return to the Dashboard without scanning.

### Camera Permission
If camera permission hasn't been granted, a prompt appears with an "Open Settings" button to navigate to your device's app settings.

> [Screenshot: Camera permission denied view with "Open Settings" button]

### After Scanning

**If the product already exists** in the database:
- A dialog appears with "Already Exists" title, showing the product image (if available), a message, and the barcode.
- Tap **OK** to dismiss and scan another product.

> [Screenshot: "Already Exists" dialog with product image and barcode chip]

**If the product is new:**
- The image capture screen opens automatically (see next section).

---

## 7. Capturing Product Images

When a new product is detected, the app guides you through capturing 3 photos in sequence.

> [Screenshot: Multi-capture screen showing camera preview with step indicator at top]

### The 3 Steps

| Step | Label | What to Photograph |
|------|-------|--------------------|
| 1 | **Product Photo** | The front of the product packaging |
| 2 | **Ingredients Photo** | The ingredients list label |
| 3 | **Nutrition Photo** | The nutrition facts label |

### Guide Sheet
At each step, a bottom sheet slides up for 2 seconds showing:
- **Step number** and **label** (e.g., "Step 1 of 3 • Product Photo")
- **An icon** representing what to capture
- **Instruction text** (e.g., "Photograph the front of the product")
- **Progress bars** at the top showing which steps are completed
- An **"Open Camera"** button to dismiss the sheet early

The sheet auto-dismisses after 2 seconds, revealing the camera viewfinder.

> [Screenshot: Step guide bottom sheet for "Product Photo" step with progress bars]

### Taking a Photo
- The **current step** is shown at the top of the screen (e.g., "Step 1 of 3 • Product Photo").
- The **barcode** is displayed as a chip below the top bar.
- **Step indicator dots** show progress (active step is wider/brighter).
- Tap the **large white shutter button** at the bottom center to capture.
- A brief white flash confirms the photo was taken.
- The app automatically advances to the next step.

After all 3 photos are captured, the **Review Screen** opens.

### Cancelling Capture
Tap the **X button** (top-left) to cancel and return to the Dashboard. Any photos taken in the current session will be discarded.

> [Screenshot: Camera viewfinder with shutter button and step progress dots]

---

## 8. Reviewing & Submitting

Before uploading, you can review all 3 captured images and replace any that aren't satisfactory.

> [Screenshot: Product Review screen showing barcode card and 3 image cards]

### Screen Layout

**Barcode Card** (top) — A gradient card showing:
- A QR code icon
- "Scanned Successfully" badge
- The barcode number in monospace font
- A green verified checkmark

**Captured Images** — Three cards, one for each photo:

| # | Card | Color |
|---|------|-------|
| 01 | Product Photo | Teal |
| 02 | Ingredients Photo | Purple |
| 03 | Nutrition Photo | Orange |

Each card shows:
- The step number and label on the left
- The captured image preview on the right
- A **"Replace"** button to retake that specific photo
- A **"Zoom"** badge — tap the image to view it full-screen with pinch-to-zoom

> [Screenshot: Single capture card showing "01 Product Photo" with image preview and Replace button]

### Replacing a Photo
1. Tap the **"Replace"** button on any image card.
2. The camera opens for you to retake that specific photo.
3. The new photo replaces the previous one in the review.

### Full-Screen Image Preview
Tap any image to open it full-screen. You can:
- **Pinch to zoom** for detail inspection
- See the image label at the top
- Tap the **X button** to close

> [Screenshot: Full-screen image preview with pinch-to-zoom hint at bottom]

### Submitting
Tap the **"Submit Product"** button (green bar at the bottom of the screen).

- The button changes to **"Uploading…"** with a spinner.
- A semi-transparent overlay covers the screen during upload.
- **On success:** A dialog appears with "Uploaded!" message and a green checkmark.
- **On offline success:** A dialog appears with "Saved Offline" message and an orange cloud icon (see [Section 11](#11-offline-mode)).
- **On error:** A red snackbar appears at the bottom with the error message.

After a successful submission, tapping **"Done"** returns you to the Dashboard and automatically opens the scanner for the next product.

> [Screenshot: Upload success dialog with green checkmark and "Done" button]

> [Screenshot: Saved Offline dialog with orange cloud icon]

---

## 9. All Scans

Access the full scan history by tapping **"View All"** on the Dashboard or navigating directly.

> [Screenshot: All Scans screen with search bar, filter chips, and scan list]

### Header
- **Back button** and **"All Scans"** title
- **Total count** badge (e.g., "142 total") in the top-right corner
- **Search bar** — type to search by product name or barcode (auto-searches after 500ms)
- **Filter chips** — horizontally scrollable status filters:
  - All | Captured | Pending | Approved | Rejected | Failed

> [Screenshot: Filter chips showing "Approved" selected with teal background]

### Scan Cards
Each card shows:
- **Product thumbnail** (or placeholder)
- **Product name** (or barcode if no name available)
- **Brand name** (if available)
- **Barcode** in a pill-shaped badge
- **Category** tag (if available)
- **Status badge** (Captured/Pending/Approved/Rejected/Failed)
- **Time** (e.g., "5m ago", "2d ago")

### Infinite Scrolling
The list loads 20 items at a time. As you scroll near the bottom, more items load automatically with a spinner indicator.

### Pull to Refresh
Pull down on the list to refresh the data.

---

## 10. Notifications

Access notifications by tapping the **bell icon** in the Dashboard's bottom navigation bar.

> [Screenshot: Notifications screen showing grouped notifications by date]

### Header
- **Back button** and **"Notifications"** title
- **"Mark all read"** button (appears when there are unread notifications)

### Notification List
Notifications are grouped by date with section headers:
- **Today** (teal icon)
- **Yesterday** (blue icon)
- **Older dates** (grey icon, shown as "Jan 15, 2026" etc.)

Each notification card shows:
- **Type icon** — color-coded by notification type:
  - 📄 OCR Completed (teal)
  - ✅ Upload Success (teal)
  - ⚠️ Duplicate Barcode (orange)
  - 🔥 Streak (red)
  - 🏆 Goal Reached (gold)
- **Unread indicator** — a small teal dot on the icon (for unread notifications)
- **Title** (bold for unread)
- **Body** (description text)
- **Time** (e.g., "5 min ago", "Yesterday, 2:30 PM")

### Infinite Scrolling
Scroll to load more notifications automatically.

### Pull to Refresh
Pull down to refresh the notification list.

### Empty State
If there are no notifications, a centered message shows "No notifications yet — You're all caught up!"

> [Screenshot: Empty notifications state with bell icon and message]

---

## 11. Offline Mode

The app is designed to work without internet connectivity.

### How It Works

1. **Barcode checking:** When offline, the app checks its local cache for previously looked-up barcodes. If the barcode hasn't been cached before, it assumes the product is new.

2. **Image capture:** Works normally — no internet required for taking photos.

3. **Submission:** When you submit a product offline:
   - Images are saved to permanent local storage
   - A "Saved Offline" dialog appears with an orange cloud icon
   - The product appears in the "Offline Sync" counter on the Dashboard

4. **Auto-sync:** When internet connectivity is restored, the app automatically:
   - Checks each pending product against the server
   - Uploads products that haven't been uploaded yet
   - Removes local files after successful upload
   - Updates the sync progress

### Sync Progress
The **"Offline Sync"** card on the Dashboard shows how many products are waiting to be synced. This count updates in real-time.

### Connectivity Banner
When your device goes offline or comes back online, a snackbar notification appears at the bottom of the screen indicating the current connection status.

> [Screenshot: Dashboard showing Offline Sync counter with 3 pending uploads]

> [Screenshot: Connectivity status snackbar showing "You're back online! Syncing..." message]

---

## 12. Logging Out

1. Tap the **logout icon** (circle button in the top-right of the Dashboard header).
2. A confirmation dialog appears: **"Are you sure you want to sign out?"**
3. Tap **"Logout"** (red button) to confirm, or **"Cancel"** to go back.
4. On logout, all stored session data is cleared and you're returned to the Login screen.

> [Screenshot: Logout confirmation dialog with Cancel and Logout buttons]

**Note:** Any products saved offline but not yet synced will be lost upon logout, as stored data is cleared. Make sure you're connected to the internet and all pending syncs are complete before logging out.

---

## 13. Privacy Policy

Accessible from the Login screen by tapping **"Privacy Policy"**.

Opens an in-app browser loading Zytama's privacy policy from `zytama.com/privacy-policy`. A loading spinner shows while the page loads.

> [Screenshot: Privacy Policy screen with WebView loading the policy page]

---

## 14. Troubleshooting

### Camera Not Working
- **Check permissions:** Go to your device Settings → Apps → Zytama Data → Permissions → Enable Camera.
- The app shows a "Camera permission required" screen with an **"Open Settings"** button if permission is denied.

### Barcode Not Scanning
- Ensure adequate lighting — use the **flash toggle** (lightning icon) in dim environments.
- Hold the phone steady and align the barcode within the green frame.
- Clean the camera lens if images appear blurry.

### Login Failed
- Verify your email and password are correct.
- Check your internet connection.
- If you've forgotten your password, contact your administrator.
- The error dialog will show the specific reason for failure (e.g., "Invalid credentials", "Account locked").

### Upload Failed
- Check your internet connection.
- The error message appears as a red snackbar at the bottom of the screen.
- You can try submitting again from the Review screen.
- If you continue to experience issues, the product can be saved offline and will sync automatically later.

### Offline Sync Not Working
- Ensure you have an active internet connection.
- Sync happens automatically when connectivity is restored.
- Check the "Offline Sync" counter on the Dashboard to see pending items.
- Try logging out and back in to restart the sync service.

### App Crashes or Freezes
- Force close the app and reopen it.
- Ensure your device has sufficient storage space (the app stores images locally before upload).
- Update to the latest version of the app.

---

## Quick Reference

| Action | How |
|--------|-----|
| Scan a barcode | Tap **New Scan** button or center nav icon |
| Toggle flash | Tap ⚡ icon in scanner top bar |
| Replace a photo | Tap **Replace** on image card in Review screen |
| Zoom into a photo | Tap the image → pinch to zoom |
| Search products | Open **All Scans** → type in search bar |
| Filter by status | Open **All Scans** → tap a filter chip |
| View notifications | Tap 🔔 icon in bottom nav bar |
| Log out | Tap logout icon (top-right) → confirm |

---

*For support or feedback, contact your team administrator.*
