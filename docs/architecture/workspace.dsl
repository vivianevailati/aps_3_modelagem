workspace "Assistente de IA para Exportação — Contexto e Coleta" "Visão C4 nível 2 da funcionalidade RF02 e RF03." {
    model {
        usuario = person "Usuário exportador" "Pessoa que consulta o assistente para obter orientações sobre uma operação de exportação."

        sistema = softwareSystem "Assistente de IA para Exportação" "Assistente que interpreta perguntas e fornece orientações de exportação fundamentadas." {
            frontend = container "Interface de Conversação" "Recebe mensagens e apresenta perguntas complementares e respostas." "React / TypeScript" 
            api = container "API de Conversas" "Recebe mensagens, identifica sessões e coordena os serviços de contexto e coleta." "Node.js / TypeScript / REST"
            contexto = container "Serviço de Contexto e Coleta" "Recupera o histórico, mescla informações da operação e identifica campos pendentes (RF02/RF03)." "Node.js / TypeScript"
            banco = container "Banco de Contextos" "Armazena sessões, mensagens e dados parciais ou completos das operações." "PostgreSQL 16"
            fila = container "Barramento de Eventos" "Distribui eventos assíncronos quando o contexto está pronto para processamento." "RabbitMQ"
            rag = container "Orquestrador RAG" "Recebe o contexto consolidado, consulta a base vetorial e solicita geração da resposta ao LLM." "Python / FastAPI"
            vetor = container "Base de Conhecimento Vetorial" "Armazena documentos e trechos regulatórios indexados para recuperação semântica." "PostgreSQL 16 / pgvector"
            llm = container "Serviço de Modelo de Linguagem" "Gera respostas em linguagem natural com base no contexto recuperado." "LLM via API"
        }

        usuario -> frontend "Envia perguntas e responde às solicitações de dados" "HTTPS"
        frontend -> api "Envia mensagens e recebe DTOs de resposta" "HTTPS / JSON / REST"
        api -> contexto "Recupera e atualiza o contexto da sessão" "REST / JSON"
        contexto -> banco "Consulta e persiste contexto e histórico" "SQL / TCP"
        api -> fila "Publica ContextoProntoDTO" "AMQP"
        fila -> rag "Entrega evento de contexto pronto" "AMQP"
        rag -> vetor "Busca trechos regulatórios relevantes" "SQL / pgvector"
        rag -> llm "Envia prompt contextualizado e recebe geração" "HTTPS / API"
        api -> frontend "Retorna pergunta complementar ou confirmação" "HTTPS / JSON"
    }

    views {
        container sistema {
            include *
            autolayout lr
        }
        styles {
            element "Person" {
                shape person
                background "#08427b"
                color "#ffffff"
            }
            element "Software System" {
                background "#1168bd"
                color "#ffffff"
            }
            element "Container" {
                background "#438dd5"
                color "#ffffff"
            }
        }
    }
}
