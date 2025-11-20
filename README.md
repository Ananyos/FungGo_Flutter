Song Finder App 🎵

A Flutter application that allows users to search for songs, view lyrics, and manage their listening history and favorites.

✨ Features

Smart Search: Search for songs by Title, Artist, or Lyrics.

Keyword Highlighting:

Search terms are highlighted in the song title and artist name.

Lyrics Snippets: Automatically finds and displays the specific part of the lyrics that matches your search query directly on the card.

Sidebar Navigation: Easy access to Home, History, and Bookmarks via a custom drawer menu.

Search History: Automatically saves the last 10 songs you've viewed for quick access.

Bookmarks: Save your favorite songs to a dedicated "Bookmarks" list.

Clean UI: A minimalist, user-friendly interface inspired by modern music apps.

📱 Screens

Landing Page: The main hub with a clean search interface.

Song Detail Page: Displays full song information and lyrics.

Search History: A list of recently viewed songs.

Bookmarks: A collection of saved/favorite songs.

📂 Project Structure

lib/
├── models/
│   └── song.dart           # Data model for Song objects
├── screens/
│   ├── sidebar_pages.dart  # Search History and Bookmarks screens
│   └── song_detail_page.dart # Detailed view of a specific song
├── services/
│   ├── mock_database.dart  # Mock data source for searching
│   └── user_manager.dart   # Singleton for managing History & Bookmarks state
├── widgets/
│   └── song_card.dart      # Reusable widget for displaying song info & highlighting
└── landing_page.dart       # Main entry point with Search & Drawer


🚀 Getting Started

Prerequisites

Flutter SDK

A code editor (VS Code, Android Studio, etc.)

Installation

Clone the repository:

git clone [https://github.com/Ananyos/FungGo_Flutter](https://github.com/Ananyos/FungGo_Flutter)


Navigate to the project directory:

cd FungGo_Flutter


Install dependencies:

flutter pub get


Run the app:

flutter run


🛠️ Customization
