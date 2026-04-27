// characters.jsx — redrawn to match source art (Loaf/Noodles/Robot/Kalia)

function WatercolorDefs({ id = 'wc' }) {
  return (
    <defs>
      <filter id={`${id}-brush`} x="-8%" y="-8%" width="116%" height="116%">
        <feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves="2" seed="3"/>
        <feDisplacementMap in="SourceGraphic" scale="1.1"/>
      </filter>
      <filter id={`${id}-paper`}>
        <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed="1"/>
        <feColorMatrix values="0 0 0 0 0.24  0 0 0 0 0.18  0 0 0 0 0.12  0 0 0 0.1 0"/>
        <feComposite in2="SourceGraphic" operator="in"/>
      </filter>
    </defs>
  );
}

// ─── Noodles — long orange+white cat, sitting upright ───
function Noodles({ mood = 'happy', size = 160 }) {
  const orange = '#E8A066', orangeDk = '#C87838', cream = '#FBF0DC';
  return (
    <svg viewBox="0 0 200 220" width={size} height={size * 1.1} style={{ overflow: 'visible' }}>
      <WatercolorDefs id="nd"/>
      <ellipse cx="100" cy="208" rx="48" ry="5" fill="#3D2E23" opacity="0.14"/>

      {/* Tail curling right */}
      <g style={{ transformOrigin: '135px 165px', animation: 'twitch-tail 5s infinite ease-in-out' }}>
        <path d="M135,165 Q175,160 175,120" stroke={orange} strokeWidth="14" strokeLinecap="round" fill="none" filter="url(#nd-brush)"/>
        <path d="M135,165 Q175,160 175,120" stroke="#3D2E23" strokeWidth="17" strokeLinecap="round" fill="none" opacity="0.25"/>
      </g>

      {/* Body — orange back + white belly, upright sitting */}
      <path d="M55,200 Q50,135 80,120 Q110,112 130,130 Q148,150 148,200 Z" fill={orange} filter="url(#nd-brush)"/>
      <path d="M70,200 Q68,170 85,160 Q105,158 118,172 Q125,190 125,200 Z" fill={cream} filter="url(#nd-brush)"/>
      <path d="M55,200 Q50,135 80,120 Q110,112 130,130 Q148,150 148,200" stroke="#3D2E23" strokeWidth="2.2" fill="none"/>

      {/* Front paws */}
      <ellipse cx="76" cy="202" rx="11" ry="5" fill={cream} stroke="#3D2E23" strokeWidth="2"/>
      <ellipse cx="118" cy="202" rx="11" ry="5" fill={cream} stroke="#3D2E23" strokeWidth="2"/>

      {/* Head — breathing */}
      <g style={{ transformOrigin: '100px 75px', animation: 'breathe 3.5s infinite ease-in-out' }}>
        {/* Ears — triangular with pink insides */}
        <path d="M55,55 L58,22 L85,50 Z" fill={orange} stroke="#3D2E23" strokeWidth="2.2" filter="url(#nd-brush)"/>
        <path d="M63,48 L62,32 L78,48 Z" fill="#E8B4A0"/>
        <path d="M145,55 L142,22 L115,50 Z" fill={orange} stroke="#3D2E23" strokeWidth="2.2" filter="url(#nd-brush)"/>
        <path d="M137,48 L138,32 L122,48 Z" fill="#E8B4A0"/>

        {/* Head orange cap + cream face */}
        <path d="M55,80 Q50,42 100,38 Q150,42 145,80 Q145,95 125,100 Q75,100 55,95 Z" fill={orange} stroke="#3D2E23" strokeWidth="2.2" filter="url(#nd-brush)"/>
        <path d="M65,85 Q65,65 100,62 Q135,65 135,85 Q135,115 100,120 Q65,115 65,85 Z" fill={cream}/>
        <path d="M65,85 Q65,65 100,62 Q135,65 135,85 Q135,115 100,120 Q65,115 65,85" stroke="#3D2E23" strokeWidth="2" fill="none"/>

        {/* Eyes */}
        {mood === 'sad' ? (
          <>
            <path d="M78,88 Q84,84 90,88" stroke="#3D2E23" strokeWidth="2.5" fill="none" strokeLinecap="round"/>
            <path d="M110,88 Q116,84 122,88" stroke="#3D2E23" strokeWidth="2.5" fill="none" strokeLinecap="round"/>
          </>
        ) : mood === 'zoomies' ? (
          <>
            <ellipse cx="84" cy="88" rx="5" ry="6" fill="#3D2E23"/>
            <ellipse cx="116" cy="88" rx="5" ry="6" fill="#3D2E23"/>
            <circle cx="86" cy="86" r="1.5" fill="#fff"/>
            <circle cx="118" cy="86" r="1.5" fill="#fff"/>
          </>
        ) : (
          <>
            <ellipse cx="84" cy="90" rx="3.5" ry="4.5" fill="#3D2E23"/>
            <ellipse cx="116" cy="90" rx="3.5" ry="4.5" fill="#3D2E23"/>
            <circle cx="85" cy="88" r="1.2" fill="#fff"/>
            <circle cx="117" cy="88" r="1.2" fill="#fff"/>
          </>
        )}

        {/* Nose */}
        <path d="M96,100 L104,100 L100,105 Z" fill="#E87E8A" stroke="#3D2E23" strokeWidth="1.3"/>
        <path d="M100,105 Q97,110 94,108 M100,105 Q103,110 106,108" stroke="#3D2E23" strokeWidth="1.5" fill="none" strokeLinecap="round"/>

        <g stroke="#6B5A4A" strokeWidth="0.8" strokeLinecap="round" opacity="0.7">
          <line x1="72" y1="102" x2="54" y2="100"/><line x1="74" y1="105" x2="56" y2="108"/>
          <line x1="128" y1="102" x2="146" y2="100"/><line x1="126" y1="105" x2="144" y2="108"/>
        </g>
      </g>
      <rect width="200" height="220" filter="url(#nd-paper)" opacity="0.3" pointerEvents="none"/>
    </svg>
  );
}

