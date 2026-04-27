// app.jsx — landscape Android prototype

const INITIAL = {
  timeOfDay: 'afternoon',
  motion: 'moderate',
  showChrome: true,
  focusedCat: null,
  xp: 245,
  level: 3,
  trunks: 2,
  pendingTrunks: 1,
  tier: 'seedling',
  cats: {
    noodles: { mood: 'happy',   hunger: 72, energy: 68, needs: null },
    loaf:    { mood: 'calm',    hunger: 42, energy: 80, needs: null },
    robot:   { mood: 'happy',   hunger: 80, energy: 55, needs: null },
  },
};

function reducer(state, action) {
  switch (action.type) {
    case 'SET': return { ...state, [action.key]: action.value };
    case 'FOCUS_CAT': return { ...state, focusedCat: action.catId };
    case 'FEED': {
      const c = state.cats[action.catId]; if (!c) return state;
      const hunger = Math.min(100, c.hunger + 25);
      return { ...state, xp: state.xp + 5, cats: { ...state.cats, [action.catId]: {
        ...c, hunger, mood: hunger > 70 ? 'happy' : c.mood,
        needs: hunger < 35 ? 'hungry' : null,
      }}};
    }
    case 'PLAY': {
      const c = state.cats[action.catId]; if (!c) return state;
      const energy = Math.min(100, c.energy + 25);
      let mood = c.mood;
      if (action.catId === 'noodles' && energy >= 85) mood = 'zoomies';
      else if (energy > 70) mood = 'happy';
      return { ...state, xp: state.xp + 5, cats: { ...state.cats, [action.catId]: {
        ...c, energy, mood, needs: energy < 35 ? 'tired' : null,
      }}};
    }
    case 'SET_MOOD': {
      const { catId, mood } = action;
      const c = state.cats[catId]; if (!c) return state;
      const needs = mood === 'grumpy' && catId === 'loaf' ? 'hungry' :
                    mood === 'grumpy' && catId === 'robot' ? 'tired' : null;
      return { ...state, cats: { ...state.cats, [catId]: { ...c, mood, needs } } };
    }
    default: return state;
  }
}

function Tweaks({ state, dispatch }) {
  const setTime = v => dispatch({ type: 'SET', key: 'timeOfDay', value: v });
  const setMotion = v => dispatch({ type: 'SET', key: 'motion', value: v });
  return (
    <div className="side">
      <h1>Kalia · redesign</h1>
      <p>Watercolor storybook, <b>landscape</b>. The whole Room, Kalia, and cats are now recognizable from the source sprite sheets — lavender paw-print wall, wood floor, yarn-basket corner, cat-ear bed.</p>

      <h2>Characters match source</h2>
      <p><b>Noodles</b> · long orange+white cat · <b>Loaf</b> · chubby white with orange "loaf" cap · <b>Robot</b> · blue boxy cat with chest panel + maraca · <b>Kalia</b> · curly-haired child in blue patterned dress, pink shoes.</p>

      <h2>Tweaks</h2>
      <div className="tweak-group">
        <label className="tweak-label">Time of day</label>
        <div className="seg seg-emoji">
          {[['morning','🌅'],['afternoon','☀️'],['dusk','🌇'],['night','🌙']].map(([v,e]) => (
            <button key={v} className={state.timeOfDay===v?'on':''} onClick={()=>setTime(v)}>{e}</button>
          ))}
        </div>
      </div>
      <div className="tweak-group">
        <label className="tweak-label">Motion</label>
        <div className="seg">{['minimal','moderate','lots'].map(v=>(
          <button key={v} className={state.motion===v?'on':''} onClick={()=>setMotion(v)}>{v}</button>
        ))}</div>
      </div>
      <div className="tweak-group">
        <label className="tweak-label">Chrome</label>
        <div className="seg">
          <button className={state.showChrome?'on':''} onClick={()=>dispatch({type:'SET',key:'showChrome',value:true})}>on</button>
          <button className={!state.showChrome?'on':''} onClick={()=>dispatch({type:'SET',key:'showChrome',value:false})}>hide</button>
        </div>
      </div>

      <h2>Preview cat moods</h2>
      {['noodles','loaf','robot'].map(id => (
        <div key={id} className="tweak-group">
          <label className="tweak-label">{id}</label>
          <div className="seg">{['happy','calm','grumpy','sad','zoomies'].map(m => (
            <button key={m} className={state.cats[id].mood===m?'on':''}
              onClick={()=>dispatch({type:'SET_MOOD',catId:id,mood:m})}>{m}</button>
          ))}</div>
        </div>
      ))}

      <h2>What changed</h2>
      <p><b>Landscape only</b> — the game plays at 16:9 Android phone proportions.</p>
      <p><b>Backdrop</b> faithful to source: soft lavender wall with paw-print pattern, wood-plank floor, cream rug with lilac border, mood-chart poster, cat-ear bed + rainbow yarn basket.</p>
      <p><b>Atmosphere</b>: parallax window with live sky, time-of-day lighting, drifting dust motes.</p>
    </div>
  );
}

// Landscape Android frame — rotated phone
function PhoneLandscape({ children }) {
  // 800 × 380 (w × h) — landscape 16:9-ish
  return (
    <div style={{
      width: 820, height: 400, borderRadius: 44,
      background: '#1E1B2E',
      padding: 12,
      boxShadow: '0 40px 80px rgba(61,46,35,0.35), 0 0 0 2px rgba(0,0,0,0.2)',
      position: 'relative',
    }}>
      {/* Speaker pill — on left edge (top of landscape) */}
      <div style={{
        position: 'absolute', left: 18, top: '50%', transform: 'translateY(-50%)',
        width: 6, height: 90, borderRadius: 100, background: '#0A0710', zIndex: 50,
      }}/>
      {/* Camera dot */}
      <div style={{
        position: 'absolute', left: 30, top: '50%', transform: 'translateY(-50%)',
        width: 6, height: 6, borderRadius: '50%', background: '#2A2234', zIndex: 50,
      }}/>
      <div style={{
        width: '100%', height: '100%', borderRadius: 34,
        overflow: 'hidden', background: '#EED6F0', position: 'relative',
      }}>
        {children}
      </div>
    </div>
  );
}

function App() {
  const [state, dispatch] = React.useReducer(reducer, INITIAL);
  return (
    <div className="page">
      <Tweaks state={state} dispatch={dispatch}/>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
        <div className="script" style={{ fontSize: 22, color: '#6B5A4A' }}>landscape · Android</div>
        <PhoneLandscape>
          <Room state={state} dispatch={dispatch}/>
          {state.focusedCat && <CareSheet state={state} dispatch={dispatch}/>}
        </PhoneLandscape>
        <div style={{ fontSize: 11, color: '#A39282', fontWeight: 700, letterSpacing: '0.14em', textTransform: 'uppercase' }}>Tap any character · try tweaks on the left</div>
      </div>
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App/>);
