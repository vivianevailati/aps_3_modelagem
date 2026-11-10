# aps_3_modelagem
Dossiê de Arquitetura Viva e Modelagem — Assistente IA Fiep Export

1. Contextualização da funcionalidade
O Assistente de IA para Exportação tem como objetivo apoiar pequenas indústrias na compreensão de regras, documentos e procedimentos necessários à exportação. A solução recebe perguntas em linguagem natural e utiliza o contexto da operação para fornecer orientações mais adequadas.

Este dossiê detalha a funcionalidade de Coleta de Dados da Operação e Gerenciamento de Contexto, responsável por manter as informações já fornecidas pelo usuário e identificar quais dados ainda precisam ser coletados antes de encaminhar uma consulta ao pipeline RAG.
1.1 Requisitos funcionais relacionados
- RF02 — Contexto da conversa (Crítico): mantém o histórico da sessão atual e permite perguntas complementares sem que o usuário repita produto, NCM, destino e demais dados já informados.
- RF03 — Coleta de dados da operação (Crítico): quando a pergunta não contém os dados mínimos, o assistente solicita apenas as informações ausentes.
1.2 Dados considerados na coleta
O contexto da operação pode conter produto, NCM, país de origem, país de destino, quantidade e finalidade. A necessidade de cada campo deve respeitar o cenário da consulta. O sistema não deve inventar ou presumir dados ausentes; quando houver ambiguidade, deve solicitar confirmação.
1.3 Fluxo resumido
1. O usuário envia uma pergunta.
2. A API identifica a sessão e recupera seu contexto.
3. O serviço de linguagem natural extrai informações da mensagem.
4. O coletor mescla as informações novas com as já armazenadas.
5. O sistema verifica os campos mínimos.
6. Se houver pendências, solicita somente os campos ausentes e atualiza o contexto.
7. Se os dados estiverem completos, persiste o contexto e publica um evento para o pipeline RAG.

ADR 0001 — Persistência incremental do contexto da operação

Status: Aprovado
Contexto
O assistente precisa manter informações fornecidas em mensagens diferentes e solicitar somente os dados ainda ausentes. Tratar cada pergunta isoladamente provocaria repetição de perguntas e perda de informações importantes para a análise de exportação.
Decisão
Adotar um serviço de gerenciamento de contexto com persistência incremental em PostgreSQL 16 e coleta por campos (slot filling). A cada mensagem, o sistema recupera o contexto da sessão, extrai novos dados, mescla as informações, identifica campos pendentes e persiste a atualização. Quando os dados mínimos estiverem completos, publica o evento ContextoProntoDTO para o pipeline RAG.
Consequências
Vantagens: continuidade da conversa, menor repetição de perguntas, coleta gradual, rastreabilidade, recuperação do contexto e desacoplamento do pipeline RAG.

Custos e riscos: necessidade de proteger dados por sessão, controlar retenção e expiração, tratar atualizações concorrentes, validar extrações feitas por IA e garantir idempotência no consumo dos eventos.

Consistência entre os artefatos
A coerência entre os cinco artefatos é garantida pelas seguintes relações:
1. Sequência e atividades: ambas representam recuperação do contexto, extração de dados, identificação de pendências, persistência e encaminhamento do contexto completo.
2. Sequência e estados: a coleta mantém o contexto em Coletando; o preenchimento dos campos permite a transição para Pronto; o evento encaminha o contexto para Processando.
3. Atividades e estados: a decisão sobre campos mínimos define se o fluxo permanece em coleta ou se libera o processamento.
4. C4 e sequência: os participantes da sequência são implementados pelos contêineres de API, serviço de contexto, PostgreSQL, RabbitMQ e orquestrador RAG.
5. ADR e arquitetura: a decisão de persistência incremental justifica o PostgreSQL e a separação do serviço de contexto.
