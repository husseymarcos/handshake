import React, { useState, useEffect } from 'react';
import { initializeApp } from 'firebase/app';
import {
  getAuth,
  onAuthStateChanged,
  signInWithCustomToken,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut
} from 'firebase/auth';
import {
  getFirestore,
  doc,
  setDoc,
  onSnapshot,
  collection,
  addDoc
} from 'firebase/firestore';
import {
  Copy,
  Check,
  X,
  LogOut,
  Loader2,
  Briefcase,
  History,
  User,
  ArrowRight,
  ChevronDown,
  ChevronUp,
  Clapperboard,
  Handshake
} from 'lucide-react';

// --- Environment Variables ---
const apiKey = "";
const firebaseConfig = typeof __firebase_config !== 'undefined' ? JSON.parse(__firebase_config) : {};
const appId = typeof __app_id !== 'undefined' ? __app_id : 'handshake-cv-app';

// --- Initialize Firebase ---
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

const DEFAULT_BLUEPRINT = `#let resume(
  name: "",
  title: "",
  contact: (),
  body
) = {
  set document(title: name + " - Resume")
  set page(margin: (x: 1.5cm, y: 1.5cm))
  set text(font: "Linux Libertine", size: 11pt)

  align(center)[
    #text(size: 24pt, weight: "bold")[#name]
    #v(0.5em)
    #text(size: 14pt, style: "italic")[#title]
    #v(0.5em)
    #contact.join("  |  ")
  ]
  v(1em)
  body
}

#show: resume.with(
  name: "Alex Developer",
  title: "Software Engineer",
  contact: (
    "alex.dev@email.com",
    "github.com/alexdev",
    "linkedin.com/in/alexdev"
  )
)

== Summary
Software Engineer with expertise in building scalable applications and robust backend systems.

== Skills
- *Programming:* [Skills injected here]
- *Tools:* Git, Docker

== Projects
=== [Project Title]
_[Year]_
- [Project Description]
- *Stack:* [Project Stack]
`;

