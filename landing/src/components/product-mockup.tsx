"use client"

import * as React from "react"
import { motion, AnimatePresence } from "framer-motion"
import {
  House,
  FileUp,
  Lightbulb,
  FolderOpen,
  User,
  Search,
  FileText,
  ChevronRight,
  Zap,
  Lock,
  Wifi,
  Battery,
  Signal,
  ArrowDownUp,
  Clipboard,
  FileQuestion,
  BookOpenCheck,
  StickyNote,
  Rocket,
  SlidersHorizontal,
  ListChecks,
  Award,
  Shield,
  Scan,
} from "lucide-react"

type TabType = "home" | "upload" | "idealab" | "library" | "profile"

/* ─── tiny helpers ─────────────────────────────────────────────────── */
function StatCard({ icon, count, label, iconBg }: { icon: React.ReactNode; count: string; label: string; iconBg: string }) {
  return (
    <div className="flex-1 bg-[#FCFAFF] dark:bg-[#171923] rounded-2xl p-2.5 flex flex-col gap-1.5 shadow-sm border border-[#E7DDFD] dark:border-[#2A2D3A]">
      <div className={`w-7 h-7 rounded-xl flex items-center justify-center ${iconBg}`}>{icon}</div>
      <p className="text-base font-bold text-[#111827] dark:text-[#F8FAFC] leading-none">{count}</p>
      <p className="text-[10px] text-[#6B7280] dark:text-[#A1A1AA]">{label}</p>
    </div>
  )
}

function UploadMethodRow({ icon, iconBg, title, desc }: { icon: React.ReactNode; iconBg: string; title: string; desc: string }) {
  return (
    <div className="flex items-center gap-3 bg-[#FCFAFF] dark:bg-[#171923] rounded-2xl p-3 shadow-sm border border-[#E7DDFD] dark:border-[#2A2D3A]">
      <div className={`w-9 h-9 rounded-2xl flex items-center justify-center shrink-0 ${iconBg}`}>{icon}</div>
      <div className="flex-1 min-w-0">
        <p className="text-[12px] font-bold text-[#111827] dark:text-[#F8FAFC]">{title}</p>
        <p className="text-[10px] text-[#6B7280] dark:text-[#A1A1AA] leading-tight mt-0.5">{desc}</p>
      </div>
      <span className="text-[9px] font-semibold text-emerald-600 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-full shrink-0">Ready</span>
    </div>
  )
}

function IdeaModeRow({ icon, iconBg, title }: { icon: React.ReactNode; iconBg: string; title: string }) {
  return (
    <div className="flex items-center gap-3 bg-[#FCFAFF] dark:bg-[#171923] rounded-2xl p-3 shadow-sm border border-[#E7DDFD] dark:border-[#2A2D3A]">
      <div className={`w-8 h-8 rounded-2xl flex items-center justify-center shrink-0 ${iconBg}`}>{icon}</div>
      <p className="flex-1 text-[12px] font-semibold text-[#111827] dark:text-[#F8FAFC]">{title}</p>
      <ChevronRight className="w-4 h-4 text-[#6B7280] dark:text-[#71717A] shrink-0" />
    </div>
  )
}

function LibraryItem({ iconBg, icon, title, type, time, source }: { iconBg: string; icon: React.ReactNode; title: string; type: string; time: string; source: string }) {
  return (
    <div className="flex items-center gap-3 bg-[#FCFAFF] dark:bg-[#171923] rounded-2xl p-3 shadow-sm border border-[#E7DDFD] dark:border-[#2A2D3A]">
      <div className={`w-9 h-9 rounded-2xl flex items-center justify-center shrink-0 ${iconBg}`}>{icon}</div>
      <div className="flex-1 min-w-0">
        <p className="text-[11px] font-bold text-[#111827] dark:text-[#F8FAFC] truncate">{title}</p>
        <p className="text-[9px] text-[#6B7280] dark:text-[#A1A1AA]">{type} · {time}</p>
        <div className="flex items-center gap-1 mt-0.5">
          <FileText className="w-2.5 h-2.5 text-[#6B7280] dark:text-[#71717A]" />
          <p className="text-[9px] text-[#6B7280] dark:text-[#A1A1AA] truncate">{source}</p>
        </div>
      </div>
    </div>
  )
}

