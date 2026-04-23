# 🤖 ResumeAI — AI-Powered Resume Analyzer

A professional Flutter app that uses **Claude AI** to analyze resumes and provide actionable feedback.

---

## ✨ Features

| Feature | Description |
|---|---|
| **Overall Score** | 0–100 score with detailed section breakdown |
| **ATS Compatibility** | Checks how well your resume passes ATS filters |
| **AI Summary** | Claude's concise assessment of your resume |
| **Section Analysis** | Per-section scores with specific feedback |
| **Strengths & Weaknesses** | AI-identified pros and cons |
| **Smart Suggestions** | Prioritized (High/Medium/Low) improvement tips |
| **Skills Detection** | Categorized skills with proficiency levels |
| **Keyword Analysis** | Found vs missing keywords |
| **Job Match** | Optional job description for tailored analysis |

---

## 🏛 Architecture: Clean Architecture + BLoC

```
lib/
├── core/
│   └── theme/          # AppTheme, AppColors
├── data/
│   ├── datasources/    # AiDatasource (Anthropic API)
│   ├── models/         # ResumeAnalysisModel (JSON parsing)
│   └── repositories/   # ResumeRepositoryImpl
├── domain/
│   ├── entities/       # ResumeAnalysis, SkillItem, etc.
│   ├── repositories/   # Abstract ResumeRepository
│   └── usecases/       # AnalyzeResumeUseCase
└── presentation/
    ├── bloc/           # ResumeBloc (Events + States)
    ├── pages/          # HomePage, ResultsPage, ApiKeyPage, SettingsPage
    └── widgets/        # UploadSection, JobDescriptionInput
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10+
- Dart 3.0+
- Anthropic API key ([console.anthropic.com](https://console.anthropic.com))

### Installation

```bash
# Clone or unzip the project
cd resume_analyzer

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### First Launch
On first launch, enter your Anthropic API key (`sk-ant-...`). It's stored locally using `shared_preferences`.

---

## 📦 Dependencies

```yaml
flutter_bloc: ^8.1.3      # State management
equatable: ^2.0.5          # Value equality for BLoC
http: ^1.1.0               # Anthropic API calls
file_picker: ^6.1.1        # Resume file selection
google_fonts: ^6.1.0       # Space Grotesk + Inter fonts
flutter_animate: ^4.3.0    # Smooth animations
percent_indicator: ^4.2.3  # Score circle
fl_chart: ^0.65.0          # Charts
dotted_border: ^2.1.0      # Upload zone border
shared_preferences: ^2.2.2 # API key storage
dartz: ^0.10.1             # Either<L, R> for error handling
```

---

## 🎨 Design System

- **Theme**: Dark, luxury aesthetic
- **Primary**: `#7C6FF7` (violet)
- **Accent**: `#00E5C0` (teal)
- **Gold**: `#FFCC55`
- **Error**: `#FF7070`
- **Fonts**: Space Grotesk (headings) + Inter (body)

---

## 🔐 Privacy
Your API key and resume content are **never transmitted** to any server other than Anthropic's official API endpoint. No data is stored in the cloud.
