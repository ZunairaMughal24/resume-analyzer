# 🤖 ResumeAI — AI-Powered Resume Analyzer

A professional Flutter application that leverages **Google Gemini AI** to analyze resumes and provide actionable, intelligent feedback to help you land your next job.

---

## ✨ Features

- **Overall Score**: Comprehensive 0–100 score with detailed section breakdowns.
- **ATS Compatibility**: Checks how well your resume passes Applicant Tracking System filters.
- **AI Summary**: Gemini's concise, intelligent assessment of your resume.
- **Section Analysis**: Detailed, per-section scores with specific feedback.
- **Strengths & Weaknesses**: AI-identified pros and cons based on industry standards.
- **Smart Suggestions**: Prioritized (High/Medium/Low) improvement tips.
- **Skills & Keyword Analysis**: Found vs missing keywords and categorized skills.
- **Job Match Analysis**: Optional tailored analysis against a specific job description.

## 🏛 Architecture

Built following Clean Architecture principles and BLoC pattern for robust state management.

```text
lib/
├── core/             # Theme, Error Handling, DI
├── data/             # API Data Sources, Models, Repository Implementations
├── domain/           # Entities, Abstract Repositories, Use Cases
└── presentation/     # BLoC, Pages, UI Components
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10+)
- Dart (3.0+)
- Google Gemini API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repository-url>
   cd resume_analyzer
   ```

2. **Configure the Environment**
   Create a `.env` file in the root directory and add your Gemini API key:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## 🎨 Design System

- **Aesthetic**: Premium, dark-mode luxury design.
- **Primary Color**: `#7C6FF7` (Violet)
- **Typography**: Space Grotesk (Headings) & Inter (Body)

## 🔐 Privacy

Your resume content is processed securely. No data is stored in the cloud or transmitted to any third-party servers other than the official Google Gemini API endpoint.