/* ─── Screens ──────────────────────────────────────────────────────── */

function HomeScreen() {
  return (
    <motion.div key="home" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} transition={{ duration: 0.2 }} className="p-3 space-y-3 overflow-y-auto h-full">

      {/* Offline banner */}
      <div className="rounded-2xl bg-[#5B4FD9] p-4 flex items-start gap-3">
        <div className="w-10 h-10 rounded-full border-2 border-white/60 flex items-center justify-center shrink-0 mt-0.5">
          <div className="w-5 h-5 rounded-full border-2 border-white/80 flex items-center justify-center">
            <div className="w-2 h-2 rounded-full bg-white" />
          </div>
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-[13px] font-bold text-white leading-tight">Offline study workspace</p>
          <p className="text-[10px] text-white/70 mt-0.5 leading-tight">Everything you create stays private on this device.</p>
          <div className="flex gap-2 mt-2">
            <span className="text-[9px] font-semibold text-white/90 border border-white/30 rounded-full px-2.5 py-0.5">Local-first</span>
            <span className="text-[9px] font-semibold text-white/90 border border-white/30 rounded-full px-2.5 py-0.5">On-device ready</span>
          </div>
        </div>
      </div>

      {/* Explore tools */}
      <div>
        <p className="text-[13px] font-bold text-[#111827] dark:text-[#F8FAFC] mb-2">Explore tools</p>
        <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-none">
          {/* Upload notes card */}
          <div className="w-28 shrink-0 bg-[#C8C5F5] rounded-2xl p-3 flex flex-col justify-between" style={{ minHeight: "90px" }}>
            <div className="w-7 h-7 bg-white/50 rounded-xl flex items-center justify-center">
              <FileUp className="w-3.5 h-3.5 text-[#5B4FD9]" />
            </div>
            <p className="text-[11px] font-bold text-gray-900 mt-3">Upload notes</p>
          </div>
          {/* Paste text card */}
          <div className="w-28 shrink-0 bg-[#CEDE8C] rounded-2xl p-3 flex flex-col justify-between" style={{ minHeight: "90px" }}>
            <div className="w-7 h-7 bg-white/50 rounded-xl flex items-center justify-center">
              <Clipboard className="w-3.5 h-3.5 text-gray-700" />
            </div>
            <p className="text-[11px] font-bold text-gray-900 mt-3">Paste text</p>
          </div>
          {/* Quick quiz card */}
          <div className="w-28 shrink-0 bg-[#F4B89A] rounded-2xl p-3 flex flex-col justify-between" style={{ minHeight: "90px" }}>
            <div className="w-7 h-7 bg-white/50 rounded-xl flex items-center justify-center">
              <FileQuestion className="w-3.5 h-3.5 text-gray-700" />
            </div>
            <p className="text-[11px] font-bold text-gray-900 mt-3">Quick quiz</p>
          </div>
        </div>
      </div>

      {/* Your progress */}
      <div>
        <p className="text-[13px] font-bold text-[#111827] dark:text-[#F8FAFC] mb-2">Your progress</p>
        <div className="flex gap-2">
          <StatCard icon={<StickyNote className="w-3.5 h-3.5 text-violet-500" />} iconBg="bg-violet-100" count="15" label="Notes" />
          <StatCard icon={<BookOpenCheck className="w-3.5 h-3.5 text-emerald-500" />} iconBg="bg-emerald-100" count="25" label="Flashcards" />
          <StatCard icon={<Lightbulb className="w-3.5 h-3.5 text-rose-400" />} iconBg="bg-rose-100" count="2" label="Ideas" />
        </div>
      </div>

      {/* Revision */}
      <div>
        <p className="text-[13px] font-bold text-[#111827] dark:text-[#F8FAFC] mb-2">Revision</p>
        <div className="flex items-center gap-3 bg-[#5B4FD9] rounded-2xl p-3.5">
          <div className="w-8 h-8 bg-white/20 rounded-xl flex items-center justify-center shrink-0">
            <Zap className="w-4 h-4 text-white" />
          </div>
          <div className="flex-1">
            <p className="text-[12px] font-bold text-white">18 cards due for review</p>
            <p className="text-[10px] text-white/70">Tap to review now</p>
          </div>
          <ChevronRight className="w-4 h-4 text-white/60 shrink-0" />
        </div>
      </div>
    </motion.div>
  )
}