// ─── Loaf Cat — chubby white cat, orange "loaf" cap on head+back ───
function LoafCat({ mood = 'happy', size = 160 }) {
  const cream = '#FBF0DC', orange = '#F0B270', gray = '#D0C8BE';
  return (
    <svg viewBox="0 0 200 220" width={size} height={size * 1.1} style={{ overflow: 'visible' }}>
      <WatercolorDefs id="lf"/>
      <ellipse cx="100" cy="208" rx="55" ry="5" fill="#3D2E23" opacity="0.14"/>

      {/* Loaf-shaped body */}
      <path d="M35,150 Q32,115 75,100 Q125,95 165,108 Q172,135 168,170 Q165,200 115,202 Q55,202 38,180 Q32,165 35,150 Z"
            fill={cream} stroke="#3D2E23" strokeWidth="2.4" filter="url(#lf-brush)"/>

      {/* Orange "loaf" cap over back */}
      <path d="M40,140 Q35,110 75,98 Q120,90 160,102 Q172,120 168,150 Q150,142 130,145 Q90,140 60,150 Q45,150 40,140 Z"
            fill={orange} stroke="#3D2E23" strokeWidth="2.2" filter="url(#lf-brush)"/>
      {/* braided texture lines on loaf */}
      <g stroke="#C07838" strokeWidth="1.6" fill="none" opacity="0.7">
        <path d="M55,115 Q70,112 85,118"/>
        <path d="M85,108 Q100,105 115,112"/>
        <path d="M115,108 Q130,108 145,115"/>
        <path d="M55,130 Q75,127 95,132"/>
        <path d="M105,128 Q130,128 155,134"/>
      </g>

      {/* Gray patch on face side */}
      <path d="M55,70 Q52,55 75,55 Q72,75 65,85 Q55,85 55,70 Z" fill={gray} opacity="0.8"/>

      {/* Little paws */}
      <ellipse cx="65" cy="200" rx="10" ry="5" fill={cream} stroke="#3D2E23" strokeWidth="2"/>
      <ellipse cx="135" cy="200" rx="10" ry="5" fill={cream} stroke="#3D2E23" strokeWidth="2"/>

      {/* Head (breathes) */}
      <g style={{ transformOrigin: '100px 75px', animation: 'breathe 4.5s infinite ease-in-out' }}>
        <path d="M60,55 L58,35 L82,55 Z" fill={cream} stroke="#3D2E23" strokeWidth="2"/>
        <path d="M68,50 L66,40 L78,52 Z" fill="#E8B4A0"/>
        <path d="M140,55 L142,35 L118,55 Z" fill={cream} stroke="#3D2E23" strokeWidth="2"/>
        <path d="M132,50 L134,40 L122,52 Z" fill="#E8B4A0"/>

        {/* Face */}
        <path d="M55,95 Q50,55 100,50 Q150,55 145,95 Q140,120 115,122 Q80,122 60,118 Q52,108 55,95 Z"
              fill={cream} stroke="#3D2E23" strokeWidth="2.4" filter="url(#lf-brush)"/>

        {/* Eyes — squinty smile */}
        {mood === 'sad' ? (
          <>
            <path d="M72,88 Q80,92 86,88" stroke="#3D2E23" strokeWidth="2.5" fill="none" strokeLinecap="round"/>
            <path d="M114,88 Q120,92 128,88" stroke="#3D2E23" strokeWidth="2.5" fill="none" strokeLinecap="round"/>
          </>
        ) : mood === 'grumpy' ? (
          <>
            <line x1="72" y1="92" x2="86" y2="86" stroke="#3D2E23" strokeWidth="2.5" strokeLinecap="round"/>
            <line x1="114" y1="86" x2="128" y2="92" stroke="#3D2E23" strokeWidth="2.5" strokeLinecap="round"/>
          </>
        ) : (
          <>
            <path d="M72,90 Q80,84 88,90" stroke="#3D2E23" strokeWidth="2.6" fill="none" strokeLinecap="round"/>
            <path d="M112,90 Q120,84 128,90" stroke="#3D2E23" strokeWidth="2.6" fill="none" strokeLinecap="round"/>
          </>
        )}

        {/* Nose + mouth (soft smile) */}
        <path d="M95,98 L105,98 L100,103 Z" fill="#3D2E23"/>
        <path d="M100,103 Q94,112 86,110 M100,103 Q106,112 114,110" stroke="#3D2E23" strokeWidth="1.8" fill="none" strokeLinecap="round"/>

        <g stroke="#6B5A4A" strokeWidth="0.8" strokeLinecap="round" opacity="0.7">
          <line x1="72" y1="104" x2="52" y2="102"/>
          <line x1="128" y1="104" x2="148" y2="102"/>
        </g>
      </g>
      <rect width="200" height="220" filter="url(#lf-paper)" opacity="0.25" pointerEvents="none"/>
    </svg>
  );
}