export default function App() {
  // Auth State
  const [user, setUser] = useState(null);
  const [authLoading, setAuthLoading] = useState(true);
  const [isLoginMode, setIsLoginMode] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [authError, setAuthError] = useState('');

  // Navigation State
  const [currentView, setCurrentView] = useState('apply'); // 'apply', 'history', 'profile'
  const [profileTab, setProfileTab] = useState('skills');

  // Profile Data State
  const [skills, setSkills] = useState([]);
  const [newSkill, setNewSkill] = useState('');
  const [projects, setProjects] = useState([]);
  const [projectForm, setProjectForm] = useState({
    name: '', year: '', title: '', description: '', stack: '', github_url: ''
  });
  const [blueprint, setBlueprint] = useState(DEFAULT_BLUEPRINT);
  const [isSavingProfile, setIsSavingProfile] = useState(false);
  const [profileSaveMsg, setProfileSaveMsg] = useState('');

  // Generator & History State
  const [companyName, setCompanyName] = useState('');
  const [gig, setGig] = useState('');
  const [generatedCV, setGeneratedCV] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);
  const [genError, setGenError] = useState('');
  const [copied, setCopied] = useState(false);

  const [history, setHistory] = useState([]);
  const [expandedHistoryId, setExpandedHistoryId] = useState(null);

  // --- Firebase Authentication Effect ---
  useEffect(() => {
    const initAuth = async () => {
      try {
        if (typeof __initial_auth_token !== 'undefined' && __initial_auth_token) {
          await signInWithCustomToken(auth, __initial_auth_token);
        }
      } catch (err) {
        console.error("Custom token auth failed:", err);
      } finally {
        setAuthLoading(false);
      }
    };
    initAuth();

    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
      setAuthLoading(false);
    });
    return () => unsubscribe();
  }, []);

  // --- Firebase Data Fetching Effect (Profile & History) ---
  useEffect(() => {
    if (!user) return;

    // Fetch Profile
    const profileRef = doc(db, 'artifacts', appId, 'users', user.uid, 'profile', 'data');
    const unsubProfile = onSnapshot(profileRef, (docSnap) => {
      if (docSnap.exists()) {
        const data = docSnap.data();
        if (data.skills) setSkills(data.skills);
        if (data.projects) setProjects(data.projects);
        if (data.template) setBlueprint(data.template);
      } else {
        setBlueprint(DEFAULT_BLUEPRINT);
      }
    }, (error) => {
      console.error("Error fetching profile:", error);
    });

    // Fetch History
    const historyRef = collection(db, 'artifacts', appId, 'users', user.uid, 'history');
    const unsubHistory = onSnapshot(historyRef, (snap) => {
      const items = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      // Sort descending by date in memory (Rule 2: No complex queries)
      items.sort((a, b) => b.createdAt - a.createdAt);
      setHistory(items);
    }, (error) => {
      console.error("Error fetching history:", error);
    });

    return () => {
      unsubProfile();
      unsubHistory();
    };
  }, [user]);

  // --- Handlers ---
  const handleAuthSubmit = async (e) => {
    e.preventDefault();
    setAuthError('');
    setAuthLoading(true);
    try {
      if (isLoginMode) {
        await signInWithEmailAndPassword(auth, email, password);
      } else {
        await createUserWithEmailAndPassword(auth, email, password);
      }
    } catch (err) {
      setAuthError(err.message.replace('Firebase: ', ''));
    } finally {
      setAuthLoading(false);
    }
  };

  const handleSignOut = () => signOut(auth);

  const saveProfileData = async (updatedSkills, updatedProjects, updatedTemplate) => {
    if (!user) return;
    setIsSavingProfile(true);
    setProfileSaveMsg('');
    try {
      const profileRef = doc(db, 'artifacts', appId, 'users', user.uid, 'profile', 'data');
      await setDoc(profileRef, {
        skills: updatedSkills,
        projects: updatedProjects,
        template: updatedTemplate
      }, { merge: true });
      setProfileSaveMsg('Saved');
      setTimeout(() => setProfileSaveMsg(''), 3000);
    } catch (err) {
      console.error("Error saving profile:", err);
      setProfileSaveMsg('Error');
    } finally {
      setIsSavingProfile(false);
    }
  };

  const handleAddSkill = (e) => {
    e.preventDefault();
    if (newSkill.trim() && !skills.includes(newSkill.trim())) {
      const newSkills = [...skills, newSkill.trim()];
      setSkills(newSkills);
      saveProfileData(newSkills, projects, blueprint);
    }
    setNewSkill('');
  };

  const removeSkill = (skillToRemove) => {
    const newSkills = skills.filter(s => s !== skillToRemove);
    setSkills(newSkills);
    saveProfileData(newSkills, projects, blueprint);
  };

  const handleAddProject = (e) => {
    e.preventDefault();
    if (!projectForm.name) return;
    const newProjects = [...projects, { ...projectForm }];
    setProjects(newProjects);
    saveProfileData(skills, newProjects, blueprint);
    setProjectForm({ name: '', year: '', title: '', description: '', stack: '', github_url: '' });
  };

  const removeProject = (index) => {
    const newProjects = [...projects];
    newProjects.splice(index, 1);
    setProjects(newProjects);
    saveProfileData(skills, newProjects, blueprint);
  };

  const handleProjectFormChange = (e) => {
    setProjectForm({ ...projectForm, [e.target.name]: e.target.value });
  };

  const handleTemplateSave = () => {
    saveProfileData(skills, projects, blueprint);
  };

  const generateWithRetry = async (prompt, retries = 5) => {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=${apiKey}`;
    const payload = {
      contents: [{ parts: [{ text: prompt }] }],
      systemInstruction: {
        parts: [{
          text: "You are an expert technical recruiter and resume writer. Your task is to output ONLY raw, valid Typst code. Do not include markdown code blocks like ```typst. Ensure the CV fits on one page and perfectly aligns the user's profile with the job description keywords. Output clean Typst."
        }]
      }
    };

    let delay = 1000;
    for (let i = 0; i < retries; i++) {
      try {
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });

        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

        const data = await response.json();
        let text = data.candidates?.[0]?.content?.parts?.[0]?.text || '';

        text = text.replace(/^```typst\n/g, '').replace(/^```\n/g, '').replace(/```$/g, '');
        return text;
      } catch (err) {
        if (i === retries - 1) throw err;
        await new Promise(resolve => setTimeout(resolve, delay));
        delay *= 2;
      }
    }
  };

  const handleGenerate = async () => {
    if (!companyName.trim()) {
      setGenError('Who are you applying to? Add a company name.');
      return;
    }
    if (!gig.trim()) {
      setGenError('What do they want? Paste a job description.');
      return;
    }

    setIsGenerating(true);
    setGenError('');
    setGeneratedCV(''); // Clear previous run to trigger transition if wanted

    const profileText = `
Skills: ${skills.join(', ')}

Projects:
${projects.map(p => `
- Name: ${p.name} (${p.year})
  Title: ${p.title}
  Description: ${p.description}
  Stack: ${p.stack}
  GitHub: ${p.github_url || 'N/A'}`).join('\n')}
`;

    const prompt = `
Given the following Template (Typst format), a Knowledge Base (skills and projects), and a Target Job (Job Description) for the company "${companyName}".
Please adapt the Template to perfectly match the Target Job. 
- Select the most relevant skills and projects from the Knowledge Base.
- Rewrite the Summary and Experience/Project bullet points naturally incorporating keywords from the Target Job.
- Keep the structure of the Template intact, but modify the content for optimization.
- Return ONLY the final Typst code.

--- TEMPLATE ---
${blueprint}

--- KNOWLEDGE BASE ---
${profileText}

--- TARGET JOB ---
${gig}
`;

    try {
      const result = await generateWithRetry(prompt);
      setGeneratedCV(result);

      // Save to History
      if (user) {
        await addDoc(collection(db, 'artifacts', appId, 'users', user.uid, 'history'), {
          companyName: companyName.trim(),
          gig: gig.trim(),
          content: result,
          createdAt: Date.now()
        });
      }

    } catch (err) {
      setGenError('An error occurred. The hive mind is resting.');
      console.error(err);
    } finally {
      setIsGenerating(false);
    }
  };

  const copyToClipboard = (text) => {
    document.execCommand('copy');
    navigator.clipboard.writeText(text).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  };

  // --- Auth UI View ---
  if (authLoading) {
    return (
      <div className="min-h-screen bg-[#FDFCF8] flex items-center justify-center">
        <Loader2 className="animate-spin text-gray-300" size={48} />
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-[#FDFCF8] flex flex-col items-center justify-center p-6 font-sans">
        <div className="w-full max-w-md bg-white p-12 rounded-3xl shadow-sm border border-gray-100">
          <h1 className="text-5xl font-black text-blue-600 mb-10 text-center tracking-tight">Handshake.</h1>

          <form onSubmit={handleAuthSubmit} className="space-y-6">
            <div>
              <input
                type="email"
                required
                placeholder="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full bg-gray-50 border-2 border-transparent focus:border-blue-600 rounded-xl px-5 py-4 text-lg text-black placeholder:text-gray-400 focus:outline-none transition-all"
              />
            </div>
            <div>
              <input
                type="password"
                required
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-gray-50 border-2 border-transparent focus:border-blue-600 rounded-xl px-5 py-4 text-lg text-black placeholder:text-gray-400 focus:outline-none transition-all"
              />
            </div>

            {authError && (
              <div className="text-red-600 text-base font-medium py-2 text-center">
                {authError}
              </div>
            )}

            <button
              type="submit"
              className="w-full py-4 bg-blue-600 hover:bg-blue-700 text-white text-xl font-bold rounded-xl transition-colors mt-4 shadow-lg shadow-blue-600/20"
            >
              {isLoginMode ? 'Log In' : 'Sign Up'}
            </button>
          </form>

          <div className="mt-8 text-center">
            <button
              onClick={() => setIsLoginMode(!isLoginMode)}
              className="text-base text-gray-500 hover:text-blue-600 font-medium transition-colors"
            >
              {isLoginMode ? "Need an account? Sign up." : "Have an account? Log in."}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // --- Main App UI ---
  const massiveInputClass = "w-full bg-transparent border-0 px-0 py-2 text-2xl md:text-3xl text-black placeholder:text-gray-300 focus:ring-0 focus:outline-none transition-colors font-bold tracking-tight";
  const standardInputClass = "w-full bg-white border-2 border-gray-200 focus:border-blue-600 rounded-xl px-4 py-3 text-lg text-black placeholder:text-gray-400 focus:outline-none transition-all focus:shadow-md focus:shadow-blue-600/10";
  const labelClass = "block text-sm font-bold text-gray-400 uppercase tracking-wider mb-2";

  return (
    <div className="h-screen flex flex-col bg-[#FDFCF8] text-black font-sans overflow-hidden">

      {/* Top Navigation Bar */}
      <header className="flex-shrink-0 px-8 py-6 flex items-center justify-between z-10 max-w-screen-2xl mx-auto w-full">
        <div className="flex items-center space-x-12">
          {/* Basecamp Style Logo Section */}
          <div className="flex items-center space-x-3 cursor-pointer" onClick={() => setCurrentView('apply')}>
            <div className="p-2.5 rounded-2xl bg-white border-2 border-gray-100 shadow-sm flex items-center justify-center">
              <Handshake size={26} strokeWidth={2.5} className="text-blue-600" />
            </div>
            <h1 className="text-4xl font-black tracking-tight text-blue-600">Handshake.</h1>
          </div>

          <nav className="hidden md:flex space-x-2">
            <button
              onClick={() => setCurrentView('apply')}
              className={`px-5 py-2.5 rounded-full text-lg font-bold transition-all flex items-center space-x-2 ${currentView === 'apply' ? 'bg-blue-600 text-white shadow-md shadow-blue-600/20' : 'text-gray-500 hover:bg-blue-50 hover:text-blue-600'}`}
            >
              <Briefcase size={20} />
              <span>Apply</span>
            </button>
            <button
              onClick={() => setCurrentView('history')}
              className={`px-5 py-2.5 rounded-full text-lg font-bold transition-all flex items-center space-x-2 ${currentView === 'history' ? 'bg-blue-600 text-white shadow-md shadow-blue-600/20' : 'text-gray-500 hover:bg-blue-50 hover:text-blue-600'}`}
            >
              <History size={20} />
              <span>Past Applications</span>
            </button>
            <button
              onClick={() => setCurrentView('profile')}
              className={`px-5 py-2.5 rounded-full text-lg font-bold transition-all flex items-center space-x-2 ${currentView === 'profile' ? 'bg-blue-600 text-white shadow-md shadow-blue-600/20' : 'text-gray-500 hover:bg-blue-50 hover:text-blue-600'}`}
            >
              <User size={20} />
              <span>Career Profile</span>
            </button>
          </nav>
        </div>

        <div className="flex items-center space-x-6">
          <span className="text-base font-bold text-gray-400 hidden sm:inline-block">{user.email}</span>
          <button
            onClick={handleSignOut}
            className="text-gray-400 hover:text-blue-600 transition-colors"
            title="Sign Out"
          >
            <LogOut size={24} />
          </button>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 overflow-hidden flex flex-col max-w-screen-2xl mx-auto w-full">

        {/* --- VIEW: APPLY (Focused Form -> Dual Column) --- */}
        {currentView === 'apply' && (
          <div className={`transition-all duration-500 ease-in-out w-full h-full pb-8 px-8 flex flex-col lg:flex-row gap-8 ${isGenerating || generatedCV ? 'items-stretch' : 'items-center justify-center'}`}>

            {/* Left: Input Form */}
            <div className={`flex flex-col bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden transition-all duration-500 ${isGenerating || generatedCV ? 'w-full lg:w-1/2 h-full' : 'w-full max-w-3xl h-[80vh]'}`}>
              <div className="flex-1 p-10 md:p-14 flex flex-col w-full h-full">

                <div className="mb-10 border-b-2 border-gray-100 pb-8">
                  <label className="block text-xl font-bold text-gray-400 mb-4">Who are you applying to?</label>
                  <input
                    value={companyName}
                    onChange={(e) => setCompanyName(e.target.value)}
                    placeholder="Company Name"
                    className={massiveInputClass}
                  />
                </div>

                <div className="flex-1 flex flex-col min-h-0">
                  <label className="block text-xl font-bold text-gray-400 mb-4">What do they want?</label>
                  <textarea
                    value={gig}
                    onChange={(e) => setGig(e.target.value)}
                    placeholder="Paste the job posting requirements here..."
                    className="flex-1 w-full bg-transparent border-0 p-0 text-xl leading-relaxed text-black placeholder:text-gray-200 focus:ring-0 resize-none outline-none font-serif"
                  />
                </div>

                <div className="pt-8 flex items-center justify-between mt-auto">
                  {genError ? (
                    <span className="text-red-500 text-lg font-bold">{genError}</span>
                  ) : (
                    <span className="hidden sm:block"></span>
                  )}

                  <button
                    onClick={handleGenerate}
                    disabled={isGenerating}
                    className={`py-4 px-10 text-xl font-bold rounded-full transition-all flex items-center space-x-3 ${isGenerating
                      ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                      : 'bg-blue-600 text-white hover:bg-blue-700 hover:scale-105 active:scale-95 shadow-xl shadow-blue-600/30'
                      }`}
                  >
                    {isGenerating ? (
                      <>
                        <Loader2 className="animate-spin" size={24} />
                        <span className="lowercase">adapting...</span>
                      </>
                    ) : (
                      <>
                        <span>adapt</span>
                        <ArrowRight size={24} />
                      </>
                    )}
                  </button>
                </div>
              </div>
            </div>

            {/* Right: Output Result (Only visible when generated or generating) */}
            {(isGenerating || generatedCV) && (
              <div className="w-full lg:w-1/2 flex flex-col bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden animate-in fade-in slide-in-from-right-8 duration-500">
                <div className="flex-1 p-10 md:p-14 flex flex-col w-full relative">
                  <div className="flex justify-between items-center mb-8">
                    <h2 className="text-xl font-black text-black">The Result</h2>
                    <button
                      onClick={() => copyToClipboard(generatedCV)}
                      disabled={!generatedCV}
                      className={`text-base font-bold transition-colors flex items-center space-x-2 ${!generatedCV
                        ? 'text-gray-200 cursor-not-allowed'
                        : copied
                          ? 'text-green-600'
                          : 'text-blue-600 hover:text-blue-700'
                        }`}
                    >
                      {copied ? <Check size={20} /> : <Copy size={20} />}
                      <span>{copied ? 'Copied' : 'Copy Typst Code'}</span>
                    </button>
                  </div>

                  {generatedCV ? (
                    <pre className="flex-1 overflow-y-auto text-base font-mono text-gray-800 whitespace-pre-wrap leading-relaxed outline-none bg-gray-50 p-8 rounded-2xl border border-gray-100">
                      <code>{generatedCV}</code>
                    </pre>
                  ) : (
                    <div className="flex-1 flex flex-col items-center justify-center text-gray-300 space-y-6 bg-gray-50 rounded-2xl border border-gray-100">
                      <Loader2 className="animate-spin" size={48} />
                      <p className="text-2xl font-serif italic text-gray-400">Brewing the perfect pitch...</p>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        )}

        {/* --- VIEW: PAST APPLICATIONS (History) --- */}
        {currentView === 'history' && (
          <div className="flex-1 overflow-y-auto pb-16 px-8">
            <div className="max-w-4xl mx-auto">
              <div className="mb-16 mt-8">
                <h2 className="text-5xl font-black text-black mb-4 tracking-tight">Past Applications</h2>
                <p className="text-xl text-gray-500 font-serif">Every CV you've tailored is saved right here.</p>
              </div>

              {history.length === 0 ? (
                <div className="text-center py-20 bg-white rounded-3xl border border-gray-100">
                  <p className="text-2xl font-bold text-gray-400">Nothing here yet.</p>
                  <p className="text-lg text-gray-400 mt-2">Go apply for some jobs!</p>
                </div>
              ) : (
                <div className="space-y-6">
                  {history.map((item) => {
                    const isExpanded = expandedHistoryId === item.id;
                    return (
                      <div key={item.id} className="bg-white rounded-3xl border border-gray-200 shadow-sm overflow-hidden transition-all duration-300 hover:shadow-md">
                        <button
                          onClick={() => setExpandedHistoryId(isExpanded ? null : item.id)}
                          className="w-full text-left p-8 flex items-center justify-between focus:outline-none"
                        >
                          <div>
                            <h3 className="text-3xl font-black text-black">{item.companyName || 'Unknown Company'}</h3>
                            <p className="text-lg text-gray-500 mt-2 font-medium">
                              Tailored on {new Date(item.createdAt).toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                            </p>
                          </div>
                          <div className="text-gray-400">
                            {isExpanded ? <ChevronUp size={32} /> : <ChevronDown size={32} />}
                          </div>
                        </button>

                        {isExpanded && (
                          <div className="px-8 pb-8 border-t border-gray-100 pt-8 bg-gray-50">
                            <div className="flex justify-between items-center mb-6">
                              <h4 className="text-xl font-bold text-black">Typst Source</h4>
                              <button
                                onClick={() => copyToClipboard(item.content)}
                                className="text-base font-bold text-black hover:text-gray-500 transition-colors flex items-center space-x-2"
                              >
                                {copied ? <Check size={18} /> : <Copy size={18} />}
                                <span>{copied ? 'Copied' : 'Copy'}</span>
                              </button>
                            </div>
                            <pre className="text-sm font-mono text-gray-700 whitespace-pre-wrap leading-relaxed bg-white p-6 rounded-2xl border border-gray-200 overflow-auto max-h-96 shadow-inner">
                              <code>{item.content}</code>
                            </pre>
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        )}

        {/* --- VIEW: CAREER PROFILE (Knowledge Base) --- */}
        {currentView === 'profile' && (
          <div className="flex-1 overflow-y-auto pb-16 px-8">
            <div className="max-w-5xl mx-auto">

              <div className="mb-16 mt-8">
                <h2 className="text-5xl font-black text-black mb-4 tracking-tight">Career Profile</h2>
                <p className="text-xl text-gray-500 font-serif">The foundation. Your skills, projects, and base templates live here.</p>
              </div>

              {/* Huge Tabs */}
              <div className="flex flex-wrap gap-4 mb-16">
                <button
                  onClick={() => setProfileTab('skills')}
                  className={`px-8 py-4 text-xl font-bold rounded-full transition-all border-2 ${profileTab === 'skills' ? 'border-blue-600 bg-blue-600 text-white shadow-md shadow-blue-600/20' : 'border-gray-200 bg-white text-gray-500 hover:border-gray-300 hover:text-blue-600'}`}
                >
                  Core Skills
                </button>
                <button
                  onClick={() => setProfileTab('projects')}
                  className={`px-8 py-4 text-xl font-bold rounded-full transition-all border-2 ${profileTab === 'projects' ? 'border-blue-600 bg-blue-600 text-white shadow-md shadow-blue-600/20' : 'border-gray-200 bg-white text-gray-500 hover:border-gray-300 hover:text-blue-600'}`}
                >
                  Past Projects
                </button>
                <button
                  onClick={() => setProfileTab('template')}
                  className={`px-8 py-4 text-xl font-bold rounded-full transition-all border-2 ${profileTab === 'template' ? 'border-blue-600 bg-blue-600 text-white shadow-md shadow-blue-600/20' : 'border-gray-200 bg-white text-gray-500 hover:border-gray-300 hover:text-blue-600'}`}
                >
                  Blueprint Template
                </button>
              </div>

              {/* Tab Content */}
              <div>

                {/* Skills Tab */}
                {profileTab === 'skills' && (
                  <div className="max-w-3xl">
                    <form onSubmit={handleAddSkill} className="mb-12">
                      <input
                        type="text"
                        value={newSkill}
                        onChange={(e) => setNewSkill(e.target.value)}
                        placeholder="Type a skill and hit enter..."
                        className="w-full bg-white border-2 border-gray-200 focus:border-blue-600 px-6 py-6 text-3xl font-bold text-black placeholder:text-gray-300 rounded-3xl outline-none transition-all focus:shadow-xl focus:shadow-blue-600/10"
                      />
                    </form>

                    <div className="flex flex-wrap gap-4">
                      {skills.length === 0 && <span className="text-gray-400 text-2xl font-serif italic">Your skill shelf is empty.</span>}
                      {skills.map(skill => (
                        <div key={skill} className="flex items-center space-x-3 bg-white border-4 border-gray-100 rounded-2xl px-6 py-4 group hover:border-blue-600 transition-colors shadow-sm hover:shadow-md cursor-default">
                          <span className="text-black text-2xl font-black group-hover:text-blue-600 transition-colors">{skill}</span>
                          <button onClick={() => removeSkill(skill)} className="text-gray-300 group-hover:text-red-500 transition-colors bg-gray-50 hover:bg-red-50 p-2 rounded-full">
                            <X size={20} />
                          </button>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Projects Tab */}
                {profileTab === 'projects' && (
                  <div className="grid grid-cols-1 lg:grid-cols-12 gap-16">

                    {/* Left: Project List */}
                    <div className="lg:col-span-7 space-y-12">
                      {projects.length === 0 && <p className="text-gray-400 text-2xl font-serif italic">No projects recorded yet.</p>}
                      {projects.map((p, idx) => (
                        <div key={idx} className="group relative bg-white p-10 rounded-3xl border-2 border-gray-100 shadow-sm hover:border-gray-300 transition-colors">
                          <button
                            onClick={() => removeProject(idx)}
                            className="absolute right-8 top-8 text-gray-300 hover:text-red-500 transition-colors bg-gray-50 p-3 rounded-full"
                          >
                            <X size={24} />
                          </button>
                          <h4 className="text-3xl font-black text-black mb-2">
                            {p.title} <span className="text-gray-400 text-2xl font-medium ml-3">{p.year}</span>
                          </h4>
                          <p className="text-base text-gray-400 font-mono mb-8 uppercase tracking-widest">{p.name}</p>
                          <p className="text-xl text-gray-600 leading-relaxed mb-8 font-serif">{p.description}</p>
                          <div className="bg-gray-50 p-6 rounded-2xl border border-gray-100">
                            <p className="text-lg text-gray-500"><span className="font-bold text-gray-900">Stack:</span> {p.stack}</p>
                            {p.github_url && <p className="text-lg text-gray-500 mt-3"><span className="font-bold text-gray-900">URL:</span> <a href={p.github_url} className="text-blue-600 hover:underline">{p.github_url}</a></p>}
                          </div>
                        </div>
                      ))}
                    </div>

                    {/* Right: Project Form */}
                    <div className="lg:col-span-5">
                      <div className="sticky top-8 bg-white p-10 rounded-3xl border-2 border-gray-100 shadow-sm">
                        <h3 className="text-3xl font-black text-black mb-8">Log a Project</h3>
                        <form onSubmit={handleAddProject} className="space-y-6">
                          <div className="grid grid-cols-2 gap-6">
                            <div>
                              <label className={labelClass}>Short Name</label>
                              <input required name="name" value={projectForm.name} onChange={handleProjectFormChange} className={standardInputClass} placeholder="taylor-app" />
                            </div>
                            <div>
                              <label className={labelClass}>Year</label>
                              <input required name="year" value={projectForm.year} onChange={handleProjectFormChange} className={standardInputClass} placeholder="2024" />
                            </div>
                          </div>
                          <div>
                            <label className={labelClass}>Display Title</label>
                            <input required name="title" value={projectForm.title} onChange={handleProjectFormChange} className={standardInputClass} placeholder="What was it called?" />
                          </div>
                          <div>
                            <label className={labelClass}>Description</label>
                            <textarea required name="description" value={projectForm.description} onChange={handleProjectFormChange} className={`${standardInputClass} resize-none h-40`} placeholder="What did you build?" />
                          </div>
                          <div>
                            <label className={labelClass}>Technologies</label>
                            <input required name="stack" value={projectForm.stack} onChange={handleProjectFormChange} className={standardInputClass} placeholder="React, Node..." />
                          </div>
                          <div>
                            <label className={labelClass}>Link (Optional)</label>
                            <input name="github_url" value={projectForm.github_url} onChange={handleProjectFormChange} className={standardInputClass} placeholder="https://..." />
                          </div>
                          <button type="submit" className="w-full py-5 bg-blue-50 hover:bg-blue-600 text-blue-600 hover:text-white text-xl font-bold rounded-2xl transition-colors mt-6">
                            Save to Profile
                          </button>
                        </form>
                      </div>
                    </div>
                  </div>
                )}

                {/* Template Tab */}
                {profileTab === 'template' && (
                  <div className="flex flex-col h-[70vh] bg-white rounded-3xl border-2 border-gray-100 shadow-sm p-10">
                    <div className="flex justify-between items-center mb-8">
                      <p className="text-xl text-gray-500 font-serif">The raw Typst structure. Handshake will fill in the blanks.</p>
                      <div className="flex items-center space-x-6">
                        {profileSaveMsg && <span className="text-xl font-bold text-green-600">{profileSaveMsg}</span>}
                        <button
                          onClick={handleTemplateSave}
                          disabled={isSavingProfile}
                          className="px-8 py-4 bg-blue-600 text-white text-xl font-bold rounded-full hover:bg-blue-700 hover:scale-105 transition-all disabled:opacity-50 shadow-lg shadow-blue-600/20"
                        >
                          {isSavingProfile ? 'Saving...' : 'Save Template'}
                        </button>
                      </div>
                    </div>
                    <textarea
                      value={blueprint}
                      onChange={(e) => setBlueprint(e.target.value)}
                      className="flex-1 w-full bg-gray-50 rounded-2xl p-10 text-lg font-mono text-gray-800 resize-none focus:outline-none focus:ring-4 focus:ring-blue-100 transition-all border border-gray-100"
                      spellCheck={false}
                    />
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
