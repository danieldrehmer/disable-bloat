#!/usr/bin/env bash

# Each service below is actually an agent or daemon
# that provides certain functionalities within macOS.
# Disabling them can help conserve system resources if
# you aren't using the corresponding features.
#
# -----------------------------------------------------------------------------
# Fork anotado (pt-BR): cada service abaixo recebeu um comentario com:
#   funcao:  para que o service serve.
#   impacto: o que pode parar de funcionar / impacto na estabilidade ao remover.
#   risco:   avaliacao rapida do risco de remocao -> baixo | medio | alto.
#
# Como ler o "risco":
#   baixo  -> telemetria, analytics, anuncios, diagnosticos ou recurso opcional
#             pouco usado; remover raramente causa problema perceptivel.
#   medio  -> quebra um recurso real (iCloud sync, Continuidade, Siri, Mapas,
#             Time Machine parcial...) que parte dos usuarios usa, mas sem
#             desestabilizar o sistema operacional.
#   alto   -> componente central do SO ou de seguranca (logs, sandbox, trust de
#             certificados, watchdog, XProtect, Buscar Mac, backups, Contatos/
#             Calendario, push) -> remover pode desestabilizar o sistema, abrir
#             brecha de seguranca ou causar perda de dados. Evite sem necessidade.
#
# As descricoes vieram de pesquisa web (man pages do macOS, eclecticlight.co,
# Apple Community, macosbin.com, theapplewiki.com, iboysoft.com, howtogeek.com,
# o gist de debloat do Sequoia de b0gdanw, entre outros). Itens marcados
# "(incerto)" tem documentacao publica escassa e a avaliacao e o melhor esforco.
# Repo original: https://github.com/jacksongoode/disable-bloat
# -----------------------------------------------------------------------------
services=(
	# funcao:  Exibe os prompts de autorizacao de Servicos de Localizacao para apps, daemons e widgets; e iniciado pelo locationd.
	# impacto: Apps nao conseguem solicitar permissao de localizacao; recursos baseados em localizacao ficam inacessiveis.  |  risco: medio
	# 'com.apple.CoreLocationAgent'
	# funcao:  Variante macOS do daemon que faz proxy transparente de servicos do sistema Apple, base do iCloud Private Relay.
	# impacto: iCloud Private Relay e o proxy "oblivious" de privacidade da Apple deixam de funcionar.  |  risco: baixo
	# 'com.apple.networkserviceproxy-osx'
	# funcao:  Baixa a configuracao do NetworkServiceProxy e a distribui aos clientes, servindo de base ao iCloud Private Relay.
	# impacto: iCloud Private Relay para de funcionar e apps que dependem do proxy de privacidade perdem essa protecao.  |  risco: baixo
	# 'com.apple.networkserviceproxy'
	# funcao:  Agente por usuario do Compartilhamento de Tela que gerencia a sessao VNC/ARD e interacoes especificas do usuario.
	# impacto: O Compartilhamento de Tela e o Apple Remote Desktop deixam de funcionar para o usuario logado.  |  risco: medio
	# 'com.apple.screensharing.agent'
	# funcao:  Exibe e gerencia o icone de status de Compartilhamento de Tela na barra de menus.
	# impacto: Some o indicador da barra de menus de que uma sessao de compartilhamento de tela esta ativa.  |  risco: baixo
	# 'com.apple.screensharing.menuextra'
	# funcao:  Trata pedidos de compartilhamento de tela iniciados pelo app Mensagens, incluindo controle remoto e area de transferencia.
	# impacto: Nao e possivel iniciar nem aceitar compartilhamento de tela via app Mensagens.  |  risco: baixo
	# 'com.apple.screensharing.MessagesAgent'
	# funcao:  LaunchDaemon de nivel de sistema que executa o servidor de Compartilhamento de Tela e aguarda conexoes VNC/ARD recebidas.
	# impacto: O Mac nao aceita mais conexoes de Compartilhamento de Tela nem de Apple Remote Desktop.  |  risco: medio
	# 'com.apple.screensharing'
	# funcao:  Daemon que controla a reproducao de midia em todo o sistema (play/pause/pular) e expoe informacoes de "Tocando Agora".
	# impacto: Teclas de midia, controles de Tocando Agora e controle remoto de reproducao por outros dispositivos param de funcionar.  |  risco: medio
	# 'com.apple.mediaremoted'
	# funcao:  Gerencia assets de acessibilidade, incluindo vozes de sintese de fala e extensoes de audio (AXAssetLoader).
	# impacto: Download e carregamento de vozes de fala e recursos de acessibilidade de audio podem falhar.  |  risco: medio
	'com.apple.accessibility.axassetsd'
	# funcao:  Daemon de acessibilidade ligado ao Reconhecimento de Som e aos Sons de Fundo (audio ambiente).
	# impacto: Reconhecimento de Som e Sons de Fundo de acessibilidade deixam de funcionar.  |  risco: baixo
	'com.apple.accessibility.heard'
	# funcao:  Captura o movimento da cabeca pela camera para mover o cursor (Ponteiro de Cabeca / rastreamento de movimento).
	# impacto: O recurso de acessibilidade de Ponteiro de Cabeca / rastreamento de movimento para de funcionar.  |  risco: baixo
	'com.apple.accessibility.MotionTrackingAgent'
	# funcao:  Daemon do framework AddressBook que gerencia o banco de dados de contatos do app Contatos.
	# impacto: App Contatos e qualquer app que leia contatos podem falhar ou ficar sem acesso aos dados.  |  risco: alto
	'com.apple.AddressBook.abd'
	# funcao:  Servico XPC que gerencia as contas de contatos e a integracao com servicos de contas (iCloud, Exchange, etc.).
	# impacto: Contas de contatos param de ser gerenciadas; sincronizacao de contatos com contas externas falha.  |  risco: medio
	'com.apple.AddressBook.ContactsAccountsService'
	# funcao:  Sincroniza os contatos com servidores iCloud, CardDAV e Exchange.
	# impacto: Contatos deixam de sincronizar com iCloud e outras contas externas.  |  risco: medio
	'com.apple.AddressBook.SourceSync'
	# funcao:  Gerencia a interface do AirPlay, descobre receptores compativeis e trata as interacoes do usuario com o AirPlay.
	# impacto: Espelhamento e streaming via AirPlay e seus controles na Central de Controle deixam de funcionar.  |  risco: medio
	'com.apple.AirPlayUIAgent'
	# funcao:  Daemon por usuario que baixa e armazena em cache as capas de album e artes da biblioteca de midia do app Musica.
	# impacto: Capas de album e artes podem nao aparecer ou nao ser baixadas no app Musica.  |  risco: baixo
	'com.apple.AMPArtworkAgent'
	# funcao:  Detecta dispositivos iOS/iPadOS conectados (via USB ou Wi-Fi) para sincronizacao e backup pelo Finder.
	# impacto: Finder pode nao detectar iPhone/iPad para sincronizar ou fazer backup.  |  risco: medio
	'com.apple.AMPDeviceDiscoveryAgent'
	# funcao:  Agente por usuario que gerencia a biblioteca de midia e metadados dos apps Musica e TV, incluindo sync com iCloud.
	# impacto: Biblioteca dos apps Musica e TV pode nao atualizar, indexar ou sincronizar com iCloud.  |  risco: medio
	'com.apple.AMPLibraryAgent'
	# funcao:  Daemon do Apple Media Services que trata recomendacoes, engajamento e conteudo de marketing de assinaturas Apple.
	# impacto: Perde-se apenas notificacoes de engajamento e recomendacoes de midia/assinaturas Apple.  |  risco: baixo
	'com.apple.amsengagementd'
	# funcao:  Coleta dados de diagnostico e uso do sistema e os envia a Apple (mediante consentimento do usuario).
	# impacto: Nenhum impacto funcional; apenas cessa o envio de telemetria de diagnostico a Apple.  |  risco: baixo
	'com.apple.analyticsd'
	# funcao:  Servico legado dos Apple Online Services (MobileMe/iCloud) que mantem sinal de presenca das conexoes com servicos Apple. (incerto)
	# impacto: Pouco ou nenhum impacto em sistemas modernos; recursos legados de conectividade iCloud podem degradar.  |  risco: baixo
	'com.apple.AOSHeartbeat'
	# funcao:  Servico legado dos Apple Online Services que retransmite mensagens push, associado ao antigo "Back to My Mac". (incerto)
	# impacto: Pouco impacto em sistemas modernos; recursos legados de relay / Back to My Mac podem deixar de funcionar.  |  risco: baixo
	'com.apple.AOSPushRelay'
	# funcao:  Daemon que gerencia a privacidade de publicidade do usuario e a opcao de limitar rastreamento de anuncios.
	# impacto: Nenhum impacto funcional relevante; some apenas a gestao de preferencias de privacidade de anuncios.  |  risco: baixo
	'com.apple.ap.adprivacyd'
	# funcao:  Daemon dos servicos de publicidade da Apple, responsavel pela atribuicao do Apple Search Ads.
	# impacto: Atribuicao de anuncios do Apple Search Ads deixa de funcionar; nenhum impacto para o usuario comum.  |  risco: baixo
	'com.apple.ap.adservicesd'
	# funcao:  Daemon que busca anuncios e conteudo promocional da Apple (ex.: anuncios na App Store).
	# impacto: Anuncios e conteudo promovido da Apple deixam de ser exibidos; sem impacto de estabilidade.  |  risco: baixo
	'com.apple.ap.promotedcontentd'
	# funcao:  Coleta estatisticas e dados de saude de SSDs (especialmente de SSDs nao-Apple) no Mac.
	# impacto: Monitoramento interno de saude/estatisticas do SSD deixa de ser coletado.  |  risco: baixo
	'com.apple.applessdstatistics'
	# funcao:  Agente de suporte da App Store que busca atualizacoes de apps e mantem o indice de apps instalados.
	# impacto: App Store pode nao buscar atualizacoes nem instalar apps corretamente.  |  risco: medio
	'com.apple.appstoreagent'
	# funcao:  Daemon do Apple Push Notification Service que entrega notificacoes push para Mail, FaceTime, Mensagens, iCloud, etc.
	# impacto: Notificacoes push param; login no iCloud, App Store e iTunes pode falhar, com efeitos imprevisiveis.  |  risco: alto
	'com.apple.apsd'
	# funcao:  Gerencia a rotacao, arquivamento e expiracao dos arquivos de log do Apple System Log (ASL) gravados pelo syslogd.
	# impacto: Logs do sistema deixam de ser rotacionados e podem crescer sem controle consumindo o disco.  |  risco: alto
	'com.apple.aslmanager'
	# funcao:  Localiza servidores de Content Cache do macOS na rede local para baixar atualizacoes e conteudo Apple localmente.
	# impacto: O Mac nao usa mais caches de conteudo locais e baixa atualizacoes diretamente da internet.  |  risco: baixo
	'com.apple.AssetCacheLocatorService'
	# funcao:  Servico do framework CoreServices que da suporte ao Siri e a recursos de assistencia do sistema.
	# impacto: Siri e funcoes de assistencia relacionadas podem deixar de funcionar.  |  risco: medio
	'com.apple.assistant_service'
	# funcao:  Daemon do Siri que processa requisicoes do Siri e do ditado, integrando-se tambem ao Spotlight.
	# impacto: Siri e ditado deixam de funcionar; buscas do Spotlight por contatos/eventos podem degradar.  |  risco: medio
	'com.apple.assistantd'
	# funcao:  Agente que agrega e analisa dados de uso de audio do sistema para usuarios que optaram por enviar relatorios a Apple.
	# impacto: Apenas a coleta/envio de telemetria de uso de audio a Apple e interrompida; sem impacto funcional.  |  risco: baixo
	'com.apple.audioanalyticsd '
	# funcao:  Daemon de audio/video que suporta FaceTime, Continuity Camera e handoff de chamadas entre dispositivos Apple.
	# impacto: FaceTime, uso do iPhone como webcam e transferencia de chamadas entre dispositivos param de funcionar.  |  risco: medio
	'com.apple.avconferenced'
	# funcao:  Daemon "Apple Wide Area Connectivity Service" que ajuda a estabelecer conexoes para o recurso Back to My Mac.
	# impacto: Back to My Mac (recurso ja descontinuado pela Apple) deixa de conectar; sistemas modernos quase nao usam.  |  risco: baixo
	'com.apple.awacsd'
	# funcao:  Daemon "Apple Wireless Diagnostics" que coleta logs e telemetria de Wi-Fi, Bluetooth, NFC e outros radios para a Apple.
	# impacto: Apenas a coleta de diagnosticos/analytics de wireless para a Apple e perdida; sem impacto funcional para o usuario.  |  risco: baixo
	'com.apple.awdd'
	# funcao:  Auxiliar do Time Machine que agenda e dispara os backups horarios, conectando o disco de destino quando necessario.
	# impacto: Backups automaticos do Time Machine deixam de ser iniciados no horario (backups manuais ainda funcionam).  |  risco: medio
	'com.apple.backupd-helper'
	# funcao:  Daemon principal do Time Machine que inventaria arquivos, detecta mudancas e grava os backups no disco de destino.
	# impacto: O Time Machine para completamente: nenhum backup automatico ou manual e criado.  |  risco: alto
	'com.apple.backupd'
	# funcao:  Agente do subsistema Biome que processa eventos de apps em tempo real para alimentar sugestoes contextuais do sistema.
	# impacto: Sugestoes proativas de Siri/QuickType e recursos contextuais degradam; pode gerar erros em apps que dependem do Biome.  |  risco: medio
	'com.apple.BiomeAgent'
	# funcao:  Daemon do Biome que executa o grafo de operacoes e aceita assinaturas para processamento de eventos em tempo real.
	# impacto: Coleta de eventos contextuais do Biome para de funcionar, degradando sugestoes proativas e personalizacao.  |  risco: medio
	'com.apple.biomed'
	# funcao:  Daemon do Biome responsavel por sincronizar os eventos contextuais do Biome entre os dispositivos Apple.
	# impacto: Sincronizacao dos dados de contexto/sugestoes entre dispositivos para; sugestoes ficam inconsistentes entre aparelhos.  |  risco: baixo
	'com.apple.biomesyncd'
	# funcao:  Daemon que sincroniza arquivos e documentos entre o Mac e o iCloud Drive (Documents in the Cloud).
	# impacto: O iCloud Drive para de sincronizar arquivos; documentos nao sao enviados nem baixados da nuvem.  |  risco: alto
	'com.apple.bird'
	# funcao:  Daemon do EventKit que coordena o acesso de apps aos dados de calendario e dispara notificacoes de calendario.
	# impacto: Apps de terceiros e do sistema perdem acesso aos dados de Calendario; notificacoes de eventos podem falhar.  |  risco: alto
	'com.apple.calaccessd'
	# funcao:  Agente de backend do app Calendario que coordena acesso aos dados e faz a sincronizacao de calendarios em segundo plano.
	# impacto: Calendarios (iCloud, Google, Exchange) param de sincronizar e o app Calendario fica sem atualizacao de eventos.  |  risco: alto
	'com.apple.CalendarAgent'
	# funcao:  Auxiliar do framework CallHistory que gerencia o historico de chamadas, associado ao FaceTime.
	# impacto: O registro/gerenciamento do historico de chamadas no FaceTime deixa de funcionar corretamente.  |  risco: medio
	'com.apple.CallHistoryPluginHelper'
	# funcao:  Auxiliar que sincroniza (de forma criptografada) o historico de chamadas entre o Mac e outros dispositivos Apple via iCloud.
	# impacto: O historico de chamadas para de sincronizar entre dispositivos; chamadas locais nao sao afetadas.  |  risco: baixo
	'com.apple.CallHistorySyncHelper'
	# funcao:  Daemon do CloudKit que sincroniza dados de apps do sistema e de terceiros com o iCloud.
	# impacto: Apps que usam CloudKit param de sincronizar com o iCloud, incluindo Desktop/Documentos na nuvem.  |  risco: alto
	'com.apple.cloudd'
	# funcao:  Daemon do framework CloudFamilyRestrictions que aplica restricoes e controles parentais do Compartilhamento Familiar via iCloud.
	# impacto: Restricoes/controles parentais do Compartilhamento Familiar deixam de ser sincronizados e aplicados.  |  risco: medio
	'com.apple.cloudfamilyrestrictionsd-mac'
	# funcao:  Daemon nao documentado pela Apple, relacionado ao pareamento de dispositivos via iCloud. (incerto)
	# impacto: O pareamento/handoff de dispositivos via iCloud pode falhar, afetando recursos de Continuidade.  |  risco: medio
	'com.apple.cloudpaird'
	# funcao:  Agente que cuida da sincronizacao da Biblioteca de Fotos do iCloud e atividades relacionadas a fotos na nuvem.
	# impacto: As Fotos do iCloud param de sincronizar entre o Mac e os servidores da Apple.  |  risco: medio
	'com.apple.cloudphotod'
	# funcao:  Componente de configuracao dos servicos de Fotos do iCloud (framework CloudPhotoServices).
	# impacto: A configuracao/ativacao das Fotos do iCloud pode falhar, impedindo o funcionamento correto da sincronizacao de fotos.  |  risco: medio
	'com.apple.CloudPhotosConfiguration'
	# funcao:  Agente de sincronizacao do iCloud responsavel por Biblioteca de Fotos, Meu Compartilhamento de Fotos e albuns compartilhados.
	# impacto: Toda a sincronizacao de Fotos do iCloud (biblioteca e albuns compartilhados) para de funcionar.  |  risco: medio
	'com.apple.cloudphotosd'
	# funcao:  Agente que sincroniza preferencias e ajustes do sistema entre dispositivos atraves do iCloud.
	# impacto: Ajustes e preferencias do sistema deixam de ser sincronizados entre os dispositivos Apple.  |  risco: baixo
	'com.apple.CloudSettingsSyncAgent'
	# funcao:  Agente do CoreTelephony que coordena telefonia e mensagens, habilitando chamadas e SMS via iPhone pareado (Continuidade).
	# impacto: Fazer/receber chamadas e SMS no Mac via iPhone para de funcionar; recursos de Continuidade de telefonia quebram.  |  risco: medio
	'com.apple.CommCenter-osx'
	# funcao:  Agente de backend do app Contatos que coordena o acesso e a sincronizacao das contas de contatos em segundo plano.
	# impacto: Contatos (iCloud, Google, Exchange) param de sincronizar e apps perdem dados de contatos atualizados.  |  risco: alto
	'com.apple.ContactsAgent'
	# funcao:  Agente do framework privado CoreDuetContext que armazena e gerencia dados de contexto de uso do sistema.
	# impacto: Recursos que dependem de contexto (sugestoes, previsao de apps, Handoff) degradam; pode gerar erros no sistema.  |  risco: medio
	'com.apple.ContextStoreAgent'
	# funcao:  Daemon do framework privado CoreDuetContext que armazena os dados de contexto coletados pelo CoreDuet.
	# impacto: O armazenamento de contexto do CoreDuet para, degradando sugestoes proativas, previsoes e Handoff.  |  risco: medio
	'com.apple.contextstored'
	# funcao:  Daemon do CoreDuet que coleta dados de comportamento e contexto para acelerar Handoff e sugestoes entre dispositivos Apple.
	# impacto: Handoff fica mais lento/instavel e sugestoes proativas baseadas em uso degradam; pode afetar Spotlight/Central de Notificacoes.  |  risco: medio
	'com.apple.coreduetd'
	# funcao:  Gerencia a autenticacao de contas Apple ID no sistema, validando credenciais e tokens para servicos da Apple.
	# impacto: Login no iCloud, App Store e demais servicos vinculados ao Apple ID para de funcionar ou falha repetidamente.  |  risco: alto
	'com.apple.coreservices.appleid.authentication'
	# funcao:  Sustenta o Handoff e a Area de Transferencia Universal, sincronizando atividades de usuario entre dispositivos Apple.
	# impacto: Handoff e o copiar/colar entre Mac e iPhone/iPad deixam de funcionar.  |  risco: medio
	'com.apple.coreservices.useractivityd'
	# funcao:  Daemon do framework CoreSpeech que processa reconhecimento de voz, ditado e captura de audio para Siri.
	# impacto: Siri, ditado e recursos de voz param de funcionar; alguns recursos de acessibilidade sao afetados.  |  risco: medio
	'com.apple.corespeechd'
	# funcao:  Auxilia a infraestrutura de relatorio de falhas do macOS, dando suporte ao ReportCrash e ao Problem Reporter.
	# impacto: Diagnostico e envio de relatorios de falha de apps ficam prejudicados; nenhum impacto em estabilidade.  |  risco: baixo
	'com.apple.CrashReporterSupportHelper'
	# funcao:  Sincroniza contatos, calendarios, notas e lembretes de contas CalDAV, Exchange, LDAP e similares.
	# impacto: Contas Exchange/CalDAV param de sincronizar calendario, contatos e notas.  |  risco: medio
	'com.apple.dataaccess.dataaccessd'
	# funcao:  Fornece dados de log ao vivo do sistema unificado de logs para o Console.app e o comando log stream.
	# impacto: Visualizacao de logs em tempo real no Console e via log stream deixa de funcionar.  |  risco: baixo
	'com.apple.diagnosticd'
	# funcao:  Daemon de coleta de diagnosticos que reune arquivos para as ferramentas de feedback e relatorio da Apple.
	# impacto: Coleta de dados de diagnostico para o Feedback Assistant e ferramentas Apple fica indisponivel.  |  risco: baixo
	'com.apple.diagnosticextensionsd'
	# funcao:  Tarefa periodica que remove relatorios de diagnostico e falhas antigos para liberar espaco em disco. (incerto)
	# impacto: Relatorios de diagnostico antigos se acumulam ocupando espaco em disco; sem impacto funcional.  |  risco: baixo
	'com.apple.DiagnosticReportCleanup'
	# funcao:  Agente que coleta periodicamente dados de diagnostico e uso e os registra para envio opcional a Apple.
	# impacto: Coleta e envio de telemetria de diagnostico e uso a Apple deixam de ocorrer.  |  risco: baixo
	'com.apple.diagnostics_agent'
	# funcao:  Daemon que implementa a privacidade diferencial, privatizando dados antes de qualquer envio a Apple.
	# impacto: Coleta de dados com privacidade diferencial para de funcionar; sem impacto em estabilidade.  |  risco: baixo
	'com.apple.dprivacyd'
	# funcao:  Captura e salva dados de diagnostico apos um reinicio ou travamento da GPU. (incerto)
	# impacto: Logs de diagnostico de falhas da GPU deixam de ser coletados; sem impacto funcional.  |  risco: baixo
	'com.apple.DumpGPURestart'
	# funcao:  Coleta dados de kernel panic da NVRAM apos a inicializacao e os salva para diagnostico.
	# impacto: Relatorios de kernel panic nao sao salvos nem enviados, dificultando diagnostico de travamentos.  |  risco: baixo
	'com.apple.DumpPanic'
	# funcao:  Daemon ligado a infraestrutura de iCloud Family/compartilhamento, coordenando tarefas em segundo plano entre componentes. (incerto)
	# impacto: Possivel degradacao de recursos de compartilhamento familiar; impacto exato indeterminado.  |  risco: medio
	'com.apple.ensemble'
	# funcao:  Gerencia a configuracao e recuperacao do codigo de seguranca do Chaveiro do iCloud junto aos servidores da Apple.
	# impacto: Configuracao e recuperacao do Chaveiro do iCloud podem falhar.  |  risco: medio
	'com.apple.EscrowSecurityAlert'
	# funcao:  Daemon do framework FamilyCircle que executa tarefas em segundo plano do iCloud Family Sharing.
	# impacto: Recursos de Compartilhamento Familiar podem parar de funcionar ou sincronizar.  |  risco: medio
	'com.apple.familycircled'
	# funcao:  Agente por usuario do framework Family Controls que aplica controles parentais e limites do Tempo de Uso na sessao.
	# impacto: Controles parentais e limites de Tempo de Uso deixam de ser aplicados na conta do usuario.  |  risco: medio
	'com.apple.familycontrols.useragent'
	# funcao:  Daemon do sistema de controles parentais que aplica limites de tempo e filtros de conteudo do Tempo de Uso.
	# impacto: Controles parentais e restricoes do Tempo de Uso param de ser aplicados em todo o sistema.  |  risco: medio
	'com.apple.familycontrols'
	# funcao:  Daemon que gerencia e entrega notificacoes relacionadas ao Compartilhamento Familiar.
	# impacto: Notificacoes de Compartilhamento Familiar (pedidos, aprovacoes) deixam de aparecer.  |  risco: baixo
	'com.apple.familynotificationd'
	# funcao:  Daemon do framework privado FinanceKit que da acesso a saldos e transacoes do Apple Card, Apple Cash e Savings.
	# impacto: Apps que usam FinanceKit nao conseguem buscar dados financeiros do Apple Wallet.  |  risco: baixo
	'com.apple.financed'
	# funcao:  Daemon que habilita o recurso Buscar Mac, permitindo localizar, bloquear ou apagar o equipamento remotamente.
	# impacto: Buscar Mac (localizacao, bloqueio e apagamento remotos) deixa de funcionar.  |  risco: alto
	'com.apple.findmymac '
	# funcao:  Componente de mensageria do Buscar Mac que troca mensagens/comandos de localizacao com os servidores da Apple.
	# impacto: Comunicacao de comandos do Buscar Mac com a Apple falha, comprometendo localizacao e bloqueio remoto.  |  risco: alto
	'com.apple.findmymacmessenger'
	# funcao:  Daemon do framework CoreFollowUp que gera lembretes e alertas de acompanhamento do sistema (ex.: verificar Apple ID).
	# impacto: Alertas de acompanhamento como "Verifique seu Apple ID" e avisos de configuracao deixam de aparecer.  |  risco: baixo
	'com.apple.followupd'
	# funcao:  App de interface do framework CoreFollowUp que exibe os dialogos de acompanhamento gerados pelo followupd.
	# impacto: Dialogos de acompanhamento (verificacao de Apple ID, conclusao de configuracao) nao sao exibidos.  |  risco: baixo
	'com.apple.FollowUpUI'
	# funcao:  Proxy de FTP que opera junto ao firewall pf, redirecionando conexoes de controle FTP; nao roda por padrao.
	# impacto: Cenarios de NAT/firewall com FTP que dependem do ftp-proxy param de funcionar; uso domestico nao e afetado.  |  risco: baixo
	'com.apple.ftp-proxy'
	# funcao:  Servidor FTP embutido do macOS, desativado por padrao e removido a partir do High Sierra.
	# impacto: Nenhum em sistemas modernos; em versoes antigas, hospedar um servidor FTP deixa de ser possivel.  |  risco: baixo
	'com.apple.ftpd'
	# funcao:  Arbitra o acesso a controles de jogo (Xbox, DualSense, Siri Remote etc.) entre apps que usam o framework GameController.
	# impacto: Controles de jogo fisicos param de funcionar ou ficam inacessiveis para apps e jogos.  |  risco: baixo
	'com.apple.GameController.gamecontrollerd'
	# funcao:  Daemon do Game Center que gerencia login, amigos, conquistas e recursos sociais de jogos.
	# impacto: Game Center e funcoes sociais de jogos (conquistas, ranking, multiplayer) deixam de funcionar.  |  risco: baixo
	'com.apple.gamed'
	# funcao:  Daemon do GeoServices que processa dados de mapas, geocodificacao e roteamento para o app Mapas e afins.
	# impacto: App Mapas, geolocalizacao de fotos e buscas por endereco param de funcionar corretamente.  |  risco: medio
	'com.apple.geod'
	# funcao:  Ponte de servico Mach que expoe as funcionalidades do geod (GeoServices) a outros processos do sistema.
	# impacto: Apps que dependem de mapas e geocodificacao perdem acesso aos servicos do geod.  |  risco: medio
	'com.apple.geodMachServiceBridge'
	# funcao:  Daemon que gerencia e indexa a documentacao de ajuda exibida pelo Help Viewer e pelo menu Ajuda.
	# impacto: O Visualizador de Ajuda e os menus de Ajuda dos apps ficam vazios ou param de abrir.  |  risco: baixo
	'com.apple.helpd'
	# funcao:  Daemon que gerencia o estado da casa e controla acessorios HomeKit, cenas e automacoes.
	# impacto: O app Casa e todo o controle de acessorios HomeKit (incl. automacoes e Siri) param de funcionar.  |  risco: medio
	'com.apple.homed'
	# funcao:  Daemon (introduzido no macOS 14) que gerencia dados de energia residencial e sua integracao com o app Casa.
	# impacto: Recursos de monitoramento de energia residencial do HomeKit deixam de funcionar.  |  risco: baixo
	'com.apple.homeenergyd'
	# funcao:  Job do findmydeviced que mantem a conexao de push (APNs) com o ambiente de demonstracao para o Find My. (incerto)
	# impacto: Praticamente nenhum impacto para usuarios comuns, pois o ambiente demo nao e usado em producao.  |  risco: baixo
	'com.apple.icloud.findmydeviced.aps-demo'
	# funcao:  Job do findmydeviced que mantem a conexao de push (APNs) com o ambiente de desenvolvimento/sandbox do Find My. (incerto)
	# impacto: Praticamente nenhum impacto para usuarios comuns, pois o ambiente de desenvolvimento nao e usado em producao.  |  risco: baixo
	'com.apple.icloud.findmydeviced.aps-development'
	# funcao:  Job do findmydeviced que mantem a conexao de push (APNs) de producao usada para comandos do Buscar (localizar, apagar, bloquear).
	# impacto: O Mac deixa de receber comandos remotos do Buscar (Find My Mac), como localizacao, bloqueio e apagamento.  |  risco: alto
	'com.apple.icloud.findmydeviced.aps-production'
	# funcao:  Agente por usuario do findmydeviced que liga a sessao do usuario logado ao daemon de Buscar Dispositivo.
	# impacto: O recurso Buscar Mac para de funcionar para o usuario, sem receber/refletir comandos remotos.  |  risco: alto
	'com.apple.icloud.findmydeviced.findmydevice-user-agent'
	# funcao:  Servicos auxiliares por usuario do findmydeviced que expoem funcoes de Buscar Dispositivo a sessao do usuario. (incerto)
	# impacto: Funcoes de Buscar Mac dependentes da sessao do usuario deixam de operar corretamente.  |  risco: alto
	'com.apple.icloud.findmydeviced.ua-services'
	# funcao:  Daemon principal do Buscar Mac (Find My Mac), responsavel por localizacao remota, bloqueio e apagamento do dispositivo.
	# impacto: Buscar Mac e desativado; o Mac nao pode ser localizado, bloqueado ou apagado remotamente se perdido/roubado.  |  risco: alto
	'com.apple.icloud.findmydeviced'
	# funcao:  Daemon do Buscar Amigos (Find My Friends) que gerencia o compartilhamento e a consulta de localizacao de pessoas.
	# impacto: Compartilhamento de localizacao com amigos e familiares no app Buscar para de funcionar.  |  risco: medio
	'com.apple.icloud.fmfd'
	# funcao:  Componente do searchpartyd que descobre e gerencia o pareamento de acessorios da rede Buscar (ex.: AirTags). (incerto)
	# impacto: O Mac deixa de descobrir e configurar acessorios Buscar como AirTags.  |  risco: medio
	'com.apple.icloud.searchpartyd.accessorydiscoverymanager'
	# funcao:  Componente do searchpartyd que mantem o cache de anuncios BLE da rede Buscar usados na localizacao offline. (incerto)
	# impacto: A localizacao offline via rede Buscar fica menos eficiente ou para de reportar corretamente.  |  risco: medio
	'com.apple.icloud.searchpartyd.advertisementcache'
	# funcao:  Endpoint interno do gerenciador de beacons do searchpartyd para comunicacao entre agente e daemon. (incerto)
	# impacto: O rastreamento de beacons/AirTags pela rede Buscar pode falhar de forma imprevisivel.  |  risco: medio
	'com.apple.icloud.searchpartyd.beaconmanager.agentdaemoninternal'
	# funcao:  Componente do searchpartyd que gerencia os beacons BLE (AirTags e acessorios) da rede Buscar.
	# impacto: Deteccao e rastreamento de AirTags e acessorios Buscar param de funcionar.  |  risco: medio
	'com.apple.icloud.searchpartyd.beaconmanager'
	# funcao:  Componente do searchpartyd que gerencia o estado do Mac atuando como dispositivo "localizador" na rede Buscar. (incerto)
	# impacto: O Mac deixa de ajudar a localizar dispositivos de outras pessoas na rede Buscar.  |  risco: baixo
	'com.apple.icloud.searchpartyd.finderstatemanager'
	# funcao:  Componente do searchpartyd que gerencia o pareamento de acessorios (ex.: AirTags) com a conta do usuario na rede Buscar. (incerto)
	# impacto: Nao e possivel parear novos AirTags ou acessorios Buscar com o Mac.  |  risco: medio
	'com.apple.icloud.searchpartyd.pairingmanager'
	# funcao:  Componente do searchpartyd que agenda tarefas periodicas da rede Buscar, como rotacao de chaves e envio de relatorios. (incerto)
	# impacto: A sincronizacao de chaves e o envio de relatorios de localizacao da rede Buscar ficam comprometidos.  |  risco: medio
	'com.apple.icloud.searchpartyd.scheduler'
	# funcao:  Daemon central da rede Buscar (offline finding): gera chaves, faz a criptografia e troca relatorios de localizacao com a Apple.
	# impacto: A localizacao do Mac (e de AirTags) pela rede Buscar offline para de funcionar.  |  risco: alto
	'com.apple.icloud.searchpartyd'
	# funcao:  Agente por usuario que externaliza parte do searchpartyd (comunicacao com servidores) para suportar a arquitetura multiusuario do macOS.
	# impacto: A comunicacao da rede Buscar com os servidores Apple para o usuario logado para de funcionar.  |  risco: medio
	'com.apple.icloud.searchpartyuseragent'
	# funcao:  Agente que entrega notificacoes de servicos iCloud ao usuario, via AOSAccounts.framework.
	# impacto: Notificacoes relacionadas a servicos e a conta iCloud deixam de aparecer.  |  risco: baixo
	'com.apple.iCloudNotificationAgent'
	# funcao:  Agente que exibe ao usuario avisos e notificacoes de configuracao do iCloud (ex.: "Comecar a usar o iCloud", alertas de armazenamento).
	# impacto: Avisos e lembretes de configuracao/estado do iCloud deixam de ser exibidos.  |  risco: baixo
	'com.apple.iCloudUserNotifications'
	# funcao:  Agente do IDS (Apple Identity Service) que faz conexoes remotas de URL para iMessage/FaceTime, como buscar bags de configuracao.
	# impacto: iMessage e FaceTime podem falhar na inicializacao de sessao e na obtencao de configuracoes dos servidores Apple.  |  risco: medio
	'com.apple.idsremoteurlconnectionagent'
	# funcao:  Processo central do IMCore que mantem sessoes de iMessage e FaceTime ativas e escuta convites recebidos em segundo plano.
	# impacto: iMessage, FaceTime e encaminhamento de SMS do iPhone param de funcionar no Mac.  |  risco: medio
	'com.apple.imagent'
	# funcao:  Agente que apaga automaticamente o historico antigo de mensagens conforme a politica de retencao configurada no app Mensagens.
	# impacto: A exclusao automatica de mensagens antigas deixa de ocorrer e o historico se acumula indefinidamente.  |  risco: baixo
	'com.apple.imautomatichistorydeletionagent'
	# funcao:  Agente do framework IMCore responsavel por coletar logs de diagnostico do iMessage/FaceTime. (incerto)
	# impacto: Perde-se a geracao de logs de diagnostico de mensagens, sem afetar o envio/recebimento.  |  risco: baixo
	'com.apple.IMLoggingAgent'
	# funcao:  Agente que faz upload e download de anexos (fotos, videos, arquivos) das conversas do iMessage via servico MMCS.
	# impacto: Anexos no iMessage param de ser enviados e baixados.  |  risco: medio
	'com.apple.imtransferagent'
	# funcao:  Daemon que analisa conteudo local para construir um grafo de conhecimento sobre o dispositivo e o usuario, consultado por Siri e outros.
	# impacto: Recursos contextuais e sugestoes baseadas no grafo de conhecimento (Siri, etc.) ficam degradados.  |  risco: medio
	'com.apple.intelligenceplatformd'
	# funcao:  Daemon que gerencia a sincronizacao de conteudo da biblioteca de midia (Music/TV) e compras com o iCloud.
	# impacto: Sincronizacao da Biblioteca de Musica do iCloud e conteudo comprado para de funcionar.  |  risco: medio
	'com.apple.itunescloudd'
	# funcao:  Agente que detecta a conexao de dispositivos iOS/iPod e abre automaticamente o iTunes/Musica.
	# impacto: O iTunes/Musica deixa de abrir sozinho ao conectar um dispositivo; nenhuma outra funcao e afetada.  |  risco: baixo
	'com.apple.iTunesHelper.launcher'
	# funcao:  Agente do knowledgeconstructiond que faz o processamento pesado de analise de conteudo para montar o grafo de conhecimento da Inteligencia.
	# impacto: A construcao do grafo de conhecimento usado por Siri e busca contextual deixa de ocorrer.  |  risco: medio
	'com.apple.knowledge-agent'
	# funcao:  Agente que exibe o icone de bussola na barra de menus quando servicos do sistema solicitam a localizacao.
	# impacto: O icone indicador de uso de localizacao deixa de aparecer na barra de menus.  |  risco: baixo
	'com.apple.locationmenu'
	# funcao:  Daemon central do sistema de log unificado que coleta, comprime, grava e rotaciona todas as entradas de log do macOS.
	# impacto: O sistema de log unificado para, quebrando diagnosticos, Console e ferramentas que dependem de logs, com risco de instabilidade.  |  risco: alto
	'com.apple.logd'
	# funcao:  Agente que gerencia a experiencia do aluno no app Sala de Aula (Classroom) para ambientes educacionais gerenciados por MDM.
	# impacto: O recurso Sala de Aula deixa de funcionar; irrelevante para quem nao usa ambiente educacional.  |  risco: baixo
	'com.apple.macos.studentd'
	# funcao:  Daemon que verifica perfis DEP/Inscricao Automatica de Dispositivos contatando os servidores Apple durante a configuracao gerenciada.
	# impacto: Inscricao automatica em MDM via DEP para de funcionar; sem efeito em Macs pessoais nao gerenciados.  |  risco: baixo
	'com.apple.ManagedClient.cloudconfigurationd'
	# funcao:  Agente que trata notificacoes de inscricao de dispositivos e processos relacionados ao ManagedClient (MDM).
	# impacto: Notificacoes e fluxo de inscricao em gerenciamento de dispositivos param; sem efeito em Macs pessoais.  |  risco: baixo
	'com.apple.ManagedClientAgent.enrollagent'
	# funcao:  Daemon do app Mapas que trata tarefas auxiliares como notificacoes de Mapas, status de "Relatar um Problema" e acesso a dados do usuario.
	# impacto: Notificacoes do Mapas e sincronizacao de favoritos/itens recentes podem deixar de funcionar.  |  risco: baixo
	'com.apple.Maps.mapspushd'
	# funcao:  Rotulo launchd do mesmo binario mapspushd, que processa notificacoes push e tarefas auxiliares em segundo plano do app Mapas.
	# impacto: Notificacoes push e tarefas de fundo do Mapas deixam de funcionar.  |  risco: baixo
	'com.apple.Maps.pushdaemon'
	# funcao:  Daemon que analisa fotos e videos localmente para alimentar busca no Fotos, Visual Look Up, Texto ao Vivo e deteccao de objetos/rostos.
	# impacto: Busca por conteudo no Fotos, Texto ao Vivo e Visual Look Up ficam degradados ou param de indexar.  |  risco: medio
	'com.apple.mediaanalysisd'
	# funcao:  Agente que gerencia o Meu Compartilhamento de Fotos e os Albuns Compartilhados do app Fotos via servidores iCloud.
	# impacto: Albuns Compartilhados e Meu Compartilhamento de Fotos param de sincronizar.  |  risco: baixo
	'com.apple.mediastream.mstreamd'
	# funcao:  Daemon que baixa e atualiza "mobile assets" sob demanda, como base de fusos horarios, modelos de autocorrecao, vozes da Siri e suporte a dispositivos.
	# impacto: Atualizacoes silenciosas de fusos, dicionarios, vozes da Siri e arquivos de suporte de dispositivos param de ser baixadas.  |  risco: medio
	'com.apple.mobileassetd '
	# funcao:  Servico que avisa e baixa atualizacoes de software necessarias para o Mac se comunicar com iPhones/iPads conectados.
	# impacto: O Mac pode nao conseguir sincronizar/conectar a dispositivos iOS que rodam versoes mais novas que ele nao reconhece.  |  risco: medio
	'com.apple.mobiledeviceupdater'
	# funcao:  Daemon de proximidade que usa banda ultralarga (chip U1) e outras tecnologias sem fio para interacao espacial entre dispositivos proximos.
	# impacto: Recursos de proximidade como AirDrop direcionado, Handoff e localizacao precisa de dispositivos/acessorios ficam prejudicados.  |  risco: medio
	'com.apple.nearbyd'
	# funcao:  Daemon que implementa o protocolo NetBIOS para descoberta e compartilhamento de arquivos SMB com computadores Windows na rede.
	# impacto: A descoberta do Mac por nome NetBIOS em redes Windows mais antigas deixa de funcionar; SMB moderno geralmente continua ok.  |  risco: baixo
	'com.apple.netbiosd'
	# funcao:  Daemon do app Apple News que sincroniza e armazena em cache conteudo e artigos de noticias, inclusive via iCloud.
	# impacto: O app Apple News para de sincronizar fontes e baixar conteudo em segundo plano.  |  risco: baixo
	'com.apple.newsd'
	# funcao:  Daemon que executa o utilitario newsyslog para rotacionar, comprimir e expurgar arquivos de log legados conforme /etc/newsyslog.conf.
	# impacto: Logs legados (estilo BSD) deixam de ser rotacionados e podem crescer e consumir espaco em disco.  |  risco: medio
	'com.apple.newsyslog'
	# funcao:  Agente por usuario que renderiza a interface da Central de Notificacoes, banners de alertas e widgets do desktop.
	# impacto: Notificacoes, banners e widgets param de aparecer; afeta um recurso central da experiencia do usuario.  |  risco: alto
	'com.apple.notificationcenterui'
	# funcao:  Gerencia transferencias de rede em segundo plano (downloads/uploads), incluindo a sincronizacao do iCloud Drive, Fotos, etc.
	# impacto: Sincronizacao do iCloud e downloads em segundo plano de apps do sistema e de terceiros param de funcionar.  |  risco: alto
	'com.apple.nsurlsessiond'
	# funcao:  Coleta relatorios de diagnostico (ex: eventos Jetsam de memoria) e os envia anonimamente a Apple via SubmitDiagInfo.
	# impacto: Perde-se o envio de telemetria de diagnostico a Apple; nenhuma funcionalidade do usuario e afetada.  |  risco: baixo
	'com.apple.osanalytics.osanalyticshelper'
	# funcao:  Verifica e aplica as restricoes de Controles Parentais / Tempo de Uso configuradas na conta do usuario.
	# impacto: Restricoes de Controles Parentais/Tempo de Uso podem deixar de ser aplicadas corretamente.  |  risco: medio
	'com.apple.parentalcontrols.check'
	# funcao:  Daemon de apoio do Siri Search que faz a descarga e o envio periodico de dados analiticos de busca do Siri.
	# impacto: Apenas o envio de telemetria analitica de busca do Siri e interrompido; sem impacto funcional.  |  risco: baixo
	'com.apple.parsec-fbf'
	# funcao:  Gerencia dados e acesso para Sugestoes do Siri, Spotlight, Safari, Consulta, #imagens e busca de artigos do Apple News.
	# impacto: Sugestoes do Siri/Spotlight/Safari e resultados de busca online deixam de funcionar.  |  risco: medio
	'com.apple.parsecd'
	# funcao:  Daemon da Carteira (Wallet) e Apple Pay que gerencia passes, cartoes e pagamentos (framework PassKitCore).
	# impacto: Carteira e Apple Pay deixam de funcionar no Mac.  |  risco: medio
	'com.apple.passd'
	# funcao:  Verifica e disponibiliza os itens do menu Servicos, mantendo o cache de Servicos atualizado em todos os apps.
	# impacto: O menu Servicos para de ser populado/atualizado nos aplicativos.  |  risco: medio
	'com.apple.pbs'
	# funcao:  Daemon que gerencia e relaciona referencias a pessoas/contatos para apps que usam a estrutura de Contatos.
	# impacto: Recursos que dependem de correspondencia de contatos (sugestoes de pessoas, integracao de apps) podem falhar.  |  risco: medio
	'com.apple.peopled'
	# funcao:  Gerencia arquivos de log estruturados que permitem recuperar dados de energia e desempenho do sistema.
	# impacto: Perde-se a coleta de dados de desempenho/energia usados em diagnosticos; sem impacto funcional perceptivel.  |  risco: baixo
	'com.apple.PerfPowerServices '
	# funcao:  Analisa a biblioteca do app Fotos no dispositivo para reconhecimento facial, de objetos/cenas, Memorias e busca.
	# impacto: Reconhecimento de rostos, album Pessoas, Memorias e busca por conteudo nas Fotos deixam de funcionar.  |  risco: medio
	'com.apple.photoanalysisd'
	# funcao:  Agente da biblioteca de Fotos que atende a todas as requisicoes e mantem o indice/organizacao da biblioteca.
	# impacto: O app Fotos deixa de funcionar corretamente (acesso, indexacao e organizacao da biblioteca quebram).  |  risco: alto
	'com.apple.photolibraryd'
	# funcao:  Coleta dados de energia/bateria e da suporte a interface de Uso da Bateria nos Ajustes do Sistema.
	# impacto: Estatisticas de uso da bateria e historico de energia ficam indisponiveis.  |  risco: baixo
	'com.apple.powerlogHelperd'
	# funcao:  Agente de sincronizacao do ClassKit que sincroniza turmas, membros, materiais e progresso entre contas de alunos e professores.
	# impacto: A sincronizacao de dados educacionais do ClassKit (Escola/Sala de Aula) para de funcionar.  |  risco: baixo
	'com.apple.progressd'
	# funcao:  Gerencia o backup e a sincronizacao das chaves de criptografia (PCS) do armazenamento protegido do iCloud via CloudKit.
	# impacto: A sincronizacao de dados criptografados do iCloud (ex: Chaveiro e outros) pode falhar de forma imprevisivel.  |  risco: alto
	'com.apple.protectedcloudstorage.protectedcloudkeysyncing'
	# funcao:  Variante por usuario (LaunchAgent) do daemon Rapport, que habilita Continuidade/Handoff entre dispositivos Apple no contexto do usuario.
	# impacto: Recursos de Continuidade como Handoff e encaminhamento de chamadas podem parar de funcionar.  |  risco: medio
	'com.apple.rapportd-user'
	# funcao:  Daemon Rapport que habilita Handoff de chamadas e outros recursos de Continuidade entre dispositivos Apple na rede local.
	# impacto: Handoff, encaminhamento de chamadas/mensagens e descoberta de dispositivos da Continuidade deixam de funcionar.  |  risco: medio
	'com.apple.rapportd'
	# funcao:  Daemon do app Lembretes que mantem os lembretes em segundo plano e dispara as notificacoes e alarmes agendados.
	# impacto: O app Lembretes fica inutilizavel e os alertas de lembretes nao sao mais disparados.  |  risco: alto
	'com.apple.remindd'
	# funcao:  Instancia do ReportCrash que analisa falhas de processos privilegiados/daemons e grava os relatorios em /Library/Logs/DiagnosticReports.
	# impacto: Falhas de processos do sistema deixam de gerar relatorios de diagnostico, dificultando a depuracao de problemas.  |  risco: baixo
	'com.apple.ReportCrash.Root'
	# funcao:  Instancia do ReportCrash responsavel por reportar falhas do proprio mecanismo de relatorio de falhas.
	# impacto: Falhas no proprio ReportCrash deixam de ser registradas; sem impacto para o usuario.  |  risco: baixo
	'com.apple.ReportCrash.Self'
	# funcao:  Invocado automaticamente pelo launchd ao detectar uma falha, analisa o processo e grava um relatorio de crash em disco.
	# impacto: Apps que travam nao geram relatorios de diagnostico, dificultando a identificacao de problemas.  |  risco: baixo
	'com.apple.ReportCrash'
	# funcao:  Servico que gera logs de diagnostico de uso de memoria em resposta a eventos como violacoes de limite de memoria.
	# impacto: Violacoes de limite de memoria deixam de gerar relatorios de diagnostico; sem impacto funcional.  |  risco: baixo
	'com.apple.ReportMemoryException'
	# funcao:  Componente que coleta e gera os relatorios de kernel panic apos uma falha grave do sistema. (incerto)
	# impacto: Apos um kernel panic, o log de panico pode nao ser gerado, dificultando o diagnostico de travamentos do sistema.  |  risco: baixo
	'com.apple.ReportPanic'
	# funcao:  Daemon por usuario que aprende padroes historicos de localizacao e preve visitas futuras (Localizacoes Significativas).
	# impacto: Sugestoes com base em localizacao no Maps, Siri e Calendario (ex: hora de sair) deixam de funcionar.  |  risco: medio
	'com.apple.routined'
	# funcao:  Daemon que coleta localmente diagnosticos e telemetria de uso de comunicacoes em tempo real (FaceTime/chamadas) para usuarios que optaram por reportar.
	# impacto: Apenas o envio de telemetria de chamadas/FaceTime e interrompido; sem impacto funcional.  |  risco: baixo
	'com.apple.rtcreportingd'
	# funcao:  Agente que escuta alteracoes no historico do Safari vindas de outros dispositivos para sincroniza-lo via iCloud.
	# impacto: O historico do Safari deixa de ser sincronizado entre os dispositivos Apple.  |  risco: baixo
	'com.apple.SafariCloudHistoryPushAgent'
	# funcao:  Sincroniza os favoritos do Safari com o iCloud (protocolo DAV) entre dispositivos Apple.
	# impacto: Favoritos do Safari deixam de sincronizar com iCloud; navegacao local continua normal.  |  risco: baixo
	'com.apple.safaridavclient'
	# funcao:  Gerencia as notificacoes push de sites no Safari, exibindo-as na Central de Notificacoes.
	# impacto: Sites nao conseguem mais enviar notificacoes push pelo Safari; resto do navegador funciona.  |  risco: baixo
	'com.apple.SafariNotificationAgent'
	# funcao:  Daemon que atende o kernel de sandbox, rastreando operacoes e registrando violacoes de apps isolados.
	# impacto: Enfraquece o isolamento de seguranca de apps e pode causar travamentos/comportamento imprevisivel.  |  risco: alto
	'com.apple.sandboxd'
	# funcao:  Processo de fundo que coleta dados de uso e aplica limites e bloqueios do Tempo de Uso (Screen Time).
	# impacto: Tempo de Uso, limites de apps, downtime e controles parentais deixam de funcionar.  |  risco: medio
	'com.apple.ScreenTimeAgent'
	# funcao:  Servico XPC que faz ponte entre o securityd e o iCloud Key-Value Store para sincronizar a Chaveiro iCloud.
	# impacto: Senhas e itens do Chaveiro iCloud deixam de sincronizar entre dispositivos Apple.  |  risco: medio
	'com.apple.security.cloudkeychainproxy'
	# funcao:  Versao mais recente do proxy de sincronizacao da Chaveiro iCloud entre dispositivos via iCloud KVS.
	# impacto: Senhas, passkeys e itens do Chaveiro iCloud deixam de sincronizar entre dispositivos.  |  risco: medio
	'com.apple.security.cloudkeychainproxy3'
	# funcao:  Daemon de compartilhamento que habilita AirDrop, Handoff, Hotspot Pessoal Instantaneo, computadores compartilhados e Remote Disc.
	# impacto: AirDrop, Handoff, Hotspot Instantaneo e disco remoto deixam de funcionar.  |  risco: medio
	'com.apple.sharingd'
	# funcao:  Repassa eventos de entrada (HID) como toque e Apple Pencil entre o Mac e o iPad usado como Sidecar.
	# impacto: Entrada via toque/Pencil no Sidecar para de funcionar; outras funcoes do Mac nao sao afetadas.  |  risco: baixo
	'com.apple.sidecar-hid-relay'
	# funcao:  Gerencia a conexao do Sidecar, transmitindo o video do display virtual do Mac para o iPad.
	# impacto: O recurso Sidecar (usar iPad como segunda tela) deixa de funcionar.  |  risco: baixo
	'com.apple.sidecar-relay'
	# funcao:  Agente principal da Siri que processa as solicitacoes do usuario ao assistente no macOS.
	# impacto: A Siri deixa de funcionar; como esta integrada ao SO, desativar pode ter efeitos imprevisiveis.  |  risco: medio
	'com.apple.Siri.agent'
	# funcao:  Servico de back-end que mantem o contexto da Siri (conversa anterior, conteudo na tela) entre interacoes. (incerto)
	# impacto: A Siri perde reconhecimento de contexto e perguntas de acompanhamento; assistente basico ainda pode responder.  |  risco: baixo
	'com.apple.siri.context.service'
	# funcao:  Daemon que baixa atualizacoes de pacotes de idioma (morphuns) usados pela Siri.
	# impacto: Os pacotes de idioma da Siri deixam de ser atualizados automaticamente.  |  risco: baixo
	'com.apple.siri.morphunassetsupdaterd'
	# funcao:  Coordena a execucao e a sincronizacao dos atalhos criados no app Atalhos (Shortcuts).
	# impacto: Atalhos podem nao executar nem sincronizar corretamente entre dispositivos.  |  risco: medio
	'com.apple.siriactionsd'
	# funcao:  Daemon do framework privado SiriInference, ligado a inferencia/personalizacao da Siri. (incerto)
	# impacto: Recursos de inteligencia e personalizacao da Siri podem degradar; impacto exato pouco documentado.  |  risco: baixo
	'com.apple.siriinferenced'
	# funcao:  Daemon de conhecimento da Siri, parte da infraestrutura que alimenta respostas baseadas em conhecimento. (incerto)
	# impacto: Respostas da Siri baseadas em conhecimento podem degradar; funcao exata pouco documentada.  |  risco: baixo
	'com.apple.siriknowledged'
	# funcao:  Gerencia notificacoes de servicos sociais integrados a Central de Notificacoes (recurso legado do Notification Center).
	# impacto: Notificacoes de contas sociais integradas ao sistema deixam de ser entregues; recurso pouco usado hoje.  |  risco: baixo
	'com.apple.SocialPushAgent'
	# funcao:  Agente que exibe notificacoes e badges de atualizacoes de software disponiveis para o macOS.
	# impacto: O usuario para de receber avisos de atualizacoes disponiveis; o download/instalacao ainda pode ser feito manualmente.  |  risco: baixo
	'com.apple.softwareupdate_notify_agent'
	# funcao:  Componente em nivel de usuario do sistema spindump que ajuda a gerar relatorios de apps travados/sem resposta.
	# impacto: Relatorios de travamento (spindump) de apps do usuario podem nao ser gerados; diagnostico fica limitado.  |  risco: baixo
	'com.apple.spindump_agent'
	# funcao:  Ferramenta de diagnostico que amostra pilhas de usuario e kernel para gerar relatorios de processos travados.
	# impacto: Relatorios de hang/travamento deixam de ser gerados, dificultando o diagnostico de problemas.  |  risco: baixo
	'com.apple.spindump'
	# funcao:  Daemon que envia a Apple dados de diagnostico e uso (se o usuario optou por isso) e limpa relatorios antigos.
	# impacto: Dados de diagnostico nao sao enviados a Apple e relatorios antigos nao sao limpos automaticamente.  |  risco: baixo
	'com.apple.SubmitDiagInfo'
	# funcao:  Processa conteudo de Spotlight, Mail, Mensagens e outros apps para detectar contatos/eventos e alimentar sugestoes e personalizacao.
	# impacto: Sugestoes proativas, QuickType e personalizacao de teclado/Siri/News deixam de funcionar.  |  risco: baixo
	'com.apple.suggestd'
	# funcao:  Componente de diagnostico do Symptom Framework, ligado a analise de sintomas de rede e desempenho. (incerto)
	# impacto: Coleta de diagnostico de problemas de rede fica limitada; conectividade em si nao e afetada.  |  risco: baixo
	'com.apple.symptomsd-diag'
	# funcao:  Daemon do Symptom Framework que monitora qualidade de rede e detecta sintomas de conexao ruim.
	# impacto: macOS perde a deteccao de redes ruins e pode nao trocar de Wi-Fi automaticamente; pode ter efeitos colaterais.  |  risco: medio
	'com.apple.symptomsd'
	# funcao:  Daemon que sincroniza dados de apps com o iCloud via NSUbiquitousKeyValueStore (armazenamento chave-valor).
	# impacto: Configuracoes e dados chave-valor de apps deixam de sincronizar com o iCloud.  |  risco: medio
	'com.apple.syncdefaultsd'
	# funcao:  Agente que dispara a coleta de sysdiagnose, um pacote amplo de logs e estado do sistema para suporte/depuracao.
	# impacto: Coleta de sysdiagnose pode falhar, dificultando o suporte da Apple ao diagnosticar problemas.  |  risco: baixo
	'com.apple.sysdiagnose_agent'
	# funcao:  Coleta sob demanda um pacote abrangente de diagnosticos do sistema (logs, processos, kernel) para depuracao e bug reports da Apple.
	# impacto: Perde-se a geracao do pacote sysdiagnose; ferramentas de troubleshooting e relatorios de bug a Apple deixam de funcionar.  |  risco: baixo
	'com.apple.sysdiagnose'
	# funcao:  Daemon de logging do sistema (Apple System Logger) que recebe, roteia e grava mensagens de log de todo o sistema.
	# impacto: Logs do sistema deixam de ser registrados, quebrando diagnostico, auditoria e troubleshooting; outros componentes podem se comportar mal.  |  risco: alto
	'com.apple.syslogd'
	# funcao:  Tarefa que analisa e consolida os dados de estatisticas de sistema e uso de energia coletados pelo systemstatsd.
	# impacto: Analise/consolidacao de metricas de energia e desempenho deixa de ocorrer; relatorios de bateria e diagnosticos de energia ficam incompletos.  |  risco: baixo
	'com.apple.systemstats.analysis'
	# funcao:  Tarefa diaria que processa e mantem o banco de estatisticas de sistema e uso de energia coletadas pelo systemstatsd.
	# impacto: Manutencao diaria das estatisticas para de rodar; historico de uso de energia/desempenho fica defasado ou cresce sem limpeza.  |  risco: baixo
	'com.apple.systemstats.daily'
	# funcao:  Daemon auxiliar do tailspin que amostra continuamente callstacks e eventos do kernel para capturar o estado do sistema em picos de CPU.
	# impacto: Perde-se a captura automatica de tailspin usada para diagnosticar travamentos e picos de CPU; sem impacto na estabilidade.  |  risco: baixo
	'com.apple.tailspind '
	# funcao:  Daemon que mantem o estado de chamadas, usado por FaceTime, Mensagens, Contatos e apps de chamada de terceiros.
	# impacto: FaceTime, chamadas via iPhone (Continuidade) e integracao de chamadas quebram; apps como Zoom podem perder funcionalidades.  |  risco: alto
	'com.apple.telephonyutilities.callservicesd'
	# funcao:  Daemon que fornece analise e compreensao de texto em documentos para recursos do sistema.
	# impacto: Recursos que dependem de analise de texto (ex.: Visual Look Up de texto, sugestoes inteligentes) deixam de funcionar.  |  risco: medio
	'com.apple.textunderstandingd'
	# funcao:  Agente de segundo plano do app Dicas (Tips) que entrega dicas de uso e roda tarefas de analytics agendadas.
	# impacto: O app Dicas para de receber/atualizar conteudo e notificacoes; nenhum impacto em funcionalidade central.  |  risco: baixo
	'com.apple.tipsd'
	# funcao:  Daemon do Time Machine que limpa caches e arquivos temporarios de backup quando o sistema precisa liberar espaco.
	# impacto: Limpeza automatica de cache do Time Machine para; em disco cheio o sistema pode nao recuperar espaco corretamente.  |  risco: medio
	'com.apple.TMCacheDelete'
	# funcao:  Agente que detecta discos externos novos e oferece configura-los como destino de backup do Time Machine.
	# impacto: Macs deixam de exibir o convite automatico para usar um disco recem-conectado como Time Machine; configuracao manual ainda funciona.  |  risco: baixo
	'com.apple.TMHelperAgent.SetupOffer'
	# funcao:  Agente auxiliar do Time Machine que da suporte as operacoes de backup e a interface de usuario do Time Machine.
	# impacto: Notificacoes, interface e auxilio as operacoes do Time Machine ficam comprometidos; backups podem nao funcionar de forma confiavel.  |  risco: medio
	'com.apple.TMHelperAgent'
	# funcao:  Daemon que faz a verificacao de Key Transparency das chaves publicas de IDS/iMessage junto ao identityservicesd.
	# impacto: A Verificacao de Chave de Contato do iMessage para de validar chaves; mensagens funcionam mas sem essa garantia de seguranca.  |  risco: medio
	'com.apple.transparencyd'
	# funcao:  Componente de sistema (root) do framework Trial, que distribui experimentos da Apple via CloudKit para recursos de ML.
	# impacto: O Mac deixa de receber experimentos/ajustes de recursos de ML; pode afetar Siri, Fotos, Spotlight e ranking de busca.  |  risco: medio
	'com.apple.triald.system'
	# funcao:  Agente (por usuario) do framework Trial que coleta dados de experimentos da Apple via CloudKit para recursos de ML.
	# impacto: Coleta de dados de experimentos para; relatos indicam quebra de recursos como "tocar a seguir" do Apple Music.  |  risco: medio
	'com.apple.triald'
	# funcao:  Agente que avalia a confianca de certificados consultando o armazenamento de certificados confiaveis do sistema.
	# impacto: Validacao de certificados SSL/TLS para apps fica comprometida, podendo quebrar conexoes seguras e seguranca do sistema.  |  risco: alto
	'com.apple.TrustEvaluationAgent'
	# funcao:  Daemon que gerencia as configuracoes e recursos de acessibilidade do macOS (VoiceOver, Zoom, etc.).
	# impacto: Recursos de acessibilidade param de funcionar e APIs de acessibilidade usadas por varios apps quebram.  |  risco: alto
	'com.apple.universalaccessd'
	# funcao:  Agente que monitora o uso de apps e aplica os limites configurados no Tempo de Uso (Screen Time).
	# impacto: Tempo de Uso deixa de registrar atividade e de aplicar limites/controles parentais.  |  risco: medio
	'com.apple.UsageTrackingAgent'
	# funcao:  Daemon que gerencia dados de assinaturas de video e contas de provedores para o app TV e Single Sign-On de TV.
	# impacto: App TV perde gerenciamento de assinaturas e login unico de provedores de TV; reproducao de conteudo assinado pode falhar.  |  risco: baixo
	'com.apple.videosubscriptionsd'
	# funcao:  Daemon que da suporte ao recurso de acessibilidade Voz Pessoal (Personal Voice), gravando e gerando a voz do usuario.
	# impacto: Criacao e uso da Voz Pessoal param de funcionar; afeta usuarios que dependem de Live Speech e apps AAC.  |  risco: baixo
	'com.apple.voicebankingd'
	# funcao:  Daemon de watchdog que verifica se kernel e espaco de usuario continuam progredindo, acionando recuperacao se o sistema travar.
	# impacto: O sistema perde a recuperacao automatica de travamentos; problemas que seriam corrigidos por reboot/panic ficam sem tratamento.  |  risco: alto
	'com.apple.watchdogd '
	# funcao:  Daemon que fornece dados meteorologicos de backend para o app Tempo e widgets de clima.
	# impacto: App Tempo e widgets de clima param de obter e atualizar previsoes.  |  risco: baixo
	'com.apple.weatherd'
	# funcao:  Daemon que coleta leituras e metricas de diagnostico das interfaces Wi-Fi para analise de desempenho de rede.
	# impacto: Perde-se a coleta de analytics de Wi-Fi; sem impacto na conectividade em si.  |  risco: baixo
	'com.apple.wifianalyticsd'
	# funcao:  Agente (contexto de usuario) do framework WiFiVelocity que executa acoes de teste e diagnostico de Wi-Fi.
	# impacto: Perde-se parte dos testes/diagnosticos de Wi-Fi em contexto de usuario; conectividade normal nao e afetada.  |  risco: baixo
	'com.apple.WiFiVelocityAgent'
	# funcao:  Daemon (contexto de sistema) do framework WiFiVelocity que executa testes periodicos e diagnosticos da conexao Wi-Fi.
	# impacto: Testes de desempenho/diagnostico de Wi-Fi do sistema param; conectividade Wi-Fi normal continua funcionando.  |  risco: baixo
	'com.apple.wifivelocityd '
	# funcao:  Tarefa do XProtect Remediator que dispara, na inicializacao (como root), uma varredura de malware conhecido no Mac.
	# impacto: A varredura antimalware de inicializacao deixa de rodar, reduzindo a protecao do macOS contra malware conhecido.  |  risco: alto
	'com.apple.XProtect.daemon.scan.startup'
	# funcao:  Tarefa do XProtect Remediator que executa varreduras periodicas de malware como root, removendo/remediando ameacas conhecidas.
	# impacto: As varreduras periodicas antimalware param, deixando o Mac sem deteccao e remediacao automatica de malware conhecido.  |  risco: alto
	'com.apple.XProtect.daemon.scan'
)

