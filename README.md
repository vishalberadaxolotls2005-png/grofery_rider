# hyper_local

Hyper Local Delivery Partner App

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Features

### Conditional Navigation Based on Status

The app implements conditional navigation based on the delivery partner's status:

#### When Status is Active:
- **Feed Tab**: Shows Available Orders and My Orders with tabbed interface
- **Gigs Tab**: Gigs and additional opportunities
- **Pockets Tab**: Wallet and financial management
- **More Tab**: Settings page with profile management, app settings, support, and account actions

#### When Status is Inactive:
- **Feed Tab**: Shows Statistics (earnings, performance metrics, quick actions)
- **Gigs Tab**: Gigs and additional opportunities
- **Pockets Tab**: Wallet and financial management
- **More Tab**: Settings page with profile management, app settings, support, and account actions

### Status Management
- Toggle between Active/Inactive status using the switch in the top-left header of the feed page (both in orders view and statistics view)
- Status is persisted locally and synced with the backend
- Real-time status updates with visual feedback

### Key Components
- `Dashboard`: Main component that handles conditional navigation
- `HomePageWithStatus`: Contains Available Orders/My Orders when active, Statistics when inactive
- `MorePage`: Settings page with profile management and other options
- `ProfilePage`: Dedicated profile management page accessible via Settings -> Profile
- Status toggle functionality with BLoC pattern
# hyper_local_rider
