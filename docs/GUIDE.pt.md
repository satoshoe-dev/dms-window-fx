# Window FX: passo a passo

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · **Português** · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Instalar o plugin

Pelo registro de plugins:

```sh
dms plugins install windowFx
```

Ou clona o repositório para a tua pasta de plugins do DMS:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
```

## 2. Ativá-lo

Abre Configurações → Plugins. O Window FX aparece na lista. Liga-o.

![Lista de plugins com o Window FX](images/01-plugin-list.png)

Se não aparecer, clica em "Scan" nessa página ou reinicia a shell com `dms restart`.

## 3. Pôr o niri a ler o ficheiro do plugin

O plugin escreve as suas animações em `~/.config/niri/windowfx.kdl`. O niri só lê esse ficheiro se a tua configuração o incluir. Acrescenta esta linha mesmo no fim de `~/.config/niri/config.kdl`:

```kdl
include optional=true "windowfx.kdl"
```

Fica no fim porque um include sobrepõe-se ao que vem antes dele. Se a tua configuração tiver um bloco `animations` próprio com `window-close` ou `window-open`, assim ganham os valores do plugin. `optional=true` evita que o niri se queixe enquanto o ficheiro ainda não existe; precisa do niri 26.04 ou mais recente.

O niri aplica a alteração assim que guardas o ficheiro.

## 4. Escolher uma animação ao fechar

Expande o Window FX na lista de plugins. Em "Animação ao fechar" escolhe um dos 13 tipos, por exemplo Estilhaçar.

![A página de definições com a lista de tipos](images/02-close-animation.png)

Abre um terminal e fecha-o outra vez. A janela parte-se em estilhaços que giram e caem para fora da moldura.

![Uma janela a partir-se em estilhaços](images/03-shatter.png)

"Duração" define quanto tempo demora, de 150 a 3000 ms. Com 600 ms é rápida, com 1500 ms dá para a ver com calma.

## 5. Escolher como as janelas abrem

"Animação ao abrir" começa em "Como ao fechar, ao contrário": uma janela nova aparece da mesma forma que a última desapareceu, no sentido inverso. As brasas juntam-se, os estilhaços sobem e unem-se. Enquanto a animação ao fechar estiver em "Predefinição do niri", isto deixa também a abertura ao niri.

Também podes escolher outro tipo para abrir, "Aleatório", ou "Predefinição do niri" se preferires manter a animação do próprio niri para janelas novas. "Duração ao abrir" funciona como a de fechar; 450 ms é a predefinição, porque uma janela nova deve estar lá depressa.

## 6. Bordas luminosas

"Bordas luminosas" faz com que a frente do fogo, as fissuras entre os estilhaços e as juntas dos quadrados se acendam na tua cor de destaque. Desliga-a para animações simples sem luz.

![Fissuras acesas na cor de destaque](images/04-glow.png)

A cor segue a cor de destaque do DMS: quando ela muda, a próxima animação brilha na cor nova. O Tubo desligado dá sempre um clarão branco.

## 7. Deixar ao acaso (opcional)

Escolhe "Aleatório" como animação ao fechar. Cada janela recebe então um tipo seu. Por baixo das definições aparece uma lista, "O modo aleatório escolhe entre estes:", onde ligas ou desligas cada tipo.

![A seleção para o modo aleatório](images/05-random.png)

No início há seis tipos ligados: Brasas, Estilhaçar, Derreter, Falha de sinal, Tubo desligado e Chuva de código. Se os desligares todos, é usado Brasas.

## 8. As vizinhas esperam (niri com hold-layout)

Quando uma janela a meio de uma fila fecha, o niri move logo as janelas à sua direita para o espaço livre, e elas deslizam por cima da animação enquanto ela ainda corre. Se o teu niri conhecer a opção `hold-layout`, a página de definições mostra o interruptor "As vizinhas esperam". Com ele ligado, as vizinhas ficam onde estão até a animação de fecho terminar, e só então avançam.

`hold-layout` não faz parte do niri; a opção vem de um patch não oficial. Com o niri da tua distribuição o interruptor fica por isso escondido. Tudo o resto deste guia funciona sem ele.

Experimenta com uma janela que tenha outra à direita; quando fecha a última janela de uma fila, nada se move.

Se o interruptor não aparecer, o teu niri não tem a opção. O plugin verifica isso ao arrancar pondo o `niri validate` a ler um ficheiro minúsculo que a usa, e nunca escreve a opção para um niri que a rejeitaria.

## 9. Guardar as animações por perfil (opcional)

Com o plugin [Profiles](https://github.com/satoshoe-dev/dms-profiles), escreve `windowFx` em "Plugins salvos com o perfil". Cada perfil guarda então as suas próprias animações, por exemplo umas calmas para o trabalho e Falha de sinal para a noite.

## 10. Usá-lo em scripts

```sh
dms ipc call windowFx kind melt      # close animation: a kind, random or default
dms ipc call windowFx open random    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Os tipos chamam-se `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` e `blinds`.

Põe-no numa tecla, no niri:

```kdl
binds {
    Mod+Shift+W hotkey-overlay-title="Window FX: random close animation" { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Resolução de problemas

### As janelas continuam a fechar como sempre

Falta a linha include do passo 3, ou "Animação ao fechar" está em "Predefinição do niri". `ls ~/.config/niri/windowfx.kdl` mostra se o plugin já escreveu o seu ficheiro.

### Ganham as minhas próprias animações do config.kdl

A linha include está acima do teu bloco `animations`. Passa-a para o fim do ficheiro.

### O niri mostra um erro de configuração que menciona `hold-layout`

O niri foi substituído por um sem a opção, e o ficheiro ainda a tem de antes. Assim que o DMS estiver a correr, o plugin volta a verificar e escreve o ficheiro sem ela; o niri volta a carregá-lo sozinho.

### "As vizinhas esperam" não aparece

O niri instalado não conhece `hold-layout`. Quando conhecer, o interruptor aparece depois do próximo arranque do DMS.

### Aleatório mostra sempre o mesmo tipo

Na lista do passo 7 só está ligado um tipo, ou nenhum; nesse caso é usado Brasas.

### As animações ficam depois de desligar o plugin

O plugin deixa o `windowfx.kdl` onde está. Põe as duas animações em "Predefinição do niri" antes de o desligar, ou apaga o ficheiro.