# Function to disable or enable services
manageServices() {
	local action=$1
	local userID=$2
	local plistPath

	userPlistPaths=(
		"${HOME}/Library/LaunchAgents/"
		"/Library/LaunchAgents/"
		"/System/Library/LaunchAgents/"
	)
	systemPlistPaths=(
		"/Library/LaunchDaemons/"
		"/System/Library/LaunchDaemons/"
	)

	# Helper function to handle the actions for a given service and domain
	handleServiceAction() {
		local domain=$1
		local service=$2
		local plistPath=$3
		local entry="${domain}/${service}"

		echo -n "${action^}: ${entry}"
		if [[ ${action} == "disable" ]]; then
			sudo launchctl bootout "${entry}" &>/dev/null || echo " - failed bootout"
			sudo launchctl disable "${entry}" || echo " - failed disable"
		elif [[ ${action} == "enable" ]]; then
			sudo launchctl enable "${entry}" || echo " - failed enable"
			sudo launchctl bootstrap "${domain}" "${plistPath}" &>/dev/null || echo " - failed bootstrap"
		fi
		sleep 0.1
	}

	for service in "${services[@]}"; do
		# Process user services
		for userPath in "${userPlistPaths[@]}"; do
			plistPath="${userPath}${service}.plist"
			if [[ -f ${plistPath} ]]; then
				handleServiceAction "gui/${userID}" "${service}" "${plistPath}"
			fi
		done
		# Process system services
		for systemPath in "${systemPlistPaths[@]}"; do
			plistPath="${systemPath}${service}.plist"
			if [[ -f ${plistPath} ]]; then
				handleServiceAction "system" "${service}" "${plistPath}"
			fi
		done
	done
}

