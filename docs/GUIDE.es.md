# Window FX: paso a paso

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · **Español** · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Instalar el plugin

Desde el registro de complementos:

```sh
dms plugins install windowFx
```

O clona el repositorio en tu carpeta de plugins de DMS:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
```

## 2. Activarlo

Abre Ajustes → Complementos. Window FX aparece en la lista. Actívalo.

![Lista de plugins con Window FX](images/01-plugin-list.png)

Si no aparece, pulsa «Scan» en esa página o reinicia el shell con `dms restart`.

## 3. Que niri lea el archivo del plugin

El plugin escribe sus animaciones en `~/.config/niri/windowfx.kdl`. niri solo lee ese archivo si tu configuración lo incluye. Añade esta línea al final del todo de `~/.config/niri/config.kdl`:

```kdl
include optional=true "windowfx.kdl"
```

Va al final porque un include sobrescribe lo que va antes. Si tu configuración tiene su propio bloque `animations` con `window-close` o `window-open`, así ganan los valores del plugin. `optional=true` evita que niri se queje mientras el archivo aún no existe; necesita niri 26.04 o más reciente.

niri recoge el cambio en cuanto guardas el archivo.

## 4. Elegir una animación al cerrar

Despliega Window FX en la lista de plugins. En «Animación al cerrar» elige uno de los 13 tipos, por ejemplo Añicos.

![La página de ajustes con la lista de tipos](images/02-close-animation.png)

Abre una terminal y vuelve a cerrarla. La ventana se rompe en trozos que giran y caen fuera del marco.

![Una ventana rompiéndose en añicos](images/03-shatter.png)

«Duración» fija cuánto tarda, de 150 a 3000 ms. Con 600 ms es rápida, con 1500 ms puedes verla con calma.

## 5. Elegir cómo se abren las ventanas

«Animación al abrir» empieza en «Como al cerrar, al revés»: una ventana nueva aparece igual que desapareció la última, reproducido en sentido contrario. Las brasas se juntan, los añicos suben y se unen. Mientras la animación al cerrar sea «Predeterminado de niri», esto deja también la apertura a niri.

También puedes elegir otro tipo para abrir, «Aleatorio», o «Predeterminado de niri» si prefieres mantener la animación propia de niri para las ventanas nuevas. «Duración al abrir» funciona como la de cerrar; 450 ms es el valor predeterminado, porque una ventana nueva debería estar ahí pronto.

## 6. Bordes luminosos

«Bordes luminosos» hace que el frente del fuego, las grietas entre los añicos y las juntas de los cuadros se iluminen en tu color de acento. Desactívalo para animaciones sencillas sin luz.

![Grietas iluminadas en el color de acento](images/04-glow.png)

El color sigue al acento de DMS: cuando cambia el acento, la siguiente animación brilla en el color nuevo. Tubo apagado siempre destella en blanco.

## 7. Dejarlo al azar (opcional)

Elige «Aleatorio» como animación al cerrar. Así cada ventana recibe su propio tipo. Debajo de los ajustes aparece una lista, «El modo aleatorio elige entre estos:», donde activas o desactivas cada tipo.

![La selección para el modo aleatorio](images/05-random.png)

Al principio hay seis tipos activados: Brasas, Añicos, Derretir, Fallo de señal, Tubo apagado y Lluvia de código. Si los desactivas todos, se usa Brasas.

## 8. Las vecinas esperan (niri con hold-layout)

Cuando se cierra una ventana en medio de una fila, niri mueve enseguida las ventanas de su derecha hacia el hueco, y estas se deslizan sobre la animación mientras sigue en marcha. Si tu niri conoce la opción `hold-layout`, la página de ajustes muestra el interruptor «Las vecinas esperan». Con él activado, las vecinas se quedan donde están hasta que termina la animación de cierre, y solo entonces se desplazan.

`hold-layout` no forma parte de niri; la opción viene de un parche no oficial. Con el niri de tu distribución el interruptor queda oculto. Todo lo demás de esta guía funciona sin él.

Pruébalo con una ventana que tenga otra a su derecha; cuando se cierra la última ventana de una fila, no se mueve nada.

Si el interruptor no aparece, tu niri no tiene la opción. El plugin lo comprueba al arrancar haciendo que `niri validate` lea un archivo diminuto que la usa, y nunca escribe la opción para un niri que la rechazaría.

## 9. Guardar las animaciones por perfil (opcional)

Con el plugin [Profiles](https://github.com/satoshoe-dev/dms-profiles), escribe `windowFx` en «Complementos guardados con el perfil». Así cada perfil guarda sus propias animaciones, por ejemplo unas tranquilas para trabajar y Fallo de señal para la noche.

## 10. Desde un script

```sh
dms ipc call windowFx kind melt      # close animation: a kind, random or default
dms ipc call windowFx open random    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Los tipos se llaman `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` y `blinds`.

Ponlo en una tecla, en niri:

```kdl
binds {
    Mod+Shift+W hotkey-overlay-title="Window FX: random close animation" { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Solución de problemas

### Las ventanas se siguen cerrando como siempre

Falta la línea include del paso 3, o «Animación al cerrar» está en «Predeterminado de niri». `ls ~/.config/niri/windowfx.kdl` muestra si el plugin ha escrito su archivo.

### Ganan mis propias animaciones de config.kdl

La línea include está por encima de tu bloque `animations`. Muévela al final del archivo.

### niri muestra un error de configuración que menciona `hold-layout`

niri se sustituyó por uno sin la opción, y el archivo aún la contiene de antes. En cuanto DMS está en marcha, el plugin vuelve a comprobarlo y escribe el archivo sin ella; niri lo vuelve a cargar por su cuenta.

### «Las vecinas esperan» no aparece

El niri instalado no conoce `hold-layout`. Cuando lo conozca, el interruptor aparece tras el siguiente arranque de DMS.

### Aleatorio muestra siempre el mismo tipo

En la lista del paso 7 solo hay un tipo activado, o ninguno; entonces se usa Brasas.

### Las animaciones se quedan después de desactivar el plugin

El plugin deja `windowfx.kdl` donde está. Pon las dos animaciones en «Predeterminado de niri» antes de desactivarlo, o borra el archivo.
