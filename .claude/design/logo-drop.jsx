// logo-drop.jsx — BrightDigit mark: a water drop falls, splashes, and swirls up into each glyph.
const { useComposition, animate, interpolate, Easing, CompositionStage } = window;

const B_HOLE = "M 21.904266 66.140671 C 26.2416 70.476669 30.8536 73.46067 35.742928 75.090004 C 41.681595 77.051338 46.577599 76.104668 50.430931 72.251335 C 54.282928 68.398003 55.436264 63.738007 53.889595 58.268669 C 52.618927 53.683334 49.898933 49.304672 45.728264 45.13533 C 37.580261 36.986008 29.956268 33.727341 22.857597 35.356674 C 20.261597 35.964676 17.885597 37.346008 15.73093 39.500671 C 11.920265 43.31134 10.75893 47.564667 12.250931 52.260666 C 13.521599 56.239334 16.588264 60.714005 21.448265 65.684669 Z";
const B_LETTER = "M 21.956398 66.191467 C 26.292397 70.527473 30.905731 73.511467 35.795067 75.1408 C 41.732399 77.1008 46.628395 76.155472 50.481728 72.302139 C 54.335068 68.448799 55.487068 63.788803 53.941734 58.319473 C 52.669731 53.732803 49.94973 49.355469 45.779068 45.184799 C 37.631065 37.036804 30.007065 33.77681 22.908401 35.407471 C 20.312397 36.015472 17.936398 37.395477 15.781731 39.55014 C 11.971066 43.362137 10.809734 47.615463 12.301731 52.311478 C 13.572399 56.288803 16.639065 60.763466 21.500397 65.735466 Z M 10.375065 0.459473 C 10.804398 0.031479 11.2244 0.024811 11.639065 0.438141 C 12.053734 0.852798 11.743065 2.80748 10.705734 6.300812 C 9.671066 9.795471 9.069733 12.011475 8.9044 12.950134 C 8.323067 15.962143 7.855064 19.082138 7.495068 22.314133 C 6.335068 32.975464 7.219067 39.854141 10.148399 42.947464 C 10.368401 42.726135 10.555065 42.402145 10.705734 41.974136 C 10.859066 41.546143 11.161732 40.800812 11.617733 39.736801 C 12.07373 38.672806 13.288399 37.154144 15.263065 35.178131 C 17.239063 33.204803 19.871063 31.580811 23.15773 30.311478 C 26.444397 29.040802 29.7724 28.4328 33.143066 28.487473 C 40.379066 28.654144 46.676399 31.415466 52.0364 36.774139 C 57.39373 42.132797 60.128395 48.472809 60.236397 55.790131 C 60.348396 63.111473 57.731064 69.442139 52.387062 74.787468 C 47.041733 80.132805 40.539063 82.24614 32.873734 81.127472 C 25.207062 80.008804 18.461731 76.535469 12.633732 70.707466 C 5.369732 63.442139 1.405731 54.755478 0.741734 44.646133 C 0.161732 35.890137 2.095066 23.903473 6.541733 8.683472 C 7.039066 6.970139 7.6964 5.278137 8.509731 3.607468 C 9.325733 1.936798 9.947067 0.887466 10.375065 0.459473";
const D_HOLE = "M 86.552124 116.315071 C 91.413467 111.343071 94.480133 106.868401 95.750793 102.892403 C 97.242798 98.195068 96.081467 93.941734 92.270798 90.129738 C 90.116135 87.975067 87.74147 86.59507 85.142799 85.985733 C 78.045464 84.357735 70.421463 87.617737 62.273468 95.764404 C 58.102798 99.936401 55.381462 104.313736 54.112129 108.899071 C 52.564133 114.368401 53.718796 119.028404 57.572128 122.881737 C 61.425468 126.735069 66.320129 127.681732 72.258797 125.720398 C 77.148132 124.091064 81.760132 121.107071 86.09613 116.771065 Z";
const D_LETTER = "M 86.604126 116.367203 C 91.465469 111.395203 94.530792 106.919205 95.801468 102.943199 C 97.293457 98.245872 96.132126 93.992538 92.321457 90.180534 C 90.166794 88.025871 87.79213 86.644539 85.196129 86.037872 C 78.097466 84.408539 70.47213 87.668533 62.325462 95.815201 C 58.153465 99.987206 55.432129 104.364532 54.162796 108.949867 C 52.616135 114.41787 53.769463 119.079201 57.622795 122.932533 C 61.476128 126.785873 66.370796 127.732536 72.309464 125.771202 C 77.198799 124.141869 81.812134 121.159203 86.148132 116.823204 Z M 99.592133 54.237869 C 100.408127 55.909866 101.064133 57.601868 101.561462 59.313866 C 106.008133 74.533867 107.941467 86.521866 107.361465 95.276535 C 106.698792 105.387199 102.73613 114.073868 95.470795 121.339203 C 89.642792 127.167206 82.896133 130.637863 75.232132 131.757874 C 67.566795 132.876526 61.060127 130.763199 55.716133 125.419205 C 50.370796 120.073868 47.753464 113.740532 47.865463 106.423203 C 47.9748 99.103203 50.709465 92.764534 56.069466 87.404533 C 61.426796 82.047203 67.725464 79.284538 74.962799 79.117867 C 78.33213 79.063202 81.658798 79.671204 84.948128 80.943199 C 88.233459 82.21254 90.865463 83.835205 92.841461 85.811203 C 94.816132 87.785866 96.030792 89.30587 96.485458 90.367203 C 96.941467 91.431206 97.244125 92.175201 97.396133 92.603203 C 97.549469 93.033867 97.73613 93.356537 97.956131 93.576538 C 100.884125 90.48587 101.768127 83.607201 100.608124 72.944534 C 100.248123 69.713867 99.780136 66.592537 99.198792 63.581871 C 99.033463 62.643204 98.433456 60.425865 97.397461 56.931198 C 96.361465 53.437866 96.050797 51.4832 96.465469 51.068542 C 96.878799 50.65387 97.300125 50.661865 97.729462 51.089874 C 98.156128 51.517868 98.778793 52.5672 99.592133 54.237869";

