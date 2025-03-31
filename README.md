# MovieHub

## A fully functional EXAMPLE project that built with UIKit and Swift
This application allows users to discover popular movies, search for any movie, and create a personal library by adding movies to their favorites list. It provides detailed information about each movie, including a list of actors and recommended movies. Users can also navigate to the movie’s individual page if available, and view detailed actor profiles.

### 🛠️ Technologies & Architecture

- **Language:** Swift
- **UI Framework:** UIKit (with storyboard)
- **Architecture:** MVVM
- **Networking:** URLSession – custom service layer to consume `TMDB API`, including pagination support.
- **Persistence:** Realm – used for local data storage to support offline usage.
- **Image Caching:** Kingfisher – optimized image loading and caching for better performance.
- **Design Patterns & Techniques:**
  - **Delegate**: For communication between view controllers and child components.
  - **Singleton**: Used in configuration and data management utilities.
  - **NotificationCenter**: Employed for decoupled inter-component communication (e.g., state updates, syncing views).
  - **Combine**: Integrated for reactive data flow, particularly in binding API responses to UI.
  - **Protocol-Oriented Programming (POP)**: Applied to increase modularity and testability, especially in services and view models.
      
#### 🧩 Design Patterns & Techniques
- **Delegate:** For communication between view controllers and child components.  
- **Singleton:** Used in configuration and data management utilities.  
- **NotificationCenter:** Used for responding to system events such as keyboard dismissal (e.g., showing navigation bar again after keyboard hides).  
- **Combine:** Utilized for reactive binding between `ViewModel` and `ViewController`, ensuring clean data flow and state updates.  
- **Protocol-Oriented Programming (POP):** Used to increase modularity, abstraction, and testability across services and view models. 

#### 🌐 App Features
- **Dark Mode Support:** Full UI adaptability based on system appearance.  
- **Localization:** Multi-language support via `.strings` files.  
- **Offline Capability:** Some parts of app usable without network connection using Realm as persistent layer.