// ─── Robot Cat — BLUE boxy robot cat with chest panel ───
function RobotCat({ mood = 'happy', size = 160 }) {
  const blue = '#4A7CB8', blueDk = '#2D5590', blueLt = '#6A9CD8', panel = '#3A6AA0';
  return (
    <svg viewBox="0 0 200 220" width={size} height={size * 1.1} style={{ overflow: 'visible' }}>
      <WatercolorDefs id="rb"/>
      <ellipse cx="100" cy="208" rx="52" ry="5" fill="#3D2E23" opacity="0.14"/>

      {/* Body — boxy */}
      <path d="M55,200 L55,130 Q60,115 100,115 Q140,115 145,130 L145,200 Z"
            fill={blue} stroke="#3D2E23" strokeWidth="2.4" filter="url(#rb-brush)"/>

      {/* Chest panel — 2x2 grid w/ heart */}
      <rect x="78" y="140" width="44" height="44" rx="3" fill={panel} stroke="#3D2E23" strokeWidth="2"/>
      <line x1="100" y1="140" x2="100" y2="184" stroke="#3D2E23" strokeWidth="1.6"/>
      <line x1="78" y1="162" x2="122" y2="162" stroke="#3D2E23" strokeWidth="1.6"/>
      <path d="M96,172 L100,168 L104,172 L100,176 Z" fill="#E87E8A"/>

      {/* Arms raised — one with maraca */}
      <g style={{ transformOrigin: '55px 130px', animation: 'sway 4s infinite ease-in-out' }}>
        <path d="M55,130 Q35,110 32,85" stroke={blue} strokeWidth="12" strokeLinecap="round" fill="none"/>
        <path d="M55,130 Q35,110 32,85" stroke="#3D2E23" strokeWidth="14" strokeLinecap="round" fill="none" opacity="0.15"/>
        <circle cx="32" cy="82" r="8" fill={blue} stroke="#3D2E23" strokeWidth="2"/>
      </g>
      <g style={{ transformOrigin: '145px 130px', animation: 'sway 4s infinite ease-in-out reverse' }}>
        <path d="M145,130 Q165,112 168,88" stroke={blue} strokeWidth="12" strokeLinecap="round" fill="none"/>
        <circle cx="168" cy="85" r="8" fill={blue} stroke="#3D2E23" strokeWidth="2"/>
        {/* maraca */}
        <ellipse cx="172" cy="78" rx="6" ry="8" fill="#F0D090" stroke="#3D2E23" strokeWidth="1.6"/>
        <path d="M168,78 L168,68" stroke="#E87E8A" strokeWidth="2"/>
      </g>

      {/* Legs */}
      <rect x="68" y="195" width="20" height="10" rx="2" fill={blueDk} stroke="#3D2E23" strokeWidth="2"/>
      <rect x="112" y="195" width="20" height="10" rx="2" fill={blueDk} stroke="#3D2E23" strokeWidth="2"/>

      {/* Head — big cat silhouette */}
      <g style={{ transformOrigin: '100px 75px', animation: 'breathe 4s infinite ease-in-out' }}>
        {/* Ears — tall triangles */}
        <path d="M58,55 L50,15 L85,45 Z" fill={blue} stroke="#3D2E23" strokeWidth="2.2"/>
        <path d="M63,48 L59,25 L78,48 Z" fill={blueLt}/>
        <path d="M142,55 L150,15 L115,45 Z" fill={blue} stroke="#3D2E23" strokeWidth="2.2"/>
        <path d="M137,48 L141,25 L122,48 Z" fill={blueLt}/>

        {/* Head circle */}
        <path d="M50,85 Q48,45 100,42 Q152,45 150,85 Q148,115 115,118 Q85,118 52,115 Q48,100 50,85 Z"
              fill={blue} stroke="#3D2E23" strokeWidth="2.4" filter="url(#rb-brush)"/>

        {/* Eyes — simple round dots */}
        {mood === 'grumpy' ? (
          <>
            <line x1="72" y1="85" x2="88" y2="82" stroke="#1A1A2A" strokeWidth="3.5" strokeLinecap="round"/>
            <line x1="112" y1="82" x2="128" y2="85" stroke="#1A1A2A" strokeWidth="3.5" strokeLinecap="round"/>
          </>
        ) : mood === 'sad' ? (
          <>
            <circle cx="80" cy="85" r="4" fill="#1A1A2A"/>
            <circle cx="120" cy="85" r="4" fill="#1A1A2A"/>
            <path d="M70,72 Q80,78 90,72" stroke="#1A1A2A" strokeWidth="1.8" fill="none" strokeLinecap="round"/>
            <path d="M110,72 Q120,78 130,72" stroke="#1A1A2A" strokeWidth="1.8" fill="none" strokeLinecap="round"/>
          </>
        ) : (
          <>
            <circle cx="80" cy="82" r="5" fill="#1A1A2A"/>
            <circle cx="120" cy="82" r="5" fill="#1A1A2A"/>
            <circle cx="82" cy="80" r="1.5" fill="#fff"/>
            <circle cx="122" cy="80" r="1.5" fill="#fff"/>
          </>
        )}

        {/* Nose + smile */}
        <path d="M96,96 L104,96 L100,101 Z" fill="#1A1A2A"/>
        <path d="M100,101 Q93,108 86,106 M100,101 Q107,108 114,106" stroke="#1A1A2A" strokeWidth="2" fill="none" strokeLinecap="round"/>
      </g>
      <rect width="200" height="220" filter="url(#rb-paper)" opacity="0.25" pointerEvents="none"/>
    </svg>
  );
}

