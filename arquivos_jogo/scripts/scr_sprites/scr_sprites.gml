// ================= SPRITES / VISUAL DOS PERSONAGENS =================

// Cria as listas de sprites. Chamar UMA vez no Create do obj_game.
////scr_sprites (ou dentro de scr_draw)

// Cria as listas de sprites. Chamar UMA vez no Create do obj_game.
function criar_biblioteca_sprites() {
    // ------------------------------------------------------------------------
    // CABEÇAS POR FACÇÃO
    // ------------------------------------------------------------------------
    // lib_cabecas[origem] = lista de sprites de cabeça daquela facção
    lib_cabecas = array_create(CARD_ORIGIN.count);

    // Neutro / Padrão (usa misturado ou a primeira facção como fallback)
    lib_cabecas[CARD_ORIGIN.neutral] = [
        spr_bluehead_1, spr_redhead_1, spr_tealhead_1
    ];

    // Facção 1 (Vermelho): redhead 1 a 5
    lib_cabecas[CARD_ORIGIN.faction_1] = [
        spr_redhead_1, spr_redhead_2, spr_redhead_3, spr_redhead_4, spr_redhead_5
    ];

    // Facção 2 (Azul-esverdeado / Teal): tealhead 1 a 5
    lib_cabecas[CARD_ORIGIN.faction_2] = [
        spr_tealhead_1, spr_tealhead_2, spr_tealhead_3, spr_tealhead_4, spr_tealhead_5
    ];

    // Facção 3 (Azul / Blue): bluehead 1 a 5
    lib_cabecas[CARD_ORIGIN.faction_3] = [
        spr_bluehead_1, spr_bluehead_2, spr_bluehead_3, spr_bluehead_4, spr_bluehead_5
    ];

    // Facção 4 (Lilás): usa os blueheads como fallback/padrão
    lib_cabecas[CARD_ORIGIN.faction_4] = [
        spr_bluehead_1, spr_bluehead_2, spr_bluehead_3, spr_bluehead_4, spr_bluehead_5
    ];


    // ------------------------------------------------------------------------
    // CORPOS POR CLASSE
    // ------------------------------------------------------------------------
    // lib_corpos[classe] = sprite com 4 subimagens (idle, atq_basico, dano, habilidade)
    lib_corpos = array_create(CLASSE.count);

    lib_corpos[CLASSE.sobrevivente] = spr_shielder;   // Exemplo: sobrevivente usa shielder
    lib_corpos[CLASSE.soldado]      = spr_shielder;
    lib_corpos[CLASSE.mutante]      = spr_lunatic;
    lib_corpos[CLASSE.maquina]      = spr_acolyte;
    lib_corpos[CLASSE.civil]        = spr_ministrel;


    // ------------------------------------------------------------------------
    // PLAYER E LÍDERES
    // ------------------------------------------------------------------------
    // Corpos únicos/fixos do jogador por facção jogável
    lib_player = array_create(FACTION.count);
    lib_player[FACTION.faction_1] = spr_shielder;
    lib_player[FACTION.faction_2] = spr_acolyte;
    lib_player[FACTION.faction_3] = spr_ministrel;

    // Líderes (sprite overworld no hub)
    lib_lideres = array_create(FACTION.count);
    lib_lideres[FACTION.faction_1] = spr_shielder;
    lib_lideres[FACTION.faction_2] = spr_acolyte;
    lib_lideres[FACTION.faction_3] = spr_ministrel;
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
        case CARD_ORIGIN.faction_1:   // vermelho (mais desaturado/suave)
            h = irandom_range(-8, 8);
            s = irandom_range(60, 110);   // reduzido de 170-255 para esbranquiçar
            v = irandom_range(210, 255);  // brilho alto
            break;
        case CARD_ORIGIN.faction_2:   // azul-esverdeado / teal
            h = irandom_range(116, 132);
            s = irandom_range(50, 100);   // reduzido de 140-220
            v = irandom_range(200, 250);
            break;
        case CARD_ORIGIN.faction_3:   // azul-marinho
            h = irandom_range(160, 172);
            s = irandom_range(60, 110);   // reduzido de 170-255
            v = irandom_range(190, 240);
            break;
        case CARD_ORIGIN.faction_4:   // lilás
            h = irandom_range(188, 204);
            s = irandom_range(40, 80);    // tom pastel leve
            v = irandom_range(220, 255);
            break;
        default:                      // neutro (quase branco/cinza claro)
            h = irandom_range(188, 204);
            s = irandom_range(5, 25);
            v = irandom_range(235, 255);
            break;
    }

    h = (h + 256) mod 256;
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