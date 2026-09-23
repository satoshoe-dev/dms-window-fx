# Window FX: passo a passo

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · **Português** · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Instale o plugin

Pelo registro de plugins:

```sh
dms plugins install windowFx
```

Ou clone o repositório na pasta de plugins do DMS:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
```

## 2. Ative o plugin

Abra Configurações → Plugins. O Window FX aparece na lista. Ative-o.

![Lista de plugins com o Window FX](images/01-plugin-list.png)

Se ele não aparecer, clique em "Escanear" nessa página ou reinicie o shell com `dms restart`.

## 3. Faça o niri ler o arquivo do plugin

O plugin escreve as animações em `~/.config/niri/windowfx.kdl`. O niri só lê esse arquivo se a sua configuração o incluir. Acrescente esta linha bem no fim de `~/.config/niri/config.kdl`:

```kdl
include optional=true "windowfx.kdl"
```

Ela fica no fim porque um include se sobrepõe ao que vem antes dele. Se a sua configuração tiver um bloco `animations` próprio com `window-close` ou `window-open`, assim valem os valores do plugin. `optional=true` evita que o niri reclame enquanto o arquivo ainda não existe; isso exige o niri 26.04 ou mais recente.

O niri aplica a mudança assim que você salva o arquivo.

## 4. Escolha uma animação ao fechar

Expanda o Window FX na lista de plugins. Em "Animação ao fechar", escolha um dos 13 tipos, por exemplo Estilhaçar.

![A página de configurações com a lista de tipos](images/02-close-animation.png)

Abra um terminal e feche-o de novo. A janela se parte em estilhaços que giram e caem para fora da moldura.

![Uma janela se partindo em estilhaços](images/03-shatter.png)

"Duração" define quanto tempo leva, de 150 a 3000 ms. Com 600 ms é rápida, com 1500 ms dá para ver com calma.

## 5. Escolha como as janelas abrem

"Animação ao abrir" começa em "Como ao fechar, ao contrário": uma janela nova aparece do mesmo jeito que a última desapareceu, no sentido inverso. As brasas se juntam, os estilhaços sobem e se unem. Enquanto a animação ao fechar estiver em "Padrão do niri", isso deixa também a abertura para o niri.

Você também pode escolher outro tipo para abrir, "Aleatório", ou "Padrão do niri" se preferir manter a animação do próprio niri para janelas novas. "Duração ao abrir" funciona como a de fechar; 450 ms é o padrão, porque uma janela nova deve aparecer rápido.

## 6. Bordas luminosas

"Bordas luminosas" faz a frente do fogo, as fissuras entre os estilhaços e as juntas dos quadrados se acenderem na sua cor de destaque. Desative a opção para animações simples, sem luz.

![Fissuras acesas na cor de destaque](images/04-glow.png)

A cor segue a cor de destaque do DMS: quando ela muda, a próxima animação brilha na cor nova. O Tubo desligado sempre dá um clarão branco.

## 7. Deixe por conta do acaso (opcional)

Escolha "Aleatório" como animação ao fechar. Cada janela recebe então um tipo próprio. Abaixo das configurações aparece uma lista, "O modo aleatório escolhe entre estes:", onde você ativa ou desativa cada tipo.

![A seleção para o modo aleatório](images/05-random.png)

No início há seis tipos ativados: Brasas, Estilhaçar, Derreter, Falha de sinal, Tubo desligado e Chuva de código. Se você desativar todos, Brasas é usado.

## 8. As vizinhas esperam (niri com hold-layout)

Quando uma janela no meio de uma fileira fecha, o niri move na hora as janelas à direita dela para o espaço livre, e elas deslizam por baixo da animação enquanto ela ainda roda. Se o seu niri conhecer a opção `hold-layout`, a página de configurações mostra o interruptor "As vizinhas esperam". Com ele ativado, as vizinhas ficam onde estão até a animação de fechamento terminar, e só então avançam.

`hold-layout` não faz parte do niri; a opção vem de um patch não oficial. Por isso, com o niri da sua distribuição, o interruptor fica escondido. Todo o resto deste guia funciona sem ele.

Teste com uma janela que tenha outra à direita; quando a última janela de uma fileira fecha, nada se move.

Se o interruptor não aparecer, o seu niri não tem a opção. O plugin verifica isso ao iniciar, fazendo o `niri validate` ler um arquivo minúsculo que a usa, e nunca escreve a opção para um niri que a rejeitaria.

## 9. Salve as animações por perfil (opcional)

Com o plugin [Profiles](https://github.com/satoshoe-dev/dms-profiles), digite `windowFx` em "Plugins salvos com o perfil". Cada perfil guarda então suas próprias animações, por exemplo umas calmas para o trabalho e Falha de sinal para a noite.

## 10. Use em scripts

```sh
dms ipc call windowFx kind melt      # close animation: a kind, random or default
dms ipc call windowFx open random    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Os tipos se chamam `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` e `blinds`.

Coloque em uma tecla, no niri:

```kdl
binds {
    Mod+Shift+W hotkey-overlay-title="Window FX: random close animation" { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Solução de problemas

### As janelas continuam fechando como sempre

Falta a linha include do passo 3, ou "Animação ao fechar" está em "Padrão do niri". `ls ~/.config/niri/windowfx.kdl` mostra se o plugin já escreveu o arquivo dele.

### Minhas próprias animações do config.kdl prevalecem

A linha include está acima do seu bloco `animations`. Mova-a para o fim do arquivo.

### O niri mostra um erro de configuração que menciona `hold-layout`

O niri foi substituído por um sem a opção, e o arquivo ainda a contém. Assim que o DMS estiver rodando, o plugin verifica de novo e reescreve o arquivo sem ela; o niri o recarrega sozinho.

### "As vizinhas esperam" não aparece

O niri instalado não conhece `hold-layout`. Quando conhecer, o interruptor aparece depois da próxima inicialização do DMS.

### Aleatório mostra sempre o mesmo tipo

Na lista do passo 7 só um tipo está ativado, ou nenhum; nesse caso Brasas é usado.

### As animações continuam depois de desativar o plugin

O plugin deixa o `windowfx.kdl` onde está. Coloque as duas animações em "Padrão do niri" antes de desativá-lo, ou apague o arquivo.