// ─── Kalia — child, dark curly hair, blue patterned dress, pink shoes ───
function Kalia({ size = 160 }) {
  const skin = '#E8C8A8', skinDk = '#C89878', hair = '#3D2518', dress = '#3E5B7A', dressLt = '#5A7BA0';
  return (
    <svg viewBox="0 0 200 260" width={size} height={size * 1.3} style={{ overflow: 'visible' }}>
      <WatercolorDefs id="kl"/>
      <ellipse cx="100" cy="248" rx="42" ry="5" fill="#3D2E23" opacity="0.14"/>

      {/* Legs (tights - dark gray) */}
      <rect x="84" y="200" width="12" height="38" rx="3" fill="#5C5560" stroke="#3D2E23" strokeWidth="2"/>
      <rect x="104" y="200" width="12" height="38" rx="3" fill="#5C5560" stroke="#3D2E23" strokeWidth="2"/>
      {/* Pink shoes */}
      <path d="M78,240 Q78,246 94,246 L98,246 L98,238 L82,238 Z" fill="#E87E8A" stroke="#3D2E23" strokeWidth="2"/>
      <path d="M102,238 L102,246 L106,246 Q122,246 122,240 L118,238 Z" fill="#E87E8A" stroke="#3D2E23" strokeWidth="2"/>

      {/* Dress — blue A-line */}
      <path d="M65,135 Q72,125 100,122 Q128,125 135,135 L148,202 Q100,210 52,202 Z"
            fill={dress} stroke="#3D2E23" strokeWidth="2.4" filter="url(#kl-brush)"/>
      {/* Dress pattern — little white dots */}
      <g fill="#FBF5EA" opacity="0.7">
        <circle cx="80" cy="155" r="2"/><circle cx="100" cy="145" r="2"/><circle cx="120" cy="160" r="2"/>
        <circle cx="75" cy="175" r="2"/><circle cx="100" cy="170" r="2"/><circle cx="128" cy="180" r="2"/>
        <circle cx="88" cy="190" r="2"/><circle cx="115" cy="192" r="2"/>
      </g>
      {/* shoulder straps + ruffle */}
      <path d="M78,130 Q75,122 82,118" stroke="#3D2E23" strokeWidth="2" fill="none"/>
      <path d="M122,130 Q125,122 118,118" stroke="#3D2E23" strokeWidth="2" fill="none"/>
      {/* pink inner top visible */}
      <path d="M82,118 Q100,112 118,118 L122,130 Q100,135 78,130 Z" fill="#F5D0C4" stroke="#3D2E23" strokeWidth="2"/>

      {/* Arms — skin tone */}
      <path d="M75,132 Q60,155 62,175" stroke={skin} strokeWidth="11" strokeLinecap="round" fill="none" stroke2="#3D2E23"/>
      <path d="M75,132 Q60,155 62,175" stroke="#3D2E23" strokeWidth="13" strokeLinecap="round" fill="none" opacity="0.15"/>
      <circle cx="62" cy="177" r="7" fill={skin} stroke="#3D2E23" strokeWidth="1.6"/>
      <path d="M125,132 Q140,155 138,175" stroke={skin} strokeWidth="11" strokeLinecap="round" fill="none"/>
      <circle cx="138" cy="177" r="7" fill={skin} stroke="#3D2E23" strokeWidth="1.6"/>

      {/* Head */}
      <g style={{ transformOrigin: '100px 80px', animation: 'breathe 4s infinite ease-in-out' }}>
        {/* Hair back halo (big curls) */}
        <path d="M45,95 Q38,45 100,32 Q162,45 155,95 Q155,115 140,118 Q100,112 60,118 Q45,115 45,95 Z"
              fill={hair} stroke="#2A1810" strokeWidth="2" filter="url(#kl-brush)"/>
        {/* individual curls around edge */}
        <circle cx="48" cy="70" r="12" fill={hair}/>
        <circle cx="52" cy="95" r="11" fill={hair}/>
        <circle cx="152" cy="70" r="12" fill={hair}/>
        <circle cx="148" cy="95" r="11" fill={hair}/>
        <circle cx="65" cy="45" r="13" fill={hair}/>
        <circle cx="100" cy="35" r="14" fill={hair}/>
        <circle cx="135" cy="45" r="13" fill={hair}/>

        {/* Face */}
        <path d="M65,85 Q62,60 100,56 Q138,60 135,85 Q132,110 100,115 Q68,110 65,85 Z"
              fill={skin} stroke="#3D2E23" strokeWidth="2.2" filter="url(#kl-brush)"/>
        {/* Bangs/fringe */}
        <path d="M65,75 Q80,65 100,68 Q120,65 135,75 Q130,60 100,58 Q70,60 65,75 Z" fill={hair}/>

        {/* Cheeks */}
        <ellipse cx="76" cy="96" rx="6" ry="3.5" fill="#E87E8A" opacity="0.6"/>
        <ellipse cx="124" cy="96" rx="6" ry="3.5" fill="#E87E8A" opacity="0.6"/>

        {/* Eyes */}
        <ellipse cx="85" cy="88" rx="3.2" ry="4" fill="#3D2518"/>
        <ellipse cx="115" cy="88" rx="3.2" ry="4" fill="#3D2518"/>
        <circle cx="86" cy="86" r="1.2" fill="#fff"/>
        <circle cx="116" cy="86" r="1.2" fill="#fff"/>

        {/* Smile */}
        <path d="M92,104 Q100,109 108,104" stroke="#3D2E23" strokeWidth="1.8" fill="none" strokeLinecap="round"/>
      </g>
      <rect width="200" height="260" filter="url(#kl-paper)" opacity="0.25" pointerEvents="none"/>
    </svg>
  );
}