# Function to apply or revert system tweaks
manageTweaks() {
	local action=$1
	# Map tweak keys to their respective domains and values
	tweaks=(
		# Disables the automatic restoration of apps after logout or shutdown
		"com.apple.loginwindow TALLogoutSavesState -bool false"
		# Prevents applications from automatically reopening upon login
		"com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false"
		# Turns off window opening and closing animations
		"NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false"
		# Reduces the time it takes to resize windows
		"NSGlobalDomain NSWindowResizeTime -float 0.001"
		# Disables the animation for Quick Look panels
		"-g QLPanelAnimationDuration -float 0"
		# Sets the Dock auto-hide and show delay to zero (making it react instantly)
		"com.apple.dock autohide-time-modifier -float 0"
		# Sets the delay before Dock auto-hide begins
		"com.apple.dock autohide-delay -float 0"
		# Disables bouncing animation for Dock icons
		"com.apple.dock no-bouncing -bool true"
		# Disables the opening animation for applications from the Dock
		"com.apple.dock launchanim -bool false"
		# Turns off auto-check for software updates
		"com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false"
		# Disables automatic download of software updates
		"com.apple.SoftwareUpdate AutomaticDownload -bool false"
		# Prevents automatic installation of app updates
		"com.apple.commerce AutoUpdate -bool false"
		# Disables automatic reboot to install macOS updates
		"com.apple.commerce AutoUpdateRestartRequired -bool false"
		# Disables automatic installation of critical security updates
		"com.apple.SoftwareUpdate CriticalUpdateInstall -bool false"
		# Disable certificate checking
		"com.apple.security.revocation.plist OCSPStyle None"
		"com.apple.security.revocation.plist CRLStyle None"
		# Disable the "Are you sure you want to open this application?" dialog
		"com.apple.LaunchServices LSQuarantine -bool false"
	)

	for cmd in "${tweaks[@]}"; do
		# Read the command into the domain, subkey, and the rest
		read -r domain subkey rest <<<"${cmd}"

		echo "${action^}: ${domain} ${subkey}"
		if [[ ${action} == "disable" ]]; then
			if defaults write "${domain}" "${subkey}" "${rest}"; then
				echo "Successfully disabled: ${domain} ${subkey}"
			else
				echo "Failed to disable: ${domain} ${subkey}" >&2
			fi
		elif [[ ${action} == "enable" ]]; then
			echo "Reverting tweak: ${domain} ${subkey}"
			if defaults delete "${domain}" "${subkey}" 2>/dev/null; then
				echo "Successfully reverted: ${domain} ${subkey}"
			else
				echo "No existing setting to revert or failed to revert: ${domain} ${subkey}" >&2
			fi
		fi
		sleep 0.1
	done

	# Throttling tweak can be uncommented if needed
	# [[ ${action} == "disable" ]] && sudo sysctl -w debug.lowpri_throttle_enabled=0
	# [[ ${action} == "enable" ]] && sudo sysctl -w debug.lowpri_throttle_enabled=1
}

# Main function to process the command line action
main() {
	local action=$1
	local launchctlAction

	if [[ ${action} == "--revert" ]]; then
		manageServices "enable" "${UID}"
		manageTweaks "enable"
		launchctlAction="load"
	else
		manageServices "disable" "${UID}"
		manageTweaks "disable"
		launchctlAction="unload"
	fi

	# Load/unload dock based
	launchctl "${launchctlAction}" /System/Library/LaunchAgents/com.apple.Dock.plist
}

main "$@"
