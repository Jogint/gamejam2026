////scr_game_defs

// ================= CONSTANTES =================
#macro TOTAL_FACCOES 4      // 3 jogáveis + 1 neutra (lilás)
#macro MAX_GRUPO 4          // player + até 3 aliados
#macro MAX_INIMIGOS 4
#macro RELACAO_MAX 3
#macro RELACAO_ALIADA 2     // relação mínima para contar como facção aliada
#macro TEMPO_CONTA_INIMIGO true   // false = só as ações do jogador contam no tempo da rodada
#macro ICONE_SKILL 48       // tamanho (px) do ícone quadrado das habilidades
#macro DEFENDER_REDUCAO 1   // fração do dano bloqueada por "Defender" (1 = 100%, 0.9 = 90%...)

enum GAME_STATE { expedition, card, combat, run_end, preparacao }
enum FACTION { faction_1, faction_2, faction_3, count }
enum CARD_ORIGIN { neutral, faction_1, faction_2, faction_3, faction_4, count }
enum CARD_TIPO { evento, hostil, amigavel, posto, missao }
enum RECOMPENSA { recurso, cura, stat, aliado, relacao }
enum STAT { vitalidade, forca, imaginacao, tecnica, sorte, carisma, count }
enum SKILL_TIPO { dano, cura, restaurar, buff, debuff, recarga, defesa }
enum SKILL_CAT { basico, skill, missao }
enum ALCANCE { unico, adjacente, global }
enum STATUS { queimadura, atordoamento, corrosao, lentidao, celeridade, count }
enum SKILL_ID { golpe, pancada, mordida, disparo, tiro, improviso, remendo, investida, sobrecarga, rajada,
                chama, atordoar, acido, purificar, estilhacos, explosao, rede, estimulante, sincronia,
                defender, cura_area }
enum ENEMY_ID { besta, saqueador, sentinela, rato, guarda, colosso }
enum CLASSE { sobrevivente, soldado, mutante, maquina, civil, count }
enum COMBAT_FASE { skill, alvo, resolver, fim }
enum COMBAT_RES { nenhum, vitoria, derrota, tempo }
enum FIM_RUN { retorno, trilha, tempo, derrota }
enum UPG_EFEITO { tempo, retorno, contornar, stat, skill, unico, basico, custo_evento, acampamento, membro_inicial }
enum MISSAO_TIPO { exploracao, escolta, entrega, combate, unica }
enum PREP_TELA { menu, upgrades, dialogo, missoes }

// Mapeamento dos frames dos sprites de corpo e cabeça
enum POSE { idle = 0, atq_basico = 1, dano = 2, habilidade = 3 }

// mapa da trilha
enum AREA { ini_1, ini_2, ini_3, ent_12, ent_23, ent_31, av_12, av_23, av_31, meio, count }

// cutscenes e tutoriais
enum CUT { intro, morte, final_1, final_2, final_3, final_4,
           tut_preparacao, tut_upgrades, tut_missoes, tut_expedicao, tut_evento, tut_diplomacia,
           tut_combate, tut_escolta, tut_entrega, tut_passagem, count }

// ids usados para animar o hover de cada elemento
enum HV { opcao = 0, avancar = 4, retorno = 5, acampar = 6, skill = 7, upg = 10, iniciar = 35, alvo = 36, hub = 44, voltar = 47, missao = 48, count = 68 }

function Skill(_nome, _tempo, _base, _stat, _tipo) constructor {
    nome = _nome;
    tempo = _tempo;
    base = _base;
    stat = _stat;
    tipo = _tipo;

    cat = SKILL_CAT.basico;
    cd_max = 0;
    cd = 0;
    alcance = ALCANCE.unico;
    particula = noone;
    efeito = -1;
    ef_dur = 0;
    ef_val = 0;

    icone = noone;
    icone_sub = 0;
}

function Personagem(_nome) constructor {
    nome = _nome;
    stats = array_create(STAT.count, 3);
    stat_mods = array_create(STAT.count, 0);
    skills = [];
    max_skills = 3;
    hp = 1;
    hp_vis = 1;
    flash = 0;

    status = [];
    pula = false;
    defendendo = false;

    classe = CLASSE.civil;
    faccao = CARD_ORIGIN.neutral;
    importante = false;
    spr_head = noone;
    spr_body = noone;
    spr_overworld = noone;
    pose = POSE.idle;
    cor = c_white;
    alpha = 1;
}

function Card() constructor {
    name = "Sem Nome";
    description = "Sem Descrição";
    origin = CARD_ORIGIN.neutral;
    tipo = CARD_TIPO.evento;
    sprite_interacao = noone;

    options = [];
    recompensa = RECOMPENSA.recurso;
    recompensa_valor = 2;
    recompensa_stat = STAT.forca;
    custo_tempo = 4;            // Custo fixo inicial elevado
    fail_tempo = 3;             // Tempo extra consumido em caso de falha
    inimigos = [];
    aliado_nome = "Aliado";

    missao_f = -1;
    missao_i = -1;
    ponto_fixo = false;
}

function Upgrade(_nome, _desc, _custo, _efeito, _alvo, _valor, _pai, _col, _lin) constructor {
    nome = _nome;
    desc = _desc;
    custo = _custo;
    efeito = _efeito;
    alvo = _alvo;
    valor = _valor;
    pai = _pai;                // Índice do upgrade pai no array (-1 = raiz)
    coluna = _col;             // Coluna na grelha da árvore
    linha = _lin;               // Linha na grelha da árvore
    faccao = -1;
}

function Missao(_nome, _desc, _tipo, _nivel) constructor {
    nome = _nome;
    desc = _desc;
    tipo = _tipo;
    nivel_alvo = _nivel;
    area = -1;
    concluida = false;
    recompensa = 3;
    npc_nome = "";
    carga_nome = "";
    inimigos = [];
    meta = 0;
    progresso = 0;
}