function UploadScreen() {
  return (
    <motion.div key="upload" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} transition={{ duration: 0.2 }} className="p-3 space-y-2.5 overflow-y-auto h-full">
      <div className="mb-1">
        <p className="text-[15px] font-bold text-[#111827] dark:text-[#F8FAFC]">Upload</p>
        <p className="text-[10px] text-[#6B7280] dark:text-[#A1A1AA] mt-0.5">Turn notes into summaries, flashcards and tools.</p>
      </div>

      <UploadMethodRow
        icon={<Clipboard className="w-4 h-4 text-violet-500" />}
        iconBg="bg-violet-100"
        title="Paste text"
        desc="Drop in lecture notes or any text."
      />
      <UploadMethodRow
        icon={<span className="text-[10px] font-bold text-lime-700 bg-lime-200 px-1 py-0.5 rounded">PDF</span>}
        iconBg="bg-lime-100"
        title="Upload PDF"
        desc="Import a text-based PDF and extract its text."
      />
      <UploadMethodRow
        icon={<Scan className="w-4 h-4 text-orange-500" />}
        iconBg="bg-orange-100"
        title="Scan notes"
        desc="Extract text from clear printed English notes."
      />
      <UploadMethodRow
        icon={<FolderOpen className="w-4 h-4 text-teal-500" />}
        iconBg="bg-teal-100"
        title="Import from files"
        desc="Bring in a saved .txt document."
      />

      {/* Privacy notice */}
      <div className="flex items-center gap-3 bg-violet-500/10 dark:bg-violet-900/20 border border-violet-200 dark:border-violet-800 rounded-2xl p-3">
        <div className="w-8 h-8 bg-violet-500 rounded-2xl flex items-center justify-center shrink-0">
          <Shield className="w-4 h-4 text-white" />
        </div>
        <p className="text-[10px] text-gray-600 leading-snug">Local-first processing. Nothing is sent to a server.</p>
      </div>
    </motion.div>
  )
}

function IdeaLabScreen() {
  return (
    <motion.div key="idealab" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} transition={{ duration: 0.2 }} className="p-3 space-y-3 overflow-y-auto h-full">
      <div className="mb-1">
        <p className="text-[15px] font-bold text-[#111827] dark:text-[#F8FAFC]">Idea Lab</p>
        <p className="text-[10px] text-[#6B7280] dark:text-[#A1A1AA] mt-0.5">Your on-device innovation coach.</p>
      </div>

      {/* Hero card */}
      <div className="bg-[#C8C5F5] rounded-2xl p-4">
        <div className="w-9 h-9 bg-white/40 rounded-2xl flex items-center justify-center mb-3">
          <Rocket className="w-5 h-5 text-[#5B4FD9]" />
        </div>
        <p className="text-[13px] font-bold text-gray-900">Build your next project idea</p>
        <p className="text-[10px] text-gray-600 mt-1 leading-snug">Go from a blank page to a plan you can put on your CV.</p>
      </div>

      {/* Choose a mode */}
      <p className="text-[13px] font-bold text-gray-900">Choose a mode</p>

      <IdeaModeRow
        icon={<span className="text-violet-500">✦</span>}
        iconBg="bg-violet-100"
        title="Generate new idea"
      />
      <IdeaModeRow
        icon={<SlidersHorizontal className="w-4 h-4 text-teal-500" />}
        iconBg="bg-teal-100"
        title="Improve my idea"
      />
      <IdeaModeRow
        icon={<ListChecks className="w-4 h-4 text-emerald-500" />}
        iconBg="bg-emerald-100"
        title="Turn into a project plan"
      />
      <IdeaModeRow
        icon={<Award className="w-4 h-4 text-rose-400" />}
        iconBg="bg-rose-100"
        title="Make it CV-worthy"
      />
    </motion.div>
  )
}