const cl = (v, a, b) => Math.max(a, Math.min(b, v));
const MOTION = {
  fall: (from, to, start, end) => animate({ from, to, start, end, ease: Easing.easeInQuad }),
  swirl: (from, to, start, end) => animate({ from, to, start, end, ease: Easing.easeOutQuart }),
  ease: (from, to, start, end) => animate({ from, to, start, end, ease: Easing.easeInOutSine }),
};

function Goo(props) {
  const { id, bf, disp, blur, gain, seed, children } = props;
  const off = -(gain - 1) * 0.5;
  return (
    <g>
      <defs>
        <filter id={'goo-' + id} x="-60%" y="-60%" width="220%" height="220%"
          colorInterpolationFilters="sRGB">
          <feTurbulence type="fractalNoise" baseFrequency={bf} numOctaves="2" seed={seed} result="t" />
          <feDisplacementMap in="SourceGraphic" in2="t" scale={disp}
            xChannelSelector="R" yChannelSelector="G" result="d" />
          <feGaussianBlur in="d" stdDeviation={blur} result="b" />
          <feColorMatrix in="b" type="matrix"
            values={'1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 ' + gain + ' ' + off} />
        </filter>
      </defs>
      <g filter={'url(#goo-' + id + ')'}>{children}</g>
    </g>
  );
}

