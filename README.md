Handshake.

Handshake: Managing 50 versions of your resume is absurd.

Handshake is an opinionated, minimalist application designed to perfectly adapt your resume to any job description. Instead of maintaining a dozen slightly tweaked PDFs, Handshake keeps a single, centralized "Career Profile" and dynamically generates a highly optimized, ready-to-send PDF for every new application.

Less formatting. More applying.

📖 The Philosophy

Handshake is built strictly on the "Getting Real" philosophy. We prioritize simplicity, utility, and speed over feature bloat.

No endless form fields: You write your profile once in plain text.

A focus on the pitch: The interface is built like a clean, distraction-free editor. You focus on what the company wants, and we handle how it looks. White space is generous, typography is massive, and structural friction is completely eliminated.

Code-driven, beautifully typeset: Under the hood, Handshake uses Typst markup to guarantee pixel-perfect layout and typography. But you never have to look at the code—you just download the pristine PDF.

✨ Core Features

The Adapt Engine: Type the company name, paste the job description, and click "adapt". Handshake's LLM intelligently merges your Career Profile with your blueprint to write the perfect pitch.

Direct PDF Download: No copying code, no external compilers. Handshake compiles the tailored markup behind the scenes and hands you a finished PDF instantly.

Career Profile (The Library): A centralized, easy-to-read database for your Core Skills, Past Projects, and your base Blueprint Template.

Past Applications (History): Every generated resume is automatically saved to the database. Review exactly what you submitted to which company, when you submitted it, and re-download the PDF at any time.

🎨 Design System

The visual language of Handshake draws heavy inspiration from classic, highly-opinionated productivity tools like Basecamp and Highrise. It feels less like a corporate dashboard and more like a focused, digital desk.

Color Palette: * Background: #FDFCF8 (A warm, paper-like off-white)

Text: Stark, high-contrast Black (#000000)

Accent: Trustworthy Blue (#2563EB / Tailwind blue-600) for primary actions and the hand-drawn logo.

Typography: * Headings: Sans-serif, extremely bold (font-black), and tightly tracked (tracking-tight).

Body & Descriptions: Readable, elegant serif fonts to emphasize the document-centric nature of the app.

UI Elements: * Massive input fields with no visible borders until focused.

Pill-shaped navigation buttons.

Playful, hand-drawn aesthetic touches (like the wobbly Handshake logo).

🛠 Tech Stack

Framework: Ruby on Rails (Hotwire, Turbo, Stimulus)

Styling: Tailwind CSS (customized with high-contrast, rounded-3xl borders, and soft shadows)

Database: PostgreSQL (or SQLite)

AI Engine: Google Gemini API (gemini-2.5-flash-preview)

Output Engine: Typst CLI for on-the-fly PDF generation.

🚀 Getting Started

Prerequisites

Ruby (3.x or higher)

Ruby on Rails 7+

Typst CLI installed and accessible in your system's PATH

A Google Gemini API Key

Installation

Clone the repository:

git clone [https://github.com/yourusername/handshake.git](https://github.com/yourusername/handshake.git)
cd handshake

Install dependencies:

bundle install

Database setup:

bin/rails db:setup

Environment Variables:
Create a .env file in the root directory and add your Gemini API key:

GEMINI_API_KEY=your_gemini_api_key_here

Run the development server:
Start the Rails server along with the Tailwind watch process:

bin/dev

Usage

Sign Up/In: Create an account to securely store your profile.

Build your Profile: Navigate to "The Library" and add your skills and projects. Paste your base Typst template into the "Blueprint Template" tab.

Adapt: Go to "Apply", type the company name, paste the job description, and hit adapt.

Download: Once Handshake is done brewing your pitch, click the download button to grab your perfectly typeset PDF.
