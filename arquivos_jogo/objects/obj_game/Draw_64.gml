draw_set_font(fnt_main);
draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(0, 0, 1280, 720, false);

if (estado == GAME_STATE.preparacao) {
    draw_preparacao();
    exit;
}

draw_paineis();

switch (estado) {
    case GAME_STATE.expedition: draw_expedicao(); break;
    case GAME_STATE.card:       draw_card(); break;
    case GAME_STATE.combat:     draw_combate(); break;
}

draw_hud();
draw_popups();

if (estado == GAME_STATE.run_end) draw_fim_run();

draw_set_color(c_white);