// One glyph's whole life: drop falls -> impact squash -> puddle -> swirls up into the letter.
function beat(T, t0, cy, dir) {
  const impact = t0 + 1.05;
  const sStart = impact + 0.22;
  const sEnd = sStart + 1.5;
  const fallU = cl((T - t0) / 1.05, 0, 1);
  const dropY = MOTION.fall(-34, cy, t0, impact)(T);
  const stretch = 1 + 1.25 * fallU * fallU;
  return {
    impact, sStart, sEnd,
    dropVisible: T > t0 - 0.05 && T < impact + 0.05,
    dropY,
    dropRx: 5.4 / (1 + 0.55 * fallU),
    dropRy: 5.4 * stretch,
    puddleRx: interpolate([impact, impact + 0.11, impact + 0.34, sStart + 0.85],
      [5.5, 17, 11.5, 3], Easing.easeOutCubic)(T),
    puddleRy: interpolate([impact, impact + 0.11, impact + 0.34, sStart + 0.85],
      [9, 2.4, 5.8, 2.4], Easing.easeOutCubic)(T),
    puddleO: interpolate([impact - 0.01, impact, sStart + 0.4, sStart + 0.85],
      [0, 1, 1, 0], Easing.easeInOutSine)(T),
    rot: MOTION.swirl(-310 * dir, 0, sStart, sEnd)(T),
    scale: MOTION.swirl(0.1, 1, sStart, sEnd)(T),
    o: cl((T - sStart) / 0.35, 0, 1),
    holeS: MOTION.swirl(0, 1, sStart + 0.6, sEnd + 0.2)(T),
    splash: cl(1 - (T - impact) / 0.6, 0, 1) * (T > impact ? 1 : 0),
    ripple: cl((T - impact) / 0.75, 0, 1) * (T > impact ? 1 : 0),
  };
}

const SPLASH = [
  { a: -2.5, r: 3.0 }, { a: -2.0, r: 2.1 }, { a: -1.15, r: 2.6 },
  { a: -0.7, r: 1.7 }, { a: -0.25, r: 2.3 },
];

function Splash(props) {
  const { cx, cy, u, fill } = props;
  if (u <= 0.01) return null;
  const p = 1 - u;
  return (
    <g>
      {SPLASH.map((s, i) => {
        const d = 8 + 26 * p;
        const x = cx + Math.cos(s.a) * d;
        const y = cy + Math.sin(s.a) * d * 0.85 + 34 * p * p;
        const st = 1 + 0.9 * p;
        return <ellipse key={i} cx={x} cy={y} rx={s.r / st} ry={s.r * st} fill={fill} opacity={u} />;
      })}
    </g>
  );
}

function Ripple(props) {
  const { cx, cy, u, stroke } = props;
  if (u <= 0.01 || u >= 1) return null;
  return (
    <g>
      <ellipse cx={cx} cy={cy} rx={6 + 40 * u} ry={(6 + 40 * u) * 0.34} fill="none"
        stroke={stroke} strokeWidth={1.4 * (1 - u)} opacity={0.8 * (1 - u)} />
      <ellipse cx={cx} cy={cy} rx={3 + 24 * u} ry={(3 + 24 * u) * 0.34} fill="none"
        stroke={stroke} strokeWidth={1 * (1 - u)} opacity={0.5 * (1 - u)} />
    </g>
  );
}

