<h1 align="center">Culinary Compass</h1>

<p align="center">
  <strong>Discover Your Next Culinary Adventure.</strong>
</p>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#features">Features</a> •
  <a href="#glimpse-into-the-experience">Screenshots</a> •
  <a href="#tech-stack--architecture">Tech Stack</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#project-structure">Project Structure</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

---

## 🌟 Overview

Welcome to **Culinary Compass** – not just another recipe app, but your future indispensable partner in the art of cooking. Crafted with an unwavering commitment to excellence, Culinary Compass aims to be the most intuitive, visually stunning, performant, and genuinely helpful recipe application in the world.

Imagine a seamless and delightful journey from discovering your next favorite meal among thousands of global recipes, to effortlessly planning your week, generating smart shopping lists, and finally, being guided step-by-step through the cooking process with unparalleled clarity. All of this, wrapped in a breathtakingly beautiful and highly responsive interface, with your personal culinary world securely managed and synced via Supabase.

**Our Vision:** To inspire culinary exploration, empower home cooks of all levels, and deliver sheer delight with every interaction, making Culinary Compass an award-winning benchmark for quality and user experience in mobile applications.

---

## ✨ Key Features

Culinary Compass is being built in phases, with a rich feature set designed to transform your cooking experience:

### 🧭 Discovery & Inspiration
*   **Dynamic Home Screen:** A vibrant hub showcasing trending recipes, curated categories, and personalized suggestions.
*   **Advanced Recipe Search:** Instantly find recipes by name, ingredients, or explore with powerful filters (diet, cuisine, intolerances, time, nutrition).
*   **Autocomplete Suggestions:** Smart suggestions as you type to speed up your search.
*   **Category Browsing:** Explore recipes through intuitive categories like meal types, diets, or cuisines.

### ❤️ Personalization & Management
*   **Supabase User Authentication:** Secure sign-up, login, and session management.
*   **Favorites Management:** Save your most-loved recipes with a single tap, synced across your devices.
*   **Meal Planning:** Visually plan your meals for the week or month on an interactive calendar.
*   **Smart Shopping List:** Automatically generate shopping lists from your meal plan or individual recipes. Add items manually and check them off as you shop. Items are intelligently grouped by category.
*   **User Profile & Preferences:** Manage your display name and persistent dietary/cooking goal preferences (e.g., Vegan, Quick & Easy) to tailor your experience.

### 🍳 Cooking Assistance
*   **Detailed Recipe View:** Stunning presentation of recipe details including high-quality images, summaries, nutritional information, ingredients, and clear step-by-step instructions.
*   **Cooking Mode:** A focused, distraction-free interface displaying instructions one step at a time, with large text and optional timers, keeping your screen awake while you cook.
*   **Ingredient Information (Optional):** Tap on ingredients to see more details or potential substitutes.

### ⚙️ App Experience
*   **Modern Minimalist++ UI:** Clean, sophisticated design with ample whitespace, rich textures, fluid transitions, and delightful micro-animations.
*   **Light & Dark Modes:** Beautifully crafted themes that adapt to your preference, synced with your profile.
*   **Responsive Design:** Adapts seamlessly to various phone sizes and orientations.
*   **Secure Credential Management:** API keys and sensitive data are handled securely, never hardcoded.
*   **Robust Error Handling & Performance:** A stable and performant application that handles issues gracefully.

---

## 📸 A Glimpse into the Experience

