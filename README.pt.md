# Window FX

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · **Português** · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Um plugin para o [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) que dá às janelas do niri animações próprias quando fecham e quando abrem: elas queimam, se estilhaçam, derretem, falham como um sinal com defeito ou se desligam como um tubo antigo. As bordas se acendem na sua cor de destaque.

![Window FX](assets/screenshot.png)

Passo a passo com imagens: [guia de instalação e configuração](docs/GUIDE.pt.md).

## O que faz

O niri consegue desenhar uma janela que fecha ou abre com um shader próprio. O plugin escreve um shader desses em `~/.config/niri/windowfx.kdl`, e o niri recarrega o arquivo sozinho assim que ele muda. Uma configuração nova vale a partir da próxima janela que fecha ou abre.

Há 13 tipos:

| Tipo | O que acontece |
|---|---|
| Brasas | a janela queima ao longo de uma frente irregular |
| Dissolver | um grão grosso desaparece em ordem aleatória |
| Pixelizar | os blocos crescem e depois somem aos poucos |
| Estilhaçar | a janela se parte em estilhaços que giram e caem |
| Derreter | colunas finas deslizam para baixo, cada uma na sua velocidade |
| Falha de sinal | rasgos, canais de cor separados e blocos que pulam, e depois tudo se desfaz |
| Tubo desligado | espremida até virar uma linha, depois um ponto, com um clarão |
| Chuvisco | a imagem se afoga em estática e se desfaz grão a grão |
| Varredura | um feixe desce e deixa para trás um esqueleto de linhas das bordas |
| Chuva de código | colunas de sinais descem, e atrás delas só fica código |
| Redemoinho | a janela se enrola em torno do próprio centro |
| Quadrados | os quadrados encolhem em ordem aleatória |
| Persiana | lâminas horizontais se fecham |

"Aleatório" escolhe um tipo novo para cada janela, de uma seleção que você define. Fechar e abrir têm cada um sua própria duração. Ao abrir, o tipo é reproduzido ao contrário: por padrão, uma janela nova aparece do mesmo jeito que a última desapareceu, só que no sentido inverso. Com "Padrão do niri" o plugin deixa essa animação para o niri.

"Bordas luminosas" faz as bordas, as fissuras e as juntas se acenderem na cor de destaque do DMS. Quando a cor de destaque muda, o plugin reescreve o arquivo. O Tubo desligado sempre dá um clarão branco, com ou sem essa opção.

Se você usa o plugin [Profiles](https://github.com/satoshoe-dev/dms-profiles), digite `windowFx` em Configurações → Plugins → Profiles → Plugins salvos com o perfil, e cada perfil guarda suas próprias animações.

## Requisitos

DankMaterialShell 1.6.1 ou mais recente e niri 26.04 ou mais recente. A versão do niri importa por causa da linha include abaixo: o niri conhece `optional=true` desde a 26.04.

O plugin só escreve o próprio arquivo. O niri o lê quando a sua configuração do niri o inclui, então acrescente esta linha no fim de `~/.config/niri/config.kdl`:

```kdl
include optional=true "windowfx.kdl"
```

No fim, porque um include se sobrepõe ao que vem antes dele; assim as animações do plugin prevalecem sobre as da sua configuração principal.

"As vizinhas esperam" precisa também de um niri com um patch não oficial, veja mais abaixo a seção "As vizinhas esperam". Todo o resto funciona com um niri normal.

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

Depois escolha uma animação ao fechar em Configurações → Plugins → Window FX. Até lá, o niri mantém suas próprias animações.

## Configurações

Configurações → Plugins → Window FX

| Configuração | Padrão |
|---|---|
| Animação ao fechar | Padrão do niri |
| Duração | 600 ms |
| As vizinhas esperam | desativado (só com um niri que conheça `hold-layout`) |
| Animação ao abrir | Como ao fechar, ao contrário |
| Duração ao abrir | 450 ms |
| Bordas luminosas | ativado |
| O modo aleatório escolhe entre estes | Brasas, Estilhaçar, Derreter, Falha de sinal, Tubo desligado, Chuva de código |

As duas durações vão de 150 a 3000 ms.

## IPC

```sh
dms ipc call windowFx kind shatter   # close animation: a kind, random or default
dms ipc call windowFx open mirror    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Os tipos se chamam `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` e `blinds`.

Um atalho no niri que joga os dados de novo para as próximas janelas:

```kdl
binds {
    Mod+Shift+W { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## As vizinhas esperam

Quando uma janela fecha, o niri a tira imediatamente do layout. As janelas ao lado começam na hora a se mover para o espaço livre e deslizam por cima da janela que está fechando enquanto a animação ainda roda. Com um fade curto quase não se percebe; com uma borda em chamas ou estilhaços caindo, a vizinha cobre quase tudo.

Escrevi um pequeno patch para o niri que acrescenta a opção `hold-layout` a `window-close`. Com ela, tudo o que a remoção coloca em movimento (as vizinhas que deslizam, a visualização que rola, as colunas que mudam de tamanho) só começa depois que a animação de fechamento termina. O patch não faz parte do niri, e o niri da sua distribuição não conhece a opção. Sem um niri compilado com esse patch, "As vizinhas esperam" não tem efeito.

O patch para o niri 26.04 está no branch [hold-layout-v26.04](https://github.com/satoshoe-dev/niri/tree/hold-layout-v26.04) do meu fork do niri. Ele é compilado como o próprio niri, veja o README dele.

Ao iniciar, o plugin verifica se o niri instalado conhece a opção, fazendo o `niri validate` ler um arquivo minúsculo que a usa. Se o niri a conhecer, o interruptor "As vizinhas esperam" aparece na página de configurações; se não, ele fica escondido e o plugin nunca escreve a opção, porque um niri sem o patch rejeitaria o arquivo inteiro.

## Desativar

Desativar o plugin deixa o `windowfx.kdl` como está, por isso as últimas animações continuam. Para voltar às animações do próprio niri, coloque antes as duas animações em "Padrão do niri" ou apague o arquivo. Com `optional=true`, um arquivo ausente não atrapalha o niri.

## Traduções

A página de configurações está disponível em alemão, espanhol, francês, italiano, português, russo, japonês e chinês simplificado e segue o idioma definido no DMS. Se alguma tradução soar errada, um pull request é bem-vindo.

## Observação

Escrevi este plugin com ajuda do Claude (Anthropic) e testei cada mudança no meu próprio desktop com niri.

## Licença

MIT
