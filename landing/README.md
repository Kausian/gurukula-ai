# Gurukula AI - Offline-First AI Learning Assistant

Gurukula AI is an offline-first AI learning assistant designed specifically for students. It enables students to learn, study, brainstorm ideas, and organize their knowledge in a private study environment, even without an active internet connection.

This project is a premium SaaS/AI startup landing page built with modern frontend tools, full responsive support, clean typography, smooth animations, and automatic light/dark modes.

---

## 🚀 Technology Stack & Libraries

Here are the specific libraries and versions used to build this project:

### Core Framework
- **Next.js**: `16.2.9`
- **React**: `19.2.4`
- **React DOM**: `19.2.4`

### Styling & Animations
- **Tailwind CSS**: `^4` (with `@tailwindcss/postcss: ^4`)
- **Framer Motion**: `^12.40.0`
- **tw-animate-css**: `^1.4.0`

### 3D & WebGL (Particle Animations)
- **Three.js**: `^0.184.0`
- **@react-three/fiber**: `^9.6.1`
- **@react-three/drei**: `^10.7.7`
- **@react-three/postprocessing**: `^3.0.4`

### UI & Icons
- **shadcn/ui**: `^4.11.0` (with `radix-ui: ^1.6.0`)
- **Lucide React**: `^1.21.0` (for icons)
- **next-themes**: `^0.4.6` (for Light/Dark mode)
- **clsx**: `^2.1.1`
- **tailwind-merge**: `^3.6.0`
- **class-variance-authority**: `^0.7.1`

---

## ✨ Components Overview

This project is built using a modular component structure located inside `src/components/`.

### 1. Custom Global Components
- `Antigravity.tsx`: Handles specific animation or layout logic.
- `animated-text.tsx`: Reusable text animation components.
- `particalAnimation.tsx`: The 3D constellation/particle animation background.
- `product-mockup.tsx`: The interactive desktop app simulation.
- `scroll-reveal.tsx`: Wrapper for revealing elements on scroll.
- `theme-provider.tsx`: Context provider for dark/light mode.
- `theme-toggle.tsx`: The switch to toggle between themes.

### 2. Section Components (`src/components/sections/`)
These represent the different visual blocks of the landing page:
- `hero.tsx`: The top section with the headline, CTA, and `product-mockup`.
- `features.tsx`: Grid highlighting key Gurukula AI features.
- `showcase.tsx`: Interactive tour displaying mockups of different app screens.
- `how-it-works.tsx`: Step-by-step timeline of usage.
- `why-us.tsx`: Comparison table against traditional cloud AI.
- `benefits.tsx`: Real-world student use cases.
- `about.tsx`: Vision and mission behind the app.
- `faq.tsx`: Frequently asked questions accordion.
- `cta.tsx`: The final call-to-action block.

### 3. UI Primitives (`src/components/ui/`)
Accessible, reusable UI components mostly sourced from shadcn/ui:
- `accordion.tsx`
- `button.tsx`
- `card.tsx`
- `dropdown-menu.tsx`
- `tabs.tsx`

---

## 🛠️ Local Setup Instructions

Follow these steps to get the project running on your local machine:

### Prerequisites
Make sure you have installed:
- **Node.js** (v18.x, v20.x, or v22.x recommended)
- **npm** (bundled with Node.js)

### Step 1: Clone the Repository
Open your terminal and navigate to your workspace directory, then clone the project (or navigate into it if you already have the files):
```bash
cd "Gurukula AI"
```

### Step 2: Install Dependencies
Run the following command to download all the libraries mentioned in the Technology Stack section:
```bash
npm install
```

### Step 3: Start the Development Server
To start the app in development mode with hot-reloading:
```bash
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) in your browser to view the landing page.

### Step 4: Build for Production (Optional)
If you want to test the optimized production build locally:
```bash
npm run build
npm run start
```

---

## 🎨 Theme Configuration

The page defaults to **Dark Mode** (`defaultTheme="dark"`), matching the premium developer/AI-startup aesthetic of OpenAI, Linear, and Perplexity. The user can switch to Light Mode at any time using the theme toggle in the header, which seamlessly updates the entire UI via CSS variables.
