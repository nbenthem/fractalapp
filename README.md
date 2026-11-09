# Fractal Sound App

Explorador interactivo de fractales que funciona en el navegador. Permite cambiar la forma y los colores, navegar por el plano, visualizar algunas órbitas y crear sonidos al mantener pulsada la imagen.

## Índice

- [Cómo empezar](#cómo-empezar)
- [Controles](#controles)
- [Fractales y movimiento del puntero](#fractales-y-movimiento-del-puntero)
- [Cómo funciona el diseño](#cómo-funciona-el-diseño)
  - [Capas y renderizado](#capas-y-renderizado)
  - [Movimiento y cámara](#movimiento-y-cámara)
  - [Órbita](#órbita)
  - [Síntesis de sonido](#síntesis-de-sonido)
  - [Colores, precisión y rendimiento](#colores-precisión-y-rendimiento)
- [Configuración y estructura](#configuración-y-estructura)
- [Solución de problemas](#solución-de-problemas)

## Cómo empezar

Abre [fractalapp.html](./fractalapp.html) en un navegador moderno. No hace falta instalar nada, iniciar un servidor ni tener conexión a internet.

1. Mueve el ratón o el dedo sobre la imagen para modificar el fractal.
2. Elige un fractal y una paleta en los menús inferiores.
3. Mantén pulsada la imagen para escuchar el sonido; suelta para que desaparezca suavemente.
4. Usa el panel de navegación, el teclado o la rueda del ratón para explorar el plano.

El navegador necesita JavaScript, WebGL, Canvas 2D y Web Audio. Si WebGL no está disponible, los fractales calculados por tiempo de escape no se mostrarán; las figuras construidas con Canvas 2D sí pueden seguir mostrándose.

## Controles

| Control | Función |
| --- | --- |
| Menús inferiores | Elegir entre diez fractales y las paletas Fullcolor, Terre y Blue. Al cambiar de fractal se restablecen su vista y sus parámetros iniciales. |
| Puntero o pantalla táctil | Modificar los parámetros de la figura. El movimiento se suaviza y no desplaza la cámara. |
| Mantener pulsada la imagen | Producir sonido; al soltar, el volumen disminuye progresivamente. |
| Botón de sonido | Silenciar o activar el audio. |
| Interruptor «Mostrar órbita» | Mostrar u ocultar los pasos de la órbita en Mandelbrot, Burning Ship y Tricorn. La elección se conserva al cambiar de fractal durante la sesión. |
| Flechas del panel o del teclado | Desplazar la vista. Mantener pulsado continúa el movimiento. |
| `+` / `−` del panel o teclado | Acercar o alejar; mantener pulsado continúa el zoom. |
| Rueda del ratón | Acercar o alejar alrededor del puntero. |
| Botón de inicio, `0` o doble clic | Restablecer la vista inicial del fractal elegido. |
| Botón redondo del panel de movimiento | Ocultar o mostrar los controles de navegación. |
| Panel de información | Consultar nombre, atribución, ecuación o regla, valores, coordenadas y zoom. El botón `−` oculta los detalles, pero mantiene visibles el nombre y las coordenadas. |
| Botón `i` e idioma | Mostrar la ayuda rápida o cerrarla con Escape; cambiar entre español e inglés con el panel de información abierto. |

Las coordenadas son de solo lectura y siguen al puntero. El zoom se expresa respecto a la vista inicial. Las zonas del panel de información que no son botones dejan interactuar con la imagen; cuando el panel tiene el foco del teclado, las flechas arriba y abajo desplazan su contenido en vez de mover la cámara.

La aplicación empieza en español, con el sonido y la órbita activados. Las preferencias y la vista no se guardan al recargar.

## Fractales y movimiento del puntero

En los fractales de tiempo de escape, `z` y `c` son números complejos: sus partes real e imaginaria corresponden a los ejes horizontal y vertical. `z` no es un tercer eje espacial.

| Fractal | Regla | Efecto del puntero |
| --- | --- | --- |
| Julia | `z(n+1) = z(n)² + c` | Cada píxel es un valor inicial `z₀`; el puntero cambia `c` para toda la imagen. |
| Mandelbrot | `z(n+1) = z(n)² + c` | Cada píxel es un valor de `c`; el puntero cambia el `z₀` común. |
| Burning Ship | `z(n+1) = (\|Re(z(n))\| − i\|Im(z(n))\|)² + c` | Cada píxel es `c`; el puntero cambia el `z₀` común. La aplicación usa esta convención reflejada de forma consistente. |
| Tricorn | `z(n+1) = conjugado(z(n))² + c` | Cada píxel es `c`; el puntero cambia el `z₀` común. |
| Multibrot | `z(n+1) = z(n)^d + c` | La posición horizontal cambia el exponente `d`; la vertical cambia la parte imaginaria de `z₀`. Las potencias no enteras usan la rama principal compleja. |
| Julia z³ | `z(n+1) = z(n)³ + c` | Cada píxel es `z₀`; el puntero cambia `c`. |
| Triángulo de Sierpinski | Cada triángulo genera tres más pequeños. | El movimiento horizontal cambia su escala y el vertical gira las subdivisiones. |
| Copo de nieve de Koch | Cada lado se sustituye por cuatro segmentos que forman un pico. | El movimiento horizontal aumenta el siguiente nivel de detalle y el vertical cambia el ángulo del pico. |
| Curva del dragón | Una línea sigue un patrón de giros basado en el plegado de papel. | El movimiento horizontal cambia el ángulo de giro y el vertical rota la figura. |
| Árbol fractal | Cada rama genera dos ramas más cortas. | El movimiento horizontal cambia el ángulo de las ramas y el vertical su proporción de longitud. |

En Mandelbrot, Burning Ship y Tricorn, alejar el puntero del centro cambia `z₀`, creando variaciones que no siempre son los conjuntos clásicos. Para volver a `z₀ = 0`, coloca el puntero en el centro y espera a que termine la transición.

## Cómo funciona el diseño

### Capas y renderizado

La página superpone dos lienzos que ocupan la pantalla:

1. **`#fractalCanvas`:** usa WebGL y un *fragment shader* GLSL para calcular en la GPU los fractales de tiempo de escape. Para cada píxel, el shader transforma su posición en coordenadas del plano, itera la ecuación y calcula el color según el resultado.
2. **`#overlay`:** usa Canvas 2D para dibujar las figuras construidas, los ejes, las marcas del puntero y la órbita. También recibe los eventos del ratón y de la pantalla táctil. Al mostrar figuras construidas se oculta el lienzo WebGL.

El bucle usa `requestAnimationFrame`: actualiza el puntero y la cámara, calcula los parámetros y dibuja lo necesario. El fractal WebGL solo se vuelve a dibujar cuando cambian su tamaño, vista, parámetros, paleta o número de iteraciones. No se utiliza una matriz con saltos de 2 × 2 píxeles ni se garantiza una velocidad fija de 60 FPS.

Las figuras construidas tienen sus propios algoritmos en Canvas 2D: Sierpinski subdivide recursivamente, Koch refina segmentos, el dragón sigue una secuencia de giros y el árbol genera ramas recursivas.

### Movimiento y cámara

La posición del puntero se normaliza entre `−1` y `1` por eje. El programa guarda un objetivo (`T`) y una posición suavizada (`P`); esta última se acerca progresivamente al objetivo y controla los parámetros del fractal y del sonido.

La cámara también tiene una vista objetivo y una vista suavizada. Las flechas desplazan su centro y el zoom cambia su escala; la rueda ajusta el centro para mantener fijo el punto situado bajo el puntero. Los límites de escala son `0.00005–4` para fractales de tiempo de escape y `0.15–4` para figuras construidas; el centro se limita a `[-3, 3]` en cada eje.

### Órbita

En Mandelbrot, Burning Ship y Tricorn, el punto bajo el puntero determina `c`. El círculo indica `z₀` y cada punto siguiente se obtiene aplicando la ecuación al valor anterior, manteniendo `c` fijo. Se muestran hasta 12 pasos, o menos si la secuencia supera el umbral de escape; el panel muestra `c` y, cuando existe, el primer resultado `z₁`.

Los puntos de la órbita son valores de `z`, dibujados a la misma escala que la imagen inferior, cuyos puntos representan valores de `c`. El interruptor solo muestra u oculta esta trayectoria: **no activa un movimiento automático ni una melodía autónoma**.

### Síntesis de sonido

El audio se crea con Web Audio tras una interacción del usuario. Mantener pulsada la imagen activa el volumen y soltarlo lo desvanece. El motor combina:

- Un oscilador senoidal principal que toca la nota seleccionada.
- Un segundo oscilador senoidal a **doble frecuencia**, una octava por encima; su intensidad aumenta al mover el puntero hacia la derecha.
- Un tercer oscilador senoidal de armonía, cuya relación de frecuencia e intensidad dependen del fractal.
- Un nodo de ganancia y un filtro de paso bajo; los cambios de frecuencia y volumen se suavizan con `setTargetAtTime`.

La altura del puntero selecciona una de diez notas generadas desde 196 Hz con los intervalos `[0, 2, 4, 7, 9, 12, 14, 16, 19, 21]` semitonos, correspondientes a una pentatónica mayor extendida. Cada fractal tiene un perfil con transposición y armonía propios. La posición horizontal controla la intensidad del armónico superior, dando más o menos brillo al sonido.

Estos perfiles son decisiones musicales: el sonido **no** se calcula a partir de la ecuación ni de la órbita del fractal. La aplicación no usa un oscilador triangular ni garantiza que todas las combinaciones resulten agradables para todo el mundo.

### Colores, precisión y rendimiento

En los fractales de tiempo de escape, el color indica cuándo la secuencia supera el umbral; el shader suaviza el valor de escape y aplica una paleta basada en cosenos. Un punto oscuro no ha escapado en los pasos calculados, pero eso no demuestra que pertenezca al conjunto infinito. El copo de Koch, en cambio, tiene un interior coloreado.

El número de iteraciones aumenta al acercar el zoom, hasta un máximo de 900. Las figuras construidas también utilizan un número finito de pasos, por lo que algunas posiciones producen variaciones o etapas intermedias de la figura clásica. La precisión de la GPU y el límite de cálculo restringen el detalle visible.

Para equilibrar detalle y rendimiento, la resolución de WebGL limita la relación de píxeles del dispositivo a `1.5` y la capa 2D a `2`. En pantallas de alta densidad la imagen puede verse más suave que a resolución nativa; el rendimiento depende del navegador y del hardware.

## Configuración y estructura

- **Implementación:** todo el HTML, CSS, JavaScript y GLSL está en [fractalapp.html](./fractalapp.html), sin bibliotecas ni recursos externos.
- **Selección inicial por URL:** añade un identificador reconocido, por ejemplo `fractalapp.html#tricorn`. Los identificadores son `julia`, `mandelbrot`, `ship`, `tricorn`, `multibrot`, `julia3`, `sierpinski`, `koch`, `dragon` y `tree`. Si no es válido, se abre Julia. Cambiar el menú no modifica la URL.
- **Idiomas:** los textos en español e inglés están en el objeto `TEXT` del archivo HTML.
- **Privacidad:** no hay solicitudes de red configuradas, cuentas ni almacenamiento persistente; la aplicación funciona localmente en el navegador.
- **Pruebas:** actualmente no hay una suite de pruebas automatizadas.

## Solución de problemas

- **No se oye nada:** mantén pulsada la imagen, comprueba el botón de sonido y el volumen del sistema, y permite audio en el navegador. Mover el puntero sin pulsar no reproduce sonido.
- **No aparece un fractal de tiempo de escape:** comprueba el aviso de WebGL, la configuración gráfica del navegador y la consola de desarrollo. No hay una alternativa de cálculo por CPU para estos fractales.
- **No aparecen las coordenadas:** mueve el puntero sobre la imagen; los valores se borran cuando sale.
- **No aparece el interruptor de órbita:** solo está disponible para Mandelbrot, Burning Ship y Tricorn.
- **La vista resulta extraña:** pulsa `0`, usa el botón de inicio o haz doble clic en la imagen para restablecer la cámara.
- **La imagen va lenta o se ve pixelada:** reduce el tamaño de la ventana o aleja el zoom. El rendimiento y la precisión dependen del navegador y del hardware.
