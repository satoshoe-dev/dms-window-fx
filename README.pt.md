# Window FX

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · **Português** · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Um plugin para o [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) que dá às janelas do niri animações próprias quando fecham e quando abrem: ardem, estilhaçam-se, derretem, falham como um sinal estragado ou desligam-se como um tubo antigo. As bordas acendem-se na tua cor de destaque.

![Window FX](assets/screenshot.png)

Passo a passo com imagens: [guia de instalação e configuração](docs/GUIDE.pt.md).

## O que faz

O niri consegue desenhar uma janela que fecha ou abre com um shader próprio. O plugin escreve um shader desses em `~/.config/niri/windowfx.kdl`, e o niri volta a carregar o ficheiro sozinho assim que ele muda. Uma definição nova vale a partir da próxima janela que fecha ou abre.

Há 13 tipos:

| Tipo | O que acontece |
|---|---|
| Brasas | a janela arde ao longo de uma frente irregular |
| Dissolver | um grão grosso desaparece por ordem aleatória |
| Pixelizar | os blocos crescem e depois desvanecem |
| Estilhaçar | a janela parte-se em estilhaços que giram e caem |
| Derreter | colunas finas deslizam para baixo, cada uma à sua velocidade |
| Falha de sinal | rasgões, canais de cor separados e blocos que saltam, e depois desfaz-se |
| Tubo desligado | espremida até uma linha, depois até um ponto, com um clarão |
| Chuvisco | a imagem afoga-se em estática e desfaz-se grão a grão |
| Varrimento | um feixe desce e deixa para trás um esqueleto de linhas das bordas |
| Chuva de código | colunas de sinais descem, e por trás só fica código |
| Remoinho | a janela enrola-se à volta do seu centro |
| Quadrados | os quadrados encolhem por ordem aleatória |
| Persiana | fecham-se lâminas horizontais |

"Aleatório" escolhe um tipo novo para cada janela, de uma seleção que tu defines. Fechar e abrir têm cada um a sua própria duração. Ao abrir, o tipo é reproduzido ao contrário: por predefinição, uma janela nova aparece da mesma forma que a última desapareceu, só que no sentido inverso. Com "Predefinição do niri" o plugin deixa essa animação ao niri.

"Bordas luminosas" faz com que as bordas, as fissuras e as juntas se acendam na cor de destaque do DMS. Quando a cor de destaque muda, o plugin volta a escrever o ficheiro. O Tubo desligado dá sempre um clarão branco, com ou sem a definição.

Se usas o plugin [Profiles](https://github.com/satoshoe-dev/dms-profiles), escreve `windowFx` em Definições → Plugins → Profiles → Plugins salvos com o perfil, e cada perfil guarda as suas próprias animações.

## Requisitos

DankMaterialShell 1.6.1 ou mais recente e niri 26.04 ou mais recente. A versão do niri conta por causa da linha include abaixo: o niri conhece `optional=true` desde a 26.04.

O plugin só escreve o seu próprio ficheiro. O niri lê-o quando a tua configuração do niri o inclui, por isso acrescenta esta linha no fim de `~/.config/niri/config.kdl`:

```kdl
include optional=true "windowfx.kdl"
```

No fim, porque um include sobrepõe-se ao que vem antes dele; assim as animações do plugin ganham às da tua configuração principal.

"As vizinhas esperam" precisa ainda de um niri com um patch não oficial, ver mais abaixo a secção "As vizinhas esperam". Tudo o resto funciona com um niri normal.

## Instalação

Pelo registro de plugins:

```sh
dms plugins install windowFx
dms ipc call plugins enable windowFx
```

Ele também aparece no DMS em Configurações → Plugins → Navegar. Para instalar a partir do repositório:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
dms ipc call plugins enable windowFx
```

Depois escolhe uma animação ao fechar em Definições → Plugins → Window FX. Até lá, o niri mantém as suas próprias animações.

## Definições

Definições → Plugins → Window FX

| Definição | Predefinição |
|---|---|
| Animação ao fechar | Predefinição do niri |
| Duração | 600 ms |
| As vizinhas esperam | desligado (só com um niri que conheça `hold-layout`) |
| Animação ao abrir | Como ao fechar, ao contrário |
| Duração ao abrir | 450 ms |
| Bordas luminosas | ligado |
| O modo aleatório escolhe entre estes | Brasas, Estilhaçar, Derreter, Falha de sinal, Tubo desligado, Chuva de código |

As duas durações vão de 150 a 3000 ms.

## IPC

```sh
dms ipc call windowFx kind shatter   # close animation: a kind, random or default
dms ipc call windowFx open mirror    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Os tipos chamam-se `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` e `blinds`.

Um atalho no niri que lança os dados para as próximas janelas:

```kdl
binds {
    Mod+Shift+W { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## As vizinhas esperam

Quando uma janela fecha, o niri tira-a logo da disposição. As janelas ao lado começam de imediato a mover-se para o espaço livre e deslizam por cima da janela que está a fechar enquanto a animação ainda corre. Com um desvanecimento curto quase não se nota; com uma borda em chamas ou estilhaços a cair, a vizinha tapa quase tudo.

Escrevi um pequeno patch para o niri que acrescenta a opção `hold-layout` a `window-close`. Com ela, tudo o que a remoção põe em movimento (as vizinhas que deslizam, a vista que se desloca, as colunas que mudam de tamanho) só começa quando a animação de fecho terminou. O patch não faz parte do niri, e o niri da tua distribuição não conhece a opção. Sem um niri compilado com este patch, "As vizinhas esperam" não tem efeito.

O plugin verifica ao arrancar se o niri instalado conhece a opção, pondo o `niri validate` a ler um ficheiro minúsculo que a usa. Se o niri a conhecer, o interruptor "As vizinhas esperam" aparece na página de definições; se não, fica escondido e o plugin nunca escreve a opção, porque um niri sem o patch rejeitaria o ficheiro inteiro.

## Desligá-lo

Desligar o plugin deixa o `windowfx.kdl` como está, por isso as últimas animações ficam. Para voltar às animações do próprio niri, põe antes as duas animações em "Predefinição do niri", ou apaga o ficheiro. Com `optional=true`, um ficheiro em falta não incomoda o niri.

## Traduções

A página de definições está disponível em alemão, espanhol, francês, italiano, português, russo, japonês e chinês simplificado e segue a língua definida no DMS. Se uma tradução soar mal, um pull request é bem-vindo.

## Nota

Escrevi este plugin com a ajuda do Claude (Anthropic) e testei cada alteração no meu próprio ambiente de trabalho com niri.

## Licença

MIT
