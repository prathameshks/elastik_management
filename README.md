### elastik_management
# Title: Elastik Teams Office Management 

## Description
Elastik Teams Office Management is a comprehensive office administration application designed to streamline workplace operations and resource management. The application serves as a centralized platform for tracking and managing various aspects of office logistics and employee workflows.

## Features
- **User Management & Authentication:** Role-based access system (admin, employee), Secure login functionality, Profile management with designations and contact information
- **Work From Office (WFO) Scheduling:** Multiple WFO schemas for different teams or departments, Employee assignment to appropriate schemas
- **Stock/Inventory Management:** Track office supplies and snacks, monitor stock levels and status (available, low, unavailable), Filter and sort items by category and status, Visual charts, showing inventory distribution
- **Community Contributions:** Track financial contributions for ET Community Contribution, Multiple contribution reasons (Friday T-shirt, missed news, etc.), Payment status tracking (paid/unpaid), Visual charts showing contribution statistics
- **Daily News & Updates:** Rotating news responsibility among team members, Daily announcements displayed prominently on home screen, Visual indicators for whose turn it is to share news 
- **Home Screen:** To give overview of all the functionality with accurate information

## Tech Stack
- Flutter
- Dart

## Getting Started
0. Prerequisites: 
    
    Ensure you have Flutter and Dart installed on your machine. You can follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install) and a Code Editor of your choice (e.g., [Visual Studio Code](https://code.visualstudio.com/), [Android Studio](https://developer.android.com/studio)).

1. Clone the repository:
    ```bash
    git clone https://github.com/prathameshks/elastik_management.git
    ```
2. Navigate to the project directory: 
    ```bash 
    cd elastik_management
    ```
3. Install dependencies: 
    ```bash
    flutter pub get
    ```
4. Run the application: 
    ```bash
    flutter run
    ```
5. Access the application on your device or emulator

## Future Enhancements
- **Actual Realtime API:** Implement a real-time API to provide instant updates on office resources, employee attendance, and community contributions, Use WebSockets or similar technology for real-time communication
- **Mobile App:** Develop a mobile application for iOS and Android platforms to provide on-the-go access to office management features, Ensure seamless synchronization with the web application
- **Desk Booking:** Implement a desk booking system for employees to reserve workspaces in advance, Integrate with WFO scheduling to ensure desk availability aligns with employee schedules
- **Notification System:** Implement a notification system to alert employees about important updates, reminders, and announcements, Integrate with the existing news and updates feature for seamless communication
- **Robust Attendance Tracking:** Enhance attendance tracking with features like geolocation, QR code check-in/check-out, and integration with existing WFO scheduling, Provide detailed reports on attendance patterns and trends
- **Fine Grained Access Control:** Implement a more granular access control system to allow for specific permissions on various features, Enable admins to customize user roles and permissions based on team needs
- **Enhanced Analytics Dashboard:** Develop a more comprehensive analytics dashboard to provide insights into office resource usage, employee attendance patterns, and community contributions, Integrate with third-party analytics tools for advanced reporting capabilities

---

[![Elastik Teams](https://raw.githubusercontent.com/prathameshks/elastik_management/refs/heads/main/assets/images/ET_logo_text.png)](https://www.elastikteams.com)

Made with ❤️ by [Prathamesh Sable](https://www.linkedin.com/in/prathamesh-sable) in [Elastik Teams India Pvt. Ltd.](https://www.elastikteams.com)
---