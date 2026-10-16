mx = device_mouse_x_to_gui(0);
my = device_mouse_y_to_gui(0);
var clicou = mouse_check_button_pressed(mb_left);
var clicou_dir = mouse_check_button_pressed(mb_right);

atualizar_animacoes();

// NOVO: tela final
if (fim_jogo) {
    if (clicou) game_restart();
    exit;
}

// menu inicial
if (menu_ativo) {
    step_menu(clicou);
    exit;
}

// NOVO: cutscene/tutorial ativo trava o resto do jogo
if (cs_ativa) {
    hover = -1;
    step_cutscene(clicou);
    exit;
}

// NOVO: um final foi desbloqueado (missão única concluída)
if (final_pendente != -1) {
    var fp = final_pendente;
    final_pendente = -1;
    cs_fila = [];
    cutscene_tocar(CUT.final_1 + fp);
    exit;
}

calcular_hover();

switch (estado) {
    case GAME_STATE.expedition:
        if (clicou) step_expedicao();
        break;
    case GAME_STATE.card:
        if (clicou) step_card();
        break;
    case GAME_STATE.combat:
        step_combate(clicou, clicou_dir);
        break;
    case GAME_STATE.preparacao:
        if (clicou) step_preparacao();
        break;
}