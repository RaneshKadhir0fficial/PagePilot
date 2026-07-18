# 📖 PagePilot

> **Offline-First Reading Discipline Engine for Serious Readers**

PagePilot is an offline-first Flutter application designed to help users actually finish books—not just collect them.

Unlike traditional PDF readers that only display documents, PagePilot creates a structured reading plan, tracks progress, adapts to missed reading days, provides AI-assisted explanations, and helps users build a consistent reading habit through discipline-focused tools.

---

# ✨ Features

## 📚 Smart PDF Library

- Import PDF books
- Automatic page count extraction
- Editable book titles
- Multiple book management
- Resume reading from last page
- Reading progress tracking
- Estimated completion date

---

## 🎯 Reading Discipline Engine

The core of PagePilot.

Features include:

- Daily reading targets
- Dynamic reading plan
- Auto Shift Plan
- Auto Advance Mode
- Adaptive Reading
- Carry Forward Mode
- Reading streak tracking
- Momentum Score

---

## 📖 Reading Experience

- Horizontal reading mode
- Vertical reading mode
- Automatic progress saving
- Resume from last position
- Offline PDF rendering

---

## 📝 Notes & Highlights

- Page-specific notes
- Rich note editing
- Search notes
- Text highlighting
- Multiple highlight colors
- Markdown export

---

## 🤖 AI Reading Assistant

Internet is required only for AI features.

Capabilities include:

- Summarize
- Explain Simply
- Key Points
- Examples
- Important Concepts

AI analyzes only the currently visible pages to provide focused assistance.

---

## ⏱ Focus Mode

- Pomodoro Timer
- Custom timer durations
- Focus session history
- Reading productivity tracking

---

## 📊 Analytics

Track your reading journey with:

- Reading streak
- Longest streak
- Momentum Score
- Total focus hours
- Pages read
- Books completed

---

# 📱 Screenshots

> Screenshots will be added soon.

| Library | Reader | AI Assistant | Analytics |
|----------|---------|--------------|------------|
| Coming Soon | Coming Soon | Coming Soon | Coming Soon |

---

# 🏗 Architecture

```
Flutter

Presentation Layer
        │
Riverpod State Management
        │
Domain Layer
        │
Repository Layer
        │
Drift Database
        │
Offline Storage
```

---

# 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod |
| Database | Drift (SQLite) |
| PDF Rendering | Syncfusion PDF Viewer |
| AI | Gemini API |
| Local Storage | SQLite |
| Platform | Android |

---

# 📂 Project Structure

```
lib/

core/

data/

domain/

presentation/

features/

reading/

analytics/

notes/

focus/

settings/

ai_assistant/
```

---

# 🚀 Installation

Clone the repository

```bash
git clone https://github.com/RaneshKadhir0fficial/PagePilot.git
```

Navigate to project

```bash
cd PagePilot
```

Install dependencies

```bash
flutter pub get
```

Run the project

```bash
flutter run
```

---

# 🎯 Why PagePilot?

Most PDF readers help users **read pages**.

PagePilot helps users **finish books**.

Its Discipline Engine continuously adapts the reading schedule based on user progress, making long books manageable and encouraging consistent reading habits.

---

# 🔒 Privacy

PagePilot follows an **offline-first** approach.

- Books remain on the user's device.
- Notes remain local.
- Highlights remain local.
- Reading analytics remain local.
- Internet is used only when interacting with the AI assistant.

---

# 🚀 Future Improvements

- OCR support
- Audiobook synchronization
- Reading groups
- Cloud backup
- Cross-device synchronization
- AI-generated flashcards
- AI quizzes
- Smart revision mode

---

# 👨‍💻 Developer

**Ranesh Kadhir**

GitHub:
https://github.com/RaneshKadhir0fficial

---

# ⭐ Support

If you like this project, consider giving it a ⭐ on GitHub.

---

# 📄 License

Licensed under the MIT License.
