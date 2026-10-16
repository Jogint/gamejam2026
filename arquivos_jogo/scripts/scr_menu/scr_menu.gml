// ================= MENU INICIAL =================
#macro MENU_BTNS 3

function box_menu_logo() { return [340, 40, 940, 340]; }
function box_menu_btn(_i) { return [460, 380 + _i * 75, 820, 440 + _i * 75]; }

function menu_iniciar_jogo() {
    menu_ativo = false;
    cutscene_tocar(CUT.intro);
    cutscene_tocar(CUT.tut_preparacao);
}

function step_menu(_clicou) {
    var h = -1;
    if (menu_tela == 0) {
        for (var i = 0; i < MENU_BTNS; i++) {
            if (util_in(box_menu_btn(i))) h = i;
        }
    } else if (util_in(box_voltar())) {
        h = MENU_BTNS;   // o "Voltar" dos créditos usa o último slot de animação
    }

    for (var k = 0; k <= MENU_BTNS; k++) {
        menu_anim[k] = lerp(menu_anim[k], (h == k) ? 1 : 0, 0.25);
    }

    if (!_clicou) return;

    if (menu_tela == 1) {
        if (h == MENU_BTNS) menu_tela = 0;
        return;
    }

    switch (h) {
        case 0: menu_iniciar_jogo(); break;
        case 1: menu_tela = 1; break;
        case 2: game_end(); break;
    }
}

function draw_menu_botao(_b, _txt, _cor, _cor_txt, _h) {
    draw_set_color(_cor);
    draw_rectangle(_b[0], _b[1], _b[2], _b[3], false);

    if (_h > 0.01) {
        draw_set_color(merge_color(_cor, c_white, 0.3));
        draw_rectangle(_b[0], _b[1], _b[0] + (_b[2] - _b[0]) * _h, _b[3], false);
    }

    draw_set_color(c_white);
    draw_rectangle(_b[0], _b[1], _b[2], _b[3], true);

    draw_set_color(_cor_txt);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text((_b[0] + _b[2]) / 2, (_b[1] + _b[3]) / 2, _txt);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function draw_menu_fundo() {
    // blocos cinza flutuando devagar (sem estado: tudo calculado pelo tempo)
    for (var i = 0; i < 18; i++) {
        var sz = 24 + (i mod 4) * 14;
        var bx = ((i * 211) + current_time * (0.012 + (i mod 3) * 0.008)) mod 1380 - 50;
        var by = ((i * 97) mod 620) + 30;
        draw_set_color(merge_color(c_black, c_dkgray, 0.3 + 0.15 * (i mod 3)));
        draw_rectangle(bx, by, bx + sz, by + sz, false);
    }
}

function draw_menu_logo() {
    static spr = asset_get_index("spr_logo");
    var l = box_menu_logo();
    var cx = (l[0] + l[2]) / 2;
    var cy = (l[1] + l[3]) / 2;

    if (sprite_exists(spr)) {
        draw_sprite(spr, 0, cx, cy);   // origem do sprite em Middle Centre
        return;
    }

    // placeholder
    draw_set_color(c_black);
    draw_rectangle(l[0], l[1], l[2], l[3], false);
    draw_set_color(c_gray);
    draw_rectangle(l[0], l[1], l[2], l[3], true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(cx, cy, "[ LOGO ]");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function draw_menu_creditos() {
    draw_set_halign(fa_center);
    draw_set_color(c_yellow);
    draw_text(640, 90, "CRÉDITOS");

    draw_set_color(c_dkgray);
    draw_rectangle(340, 150, 940, 560, false);
    draw_set_color(c_white);
    draw_rectangle(340, 150, 940, 560, true);

    // troque pelos nomes e funções da equipe
    var linhas = [
        "Kaue Ferreira Motta  -  Programação",
        "Leandro Pinho Gonçalves -  Arte",
        "Lyam Santos Peres  -  Programação",
        "Rafael Oliveira dos Santos  -  Programação"
    ];
    for (var i = 0; i < array_length(linhas); i++) {
        draw_set_color(c_white);
        draw_text(640, 200 + i * 55, linhas[i]);
    }

    draw_set_color(c_gray);
    draw_text(640, 500, "Feito em GameMaker");
    draw_set_halign(fa_left);

    draw_menu_botao(box_voltar(), "Voltar", c_dkgray, c_white, menu_anim[MENU_BTNS]);
}

function draw_menu() {
    draw_menu_fundo();

    if (menu_tela == 1) {
        draw_menu_creditos();
        return;
    }

    draw_menu_logo();

    draw_menu_botao(box_menu_btn(0), "Jogar",    c_lime,   c_black, menu_anim[0]);
    draw_menu_botao(box_menu_btn(1), "Créditos", c_dkgray, c_white, menu_anim[1]);
    draw_menu_botao(box_menu_btn(2), "Sair",     c_maroon, c_white, menu_anim[2]);

    draw_set_color(c_gray);
    draw_set_halign(fa_right);
    draw_text(1250, 690, "v0.1");
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}