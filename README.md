# 🛍️ ShopFlow

A full-featured, production-style E-Commerce mobile application built with Flutter — featuring separate Customer and Admin experiences, real-time order tracking, and a complete shopping flow from browsing to checkout.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-6C63FF?style=for-the-badge)

---

## 📱 Overview

ShopFlow is a dual-role e-commerce app — customers can browse products, manage their cart and wishlist, place orders, and track delivery status in real time, while admins get a dedicated dashboard to manage the product catalog and process incoming orders. All data is synced live through Firebase, so changes made by an admin (like updating an order's status) are instantly reflected in the customer's app.

---

## ✨ Features

### Customer Side
- 🔐 **Authentication** — Email/password sign up & login, forgot password flow
- 🏠 **Home** — Category-based browsing with a dynamic, color-coded category selector
- 🔍 **Explore & Search** — Real-time search with multi-keyword matching and category filters
- 🛍️ **Product Details** — Image gallery, size selection, ratings, and discount badges
- 🛒 **Cart** — Live quantity updates with automatically recalculated totals
- ❤️ **Wishlist** — Save products for later, move directly to cart
- 📦 **Checkout** — Delivery form with Pakistani city autocomplete and address auto-fill from past orders
- 📍 **Order Tracking** — Visual progress tracker (Confirmed → Shipped → Delivered)
- ❌ **Order Cancellation** — Cancel orders that haven't shipped yet
- 🔔 **Real-time Notifications** — Get notified instantly when an order's status changes
- 👤 **Profile** — Editable name & profile picture (camera/gallery), order history, saved addresses
- ❓ **Help & Support** — FAQs and contact information

### Admin Side
- 📊 **Dashboard** — Live stats: total products, total orders, revenue, recent activity
- 📦 **Product Management** — Add, edit, and delete products with image, pricing, and category fields
- 🧾 **Order Management** — View all orders and update their status in real time
- 🔐 **Role-based Access** — Automatic routing to Admin or Customer experience based on Firestore user role

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod (StateNotifier, StreamProvider, FutureProvider) |
| Backend | Firebase (Auth, Cloud Firestore) |
| Local Persistence | SharedPreferences |
| Image Handling | image_picker, cached_network_image |
| Architecture | Feature-based folder structure with clean separation of Models, Providers, Services, and Screens |

---

## 🏗️ Architecture

```
lib/
├── models/          # Data models (Product, Order, Notification, CartItem)
├── providers/        # Riverpod providers (auth, cart, wishlist, orders, notifications)
├── services/          # Firebase service classes (Auth, Firestore)
├── screens/
│   ├── customer/      # Home, Explore, Cart, Wishlist, Profile, Checkout, Orders
│   ├── admin/          # Dashboard, Products, Orders
│   └── auth_screen.dart
├── data/                # Static data (Pakistan cities list)
└── main.dart
```

This project follows a **Repository + Provider pattern**, keeping UI, business logic, and data access cleanly separated — making the codebase easy to extend and test.

---

## 🔑 Key Implementation Highlights

- **Real-time sync** between admin actions and customer UI using Firestore streams — no manual refresh needed
- **Role-based navigation** — a single login flow routes users to entirely different app experiences based on their Firestore role
- **Custom notification system** built on Firestore `docChanges` to detect order status updates and generate notifications automatically
- **Persistent local state** (profile name/photo) using SharedPreferences alongside cloud data
- **Smart search** with multi-keyword matching across product name, description, and category

---

## 🚀 Getting Started

```bash
git clone https://github.com/yourusername/shopflow.git
cd shopflow
flutter pub get
flutter run
```

### Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password) and **Cloud Firestore**
3. Download `google-services.json` and place it in `android/app/`
4. Add a `users` collection with `role: "admin"` or `role: "customer"` documents keyed by Firebase Auth UID

---

## 📸 Screenshots

*Add screenshots here before publishing*

---

## 📄 License

This project is open source and available for learning purposes.

---

## 👨‍💻 Developer

Built as a portfolio project to demonstrate full-stack mobile development skills — from UI/UX design to backend integration and state management.