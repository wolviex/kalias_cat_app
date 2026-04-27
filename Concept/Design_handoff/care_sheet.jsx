// care_sheet.jsx
// The cat profile/care sheet — expansive bottom sheet with rich Feed/Play feedback.

function CareSheet({ state, dispatch }) {
  const { focusedCat, cats } = state;
  const [particles, setParticles] = React.useState([]);
  const [toast, setToast] = React.useState(null);

  if (!focusedCat) return null;

  const data = focusedCat === 'kalia' ? null : cats[focusedCat];
  const isKalia = focusedCat === 'kalia';

  const info = {
    noodles: { name: 'Noodles', blurb: 'a zoomy orange storm', color: '#F0B278', pillar: 'Spelling · Energy' },
    loaf:    { name: 'Loaf Cat', blurb: 'soft, slow, always hungry', color: '#E8D5B0', pillar: 'Math · Counting' },
    robot:   { name: 'Robot Cat', blurb: 'curious circuits, tidy mind', color: '#C8B8DC', pillar: 'Logic · Sequences' },
    kalia:   { name: 'Kalia', blurb: 'the gentle guide', color: '#F0D090', pillar: 'You!' },
  }[focusedCat];

  // Emoji vocab keyed by mood — the SAME glyph appears on the button
  // AND bursts as particles when the action fires, so kids connect cause → effect.
  const moodEmoji = {
    happy:   { feed: '🍓', play: '✨', pet: '♥️', toast: 'purr purr' },
    calm:    { feed: '🥛', play: '🍃', pet: '♥️', toast: 'cozy' },
    grumpy:  { feed: '🍗', play: '🩰', pet: '✨',    toast: 'feeling better' },
    sad:     { feed: '🥞', play: '🎈', pet: '🤗', toast: 'cheered up' },
    zoomies: { feed: '🐟', play: '⚡',    pet: '💫', toast: 'zoom zoom!' },
    neutral: { feed: '🍓', play: '🪶', pet: '♥️', toast: 'nice' },
  };
  const curMood = (!isKalia && data) ? (data.mood || 'neutral') : 'neutral';
  const glyphs = moodEmoji[curMood] || moodEmoji.neutral;

  const fire = (kind) => {
    const burstGlyph = glyphs[kind] || '✨';
    const newParticles = [...Array(8)].map((_, i) => ({
      id: Date.now() + i,
      kind, glyph: burstGlyph,
      drift: (Math.random() - 0.5) * 70,
    }));
    setParticles(p => [...p, ...newParticles]);
    setTimeout(() => setParticles(p => p.filter(x => !newParticles.find(n => n.id === x.id))), 1800);

    if (kind === 'feed') {
      dispatch({ type: 'FEED', catId: focusedCat });
      setToast(`+5 ✦  ${burstGlyph} ${glyphs.toast}`);
    } else if (kind === 'play') {
      dispatch({ type: 'PLAY', catId: focusedCat });
      setToast(`+5 ✦  ${burstGlyph} ${glyphs.toast}`);
    } else {
      setToast(`✨  ${burstGlyph} ${glyphs.toast}`);
    }
    setTimeout(() => setToast(null), 1600);
  };

  return (
    <>
      {/* Backdrop */}
      <div
        onClick={() => dispatch({ type: 'FOCUS_CAT', catId: null })}
        style={{
          position: 'absolute', inset: 0, background: 'rgba(61,46,35,0.28)',
          backdropFilter: 'blur(2px)',
          animation: 'popin 0.3s ease-out',
          zIndex: 10,
        }}/>

      {/* Toast */}
      <div className={`toast ${toast ? 'show' : ''}`}>{toast}</div>

      {/* Sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: '#FBF5EA',
        borderTopLeftRadius: 28, borderTopRightRadius: 28,
        padding: '16px 24px 24px',
        boxShadow: '0 -10px 30px rgba(61,46,35,0.25)',
        zIndex: 20,
        animation: 'popin 0.35s cubic-bezier(.2,.8,.2,1)',
        maxHeight: '72%',
        overflowY: 'auto',
      }}>
        {/* Grabber */}
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 10 }}>
          <div style={{ width: 44, height: 4, borderRadius: 2, background: '#E0D0B8' }}/>
        </div>

        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 14 }}>
          <div style={{
            width: 56, height: 56, borderRadius: '50%',
            background: info.color,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 4px 10px rgba(61,46,35,0.12)',
          }}>
            <div style={{ transform: 'scale(0.46) translateY(-18%)', transformOrigin: 'center' }}>
              {focusedCat === 'noodles' && <Noodles size={80}/>}
              {focusedCat === 'loaf' && <LoafCat size={80}/>}
              {focusedCat === 'robot' && <RobotCat size={80}/>}
              {focusedCat === 'kalia' && <Kalia size={80}/>}
            </div>
          </div>
          <div style={{ flex: 1 }}>
            <div className="script" style={{ fontSize: 30, color: '#3D2E23', lineHeight: 1 }}>{info.name}</div>
            <div style={{ fontSize: 13, color: '#6B5A4A', marginTop: 2 }}>{info.blurb}</div>
            <div style={{ fontSize: 10, fontWeight: 800, color: '#A39282', letterSpacing: '0.14em', textTransform: 'uppercase', marginTop: 3 }}>{info.pillar}</div>
          </div>
          <button onClick={() => dispatch({ type: 'FOCUS_CAT', catId: null })}
            style={{ width: 34, height: 34, borderRadius: '50%', border: 'none', background: '#EEE1CB', fontSize: 18, cursor: 'pointer', color: '#6B5A4A' }}>×</button>
        </div>

        {!isKalia && data && (
          <>
            {/* Status bars — painted, soft */}
            <div style={{ display: 'flex', gap: 10, marginBottom: 16 }}>
              <StatBar label="Fullness" icon="🍓" value={data.hunger} color="#D88A7A"/>
              <StatBar label="Energy"    icon="✧"  value={data.energy} color="#A8C5A0"/>
            </div>

            {/* Minigame trigger banner — only if genuinely needed */}
            {data.needs && (
              <div style={{
                background: '#FCE9D6', border: '1.5px dashed #D88A7A',
                borderRadius: 16, padding: '10px 14px',
                display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14,
              }}>
                <div style={{ fontSize: 22 }}>
                  {data.needs === 'hungry' ? '🥣' : data.needs === 'tired' ? '💤' : '✦'}
                </div>
                <div style={{ flex: 1 }}>
                  <div className="script" style={{ fontSize: 20, color: '#3D2E23', lineHeight: 1 }}>
                    {data.needs === 'hungry' ? 'a little hungry' :
                     data.needs === 'tired'  ? 'feeling low on spark' : 'needs a moment'}
                  </div>
                  <div style={{ fontSize: 11, color: '#6B5A4A', marginTop: 2 }}>
                    Play the minigame to help them feel better.
                  </div>
                </div>
                <button style={{
                  background: '#3D2E23', color: '#FBF5EA', border: 'none',
                  padding: '8px 14px', borderRadius: 100, fontWeight: 700,
                  fontSize: 12, cursor: 'pointer',
                }}>Help →</button>
              </div>
            )}

            {/* Care actions — icons shift with the cat's mood */}
            <div style={{ fontSize: 10, fontWeight: 800, color: '#A39282', letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 6 }}>
              They're feeling <span style={{ color: '#3D2E23' }}>{curMood}</span> — try:
            </div>
            <div style={{ display: 'flex', gap: 10 }}>
              <CareBtn icon={glyphs.feed} label="Feed" tint="#E8B4A0" onClick={() => fire('feed')}/>
              <CareBtn icon={glyphs.play} label="Play" tint="#A8C5A0" onClick={() => fire('play')}/>
              <CareBtn icon={glyphs.pet}  label="Pet"  tint="#B8A5D0" onClick={() => fire('pet')}/>
            </div>
          </>
        )}

        {isKalia && (
          <div style={{
            padding: '16px 0', color: '#6B5A4A', fontSize: 14, textAlign: 'center',
          }}>
            <div className="script" style={{ fontSize: 26, color: '#3D2E23' }}>That's you!</div>
            <div style={{ marginTop: 6 }}>Total XP · <b style={{ color: '#3D2E23' }}>{state.xp} ✦</b>  ·  Trunks · <b style={{ color: '#3D2E23' }}>{state.trunks} 🧳</b></div>
            <div style={{ marginTop: 14, display: 'flex', gap: 8, justifyContent: 'center' }}>
              {['Sprout', 'Seedling', 'Bloom'].map(t => (
                <button key={t} style={{
                  padding: '8px 14px', borderRadius: 100,
                  border: state.tier === t.toLowerCase() ? '2px solid #3D2E23' : '1.5px solid #E0D0B8',
                  background: state.tier === t.toLowerCase() ? '#F0D090' : '#fff',
                  fontWeight: 700, fontSize: 12, color: '#3D2E23', cursor: 'pointer',
                }}>{t}</button>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Particles — the chosen mood-glyph rises, with a sparkle or two mixed in */}
      {particles.map((p, i) => (
        <div key={p.id} style={{
          position: 'absolute',
          left: `calc(50% + ${p.drift}px)`,
          bottom: '55%',
          fontSize: 20 + (i % 3) * 2,
          pointerEvents: 'none',
          zIndex: 30,
          animation: 'floatUp 1.6s ease-out forwards',
        }}>
          {i % 4 === 3 ? '✨' : p.glyph}
        </div>
      ))}
    </>
  );
}

function StatBar({ label, icon, value, color }) {
  return (
    <div style={{
      flex: 1, background: '#fff', borderRadius: 16, padding: '10px 12px',
      boxShadow: 'inset 0 0 0 1px #EEE1CB',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
        <span style={{ fontSize: 14 }}>{icon}</span>
        <span style={{ fontSize: 11, fontWeight: 800, color: '#6B5A4A', letterSpacing: '0.1em', textTransform: 'uppercase' }}>{label}</span>
      </div>
      <div style={{ height: 8, background: '#F5ECDE', borderRadius: 100, overflow: 'hidden', position: 'relative' }}>
        <div style={{
          position: 'absolute', inset: 0,
          width: `${value}%`, background: color, borderRadius: 100,
          transition: 'width 0.5s cubic-bezier(.2,.8,.2,1)',
        }}/>
      </div>
      <div style={{ fontSize: 10, color: '#A39282', marginTop: 4, fontWeight: 700 }}>{value}/100</div>
    </div>
  );
}

function CareBtn({ icon, label, tint, onClick }) {
  return (
    <button onClick={onClick} style={{
      flex: 1, padding: '14px 8px', border: 'none',
      borderRadius: 18,
      background: tint,
      color: '#3D2E23',
      fontFamily: 'Nunito', fontWeight: 800, fontSize: 14,
      cursor: 'pointer',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
      boxShadow: '0 4px 12px rgba(61,46,35,0.14)',
      transition: 'transform 0.15s',
    }}
    onMouseDown={e => e.currentTarget.style.transform = 'scale(0.96)'}
    onMouseUp={e => e.currentTarget.style.transform = 'scale(1)'}
    onMouseLeave={e => e.currentTarget.style.transform = 'scale(1)'}>
      <span style={{ fontSize: 22 }}>{icon}</span>
      <span>{label}</span>
    </button>
  );
}

Object.assign(window, { CareSheet });