function Piece(props) {
  const { T, authoredTotal, CUES } = useComposition();
  const accent = props.accent || '#f9ed32';
  const ink = props.ink || '#111111';

  const b = beat(T, CUES.Drop + 0.15, 62, 1);
  const d = beat(T, CUES.Drop + 0.15, 112, -1);

  // liquid amount: everything is molten until the mark sets, then it drains away
  const melt = interpolate(
    [0, b.sEnd - 0.4, CUES.Set + 0.5, authoredTotal],
    [1, 0.5, 0.03, 0], Easing.easeInOutSine)(T);
  const blur = 0.16 + melt * 2.4;
  const gain = 1 + 16 * Math.min(1, blur / 1.2);
  const disp = melt * 11 + melt * 4 * (0.5 + 0.5 * Math.sin(T * 3.3));
  const bf = (0.022 + 0.012 * Math.sin(T * 1.7)).toFixed(4);
  const seed = Math.floor(T * 9) % 120;

  const drain = 0;
  const markO = interpolate([0, 0.12], [0, 1], Easing.easeInOutSine)(T);
  const camScale = interpolate([0, CUES.Swirl, CUES.Set + 1.2, authoredTotal],
    [1.12, 1.05, 1.0, 1.0], Easing.easeInOutSine)(T);
  const camY = interpolate([CUES.Set, authoredTotal],
    [5, 0], Easing.easeInOutSine)(T);

  const gT = (cx, cy, s, rot) =>
    'translate(' + cx + ' ' + cy + ') rotate(' + rot + ') scale(' + s + ') translate(' + (-cx) + ' ' + (-cy) + ')';

  return (
    <div style={{ position: 'absolute', inset: 0, overflow: 'hidden',
                  display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ position: 'absolute', inset: 0,
        background: 'radial-gradient(120% 90% at 50% 42%, rgba(255,255,255,0.92), rgba(0,0,0,0.05))' }} />
      <div style={{ position: 'relative', opacity: markO,
        transform: 'translateY(' + (camY + drain * 0.4) + 'px) scale(' + camScale + ')',
        transformOrigin: '50% 50%' }}>
        <svg width="700" height="861" viewBox="-16 -14 140 161" style={{ display: 'block', overflow: 'visible' }}>
          <Ripple cx={33.5} cy={62} u={b.ripple} stroke={accent} />
          <Ripple cx={74.5} cy={112} u={d.ripple} stroke={accent} />

          <Goo id="y" seed={seed} bf={bf} disp={disp} blur={blur} gain={gain}>
            <g transform={'translate(0 ' + drain + ')'}>
              <g opacity={b.holeS} transform={gT(33.5, 56, (0.15 + 0.85 * b.holeS) * (1 + 0.1 * melt), 0)}>
                <path d={B_HOLE} fill={accent} />
              </g>
              <g opacity={d.holeS} transform={gT(74.5, 106.5, (0.15 + 0.85 * d.holeS) * (1 + 0.1 * melt), 0)}>
                <path d={D_HOLE} fill={accent} />
              </g>
            </g>
          </Goo>

          <Goo id="k" seed={seed} bf={bf} disp={disp} blur={blur} gain={gain}>
            <g transform={'translate(0 ' + drain + ')'}>
              {b.dropVisible &&
                <ellipse cx={33.5} cy={b.dropY} rx={b.dropRx} ry={b.dropRy} fill={ink} />}
              {d.dropVisible &&
                <ellipse cx={74.5} cy={d.dropY} rx={d.dropRx} ry={d.dropRy} fill={ink} />}
              <ellipse cx={33.5} cy={62} rx={b.puddleRx} ry={b.puddleRy} fill={ink} opacity={b.puddleO} />
              <ellipse cx={74.5} cy={112} rx={d.puddleRx} ry={d.puddleRy} fill={ink} opacity={d.puddleO} />
              <Splash cx={33.5} cy={62} u={b.splash} fill={ink} />
              <Splash cx={74.5} cy={112} u={d.splash} fill={ink} />
              <g opacity={b.o} transform={gT(33.5, 56, b.scale, b.rot)}>
                <path d={B_LETTER} fill={ink} />
              </g>
              <g opacity={d.o} transform={gT(74.5, 106.5, d.scale, d.rot)}>
                <path d={D_LETTER} fill={ink} />
              </g>
            </g>
          </Goo>
        </svg>
      </div>
    </div>
  );
}

function LogoDrop(props) {
  return (
    <CompositionStage width={1920} height={1080}
      scenes={window.OM_SCENES} playback={window.OM_PLAYBACK}
      bg={props.bg || '#f7f5ef'}>
      <Piece accent={props.accent} ink={props.ink} />
    </CompositionStage>
  );
}

window.LogoDrop = LogoDrop;