// ─── Yarn-basket corner (matches source reference) ───
function YarnBasket({ active = false }) {
  return (
    <svg viewBox="0 0 220 180" width="100%" height="100%" style={{ overflow: 'visible' }}>
      <defs>
        <filter id="yb-brush"><feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed="4"/><feDisplacementMap in="SourceGraphic" scale="1.2"/></filter>
      </defs>
      {active && (
        <ellipse cx="110" cy="110" rx="90" ry="70" fill="#F0D090" opacity="0.35">
          <animate attributeName="rx" from="70" to="100" dur="1.6s" repeatCount="indefinite"/>
          <animate attributeName="opacity" from="0.5" to="0" dur="1.6s" repeatCount="indefinite"/>
        </ellipse>
      )}
      {/* Cat bed — purple, cat-ear shape */}
      <path d="M50,80 L45,55 L70,70 Q95,60 120,72 L135,50 L132,80 Q145,95 140,130 Q120,150 85,148 Q55,145 45,125 Q40,100 50,80 Z"
            fill="#B8A5D0" stroke="#3D2E23" strokeWidth="2" filter="url(#yb-brush)"/>
      <path d="M58,85 Q55,105 62,125 Q90,135 118,125 Q128,105 125,85 Q100,78 58,85 Z" fill="#8B7AAE"/>
      {/* cushion */}
      <ellipse cx="90" cy="115" rx="32" ry="10" fill="#D0C0E0"/>

      {/* Yarn basket (right) */}
      <ellipse cx="175" cy="135" rx="38" ry="28" fill="#B88858" stroke="#3D2E23" strokeWidth="2" filter="url(#yb-brush)"/>
      <g stroke="#8B5E3C" strokeWidth="1.5" fill="none" opacity="0.7">
        <ellipse cx="175" cy="128" rx="36" ry="4"/>
        <ellipse cx="175" cy="138" rx="38" ry="4"/>
      </g>
      {/* yarn balls in basket */}
      <circle cx="160" cy="115" r="11" fill="#E87E8A" stroke="#3D2E23" strokeWidth="1.5"/>
      <circle cx="180" cy="112" r="12" fill="#F0D090" stroke="#3D2E23" strokeWidth="1.5"/>
      <circle cx="195" cy="118" r="10" fill="#7BC4A8" stroke="#3D2E23" strokeWidth="1.5"/>
      <circle cx="170" cy="122" r="10" fill="#8A9BD8" stroke="#3D2E23" strokeWidth="1.5"/>
      <circle cx="188" cy="128" r="9" fill="#B8A5D0" stroke="#3D2E23" strokeWidth="1.5"/>
      {/* yarn ball detail lines */}
      <g stroke="#3D2E23" strokeWidth="0.6" fill="none" opacity="0.5">
        <path d="M155,112 Q160,110 166,115"/><path d="M175,108 Q182,108 186,114"/>
      </g>
      {/* loose ball front */}
      <circle cx="135" cy="150" r="10" fill="#F0B270" stroke="#3D2E23" strokeWidth="1.5"/>
      <path d="M135,150 Q110,155 90,160" stroke="#F0B270" strokeWidth="1.5" fill="none"/>
      {/* mouse toy */}
      <ellipse cx="100" cy="165" rx="8" ry="5" fill="#8A8090" stroke="#3D2E23" strokeWidth="1.5"/>
      <path d="M108,165 Q118,168 120,172" stroke="#E87E8A" strokeWidth="1.3" fill="none"/>
    </svg>
  );
}

