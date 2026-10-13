enum GAME_STATE { expedition, card, combat, run_end, preparacao }
enum FACTION { faction_1, faction_2, faction_3, count }
enum CARD_ORIGIN { neutral, faction_1, faction_2, faction_3, faction_4, count }   // ALTERADO: count
enum CARD_TIPO { evento, hostil, amigavel, posto }
enum RECOMPENSA { recurso, cura, stat, aliado }
enum STAT { vitalidade, forca, imaginacao, tecnica, sorte, carisma, count }
enum SKILL_TIPO { dano, cura }
enum SKILL_ID { golpe, tiro, improviso, remendo, mordida, investida, disparo, sobrecarga, rajada }
enum ENEMY_ID { besta, saqueador, sentinela, rato, guarda }
enum CLASSE { sobrevivente, soldado, mutante, maquina, civil, count }   // NOVO
enum COMBAT_FASE { skill, alvo, resolver, fim }
enum COMBAT_RES { nenhum, vitoria, derrota, tempo }
enum FIM_RUN { retorno, trilha, tempo, derrota }
enum UPG_EFEITO { tempo, retorno, contornar, stat, skill }

// ids usados para animar o hover de cada elemento
enum HV { opcao = 0, avancar = 4, retorno = 5, skill = 6, upg = 9, iniciar = 19, alvo = 20, count = 24 }

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

    // visual                                 // NOVO
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
}

function Upgrade(_nome, _desc, _custo, _efeito, _alvo, _valor) constructor {
    nome = _nome;
    desc = _desc;
    custo = _custo;
    efeito = _efeito;
    alvo = _alvo;
    valor = _valor;
}