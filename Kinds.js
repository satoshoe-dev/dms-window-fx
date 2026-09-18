.pragma library

// Close animations, numbered as in shaders/close.glsl. "pool" is the default
// for the random mode.
var list = [
    { id: 1, key: "ember", label: "Ember", pool: true },
    { id: 2, key: "dissolve", label: "Dissolve", pool: false },
    { id: 3, key: "pixel", label: "Pixelate", pool: false },
    { id: 4, key: "shatter", label: "Shatter", pool: true },
    { id: 5, key: "melt", label: "Melt", pool: true },
    { id: 6, key: "glitch", label: "Glitch", pool: true },
    { id: 7, key: "crt", label: "Tube off", pool: true },
    { id: 8, key: "snow", label: "Snowstorm", pool: false },
    { id: 9, key: "scan", label: "Scan", pool: false },
    { id: 10, key: "code", label: "Code rain", pool: true },
    { id: 11, key: "swirl", label: "Swirl", pool: false },
    { id: 12, key: "squares", label: "Squares", pool: false },
    { id: 13, key: "blinds", label: "Blinds", pool: false }
];

function byKey(key) {
    for (var i = 0; i < list.length; i++) {
        if (list[i].key === key)
            return list[i];
    }
    return null;
}