// ─── Window (matches source: arched window w/ curtains + hills) ───
function Window({ timeOfDay = 'afternoon' }) {
  const skies = {
    morning:   { top: '#FCE4BA', bot: '#F4B88A' },
    afternoon: { top: '#BCDFF2', bot: '#E8D5B0' },
    dusk:      { top: '#E8A878', bot: '#D88A7A' },
    night:     { top: '#2A3450', bot: '#5D5070' },
  };
  const s = skies[timeOfDay] || skies.afternoon;
  const isNight = timeOfDay === 'night';
  return (
    <svg viewBox="0 0 180 150" width="100%" height="100%">
      <defs>
        <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={s.top}/><stop offset="100%" stopColor={s.bot}/>
        </linearGradient>
      </defs>
      {/* Sky inside window */}
      <rect x="30" y="15" width="120" height="115" fill="url(#sky)"/>
      {/* Sun/moon */}
      {isNight ? (
        <circle cx="110" cy="45" r="12" fill="#FBF5EA"/>
      ) : (
        <circle cx={timeOfDay==='morning'?55:timeOfDay==='dusk'?120:110} cy="45" r="12" fill="#FFE89C"/>
      )}
      {/* clouds */}
      {!isNight && (<g fill="#fff" opacity="0.9">
        <ellipse cx="60" cy="40" rx="10" ry="4"/>
        <ellipse cx="85" cy="55" rx="12" ry="4"/>
      </g>)}
      {/* Trees/hills */}
      <path d="M30,95 Q60,75 90,90 Q120,80 150,95 L150,130 L30,130 Z" fill={isNight ? '#3D3050' : '#7BA078'}/>
      <circle cx="55" cy="85" r="12" fill={isNight ? '#2A2240' : '#7BA078'}/>
      <circle cx="115" cy="80" r="14" fill={isNight ? '#2A2240' : '#7BA078'}/>

      {/* Window frame */}
      <rect x="30" y="15" width="120" height="115" fill="none" stroke="#E8D5B0" strokeWidth="6"/>
      <line x1="90" y1="15" x2="90" y2="130" stroke="#E8D5B0" strokeWidth="4"/>
      <line x1="30" y1="72" x2="150" y2="72" stroke="#E8D5B0" strokeWidth="4"/>

      {/* Curtains — pink */}
      <path d="M30,15 Q20,70 25,130 L10,130 Q5,70 15,15 Z" fill="#F5C0CC" stroke="#3D2E23" strokeWidth="1.5"/>
      <path d="M150,15 Q160,70 155,130 L170,130 Q175,70 165,15 Z" fill="#F5C0CC" stroke="#3D2E23" strokeWidth="1.5"/>
      {/* curtain rod */}
      <rect x="5" y="10" width="170" height="6" rx="3" fill="#B88858" stroke="#3D2E23" strokeWidth="1.2"/>
      <circle cx="8" cy="13" r="5" fill="#B88858" stroke="#3D2E23" strokeWidth="1.2"/>
      <circle cx="172" cy="13" r="5" fill="#B88858" stroke="#3D2E23" strokeWidth="1.2"/>
      {/* curtain ties */}
      <ellipse cx="27" cy="75" rx="8" ry="4" fill="#D8A0B0"/>
      <ellipse cx="153" cy="75" rx="8" ry="4" fill="#D8A0B0"/>
    </svg>
  );
}

