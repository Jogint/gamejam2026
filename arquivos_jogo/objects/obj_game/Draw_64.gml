draw_set_font(fnt_main);
draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(0, 0, 1280, 720, false);

if (fim_jogo) {
    draw_fim_jogo();
    exit;
}

if (menu_ativo) {
    draw_menu();
    draw_set_color(c_white);
    exit;
}

// cutscene de história: a cena desliza para baixo.
// tutorial: a cena fica parada, para o destaque aparecer em cima da HUD.
if (cs_ativa && !cutscene_eh_tutorial(cs_id)) {
    matrix_set(matrix_world, matrix_build(0, cs_anim * 720, 0, 0, 0, 0, 1, 1, 1));
}

if (estado == GAME_STATE.preparacao) {
    draw_preparacao();
} else {
	draw_background();
    draw_paineis();

    switch (estado) {
        case GAME_STATE.expedition: draw_expedicao(); break;
        case GAME_STATE.card:       draw_card(); break;
        case GAME_STATE.combat:     draw_combate(); break;
    }

    draw_hud();
    draw_popups();
    draw_particulas();
}

matrix_set(matrix_world, matrix_build_identity());
if (cs_ativa) draw_cutscene();

draw_set_color(c_white);