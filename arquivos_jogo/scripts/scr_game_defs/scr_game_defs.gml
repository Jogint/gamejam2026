// ================= CONSTANTES =================
#macro TOTAL_FACCOES 4      // 3 jogáveis + 1 neutra (lilás)
#macro MAX_GRUPO 4          // player + até 3 aliados
#macro MAX_INIMIGOS 4
#macro RELACAO_MAX 3
#macro RELACAO_ALIADA 2     // relação mínima para contar como facção aliada

enum GAME_STATE { expedition, card, combat, run_end, preparacao }
enum FACTION { faction_1, faction_2, faction_3, count }
enum CARD_ORIGIN { neutral, faction_1, faction_2, faction_3, faction_4, count }
enum CARD_TIPO { evento, hostil, amigavel, posto, missao }                 // ALTERADO: missao
enum RECOMPENSA { recurso, cura, stat, aliado, relacao }                   // ALTERADO: relacao
enum STAT { vitalidade, forca, imaginacao, tecnica, sorte, carisma, count }
enum SKILL_TIPO { dano, cura, carga }                                      // ALTERADO: carga
enum SKILL_ID { golpe, tiro, improviso, remendo, mordida, investida, disparo, sobrecarga, rajada }
enum ENEMY_ID { besta, saqueador, sentinela, rato, guarda, colosso }       // ALTERADO: colosso
enum CLASSE { sobrevivente, soldado, mutante, maquina, civil, count }
enum COMBAT_FASE { skill, alvo, resolver, fim }
enum COMBAT_RES { nenhum, vitoria, derrota, tempo }
enum FIM_RUN { retorno, trilha, tempo, derrota }
enum UPG_EFEITO { tempo, retorno, contornar, stat, skill, unico }          // ALTERADO: unico
enum MISSAO_TIPO { exploracao, escolta, entrega, combate, unica }          // NOVO
enum PREP_TELA { menu, upgrades, dialogo, missoes }                        // NOVO

// ids usados para animar o hover de cada elemento
// ALTERADO: alvo agora tem 8 ids (inimigos 0..3, grupo 4..7); novos ids do hub e das missões
enum HV { opcao = 0, avancar = 4, retorno = 5, skill = 6, upg = 9, iniciar = 19, alvo = 20, hub = 28, voltar = 31, missao = 32, count = 52 }

function Skill(_nome, _tempo, _base, _stat, _tipo) constructor {
    nome = _nome;
    tempo = _tempo;
    base = _base;
    stat = _stat;
    tipo = _tipo;
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

    // NOVO
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
    faccao = -1;            // NOVO: -1 = todas as facções; senão só aquela FACTION
}

// NOVO
function Missao(_nome, _desc, _tipo, _nivel) constructor {
    nome = _nome;
    desc = _desc;
    tipo = _tipo;
    nivel_alvo = _nivel;    // nível da trilha onde o evento fixo aparece (-1 = sem evento)
    concluida = false;
    recompensa = 3;         // recursos ao concluir (dentro da run)
    npc_nome = "";          // escolta
    carga_nome = "";        // entrega
    inimigos = [];          // combate
    meta = 0;               // missão única: valor para concluir
    progresso = 0;
}