*(Captivating screenshots and short GIFs showcasing the app's UI and key features are currently being prepared and will be added here soon! We are in the final stages of tweaking the visuals to ensure they perfectly capture the world-class aesthetic of Culinary Compass.)*

---

## 🛠️ Tech Stack & Architecture

Culinary Compass is built with a focus on quality, scalability, and maintainability, utilizing a modern, robust technology stack:

*   **Frontend Framework:** Flutter (Latest Stable)
*   **Architecture:** Clean Architecture (Domain, Data, Presentation) with a Feature-First organizational approach.
*   **State Management:** `flutter_bloc` (Bloc/Cubit) combined with `Freezed` for immutable states and models.
*   **Dependency Injection:** `get_it` for service location.
*   **Error Handling:** `dartz` (Either type) for functional error propagation.
*   **Routing:** `go_router` for declarative navigation and deep linking.
*   **Backend & Database:** **Supabase**
    *   Authentication: Supabase Auth (`supabase_flutter`)
    *   Database: Supabase PostgreSQL (`supabase_flutter`) with Row Level Security (RLS).
    *   Storage: Supabase Storage (planned for future use).
*   **External Recipe API:** **Spoonacular API** for comprehensive recipe data.
*   **HTTP Client:** `dio` for network requests.
*   **Image Caching:** `cached_network_image`.
*   **Security - Credential Management:** `flutter_dotenv` (or compile-time variables via `--dart-define`) for API keys. **No secrets are hardcoded.**
*   **Linting:** Strict linting rules with `flutter_lints`.
*   **Other Key Packages:** `table_calendar` (for meal planning), `share_plus` (for sharing), `wakelock` (for cooking mode).

---

## 🚀 Getting Started

To get Culinary Compass running locally for development and contributions:

**1. Prerequisites:**
   * Ensure you have Flutter (latest stable version) installed. See [Flutter installation guide](https://flutter.dev/docs/get-started/install).
   * A code editor like VS Code or Android Studio.
   * Access to a Spoonacular API key.
   * A Supabase project set up with the required tables (see schema details in phase documentation) and Auth configured.

**2. Clone the Repository:**
   ```bash
   git clone https_link_to_your_github_repository_here
   cd culinary-compass
   ```

**3. Set Up Environment Variables:**
   *   **API Keys are crucial and MUST NOT be committed to the repository.**
   *   This project uses `flutter_dotenv` for managing environment variables.
   *   Create a `.env` file in the root of the project:
       ```
       SPOONACULAR_API_KEY=your_spoonacular_api_key
       SUPABASE_URL=your_supabase_project_url
       SUPABASE_ANON_KEY=your_supabase_anon_key
       ```
   *   **Important:** Add `.env` to your `.gitignore` file if it's not already there.
       ```gitignore
       # Environment variables
       .env
       ```
   *   Alternatively, you can pass these variables at compile time using `--dart-define`:
       ```bash
       flutter run \
         --dart-define=SPOONACULAR_API_KEY=your_spoonacular_api_key \
         --dart-define=SUPABASE_URL=your_supabase_project_url \
         --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
       ```

**4. Install Dependencies:**
   ```bash
   flutter pub get
   ```

**5. Run Code Generation (if using Freezed, GetIt, etc.):**
   This project extensively uses code generation. If you make changes to models, Blocs, or DI setup, you might need to run:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

**6. Run the App:**
   ```bash
   flutter run
   ```
   Select your target device/emulator when prompted.

---

## 📁 Project Structure

The project follows a **Clean Architecture** with a **Feature-First** directory structure to ensure modularity, scalability, and separation of concerns:

```
lib/
├── core/                          # Shared code, utilities, base classes (DI, routing, theme, error handling, etc.)
├── features/                      # All app features as self-contained modules
│   ├── app_init/                  # Splash screen & initial app setup
│   ├── auth/                      # User authentication (Login, Sign Up)
│   ├── home_discovery/            # Home screen, trending, categories
│   ├── search/                    # Recipe search, filtering, results
│   ├── recipe_detail/             # Viewing detailed recipe information
│   ├── cooking_mode/              # Step-by-step cooking assistance
│   ├── user_favorites/            # Managing user's favorite recipes
│   ├── meal_plan/                 # Meal planning functionality
│   ├── shopping_list/             # Shopping list management
│   └── settings/                  # User profile, preferences, app settings
├── di_container.dart              # Main GetIt dependency injection setup
├── main.dart                      # App entry point
└── ... (other configuration files)
```

Each `feature_name/` directory is structured into:
*   `data/`: Data sources (remote/local), models (DTOs), repository implementations.
*   `domain/`: Core business logic, entities, repository interfaces (contracts), use cases.
*   `presentation/`: UI layer (Blocs/Cubits, pages/screens, widgets).

---

## ❤️ Contributing

We are thrilled you're interested in contributing to Culinary Compass and helping us build a world-class application!
*(This section should be expanded with specific guidelines once you are ready for external contributions.)*

**General Guidelines (Placeholder):**
*   Fork the repository.
*   Create a new branch for your feature or bug fix: `git checkout -b feature/your-feature-name` or `fix/issue-description`.
*   Ensure your code adheres to the project's linting rules and coding standards.
*   Write meaningful commit messages.
*   Create unit and widget tests for your changes.
*   Push your branch and open a Pull Request with a clear description of your changes.

---

## 📜 License

*(Choose a license for your project, e.g., MIT, Apache 2.0. Replace this placeholder.)*

This project is licensed under the [Your Chosen License Name] - see the `LICENSE.md` file for details.

---

<p align="center">
  Happy Cooking with Culinary Compass! 🍲✨
</p> 