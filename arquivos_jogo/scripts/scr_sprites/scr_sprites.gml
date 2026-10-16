// ================= SPRITES / VISUAL DOS PERSONAGENS =================

// Busca um sprite pelo nome. Avisa no console se não existir.
function sprite_por_nome(_nome) {
    var s = asset_get_index(_nome);
    if (s == -1 || !sprite_exists(s)) {
        show_debug_message("Sprite não encontrado: " + _nome);
        return noone;
    }
    return s;
}

// Cria as listas de sprites. Chamar UMA vez no Create do obj_game.
function criar_biblioteca_sprites() {
    // índice = CARD_ORIGIN (1 = facção 1, 2 = facção 2, 3 = facção 3)
    var cores = ["", "blue", "red", "teal"];   // F1 azul, F2 vermelha, F3 verde

    // nomes dos sprites na mesma ordem do enum CLASSE
    var tipos = ["shielder", "miner", "ministrel", "lunatic", "acolyte"];

    // ------------------------------------------------------------------------
    // CABEÇAS: lib_cabecas[origem] = lista com as 15 cabeças da cor
    // ------------------------------------------------------------------------
    lib_cabecas = array_create(CARD_ORIGIN.count, noone);
    for (var o = 1; o <= 3; o++) {
        var lista = [];
        for (var n = 1; n <= 15; n++) {
            array_push(lista, sprite_por_nome("spr_" + cores[o] + "head_" + string(n)));
        }
        lib_cabecas[o] = lista;
    }

    // ------------------------------------------------------------------------
    // CORPOS: lib_corpos[classe][origem] (4 subimagens: idle, atq, dano, habilidade)
    // ------------------------------------------------------------------------
    lib_corpos = array_create(CLASSE.count);
    for (var c = 0; c < CLASSE.count; c++) {
        lib_corpos[c] = array_create(CARD_ORIGIN.count, noone);
        for (var o = 1; o <= 3; o++) {
            lib_corpos[c][o] = sprite_por_nome("spr_" + tipos[c] + "_" + cores[o]);
        }
    }

    // ------------------------------------------------------------------------
    // PLAYER E LÍDERES (corpo fixo por facção jogável)
    // ------------------------------------------------------------------------
    lib_player = array_create(FACTION.count);
    lib_player[FACTION.faction_1] = lib_corpos[CLASSE.escudeiro][CARD_ORIGIN.faction_1];
    lib_player[FACTION.faction_2] = lib_corpos[CLASSE.acolito][CARD_ORIGIN.faction_2];
    lib_player[FACTION.faction_3] = lib_corpos[CLASSE.menestrel][CARD_ORIGIN.faction_3];

    lib_lideres = array_create(FACTION.count);
	lib_lideres[FACTION.faction_1] = sprite_por_nome("spr_leader");     // azul
	lib_lideres[FACTION.faction_2] = sprite_por_nome("spr_leader_1");   // vermelho
	lib_lideres[FACTION.faction_3] = sprite_por_nome("spr_leader_2");   // verde
}

// FACTION (0..2) -> CARD_ORIGIN (1..3)
function origem_da_faccao(_f) {
    return _f + 1;
}

// Qual cor de sprite usar para uma origem:
// neutro sorteia uma das 3 cores; facção 4 (lilás) usa azul por enquanto
function origem_visual(_o) {
    if (_o == CARD_ORIGIN.neutral) return irandom_range(1, 3);
    if (_o == CARD_ORIGIN.faction_4) return CARD_ORIGIN.faction_3;
    return _o;
}

// todas as classes usam corpo + cabeça
function classe_tem_cabeca(_c) {
    return true;
}

function nome_da_classe(_c) {
    switch (_c) {
        case CLASSE.escudeiro:  return "Escudeiro";
        case CLASSE.mineirador: return "Mineirador";
        case CLASSE.menestrel:  return "Menestrel";
        case CLASSE.lunatico:   return "Lunático";
        case CLASSE.acolito:    return "Acólito";
    }
    return "???";
}

// monta o visual de um personagem NÃO importante:
// corpo da classe + cabeça sorteada, ambos da cor da facção
function visual_aleatorio(_p, _classe, _faccao) {
    var o = origem_visual(_faccao);

    _p.classe = _classe;
    _p.faccao = _faccao;
    _p.importante = false;

    _p.spr_body = lib_corpos[_classe][o];
    _p.pose = POSE.idle;

    _p.spr_head = noone;
    if (classe_tem_cabeca(_classe)) {
        var lista = lib_cabecas[o];
        _p.spr_head = lista[irandom(array_length(lista) - 1)];
    }

    _p.spr_overworld = noone;
    _p.cor = c_white;
}

// visual de um personagem IMPORTANTE (sprites escolhidos à mão, sem blend)
function visual_fixo(_p, _classe, _faccao, _body, _head) {
    _p.classe = _classe;
    _p.faccao = _faccao;
    _p.importante = true;
    _p.spr_body = _body;
    _p.spr_head = _head;
    _p.spr_overworld = noone;
    _p.pose = POSE.idle;
    _p.cor = c_white;
}

// personagem aleatório só para aparecer em eventos
function figurante_novo(_origem) {
    var f = new Personagem("Figurante");
    visual_aleatorio(f, CLASSE.menestrel, _origem);
    return f;
}

// líder de uma facção jogável (importante, com sprite overworld)
function lider_novo(_f) {
    var o = origem_da_faccao(_f);
    var l = new Personagem("Líder da Facção " + string(_f + 1));
    visual_fixo(l, CLASSE.escudeiro, o, lib_corpos[CLASSE.escudeiro][o], lib_cabecas[o][0]);
    l.spr_overworld = lib_lideres[_f];
    return l;
}

function criar_lideres() {
    var l = [];
    for (var f = 0; f < FACTION.count; f++) {
        array_push(l, lider_novo(f));
    }
    return l;
}

// inimigos usam sempre uma cor diferente da facção do jogador
function origem_inimigo(_o) {
    var meu = origem_da_faccao(faccao_atual);
    var o = (_o == CARD_ORIGIN.faction_4) ? CARD_ORIGIN.faction_3 : _o;
    if (o == CARD_ORIGIN.neutral || o == meu) {
        do { o = irandom_range(1, 3); } until (o != meu);
    }
    return o;
}