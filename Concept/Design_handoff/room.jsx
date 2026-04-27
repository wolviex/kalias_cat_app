// room.jsx — landscape room backdrop, matches source art (lavender paw wall, wood floor)

function Room({ state, dispatch }) {
  const { timeOfDay, motion, cats, pendingTrunks, showChrome, focusedCat } = state;

  const timeTones = {
    morning:   { wall: '#F0DCE8', floor1: '#E8C89A', floor2: '#D8A878', overlay: 'rgba(255,220,170,0.04)' },
    afternoon: { wall: '#E2D0E8', floor1: '#E8C89A', floor2: '#C89860', overlay: 'rgba(0,0,0,0)' },
    dusk:      { wall: '#D0A8B8', floor1: '#C89868', floor2: '#A06838', overlay: 'rgba(230,140,90,0.14)' },
    night:     { wall: '#453850', floor1: '#3D3238', floor2: '#2A2028', overlay: 'rgba(50,60,120,0.25)' },
  };
  const t = timeTones[timeOfDay];
  const isNight = timeOfDay === 'night';

  return (
    <div style={{
      position: 'relative', width: '100%', height: '100%',
      overflow: 'hidden',
      background: t.wall,
      transition: 'background 0.8s ease',
    }}>
      {/* ── Paw-print wallpaper pattern (matches source) ─────────── */}
      <svg style={{ position: 'absolute', inset: 0, width: '100%', height: '66%', opacity: isNight ? 0.2 : 0.35 }}>
        <defs>
          <pattern id="paws" x="0" y="0" width="70" height="70" patternUnits="userSpaceOnUse">
            <g fill={isNight ? '#6A5A78' : '#D0BEDC'}>
              <circle cx="20" cy="22" r="4"/>
              <circle cx="12" cy="14" r="2"/><circle cx="28" cy="14" r="2"/>
              <circle cx="10" cy="26" r="2"/><circle cx="30" cy="26" r="2"/>
              <path d="M48,45 L52,52 L58,55 L58,60 L38,60 L38,55 L44,52 Z" opacity="0.5"/>
              <circle cx="48" cy="48" r="1.5"/>
            </g>
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#paws)"/>
      </svg>

      {/* ── Wood floor (bottom 34%) ────────────────────────────── */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, height: '34%',
        background: `linear-gradient(to bottom, ${t.floor1}, ${t.floor2})`,
        transition: 'background 0.8s ease',
      }}>
        {/* Plank lines */}
        <svg style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0.35 }}>
          {[0, 25, 50, 75, 100].map((x,i) => (
            <line key={i} x1={`${x}%`} y1="0" x2={`${x-8}%`} y2="100%" stroke="#7A4820" strokeWidth="1.2"/>
          ))}
          {[22, 55].map((y,i) => (
            <line key={'h'+i} x1="0" y1={`${y}%`} x2="100%" y2={`${y+2}%`} stroke="#7A4820" strokeWidth="0.8" opacity="0.6"/>
          ))}
        </svg>
        {/* Baseboard */}
        <div style={{ position: 'absolute', left: 0, right: 0, top: -4, height: 8, background: '#FBF5EA', opacity: 0.9 }}/>
      </div>

      {/* ── Window (upper left, matches source curtained window) ── */}
      <div style={{
        position: 'absolute', top: '8%', left: '3%', width: '22%', height: '46%',
        filter: 'drop-shadow(0 8px 16px rgba(61,46,35,0.15))',
      }}>
        <Window timeOfDay={timeOfDay}/>
      </div>

      {/* ── Mood chart poster (upper right) ────────────────────── */}
      <div style={{
        position: 'absolute', top: '10%', right: '4%', width: '16%', height: '32%',
        filter: 'drop-shadow(0 6px 12px rgba(61,46,35,0.15))',
      }}>
        <MoodChart/>
      </div>

      {/* ── Plant (far right floor, on small shelf) ────────────── */}
      <div style={{
        position: 'absolute', bottom: '30%', right: '2%', width: '8%', height: '28%',
      }}>
        <Plant/>
      </div>

      {/* ── Rug (painted, cream w/ lilac border) ────────────────── */}
      <div style={{
        position: 'absolute', left: '18%', right: '18%', bottom: '4%', height: '24%',
      }}>
        <svg viewBox="0 0 400 120" width="100%" height="100%" preserveAspectRatio="none">
          <defs>
            <filter id="rug-brush"><feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="2" seed="6"/><feDisplacementMap in="SourceGraphic" scale="2"/></filter>
          </defs>
          <ellipse cx="200" cy="60" rx="195" ry="55" fill="#C8B5D8" filter="url(#rug-brush)"/>
          <ellipse cx="200" cy="60" rx="175" ry="45" fill="#FBF0E2" filter="url(#rug-brush)"/>
        </svg>
      </div>

      {/* ── Yarn basket + cat bed (bottom-left, replaces old corner) ── */}
      <div style={{
        position: 'absolute', left: '2%', bottom: '2%', width: '20%', height: '40%',
      }}>
        <YarnBasket active={cats.noodles.mood === 'zoomies'}/>
      </div>

      {/* ── Magical trunk (bottom, right of center) ───────────── */}
      <div style={{
        position: 'absolute', right: '22%', bottom: '4%', width: '11%', height: '22%',
        animation: pendingTrunks > 0 && motion !== 'minimal' ? 'bob 1.8s infinite ease-in-out' : 'none',
      }}>
        <MagicalTrunk pending={pendingTrunks > 0}/>
      </div>

      {/* ── Dust motes ──────────────────────────────────────────── */}
      {motion !== 'minimal' && !isNight && (
        <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
          {[...Array(motion === 'lots' ? 10 : 6)].map((_, i) => (
            <div key={i} style={{
              position: 'absolute',
              left: `${8 + i * 9}%`, top: `${18 + (i % 3) * 22}%`,
              width: 4, height: 4, borderRadius: '50%', background: '#FBF5EA',
              '--dx': `${(i % 2 ? 1 : -1) * 40}px`, '--dy': `-${70 + i*6}px`,
              animation: `driftDust ${7 + i * 0.7}s ease-in infinite`,
              animationDelay: `${i * 0.9}s`, filter: 'blur(0.8px)',
            }}/>
          ))}
        </div>
      )}

      {/* Night overlay */}
      <div style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        background: t.overlay, transition: 'background 0.8s ease',
      }}/>

      {/* ── Characters ─────────────────────────────────────────── */}
      <Character style={{ left: '18%', bottom: '4%', width: '16%' }}
        mood={cats.noodles.mood} needs={cats.noodles.needs} focused={focusedCat === 'noodles'}
        onTap={() => dispatch({ type: 'FOCUS_CAT', catId: 'noodles' })}>
        <Noodles mood={cats.noodles.mood} size={115}/>
      </Character>

      <Character style={{ left: '33%', bottom: '2%', width: '17%' }}
        mood={cats.loaf.mood} needs={cats.loaf.needs} focused={focusedCat === 'loaf'}
        onTap={() => dispatch({ type: 'FOCUS_CAT', catId: 'loaf' })}>
        <LoafCat mood={cats.loaf.mood} size={120}/>
      </Character>

      <Character style={{ left: '48%', bottom: '2%', width: '15%' }}
        focused={focusedCat === 'kalia'}
        onTap={() => dispatch({ type: 'FOCUS_CAT', catId: 'kalia' })}>
        <Kalia size={115}/>
      </Character>

      <Character style={{ left: '64%', bottom: '3%', width: '15%' }}
        mood={cats.robot.mood} needs={cats.robot.needs} focused={focusedCat === 'robot'}
        onTap={() => dispatch({ type: 'FOCUS_CAT', catId: 'robot' })}>
        <RobotCat mood={cats.robot.mood} size={115}/>
      </Character>

      {/* ── Chrome: title top-left, buttons top-right ──────────── */}
      {showChrome && (
        <>
          <div style={{
            position: 'absolute', top: 10, left: 16, pointerEvents: 'auto',
            background: 'rgba(251,245,234,0.7)', backdropFilter: 'blur(4px)',
            padding: '6px 14px', borderRadius: 100,
            boxShadow: '0 3px 10px rgba(61,46,35,0.12)',
          }}>
            <span className="script" style={{ fontSize: 22, color: isNight ? '#3D2E23' : '#3D2E23', lineHeight: 1 }}>Kalia's room</span>
            <span style={{ fontSize: 10, fontWeight: 700, color: '#6B5A4A', letterSpacing: '0.12em', textTransform: 'uppercase', marginLeft: 10 }}>
              {timeOfDay === 'morning' ? 'morning' : timeOfDay === 'afternoon' ? 'afternoon' : timeOfDay === 'dusk' ? 'golden hour' : 'night'}
            </span>
          </div>

          <div style={{
            position: 'absolute', top: 10, right: 16, display: 'flex', gap: 6,
          }}>
            <ChromeBtn icon="🧘" dark={isNight}/>
            <ChromeBtn icon="🧳" dark={isNight} badge={pendingTrunks > 0 ? pendingTrunks : null}/>
            <ChromeBtn icon="♪" dark={isNight}/>
          </div>

          <PurrBar xp={state.xp} level={state.level}/>
        </>
      )}
    </div>
  );
}