function LibraryScreen() {
  const [activeFilter, setActiveFilter] = React.useState("All")
  const filters = ["All", "Notes", "Summaries", "Flashcards"]

  return (
    <motion.div key="library" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} transition={{ duration: 0.2 }} className="p-3 space-y-2.5 overflow-y-auto h-full">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-[15px] font-bold text-[#111827] dark:text-[#F8FAFC]">Library</p>
          <p className="text-[10px] text-[#6B7280] dark:text-[#A1A1AA] mt-0.5">Everything you create, in one place.</p>
        </div>
        <span className="flex items-center gap-1 text-[9px] font-semibold text-emerald-600 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-full mt-1">
          <Lock className="w-2.5 h-2.5" /> On device
        </span>
      </div>

      {/* Search */}
      <div className="flex items-center gap-2 bg-[#FFFFFF] dark:bg-[#1D2030] border border-[#E7DDFD] dark:border-[#2A2D3A] rounded-2xl px-3 py-2 shadow-sm">
        <Search className="w-3.5 h-3.5 text-[#6B7280] dark:text-[#A1A1AA] shrink-0" />
        <span className="text-[11px] text-[#6B7280] dark:text-[#A1A1AA]">Search your library</span>
      </div>

      {/* Filter pills */}
      <div className="flex gap-1.5 overflow-x-auto scrollbar-none pb-0.5">
        {filters.map((f) => (
          <button
            key={f}
            onClick={() => setActiveFilter(f)}
            className={`shrink-0 text-[10px] font-semibold px-3 py-1 rounded-full border transition-all ${activeFilter === f ? "bg-[#591EE8] text-white border-[#591EE8]" : "bg-[#FCFAFF] dark:bg-[#1D2030] text-[#111827] dark:text-[#F8FAFC] border-[#E7DDFD] dark:border-[#2A2D3A]"}`}
          >
            {f}
          </button>
        ))}
      </div>

      {/* Sort row */}
      <div className="flex items-center justify-between text-[10px] text-[#6B7280] dark:text-[#A1A1AA]">
        <span>60 items</span>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-1 text-[#591EE8] dark:text-[#818CF8] font-semibold">
            <SlidersHorizontal className="w-3 h-3" /> Source
          </button>
          <button className="flex items-center gap-1 text-[#591EE8] dark:text-[#818CF8] font-semibold">
            <ArrowDownUp className="w-3 h-3" /> Newest
          </button>
        </div>
      </div>

      {/* Items */}
      <div className="space-y-2">
        <LibraryItem
          iconBg="bg-violet-100"
          icon={<FileQuestion className="w-4 h-4 text-violet-500" />}
          title="Quiz: guidedread017"
          type="Quiz"
          time="16h ago"
          source="guidedread017.pdf"
        />
        <LibraryItem
          iconBg="bg-teal-100"
          icon={<BookOpenCheck className="w-4 h-4 text-teal-500" />}
          title="guidedread017"
          type="Summary"
          time="16h ago"
          source="guidedread017.pdf"
        />
        <LibraryItem
          iconBg="bg-indigo-100"
          icon={<StickyNote className="w-4 h-4 text-indigo-500" />}
          title="guidedread017"
          type="Note"
          time="16h ago"
          source="guidedread017.pdf"
        />
        <LibraryItem
          iconBg="bg-violet-100"
          icon={<FileQuestion className="w-4 h-4 text-violet-500" />}
          title="Quiz: Screenshot_20260615_02…"
          type="Quiz"
          time="1d ago"
          source="Screenshot_20260615_020000_Insta…"
        />
      </div>
    </motion.div>
  )
}

function ProfileScreen() {
  return (
    <motion.div key="profile" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} transition={{ duration: 0.2 }} className="p-3 space-y-3 overflow-y-auto h-full">
      <p className="text-[15px] font-bold text-[#111827] dark:text-[#F8FAFC]">Profile</p>

      {/* Avatar */}
      <div className="flex flex-col items-center gap-2 py-3">
        <div className="w-16 h-16 rounded-full bg-[#5B4FD9] flex items-center justify-center shadow-lg">
          <User className="w-8 h-8 text-white" />
        </div>
        <div className="text-center">
          <p className="text-[13px] font-bold text-[#111827] dark:text-[#F8FAFC]">Student</p>
          <p className="text-[10px] text-[#6B7280] dark:text-[#A1A1AA]">Local account · no sign-in required</p>
        </div>
      </div>

      {/* Stats row */}
      <div className="flex gap-2">
        <div className="flex-1 bg-violet-50 border border-violet-100 rounded-2xl p-3 text-center">
          <p className="text-[16px] font-bold text-[#5B4FD9]">15</p>
          <p className="text-[9px] text-gray-400">Notes</p>
        </div>
        <div className="flex-1 bg-emerald-50 border border-emerald-100 rounded-2xl p-3 text-center">
          <p className="text-[16px] font-bold text-emerald-600">25</p>
          <p className="text-[9px] text-gray-400">Flashcards</p>
        </div>
        <div className="flex-1 bg-rose-50 border border-rose-100 rounded-2xl p-3 text-center">
          <p className="text-[16px] font-bold text-rose-500">2</p>
          <p className="text-[9px] text-gray-400">Ideas</p>
        </div>
      </div>

      {/* Study streak */}
      <div className="flex items-center gap-3 bg-amber-50 border border-amber-100 rounded-2xl p-3">
        <div className="w-9 h-9 bg-amber-400 rounded-2xl flex items-center justify-center shrink-0">
          <Zap className="w-5 h-5 text-white" />
        </div>
        <div>
          <p className="text-[12px] font-bold text-[#111827] dark:text-[#F8FAFC]">7-day study streak 🔥</p>
          <p className="text-[10px] text-[#6B7280] dark:text-[#A1A1AA]">Keep it up! Review cards daily.</p>
        </div>
      </div>

      {/* Privacy badge */}
      <div className="flex items-center gap-3 bg-violet-50 border border-violet-100 rounded-2xl p-3">
        <div className="w-8 h-8 bg-[#5B4FD9] rounded-2xl flex items-center justify-center shrink-0">
          <Shield className="w-4 h-4 text-white" />
        </div>
        <div>
          <p className="text-[12px] font-bold text-[#111827] dark:text-[#F8FAFC]">100% Private</p>
          <p className="text-[10px] text-[#6B7280] dark:text-[#A1A1AA] leading-snug">All data stays on this device. Zero cloud sync.</p>
        </div>
      </div>

      {/* Settings rows */}
      {[
        { label: "App version", value: "v1.0.0" },
        { label: "Storage used", value: "24 MB" },
        { label: "Clear all data", value: "" },
      ].map((row) => (
        <div key={row.label} className="flex items-center justify-between bg-[#FCFAFF] dark:bg-[#171923] border border-[#E7DDFD] dark:border-[#2A2D3A] rounded-2xl px-3 py-2.5 shadow-sm">
          <p className="text-[11px] font-semibold text-[#111827] dark:text-[#F8FAFC]">{row.label}</p>
          <p className="text-[11px] text-[#6B7280] dark:text-[#A1A1AA]">{row.value}</p>
        </div>
      ))}
    </motion.div>
  )
}

