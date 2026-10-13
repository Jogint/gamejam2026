// ================= SPRITES / VISUAL DOS PERSONAGENS =================

// Cria as listas de sprites. Chamar UMA vez no Create do obj_game.
function criar_biblioteca_sprites() {
    // cabeças: lib_cabecas[origem] = lista de cabeças daquela facção
    lib_cabecas = array_create(CARD_ORIGIN.count);
    for (var o = 0; o < CARD_ORIGIN.count; o++) {
        lib_cabecas[o] = [spr_cabeca_base, spr_cabeca_base];   // depois: algumas cabeças diferentes por facção
    }

    // corpos: lib_corpos[classe] = sprite com 4 poses (4 subimagens)
    lib_corpos = array_create(CLASSE.count, spr_corpo_base);

    // player: um sprite fixo por facção jogável
    lib_player = array_create(FACTION.count, spr_corpo_base);

    // NOVO: líderes (sprite overworld) por facção jogável
    lib_lideres = array_create(FACTION.count, spr_lider_base);
}

// FACTION (0..2) -> CARD_ORIGIN (1..3)
function origem_da_faccao(_f) {
    return _f + 1;
}

function classe_tem_cabeca(_c) {
    return (_c != CLASSE.mutante && _c != CLASSE.maquina);
}

// sorteia uma cor dentro do range da facção (h, s, v de 0 a 255)
function cor_da_faccao(_f) {
    var h = 0;
    var s = 0;
    var v = 255;

    switch (_f) {
        case CARD_ORIGIN.faction_1:   // vermelho
            h = irandom_range(-8, 8);
            s = irandom_range(170, 255);
            v = irandom_range(180, 240);
            break;
        case CARD_ORIGIN.faction_2:   // azul-esverdeado
            h = irandom_range(116, 132);
            s = irandom_range(140, 220);
            v = irandom_range(160, 230);
            break;
        case CARD_ORIGIN.faction_3:   // azul-marinho
            h = irandom_range(160, 172);
            s = irandom_range(170, 255);
            v = irandom_range(130, 190);
            break;
        case CARD_ORIGIN.faction_4:   // lilás
            h = irandom_range(188, 204);
            s = irandom_range(90, 150);
            v = irandom_range(190, 255);
            break;
        default:                      // lilás esbranquecido (neutro)
            h = irandom_range(188, 204);
            s = irandom_range(15, 45);
            v = irandom_range(235, 255);
            break;
    }

    h = (h + 256) mod 256;   // o vermelho passa de 0 para baixo
    return make_color_hsv(h, s, v);
}

// monta o visual de um personagem NÃO importante (partes em branco + cor da facção)
function visual_aleatorio(_p, _classe, _faccao) {
    _p.classe = _classe;
    _p.faccao = _faccao;
    _p.importante = false;

    _p.spr_body = lib_corpos[_classe];
    _p.pose = irandom(sprite_get_number(_p.spr_body) - 1);

    _p.spr_head = noone;
    if (classe_tem_cabeca(_classe)) {
        var lista = lib_cabecas[_faccao];
        _p.spr_head = lista[irandom(array_length(lista) - 1)];
    }

    _p.spr_overworld = noone;
    _p.cor = cor_da_faccao(_faccao);
}

// visual de um personagem IMPORTANTE (sprites já completos e coloridos, sem blend)
function visual_fixo(_p, _classe, _faccao, _body, _head) {
    _p.classe = _classe;
    _p.faccao = _faccao;
    _p.importante = true;
    _p.spr_body = _body;
    _p.spr_head = _head;
    _p.spr_overworld = noone;
    _p.pose = 0;
    _p.cor = c_white;
}

// personagem aleatório só para aparecer em eventos
function figurante_novo(_origem) {
    var f = new Personagem("Figurante");
    visual_aleatorio(f, CLASSE.civil, _origem);
    return f;
}

// NOVO: líder de uma facção jogável (importante, com sprite overworld)
function lider_novo(_f) {
    var l = new Personagem("Líder da Facção " + string(_f + 1));
    visual_fixo(l, CLASSE.soldado, origem_da_faccao(_f), lib_corpos[CLASSE.soldado], noone);
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