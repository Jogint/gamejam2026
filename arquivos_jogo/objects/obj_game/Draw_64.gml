//mapa
draw_set_color(c_gray);
for (var i = 0; i < map_rows; i++) {
    for (var j = 0; j < map_cols; j++) {
        var tx = map_x + j * tile_size;
        var ty = map_y + i * tile_size;
        draw_rectangle(tx, ty, tx + tile_size - 2, ty + tile_size - 2, true);
    }
}

//base
var bx = map_x + base_col * tile_size;
var by = map_y + base_lin * tile_size;
draw_set_color(c_yellow);
draw_text(bx + 6, by + 6, "BASE");

//player
var px = map_x + player_col * tile_size + tile_size / 2;
var py = map_y + player_lin * tile_size + tile_size / 2;
draw_set_color(c_lime);
draw_circle(px, py, 12, false);

//carta atual
if (carta_atual != undefined && card_x < card_x_off) {
    var card_r = card_x + card_w;
    var card_b = card_y + card_h;

    draw_set_color(c_black);
    draw_rectangle(card_x, card_y, card_r, card_b, false);
    draw_set_color(origem_cores[carta_atual.origin]);
    draw_rectangle(card_x, card_y, card_r, card_b, true);

    draw_set_color(c_white);
    draw_text(card_x + opt_margin, card_y + 20, carta_atual.name);
    draw_text_ext(card_x + opt_margin, card_y + 60, carta_atual.description, 24, card_w - opt_margin * 2);

    if (!carta_resolvida) {
        for (var i = 0; i < CARD_CHOICE.count; i++) {
            var b_top = card_y + opt_top + i * opt_gap;
            var b_bot = b_top + opt_h;
            draw_rectangle(card_x + opt_margin, b_top, card_r - opt_margin, b_bot, true);

            var texto_opt = "";
            if (i != CARD_CHOICE.skip) {
                var opt_card = carta_atual.options[i];
                var pct = floor(get_chance_sucesso(opt_card) * 100);
                texto_opt = stat_nomes[opt_card.stat] + " " + string(opt_card.required) 
                          + " (voce: " + string(get_stat_total(opt_card.stat)) 
                          + " - " + string(pct) + "%)";
            } else {
                texto_opt = "Contornar (custa " + string(carta_atual.time) + " de tempo)";
            }
            draw_text(card_x + opt_margin + 10, b_top + 10, texto_opt);
        }
    } else {
        draw_text_ext(card_x + opt_margin, card_y + opt_top, card_msg, 24, card_w - opt_margin * 2);
        draw_text(card_x + opt_margin, card_y + card_h - 40, "Clique para continuar");
    }
    draw_set_color(c_white);
}

//HUD
draw_set_color(c_dkgray);
draw_rectangle(0, hud_y, 1280, 720, false);
draw_set_color(c_white);

for (var i = 0; i < STAT.count; i++) {
    var txt_stat = stat_nomes[i] + ": " + string(stats[i]);
    var bonus = stat_mods[i];
    if (bonus != 0) {
        var s = bonus > 0 ? "+" : "";
        txt_stat += " (" + s + string(bonus) + ")";
    }
    draw_text(stats_x, stats_y + i * stats_gap, txt_stat);
}

for (var j = 0; j < 3; j++) {
    var sx = skills_x + j * skills_gap;
    draw_text(sx, skills_y, skill_nomes[j]);
    draw_text(sx, skills_y + 30, "tempo: " + string(skill_custos[j]));
}

draw_text(info_x, stats_y, "Tempo: " + string(tempo));
draw_text(info_x, stats_y + 30, "Recurso: " + string(recurso));

//botão voltar
var custo_v = calc_custo_volta();
draw_set_color(tempo >= custo_v ? c_white : c_red);
draw_rectangle(btn_voltar[0], btn_voltar[1], btn_voltar[2], btn_voltar[3], true);
draw_text(btn_voltar[0] + 10, btn_voltar[1] + 10, "Voltar (custo " + string(custo_v) + ")");
draw_set_color(c_white);

// tela de fim
if (estado == GAME_STATE.run_end) {
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 1280, 720, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(640, 300, msg_fim);
    draw_text(640, 340, "Clique para proxima faccao");
    draw_set_halign(fa_left);
}