// ─── Mood poster (matches source: "HOW ARE YOU FEELING?" chart) ───
function MoodChart() {
  return (
    <svg viewBox="0 0 140 90" width="100%" height="100%">
      <rect width="140" height="90" rx="4" fill="#FBF5EA" stroke="#B88858" strokeWidth="3"/>
      <text x="70" y="14" textAnchor="middle" fontSize="9" fontWeight="700" fontFamily="Nunito" fill="#B8A5D0">HOW ARE YOU FEELING?</text>
      {[
        {c:'#F0D090', e:'happy'}, {c:'#8FB8C7', e:'sad'}, {c:'#E87E8A', e:'mad'},
        {c:'#B8A5D0', e:'shy'}, {c:'#7BC4A8', e:'calm'}, {c:'#E8B4A0', e:'ok'},
      ].map((f, i) => (
        <g key={i} transform={`translate(${10 + (i%3)*42}, ${22 + Math.floor(i/3)*32})`}>
          <circle cx="14" cy="10" r="9" fill={f.c} stroke="#3D2E23" strokeWidth="1.4"/>
          <circle cx="11" cy="9" r="1" fill="#3D2E23"/>
          <circle cx="17" cy="9" r="1" fill="#3D2E23"/>
          <path d="M10,13 Q14,15 18,13" stroke="#3D2E23" strokeWidth="0.9" fill="none"/>
        </g>
      ))}
    </svg>
  );
}