/* ─── Main Component ───────────────────────────────────────────────── */
export function ProductMockup() {
  const [activeTab, setActiveTab] = React.useState<TabType>("home")

  const navItems: { id: TabType; icon: React.ComponentType<any>; label: string }[] = [
    { id: "home",    icon: House,       label: "Home" },
    { id: "upload",  icon: FileUp,      label: "Upload" },
    { id: "idealab", icon: Lightbulb,   label: "Idea Lab" },
    { id: "library", icon: FolderOpen,  label: "Library" },
    { id: "profile", icon: User,        label: "Profile" },
  ]

  return (
    /* Phone outer frame */
    <div className="w-[280px] sm:w-[300px]">
      <div className="relative rounded-[40px] bg-[#0E0F14] p-[10px] shadow-[0_0_0_2px_#333,0_30px_80px_rgba(0,0,0,0.6)] ring-1 ring-white/5">

        {/* Side buttons */}
        <div className="absolute -left-[3px] top-[100px] w-[3px] h-8 rounded-l-full bg-[#2A2D3A]" />
        <div className="absolute -left-[3px] top-[148px] w-[3px] h-12 rounded-l-full bg-[#2A2D3A]" />
        <div className="absolute -left-[3px] top-[210px] w-[3px] h-12 rounded-l-full bg-[#2A2D3A]" />
        <div className="absolute -right-[3px] top-[140px] w-[3px] h-16 rounded-r-full bg-[#2A2D3A]" />

        {/* Screen – light-mode app UI */}
        <div className="overflow-hidden rounded-[32px] bg-[#F7F4FF] dark:bg-[#0E0F14] flex flex-col" style={{ height: "620px" }}>

          {/* Status Bar */}
          <div className="flex items-center justify-between px-5 pt-3 pb-1 shrink-0 bg-[#F7F4FF] dark:bg-[#0E0F14]">
            <span className="text-[11px] font-semibold text-[#111827] dark:text-[#F8FAFC]">9:41</span>
            <div className="flex items-center space-x-1.5">
              <Signal className="w-3 h-3 text-[#111827] dark:text-[#F8FAFC]" />
              <Wifi className="w-3 h-3 text-[#111827] dark:text-[#F8FAFC]" />
              <Battery className="w-3.5 h-3.5 text-[#111827] dark:text-[#F8FAFC]" />
            </div>
          </div>

          {/* Scrollable content */}
          <div className="flex-1 overflow-hidden">
            <AnimatePresence mode="wait">
              {activeTab === "home"    && <HomeScreen />}
              {activeTab === "upload"  && <UploadScreen />}
              {activeTab === "idealab" && <IdeaLabScreen />}
              {activeTab === "library" && <LibraryScreen />}
              {activeTab === "profile" && <ProfileScreen />}
            </AnimatePresence>
          </div>

          {/* Bottom Navigation Bar */}
          <div className="shrink-0 bg-[#FFFFFF] dark:bg-[#12131A] border-t border-[#E7DDFD] dark:border-[#2A2D3A]">
            <div className="flex items-center justify-around px-1 py-2">
              {navItems.map((item) => {
                const Icon = item.icon
                const isActive = activeTab === item.id
                return (
                  <button
                    key={item.id}
                    onClick={() => setActiveTab(item.id)}
                    className="flex flex-col items-center gap-0.5 px-2 py-1 transition-all duration-200"
                  >
                    <div className={`w-8 h-7 flex items-center justify-center rounded-full transition-all duration-200 ${isActive ? "bg-[#591EE8]" : ""}`}>
                      <Icon className={`w-4 h-4 transition-all ${isActive ? "text-white scale-110" : "text-[#6B7280] dark:text-[#71717A]"}`} />
                    </div>
                    <span className={`text-[8px] font-semibold transition-colors ${isActive ? "text-[#591EE8] dark:text-[#818CF8]" : "text-[#6B7280] dark:text-[#71717A]"}`}>{item.label}</span>
                  </button>
                )
              })}
            </div>
            {/* iOS home indicator */}
            <div className="flex justify-center pb-2">
              <div className="w-24 h-1 rounded-full bg-[#E7DDFD] dark:bg-[#2A2D3A]" />
            </div>
          </div>

        </div>
      </div>
    </div>
  )
}
