// Window FX: close and open animations for niri, filled in by the Window FX plugin.
//
// niri runs this over the whole screen while a closed window disappears, or
// while a new one appears. Opening plays the same kind backwards: the plugin
// fills in open_color and a reversed progress. The window texture is
// premultiplied, and so is the result. coords_geo is 0..1 inside the window;
// the shards and the melt may leave the window downwards, every other kind
// stays inside it.
//
//  1 ember      2 dissolve   3 pixel      4 shatter    5 melt
//  6 glitch     7 crt        8 snow       9 scan      10 code
// 11 swirl     12 squares   13 blinds
//
// The lines marked with @ are filled in by the plugin.

const int wfxKind = @KIND@;           // 0: pick from the pool below
const float wfxGlow = @GLOW@;         // 0 no edge glow, 1 full
const vec3 wfxAccent = vec3(@ACCENT@);

int wfxPick(float r) {
@PICK@
}

float wfxHash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float wfxHash1(float n) {
    return fract(sin(n * 91.3458) * 47453.5453);
}

vec2 wfxHash2(vec2 p) {
    return vec2(wfxHash(p), wfxHash(p + vec2(17.13, 3.71)));
}

float wfxNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(wfxHash(i), wfxHash(i + vec2(1.0, 0.0)), u.x),
               mix(wfxHash(i + vec2(0.0, 1.0)), wfxHash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float wfxFbm(vec2 p) {
    float s = 0.0;
    float a = 0.5;
    for (int i = 0; i < 5; i++) {
        s += a * wfxNoise(p);
        p *= 2.03;
        a *= 0.5;
    }
    return s;
}

bool wfxInside(vec2 g) {
    return g.x >= 0.0 && g.y >= 0.0 && g.x <= 1.0 && g.y <= 1.0;
}

// window color at a point in geometry coordinates, clear outside the window
vec4 wfxTex(vec2 g) {
    if (!wfxInside(g))
        return vec4(0.0);
    vec3 t = niri_geo_to_tex * vec3(g, 1.0);
    return texture2D(niri_tex, t.st);
}

float wfxKeep(float value, float threshold, float w) {
    return smoothstep(threshold - w, threshold, value);
}

float wfxBand(float value, float threshold, float w) {
    float d = (value - threshold + w * 0.5) / (w * 0.35);
    return exp(-d * d);
}

float wfxLuma(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

vec4 @FUNCTION@(vec3 coords_geo, vec3 size_geo) {
    vec2 uv = coords_geo.xy;
    vec2 px = max(size_geo.xy, vec2(1.0));
    float aspect = px.x / px.y;
    // 0: window fully there, 1: gone. Opening runs it from 1 to 0.
    float p = clamp(@PROGRESS@, 0.0, 1.0);
    float z = fract(niri_random_seed * 7.137 + 0.31);
    int kind = wfxKind;
    if (kind == 0)
        kind = wfxPick(niri_random_seed);

    // Only the shards and the melt draw below the window.
    bool falls = kind == 4 || kind == 5;
    if (falls) {
        if (uv.x < -0.7 || uv.x > 1.7 || uv.y < 0.0 || uv.y > 3.2)
            return vec4(0.0);
    } else if (!wfxInside(uv)) {
        return vec4(0.0);
    }

    vec2 src = uv;
    float a = 1.0;
    float edge = 0.0;
    vec4 col = vec4(0.0);
    bool done = false;
    float bright = 1.0;

    if (kind == 1) {
        // ember: the window burns away along a noisy front
        float n = wfxFbm(uv * px / 260.0 + z * 31.0);
        n = n * 0.85 + 0.15 * (1.0 - length(uv - 0.5));
        float w = 0.045;
        float f = p * (1.0 + 2.0 * w) - w;
        a = wfxKeep(n, f, w * 0.5);
        edge = wfxBand(n, f, w * 1.6);
    } else if (kind == 2) {
        // dissolve: coarse grain in random order
        float grain = wfxHash(floor(uv * px / 3.0) + floor(z * 13.0));
        a = smoothstep(p - 0.04, p, grain * 0.96 + 0.02);
    } else if (kind == 3) {
        // pixel: blocks grow, then fade
        float size = mix(1.0, 48.0, p * p);
        src = (floor(uv * px / size) + 0.5) * size / px;
        a = 1.0 - smoothstep(0.55, 1.0, p);
    } else if (kind == 4) {
        // shatter: Voronoi shards break apart, spin and fall out of the window
        vec2 grid = max(vec2(3.0), floor(px / 90.0));
        vec2 cellPos = uv * grid;
        vec2 base = floor(cellPos);
        a = 0.0;
        float t = smoothstep(0.08, 1.0, p);
        for (int j = -3; j <= 1; j++) {
            for (int i = -1; i <= 1; i++) {
                vec2 cell = base + vec2(float(i), float(j));
                vec2 c = cell + 0.15 + 0.7 * wfxHash2(cell + floor(z * 41.0));
                float spin = (wfxHash(cell + 5.0) - 0.5) * 3.0 * t;
                float size = max(0.001, 1.0 - t * (0.7 + 0.3 * wfxHash(cell + 9.0)));
                vec2 drift = vec2((c.x / grid.x - 0.5) * 1.6 * t, 2.6 * t * t);
                vec2 rel = cellPos - c - drift;
                float s = sin(-spin);
                float co = cos(-spin);
                rel = mat2(co, -s, s, co) * rel / size;
                vec2 q = c + rel;
                vec2 qb = floor(q);
                float best = 1e9;
                float second = 1e9;
                vec2 bestCell = vec2(-999.0);
                for (int jj = -1; jj <= 1; jj++) {
                    for (int ii = -1; ii <= 1; ii++) {
                        vec2 z2 = qb + vec2(float(ii), float(jj));
                        vec2 c2 = z2 + 0.15 + 0.7 * wfxHash2(z2 + floor(z * 41.0));
                        float d2 = length(q - c2);
                        if (d2 < best) {
                            second = best;
                            best = d2;
                            bestCell = z2;
                        } else if (d2 < second) {
                            second = d2;
                        }
                    }
                }
                if (bestCell == cell) {
                    src = q / grid;
                    // cracks glow only on the window itself, not in the empty space around it
                    bool on = wfxInside(src);
                    a = on ? 1.0 - smoothstep(0.55, 1.0, p) : 0.0;
                    edge = (on ? 1.0 : 0.0) * exp(-pow((second - best) / 0.05, 2.0)) * (1.0 - smoothstep(0.0, 0.5, p)) * smoothstep(0.0, 0.05, p) * 1.5;
                }
            }
        }
    } else if (kind == 5) {
        // melt: thin columns slide down, each at its own speed
        float columns = max(20.0, floor(px.x / 5.0));
        float i = floor(uv.x * columns);
        float delay = (wfxHash1(i + floor(z * 77.0)) * 0.6 + wfxHash1(floor(i / 6.0) + 3.0) * 0.4) * 0.35;
        float t = max(0.0, p - delay) / (1.0 - delay * 0.6);
        float drop = t * t * 1.6;
        src = vec2(uv.x, uv.y - drop);
        a = 1.0 - smoothstep(0.7, 1.0, p);
        edge = wfxInside(src) ? exp(-pow(src.y / 0.006, 2.0)) * step(0.001, drop) * 0.8 : 0.0;
    } else if (kind == 6) {
        // glitch: tears, split channels, jumping blocks, then it breaks up
        float tick = floor(p * 30.0) + floor(z * 1000.0);
        float I = smoothstep(0.0, 0.18, p);
        vec2 q = uv;
        if (wfxHash1(tick * 1.7) > 0.72)
            q.y = fract(q.y + (wfxHash1(tick + 4.0) - 0.5) * 0.08 * I);
        float bands = mix(8.0, 36.0, wfxHash1(tick + 2.0));
        float band = floor(q.y * bands);
        if (wfxHash(vec2(band, tick)) > 1.0 - 0.45 * I)
            q.x = fract(q.x + (wfxHash(vec2(band + 9.0, tick)) - 0.5) * 0.35 * I);
        vec2 blk = floor(q * vec2(16.0, 10.0));
        if (wfxHash(blk + vec2(tick * 0.37, tick)) > 1.0 - 0.22 * I)
            q = fract(q + (wfxHash2(blk + tick) - 0.5) * 0.25 * I);
        float shift = (0.004 + 0.03 * wfxHash1(tick + 7.0)) * I;
        vec2 vr = vec2(shift, shift * 0.3 * (wfxHash1(tick + 8.0) - 0.5));
        vec4 mid = wfxTex(q);
        col = vec4(wfxTex(fract(q + vr)).r, mid.g, wfxTex(fract(q - vr)).b, mid.a);
        float bf = wfxHash(blk * 1.3 + tick * 2.1);
        if (bf > 1.0 - 0.06 * I)
            col.rgb = vec3(col.a) - col.rgb;
        else if (bf > 1.0 - 0.14 * I)
            col.rgb = mix(col.rgb, wfxAccent * wfxLuma(col.rgb) * 2.2, 0.8 * max(wfxGlow, 0.4));
        float levels = mix(64.0, 5.0, I * wfxHash1(tick + 11.0));
        col.rgb = floor(col.rgb * levels) / levels;
        col.rgb *= 0.82 + 0.18 * sin(uv.y * px.y * 1.4 + tick);
        col.rgb += (wfxHash(uv * px + tick) - 0.5) * 0.35 * I * col.a;
        col.rgb = clamp(col.rgb, 0.0, col.a);
        done = true;
        float zb = wfxHash(floor(uv * vec2(20.0, 12.0)) + floor(z * 91.0));
        a = step(smoothstep(0.35, 1.0, p) * 1.05, zb);
        if (p > 0.25 && wfxHash1(tick * 3.3) > 1.0 - 0.3 * p)
            a = 0.0;
        if (p > 0.97)
            a = 0.0;
    } else if (kind == 7) {
        // crt: squeeze to a line, then to a dot, with a bright flash
        float sy = mix(1.0, 0.003, smoothstep(0.0, 0.5, p));
        float sx = mix(1.0, 0.002, smoothstep(0.5, 0.82, p));
        vec2 q = uv - 0.5;
        src = vec2(q.x / sx, q.y / sy) + 0.5;
        float inY = 1.0 - smoothstep(0.5 * sy, 0.5 * sy + 1.5 / px.y, abs(q.y));
        float inX = 1.0 - smoothstep(0.5 * sx, 0.5 * sx + 1.5 / px.x, abs(q.x));
        a = inY * inX * (1.0 - smoothstep(0.82, 1.0, p));
        bright = 1.0 + 3.5 * smoothstep(0.1, 0.5, p);
        float dot0 = exp(-length(q * vec2(aspect, 1.0)) / 0.02) * smoothstep(0.6, 0.85, p) * (1.0 - smoothstep(0.85, 1.0, p));
        edge = dot0 * 3.0;
    } else if (kind == 8) {
        // snow: the picture drowns in static, then breaks up grain by grain
        float tick = floor(p * 40.0);
        float amount = smoothstep(0.0, 0.45, p);
        vec2 q = uv;
        q.x = fract(q.x + (wfxHash1(floor(uv.y * px.y / 3.0) + tick * 1.3) - 0.5) * 0.03 * amount);
        vec4 prev = wfxTex(q);
        float grain = wfxHash(floor(uv * px / 2.0) + tick * 3.1);
        col = mix(prev, vec4(vec3(grain), 1.0), amount);
        col.rgb *= (0.9 + 0.2 * wfxHash1(tick + 5.0)) * (0.9 + 0.1 * sin(uv.y * px.y * 1.3));
        col.rgb = min(col.rgb, vec3(col.a));
        done = true;
        float gone = smoothstep(0.55, 1.0, p) * 1.1;
        a = smoothstep(gone - 0.1, gone, wfxHash(floor(uv * px / 2.0) + tick * 7.7 + 11.0));
    } else if (kind == 9) {
        // scan: a beam moves down, behind it a glowing wireframe of the edges
        float beam = p * 1.6 - 0.1;
        float behind = beam - uv.y;
        if (behind > 0.0) {
            vec2 o = 1.5 / px;
            float l = wfxLuma(wfxTex(uv + vec2(o.x, 0.0)).rgb) - wfxLuma(wfxTex(uv - vec2(o.x, 0.0)).rgb);
            float m = wfxLuma(wfxTex(uv + vec2(0.0, o.y)).rgb) - wfxLuma(wfxTex(uv - vec2(0.0, o.y)).rgb);
            float outline = clamp(length(vec2(l, m)) * 6.0, 0.0, 1.0);
            float lines = max(step(0.94, fract(uv.x * px.x / 40.0)), step(0.94, fract(uv.y * px.y / 40.0))) * 0.12;
            vec3 tone = wfxGlow > 0.5 ? wfxAccent : vec3(0.3, 1.0, 0.8);
            float lit = outline + lines;
            vec4 prev = wfxTex(uv);
            col = vec4(prev.rgb * 0.08 + tone * lit, max(prev.a * 0.08, min(lit, 1.0)));
            a = 1.0 - smoothstep(0.12, 0.5, behind);
        } else {
            vec2 q = uv;
            float near = exp(-(uv.y - beam) / 0.02);
            q.x += (wfxHash1(floor(uv.y * px.y / 4.0) + floor(p * 40.0)) - 0.5) * 0.03 * near;
            col = wfxTex(q);
        }
        done = true;
        edge = exp(-pow((uv.y - beam) / 0.004, 2.0)) * 1.4;
    } else if (kind == 10) {
        // code: columns of glyphs run down, behind them only code remains
        vec2 cellSize = vec2(10.0, 15.0);
        vec2 zz = floor(uv * px / cellSize);
        vec2 local = fract(uv * px / cellSize);
        float rows = px.y / cellSize.y;
        float speed = 0.9 + wfxHash1(zz.x + floor(z * 71.0)) * 0.9;
        float start = wfxHash1(zz.x * 1.31 + 3.0) * 0.3;
        float head = (p - start) * speed * 1.6;
        float cy = zz.y / rows;
        vec4 prev = wfxTex(uv);
        vec3 tone = mix(vec3(0.25, 1.0, 0.45), wfxAccent, 0.35 * wfxGlow);
        if (cy < head) {
            vec2 sub = floor(local * vec2(6.0, 8.0));
            float glyph = floor(p * 20.0 + wfxHash(zz) * 9.0);
            float lit = step(0.52, wfxHash(sub + zz * 13.1 + glyph));
            lit *= step(0.5, sub.x) * step(sub.x, 4.5) * step(0.5, sub.y) * step(sub.y, 6.5);
            float behind = head - cy;
            float shine = 0.3 + 0.7 * exp(-behind * 9.0);
            vec3 c = prev.rgb * 0.15 + tone * lit * shine;
            if (behind < 1.0 / rows)
                c += vec3(0.8) * lit;
            col = vec4(c, max(prev.a * 0.15, lit * shine));
            a = 1.0 - smoothstep(0.5, 0.95, p + (wfxHash(zz + 7.0) - 0.5) * 0.25);
        } else {
            col = prev;
        }
        done = true;
    } else if (kind == 11) {
        // swirl: the window is wound up around its center
        vec2 q = (uv - 0.5) * vec2(aspect, 1.0);
        float d = length(q);
        float radius = 0.5 * length(vec2(aspect, 1.0));
        float strength = p * p * 9.0 * pow(max(0.0, 1.0 - d / radius), 2.0);
        float s = sin(strength);
        float c = cos(strength);
        q = mat2(c, -s, s, c) * q;
        src = q / vec2(aspect, 1.0) + 0.5;
        a = 1.0 - smoothstep(0.35, 1.0, p);
    } else if (kind == 12) {
        // squares shrink in random order
        vec2 grid = max(vec2(2.0), floor(px / 80.0));
        vec2 cell = floor(uv * grid);
        vec2 local = fract(uv * grid) - 0.5;
        float delay = wfxHash(cell + floor(z * 53.0)) * 0.6;
        float lp = clamp((p - delay) / 0.4, 0.0, 1.0);
        float halfSize = 0.5 * (1.0 - lp);
        float d = max(abs(local.x), abs(local.y));
        a = (1.0 - smoothstep(halfSize - 0.02, halfSize, d)) * (1.0 - lp * 0.3);
        edge = wfxBand(-d, -halfSize, 0.05) * step(0.01, lp) * step(lp, 0.99) * 0.7;
    } else if (kind == 13) {
        // blinds: horizontal slats close towards their own center
        float n = max(4.0, floor(px.y / 40.0));
        float i = floor(uv.y * n);
        float f = fract(uv.y * n);
        float lp = clamp((p - i / n * 0.3) / 0.7, 0.0, 1.0);
        float halfOpen = 0.5 * (1.0 - lp);
        float d = abs(f - 0.5);
        float w = 0.04;
        a = 1.0 - smoothstep(halfOpen - w, halfOpen, d);
        edge = wfxBand(-d, -halfOpen, w) * step(0.01, lp) * step(lp, 0.99);
    } else {
        a = 1.0 - p;
    }

    if (!done)
        col = wfxTex(src);
    if (kind == 7)
        col.rgb = mix(col.rgb, vec3(col.a), clamp((bright - 1.0) / 4.0, 0.0, 0.85));
    else
        col.rgb *= bright;

    // edge glow only while moving; the crt always glows white
    float envelope = smoothstep(0.0, 0.08, p) * (1.0 - smoothstep(0.9, 1.0, p));
    edge *= kind == 7 ? 1.0 : envelope * wfxGlow;
    vec3 tone = kind == 7 ? vec3(1.0) : wfxAccent;
    vec3 light = tone * edge * 0.85 + vec3(1.0, 0.95, 0.85) * pow(min(edge, 1.5), 4.0) * 0.25;

    return col * a + vec4(light, 0.0);
}
