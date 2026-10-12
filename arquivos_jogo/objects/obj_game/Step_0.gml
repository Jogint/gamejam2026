card_x = lerp(card_x, card_dest_x, card_spd);
if (abs(card_x - card_dest_x) < 1) card_x = card_dest_x;

if (mouse_check_button_pressed(mb_left)) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    switch (estado) {
        case GAME_STATE.map:
            if (clicou_box(mx, my, btn_voltar[0], btn_voltar[1], btn_voltar[2], btn_voltar[3])) {
                voltar_base();
            } else {
                var cl = floor((mx - map_x) / tile_size);
                var ln_clicada = floor((my - map_y) / tile_size);

                if (cl >= 0 && cl < map_cols && ln_clicada >= 0 && ln_clicada < map_rows) {
                    if (abs(cl - player_col) + abs(ln_clicada - player_lin) == 1) {
                        mover_para(cl, ln_clicada);
                    }
                }
            }
            break;

        case GAME_STATE.card:
            if (card_x == card_dest_x) {
                if (!carta_resolvida) {
                    for (var i = 0; i < CARD_CHOICE.count; i++) {
                        var b_top = card_y + opt_top + i * opt_gap;
                        if (clicou_box(mx, my, card_x + opt_margin, b_top, card_x + card_w - opt_margin, b_top + opt_h)) {
                            resolver_escolha(i);
                        }
                    }
                } else {
                    fechar_carta();
                }
            }
            break;

        case GAME_STATE.run_end:
            reencarnar();
            break;
    }
}