function Character({ children, style, mood, onTap, focused, needs }) {
  return (
    <div onClick={onTap} style={{
      position: 'absolute', cursor: 'pointer',
      filter: focused ? 'drop-shadow(0 10px 20px rgba(61,46,35,0.3))' : 'drop-shadow(0 3px 8px rgba(61,46,35,0.14))',
      transition: 'all 0.35s cubic-bezier(.2,.8,.2,1)',
      transform: focused ? 'translateY(-3px) scale(1.05)' : 'scale(1)',
      ...style,
    }}>
      {mood && (<div style={{ position: 'absolute', top: -2, left: 0, right: 0 }}><MoodBubble mood={mood}/></div>)}
      {needs && (
        <div style={{
          position: 'absolute', top: 8, right: 4,
          width: 20, height: 20, borderRadius: '50%',
          background: '#fff', border: '1.6px solid #E8B4A0',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 11, animation: 'bob 1.5s infinite ease-in-out',
          boxShadow: '0 2px 6px rgba(61,46,35,0.22)',
        }}>{needs === 'hungry' ? '🥣' : needs === 'tired' ? '💤' : '!'}</div>
      )}
      <div style={{ width: '100%', display: 'flex', justifyContent: 'center' }}>{children}</div>
    </div>
  );
}

function ChromeBtn({ icon, dark, badge }) {
  return (
    <button style={{
      position: 'relative', width: 32, height: 32, borderRadius: '50%',
      background: 'rgba(251,245,234,0.9)', border: 'none',
      fontSize: 15, cursor: 'pointer',
      boxShadow: '0 3px 8px rgba(61,46,35,0.18)',
      backdropFilter: 'blur(4px)',
    }}>
      {icon}
      {badge && (
        <div style={{
          position: 'absolute', top: -2, right: -2, width: 14, height: 14, borderRadius: '50%',
          background: '#D88A7A', color: '#fff', fontSize: 9, fontWeight: 800,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>{badge}</div>
      )}
    </button>
  );
}

function PurrBar({ xp, level }) {
  const pct = xp % 100;
  return (
    <div style={{
      position: 'absolute', left: 16, bottom: 10, width: 260,
      background: 'rgba(251,245,234,0.96)', borderRadius: 100,
      padding: '5px 8px 5px 10px',
      display: 'flex', alignItems: 'center', gap: 8,
      boxShadow: '0 4px 12px rgba(61,46,35,0.18)',
      backdropFilter: 'blur(6px)',
    }}>
      <div style={{
        width: 22, height: 22, borderRadius: '50%',
        background: '#E8B4A0', display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 11, fontWeight: 800, color: '#fff',
      }}>{level}</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 9, fontWeight: 800, color: '#6B5A4A', letterSpacing: '0.08em', textTransform: 'uppercase' }}>Purr-gress</div>
        <div style={{ height: 5, background: '#EEE1CB', borderRadius: 100, overflow: 'hidden', marginTop: 1 }}>
          <div style={{ height: '100%', width: `${pct}%`, background: 'linear-gradient(90deg, #E8B4A0, #F0D090)', borderRadius: 100, transition: 'width 0.6s cubic-bezier(.2,.8,.2,1)' }}/>
        </div>
      </div>
      <div style={{ fontFamily: 'Caveat', fontWeight: 700, fontSize: 16, color: '#3D2E23', minWidth: 42, textAlign: 'right' }}>{xp} ✦</div>
    </div>
  );
}

Object.assign(window, { Room });