function Plant() {
  return (
    <svg viewBox="0 0 80 110" width="100%" height="100%">
      <path d="M22,85 L58,85 L54,108 L26,108 Z" fill="#B8A5D0" stroke="#3D2E23" strokeWidth="2"/>
      <ellipse cx="40" cy="86" rx="18" ry="4" fill="#D0BEE0"/>
      <g style={{ transformOrigin: '40px 85px', animation: 'sway 6s infinite ease-in-out' }}>
        <path d="M40,85 Q25,55 22,25 Q38,40 42,75" fill="#7BA078" stroke="#3D2E23" strokeWidth="1.5"/>
        <path d="M40,85 Q55,50 58,20 Q45,38 40,76" fill="#A8C5A0" stroke="#3D2E23" strokeWidth="1.5"/>
        <path d="M40,85 Q40,55 40,15 Q46,40 44,80" fill="#7BA078" stroke="#3D2E23" strokeWidth="1.5"/>
      </g>
    </svg>
  );
}

function MagicalTrunk({ pending = false }) {
  return (
    <svg viewBox="0 0 120 100" width="100%" height="100%" style={{ overflow: 'visible' }}>
      {pending && (
        <circle cx="60" cy="55" r="50" fill="#B8A5D0" opacity="0.4">
          <animate attributeName="r" from="40" to="58" dur="1.4s" repeatCount="indefinite"/>
          <animate attributeName="opacity" from="0.5" to="0" dur="1.4s" repeatCount="indefinite"/>
        </circle>
      )}
      <rect x="16" y="45" width="88" height="46" rx="4" fill="#8B5E3C" stroke="#3D2E23" strokeWidth="2"/>
      <path d="M16,45 Q16,22 60,22 Q104,22 104,45 Z" fill="#A87048" stroke="#3D2E23" strokeWidth="2"/>
      <rect x="28" y="22" width="6" height="69" fill="#F0D090" stroke="#3D2E23" strokeWidth="1.4"/>
      <rect x="86" y="22" width="6" height="69" fill="#F0D090" stroke="#3D2E23" strokeWidth="1.4"/>
      <rect x="54" y="55" width="12" height="14" rx="2" fill="#F0D090" stroke="#3D2E23" strokeWidth="1.4"/>
      <circle cx="60" cy="60" r="2" fill="#3D2E23"/>
      {pending && (<g fill="#F0D090">
        <circle cx="30" cy="15" r="2"><animate attributeName="opacity" values="1;0;1" dur="2s" repeatCount="indefinite"/></circle>
        <circle cx="95" cy="18" r="1.5"><animate attributeName="opacity" values="0;1;0" dur="2s" repeatCount="indefinite"/></circle>
        <circle cx="60" cy="8" r="2"><animate attributeName="opacity" values="1;0.2;1" dur="1.6s" repeatCount="indefinite"/></circle>
      </g>)}
    </svg>
  );
}

function MoodBubble({ mood }) {
  const glyph = { happy:'♡', calm:'˚', sad:'•︵•', grumpy:'⌢', zoomies:'⚡', neutral:'∙' }[mood] || '∙';
  const color = { happy:'#D88A7A', calm:'#7BA078', sad:'#8FB8C7', grumpy:'#B25C20', zoomies:'#E87E8A', neutral:'#A39282' }[mood];
  return (
    <div style={{
      position: 'absolute', top: -4, left: '50%', transform: 'translateX(-50%)',
      background: '#fff', padding: '3px 10px', borderRadius: 100,
      fontSize: 13, fontWeight: 800, color,
      boxShadow: '0 4px 10px rgba(61,46,35,0.18)',
      animation: 'popin 0.4s ease-out', whiteSpace: 'nowrap',
    }}>{glyph}</div>
  );
}

Object.assign(window, { Noodles, LoafCat, RobotCat, Kalia, Window, MoodChart, YarnBasket, MagicalTrunk, Plant, MoodBubble });
