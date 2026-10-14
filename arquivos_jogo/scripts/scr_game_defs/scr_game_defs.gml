// ================= CONSTANTES =================
#macro TOTAL_FACCOES 4      // 3 jogáveis + 1 neutra (lilás)
#macro MAX_GRUPO 4          // player + até 3 aliados
#macro MAX_INIMIGOS 4
#macro RELACAO_MAX 3
#macro RELACAO_ALIADA 2     // relação mínima para contar como facção aliada
#macro TEMPO_CONTA_INIMIGO true   // false = só as ações do jogador contam no tempo da rodada

enum GAME_STATE { expedition, card, combat, run_end, preparacao }   // run_end não é mais usado
enum FACTION { faction_1, faction_2, faction_3, count }
enum CARD_ORIGIN { neutral, faction_1, faction_2, faction_3, faction_4, count }
enum CARD_TIPO { evento, hostil, amigavel, posto, missao }
enum RECOMPENSA { recurso, cura, stat, aliado, relacao }
enum STAT { vitalidade, forca, imaginacao, tecnica, sorte, carisma, count }
enum SKILL_TIPO { dano, cura, restaurar, buff, debuff, recarga }
enum SKILL_CAT { basico, skill, missao }
enum ALCANCE { unico, adjacente, global }
enum STATUS { queimadura, atordoamento, corrosao, lentidao, celeridade, count }
enum SKILL_ID { golpe, pancada, mordida, disparo, tiro, improviso, remendo, investida, sobrecarga, rajada,
                chama, atordoar, acido, purificar, estilhacos, explosao, rede, estimulante, sincronia }
enum ENEMY_ID { besta, saqueador, sentinela, rato, guarda, colosso }
enum CLASSE { sobrevivente, soldado, mutante, maquina, civil, count }
enum COMBAT_FASE { skill, alvo, resolver, fim }
enum COMBAT_RES { nenhum, vitoria, derrota, tempo }
enum FIM_RUN { retorno, trilha, tempo, derrota }
enum UPG_EFEITO { tempo, retorno, contornar, stat, skill, unico, basico }
enum MISSAO_TIPO { exploracao, escolta, entrega, combate, unica }
enum PREP_TELA { menu, upgrades, dialogo, missoes }

// NOVO: mapa da trilha (ini_1..3 têm o mesmo índice de FACTION)
enum AREA { ini_1, ini_2, ini_3, ent_12, ent_23, ent_31, av_12, av_23, av_31, meio, count }

// NOVO: cutscenes (do intro aos finais) e tutoriais (a partir de tut_preparacao)
enum CUT { intro, morte, final_1, final_2, final_3, final_4,
           tut_preparacao, tut_upgrades, tut_missoes, tut_expedicao, tut_evento, tut_diplomacia,
           tut_combate, tut_escolta, tut_entrega, tut_passagem, count }

// ids usados para animar o hover de cada elemento
enum HV { opcao = 0, avancar = 4, retorno = 5, skill = 6, upg = 9, iniciar = 25, alvo = 26, hub = 34, voltar = 37, missao = 38, count = 58 }

function Skill(_nome, _tempo, _base, _stat, _tipo) constructor {
    nome = _nome;
    tempo = _tempo;
    base = _base;
    stat = _stat;
    tipo = _tipo;

    cat = SKILL_CAT.basico;     // basico (sem recarga), skill (com recarga) ou missao (não faz nada em combate)
    cd_max = 0;                 // turnos de recarga depois de usar
    cd = 0;                     // recarga restante
    alcance = ALCANCE.unico;
    particula = noone;          // sprite de partícula desenhado sobre o alvo (noone = nada)
    efeito = -1;                // STATUS aplicado no alvo (-1 = nenhum)
    ef_dur = 0;
    ef_val = 0;
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

    status = [];                // lista de { ef, dur, val, acc }
    pula = false;               // true = perde o turno desta rodada (atordoado)

    // visual
    classe = CLASSE.civil;
    faccao = CARD_ORIGIN.neutral;
    importante = false;
    spr_head = noone;
    spr_body = noone;
    spr_overworld = noone;
    pose = 0;
    cor = c_white;
}

function Card() constructor {
    name = "Sem Nome";
    description = "Sem Descrição";
    origin = CARD_ORIGIN.neutral;
    tipo = CARD_TIPO.evento;
    sprite_interacao = noone;   // sprite de cenário (se noone, o evento usa um personagem aleatório)

    options = [];
    recompensa = RECOMPENSA.recurso;
    recompensa_valor = 2;
    recompensa_stat = STAT.forca;
    fail_tempo = 3;
    inimigos = [];
    aliado_nome = "Aliado";

    missao_f = -1;          // índice da facção dona da missão (-1 = não é carta de missão)
    missao_i = -1;          // índice da missão
    ponto_fixo = false;     // ponto fixo hostil de outra facção (conta para dominação)
}

function Upgrade(_nome, _desc, _custo, _efeito, _alvo, _valor) constructor {
    nome = _nome;
    desc = _desc;
    custo = _custo;
    efeito = _efeito;
    alvo = _alvo;
    valor = _valor;
    faccao = -1;            // -1 = todas as facções; senão só aquela FACTION
}

function Missao(_nome, _desc, _tipo, _nivel) constructor {
    nome = _nome;
    desc = _desc;
    tipo = _tipo;
    nivel_alvo = _nivel;    // nível da área onde o evento fixo aparece (-1 = sem evento)
    area = -1;              // NOVO: AREA onde o evento aparece (-1 = nenhuma)
    concluida = false;
    recompensa = 3;         // recursos ao concluir (dentro da run)
    npc_nome = "";          // escolta
    carga_nome = "";        // entrega
    inimigos = [];          // combate
    meta = 0;               // missão única: valor para concluir
    progresso = 0;
}