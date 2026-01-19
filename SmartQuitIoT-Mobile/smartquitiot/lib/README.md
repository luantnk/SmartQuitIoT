# SmartQuitIoT - Views Structure


This directory contains all the UI components and screens for the SmartQuitIoT application, organized following Flutter best practices and MVVM architecture.

## 📁 Directory Structure

### Widgets (`/widgets/`)

Widgets are organized by functionality and type for better maintainability:

#### `/buttons/`
- `primary_button.dart` - Main action button component
- `action_button.dart` - Secondary action button with icon
- `social_login_buttons.dart` - Social media login buttons
- `social_button.dart` - Individual social button component

#### `/inputs/`
- `custom_text_field.dart` - Custom styled text input field
- `auth_text_field.dart` - Authentication-specific text field

#### `/headers/`
- `auth_header.dart` - Authentication screen headers
- `home_header.dart` - Home screen header component
- `curved_header.dart` - Curved header design
- `section_header.dart` - Section divider headers

#### `/cards/`
All card-based UI components including:
- Achievement cards
- Article cards
- Mission cards
- Profile cards
- Statistics cards
- And many more...

#### `/forms/`
- `auth_divider.dart` - Authentication form dividers
- `switch_option.dart` - Toggle switch components
- `post_type_selector.dart` - Post type selection
- `category_tab.dart` - Category tab components

#### `/lists/`
- `chat_recent_item.dart` - Chat list items
- `notification_item.dart` - Notification list items
- `insight_item.dart` - Insight list items
- `profile_menu_item.dart` - Profile menu items

#### `/animations/`
- `success_animation.dart` - Success state animations

#### `/common/`
- Miscellaneous widgets that don't fit other categories
- Shared components used across multiple screens

### Screens (`/screens/`)

Screens are organized by feature modules:

#### `/authentication/`
- `login_screen.dart` - User login
- `signup_screen.dart` - User registration
- `forgot_password_screen.dart` - Password recovery
- `reset_password_screen.dart` - Password reset
- `otp_screen.dart` - OTP verification

#### `/profile/`
- `profile_screen.dart` - User profile view
- `edit_profile_screen.dart` - Profile editing
- `setting_screen.dart` - App settings

#### `/community/`
- `community_screen.dart` - Community feed
- `post_screen.dart` - Individual post view
- `create_post_screen.dart` - Post creation
- `filter_post_screen.dart` - Post filtering

#### `/diary/`
- `diary_screen.dart` - Diary main screen
- `create_diary_screen.dart` - Diary entry creation
- `diary_history_screen.dart` - Diary history
- `diary_history_screen_refactored.dart` - Refactored diary history

#### `/achievements/`
- `achievement_screen.dart` - Achievements overview
- `badges_screen.dart` - Badges collection
- `badge_detail_screen.dart` - Individual badge details

#### `/ai_chat/`
- `ai_chat_screen.dart` - AI chat interface
- `ai_chat_welcome_screen.dart` - AI chat welcome
- `ai_chat_instructions_screen.dart` - AI chat instructions
- `chat_screen.dart` - General chat interface

#### `/articles/`
- `article_list_screen.dart` - Articles listing
- `article_detail_screen.dart` - Article reading

#### `/payment/`
- `payment_options_screen.dart` - Payment methods
- `premium_membership_screen.dart` - Premium subscription
- `qr_payment_screen.dart` - QR code payment
- `success_payment_screen.dart` - Payment confirmation

#### `/onboarding/`
- `onboarding_screen.dart` - App introduction
- `welcome_screen.dart` - Welcome screen
- `questionnaire_screen.dart` - User questionnaire
- `quit_plan_screen.dart` - Quit plan selection
- `quit_plan_options.dart` - Quit plan options

#### `/common/`
- `splash_screen.dart` - App splash screen
- `main_navigation_screen.dart` - Main navigation
- `home_screen.dart` - Home dashboard
- `notification_screen.dart` - Notifications
- `api_demo_screen.dart` - API demonstration
- And other shared screens...

## 🚀 Usage

### Importing Widgets

```dart
// Import specific widget category
import 'package:SmartQuitIoT/views/widgets/buttons/buttons.dart';
import 'package:SmartQuitIoT/views/widgets/cards/cards.dart';

// Or import all widgets
import 'package:SmartQuitIoT/views/widgets/widgets.dart';
```

### Importing Screens

```dart
// Import specific screen category
import 'package:SmartQuitIoT/views/screens/authentication/authentication.dart';
import 'package:SmartQuitIoT/views/screens/profile/profile.dart';

// Or import all screens
import 'package:SmartQuitIoT/views/screens/screens.dart';
```

## 📋 Best Practices

1. **Naming Convention**: Use snake_case for file names
2. **Widget Organization**: Group related widgets in appropriate folders
3. **Screen Organization**: Group screens by feature modules
4. **Barrel Exports**: Use barrel export files for easy importing
5. **Consistent Structure**: Follow the established folder structure
6. **Documentation**: Add comments for complex widgets and screens

## 🔧 Maintenance

- When adding new widgets, place them in the appropriate category folder
- When adding new screens, place them in the appropriate module folder
- Update the barrel export files when adding new components
- Keep the folder structure clean and organized
- Follow Flutter and Dart style guidelines

## 📱 Architecture

This structure follows the MVVM (Model-View-ViewModel) pattern:
- **Views**: All UI components and screens in this directory
- **ViewModels**: Located in `/lib/viewmodels/`
- **Models**: Located in `/lib/models/`
- **Services**: Located in `/lib/services/`

The organized structure makes it easy to:
- Find specific components quickly
- Maintain and update code
- Scale the application
- Onboard new developers
- Follow consistent patterns
