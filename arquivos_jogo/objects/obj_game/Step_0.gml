mx = device_mouse_x_to_gui(0);
my = device_mouse_y_to_gui(0);
var clicou = mouse_check_button_pressed(mb_left);
var clicou_dir = mouse_check_button_pressed(mb_right);

atualizar_animacoes();
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
    case GAME_STATE.run_end:
        if (clicou) acao_reencarnar();
        break;
    case GAME_STATE.preparacao:
        if (clicou) step_preparacao();
        break;
}