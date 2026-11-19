# ModLingo
### Conversor de localização para Victoria 3

Bem-vindo!

Esta ferramenta foi criada para ajudar jogadores de Victoria 3 que utilizam o jogo em português brasileiro, mas possuem mods que disponibilizam seus arquivos de localização apenas em inglês.

Com ela, você pode preparar automaticamente esses mods para funcionar com o idioma português brasileiro, sem precisar editar arquivos manualmente.

## Como utilizar

1. Inscreva-se na Oficina Steam.

Clique em Inscrever-se para adicionar a ferramenta à sua coleção.

2. Aguarde o download.

Espere a Steam terminar de baixar os arquivos.

3. Execute a ferramenta.

Localize a pasta deste item na Oficina Steam e abra o arquivo `INICIAR.bat` com dois cliques.

4. Aguarde o processamento.

A ferramenta irá procurar automaticamente as bibliotecas da Steam, identificar os mods instalados do Victoria 3 e preparar os arquivos de localização.

5. Pronto!

Ao terminar, será apresentado um relatório mostrando quantos mods foram analisados, quantos foram modificados e se algum problema foi encontrado.

## O que a ferramenta faz?

- Detecta automaticamente as bibliotecas da Steam.
- Localiza os mods instalados do Victoria 3.
- Identifica mods que possuem arquivos de localização em inglês.
- Cria automaticamente a pasta `braz_por`.
- Copia os arquivos de localização em inglês.
- Ajusta os nomes dos arquivos e seus cabeçalhos para português brasileiro.
- Preserva arquivos `braz_por` que já existam.

## Perguntas frequentes

A ferramenta traduz os mods?

Não. Ela não realiza traduções. Os textos continuam em inglês, mas os arquivos passam a utilizar a estrutura de localização esperada pelo jogo em português brasileiro.

Preciso configurar o caminho da Steam?

Não. A ferramenta procura automaticamente as bibliotecas Steam disponíveis no computador.

Preciso executar toda vez que instalar um novo mod?

Sim. Recomenda-se executar novamente depois de instalar novos mods ou atualizar os existentes.

A ferramenta apaga ou modifica os arquivos originais?

Não. Os arquivos originais em inglês são preservados. Arquivos brasileiros que já existam também não são sobrescritos.

A ferramenta funciona com qualquer mod?

Funciona com mods que possuam arquivos `.yml` dentro da pasta `localization/english`. Mods com estruturas diferentes podem não ser compatíveis.

## Requisitos

- Victoria 3 instalado pela Steam.
- Windows.
- PowerShell disponível no sistema.
- Mods instalados pela Oficina Steam.

## Aviso importante

Esta ferramenta é independente e não é uma tradução oficial do Victoria 3 nem dos mods utilizados.

O objetivo é facilitar a compatibilidade de localização para jogadores brasileiros.

Se encontrar algum problema, informe nos comentários da Oficina Steam.

---

## Criador

Desenvolvido por Bruno Rocha.

🎮 Acompanhe meus vídeos, gameplays, tutoriais e lives de jogos no YouTube:

https://youtube.com/@brunorochajoga?sub_confirmation=1

Se gostar do projeto, considere se inscrever no canal e acompanhar os próximos conteúdos!

Bom jogo!