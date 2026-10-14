// ================= FUNÇÕES AUXILIARES =================
function tempo_para_relogio(_tempo_atual, _tempo_maximo) {
    var minutos_limite = 360; 
    var minutos_atuais = minutos_limite - max(0, _tempo_atual);
    
    var hora_atual = (minutos_atuais div 60) mod 24;
    var min_atual = minutos_atuais mod 60;

    var str_h = (hora_atual < 10 ? "0" : "") + string(hora_atual);
    var str_m = (min_atual < 10 ? "0" : "") + string(min_atual);

    return str_h + ":" + str_m + " AM";
}

// ================= ÍCONES =================
function draw_icone(_spr, _sub, _x, _y, _tam) {
    var sx = _tam / sprite_get_width(_spr);
    var sy = _tam / sprite_get_height(_spr);
    var n = sprite_get_number(_spr);
    draw_sprite_ext(_spr, _sub mod n, _x + sprite_get_xoffset(_spr) * sx, _y + sprite_get_yoffset(_spr) * sy,
                    sx, sy, 0, c_white, draw_get_alpha());
}

function draw_icone_stat(_stat, _x, _y, _tam) {
    static spr = asset_get_index("spr_icon_stat");
    static cores = [c_red, c_orange, c_purple, c_aqua, c_lime, c_fuchsia];

    if (sprite_exists(spr)) {
        draw_icone(spr, _stat, _x, _y, _tam);
        return;
    }

    var cor_ant = draw_get_color();
    var ha = draw_get_halign();
    var va = draw_get_valign();

    draw_set_color(cores[_stat mod 6]);
    draw_rectangle(_x, _y, _x + _tam - 1, _y + _tam - 1, false);
    draw_set_color(c_white);
    draw_rectangle(_x, _y, _x + _tam - 1, _y + _tam - 1, true);
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_x + _tam / 2, _y + _tam / 2, string_upper(string_char_at(stat_nomes[_stat], 1)));

    draw_set_halign(ha);
    draw_set_valign(va);
    draw_set_color(cor_ant);
}

function draw_icone_skill(_s, _x, _y, _tam) {
    if (sprite_exists(_s.icone)) {
        draw_icone(_s.icone, _s.icone_sub, _x, _y, _tam);
        return;
    }

    var cor_ant = draw_get_color();
    var ha = draw_get_halign();
    var va = draw_get_valign();

    draw_set_color(merge_color(cor_categoria_skill(_s.cat), c_black, 0.5));
    draw_rectangle(_x, _y, _x + _tam - 1, _y + _tam - 1, false);
    draw_set_color(c_white);
    draw_rectangle(_x, _y, _x + _tam - 1, _y + _tam - 1, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_x + _tam / 2, _y + _tam / 2, string_upper(string_char_at(_s.nome, 1)));

    draw_set_halign(ha);
    draw_set_valign(va);
    draw_set_color(cor_ant);
}

function skill_cat_nome(_c) {
    switch (_c) {
        case SKILL_CAT.basico: return "Básica";
        case SKILL_CAT.skill:  return "Habilidade";
        case SKILL_CAT.missao: return "Missão";
    }
    return "";
}

function draw_botao(_b, _txt, _cor, _cor_txt, _hv_id, _ativo) {
    var h = (_hv_id >= 0) ? hover_anim[_hv_id] : 0;

    draw_set_color(_ativo ? _cor : c_dkgray);
    draw_rectangle(_b[0], _b[1], _b[2], _b[3], false);

    if (_ativo && h > 0.01) {
        draw_set_color(merge_color(_cor, c_white, 0.3));
        draw_rectangle(_b[0], _b[1], _b[0] + (_b[2] - _b[0]) * h, _b[3], false);
    }

    draw_set_color(c_white);
    draw_rectangle(_b[0], _b[1], _b[2], _b[3], true);

    draw_set_color(_ativo ? _cor_txt : c_gray);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text((_b[0] + _b[2]) / 2, (_b[1] + _b[3]) / 2, _txt);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function draw_personagem(_p, _x, _y, _esc, _overworld, _flip) {
    var mult_corpo = 0.35;
    var mult_cabeca = 0.25;
    
    var esc_corpo = _esc * mult_corpo;
    var esc_cabeca = _esc * mult_cabeca;

    var vivo = (_p.hp > 0);
    var cor = _p.importante ? c_white : _p.cor;
    
    var xs_corpo = _flip ? -esc_corpo : esc_corpo;
    var xs_cabeca = _flip ? -esc_cabeca : esc_cabeca;

    if (!vivo) {
        cor = merge_color(cor, c_black, 0.6);
        _p.alpha = lerp(_p.alpha, 0, 0.05); 
    } else {
        _p.alpha = lerp(_p.alpha, 1, 0.1);
    }

    if (_p.alpha <= 0.01) return; 

    var alfa_atual = draw_get_alpha() * _p.alpha;

    if (_overworld && _p.spr_overworld != noone) {
        draw_sprite_ext(_p.spr_overworld, 0, _x, _y, xs_corpo, esc_corpo, 0, cor, alfa_atual);
        return;
    }

    var frame_corpo = clamp(_p.pose, 0, 3);
    if (!vivo) frame_corpo = POSE.dano; 

    if (_p.spr_body != noone) {
        var sub_c = frame_corpo mod sprite_get_number(_p.spr_body);
        draw_sprite_ext(_p.spr_body, sub_c, _x, _y, xs_corpo, esc_corpo, 0, cor, alfa_atual);
    }

    if (_p.spr_head != noone) {
        var frame_cabeca = 0;
        if (!vivo || frame_corpo == POSE.dano) {
            frame_cabeca = 1; 
        } else if (frame_corpo == POSE.atq_basico || frame_corpo == POSE.habilidade) {
            frame_cabeca = 2; 
        }
        
        var sub_h = frame_cabeca mod sprite_get_number(_p.spr_head);

        var altura_corpo = sprite_get_height(_p.spr_body);
        var pos_pesc_relativa = 105 - (altura_corpo / 2); 
        var head_y = _y + (pos_pesc_relativa * esc_corpo);

        draw_sprite_ext(_p.spr_head, sub_h, _x, head_y, xs_cabeca, esc_cabeca, 0, cor, alfa_atual);
    }
}

function draw_hp_barra(_x1, _y1, _x2, _y2, _p) {
    var m = p_hp_max(_p);
    var r = clamp(_p.hp_vis / m, 0, 1);

    draw_set_color(c_black);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_color(r > 0.5 ? c_lime : (r > 0.25 ? c_yellow : c_red));
    draw_rectangle(_x1, _y1, _x1 + (_x2 - _x1) * r, _y2, false);
    draw_set_color(c_white);
    draw_rectangle(_x1, _y1, _x2, _y2, true);

    draw_set_halign(fa_center);
    draw_text((_x1 + _x2) / 2, _y2 + 2, string(_p.hp) + " / " + string(m));
    draw_set_halign(fa_left);
}

function draw_slot_personagem(_b, _p, _hv_id, _valido, _flip) {
    var sx = (_p.flash > 0) ? irandom_range(-4, 4) : 0;
    var x1 = _b[0] + sx;
    var y1 = _b[1];
    var x2 = _b[2] + sx;
    var y2 = _b[3];
    var vivo = (_p.hp > 0);
    var h = (_hv_id >= 0) ? hover_anim[_hv_id] : 0;

    draw_set_color(vivo ? c_dkgray : c_black);
    draw_rectangle(x1, y1, x2, y2, false);

    if (h > 0.01 && _valido) {
        draw_set_color(merge_color(c_dkgray, c_white, 0.3));
        draw_rectangle(x1, y1, x1 + (x2 - x1) * h, y2, false);
    }

    if (_p.flash > 0) {
        draw_set_alpha((_p.flash / 12) * 0.6);
        draw_set_color(c_red);
        draw_rectangle(x1, y1, x2, y2, false);
        draw_set_alpha(1);
    }

    draw_set_color(_valido ? c_yellow : (vivo ? c_white : c_gray));
    draw_rectangle(x1, y1, x2, y2, true);
    if (_valido) draw_rectangle(x1 + 1, y1 + 1, x2 - 1, y2 - 1, true);

    draw_set_halign(fa_center);
    draw_set_color(vivo ? c_white : c_gray);
    draw_text((x1 + x2) / 2, y1 + 8, _p.nome);
    draw_personagem(_p, (x1 + x2) / 2, y2 - 48, 1, false, _flip);
    if (!vivo) draw_text((x1 + x2) / 2, y1 + 80, "[ Derrotado ]");
    draw_set_halign(fa_left);

    if (vivo) {
        var ns = array_length(_p.status);
        for (var s = 0; s < ns; s++) {
            var st = _p.status[s];
            draw_set_color(status_cor(st.ef));
            draw_text(x1 + 6, y1 + 28 + s * 18, status_sigla(st.ef) + " " + string(st.dur));
        }
        if (_p.defendendo) {
            draw_set_color(c_aqua);
            draw_text(x1 + 6, y1 + 28 + ns * 18, "Defesa");
        }
    }

    draw_hp_barra(x1 + 10, y2 - 42, x2 - 10, y2 - 24, _p);
}

function draw_paineis() {
    draw_set_color(c_dkgray);
    draw_rectangle(30, 20, 330, 520, false);
    draw_rectangle(950, 20, 1250, 520, false);
    draw_set_color(c_white);
    draw_rectangle(30, 20, 330, 520, true);
    draw_rectangle(950, 20, 1250, 520, true);

    if (estado == GAME_STATE.combat) return;

    draw_set_halign(fa_center);
    draw_text(180, 40, player.nome);
    var g = get_grupo();
    for (var i = 0; i < array_length(g); i++) {
        draw_personagem(g[i], 290 - i * 75, 300, 1, false, false);
    }

    draw_text(1100, 40, "Ameaça / Interação");
    if (estado == GAME_STATE.card && carta_atual != undefined && carta_atual.sprite_interacao != noone) {
        draw_sprite(carta_atual.sprite_interacao, 0, 1100, 260);
    } else if (estado == GAME_STATE.card && figura_evento != undefined) {
        draw_personagem(figura_evento, 1100, 300, 2, false, true);
    } else {
        draw_text(1100, 260, "[ Sem imagem ]");
    }
    draw_set_halign(fa_left);
}

function draw_trilha() {
    var n = nivel_max_expedicao;
    var tx0 = 400;
    var tx1 = 880;
    var ty = 470;

    draw_set_color(c_gray);
    draw_line(tx0, ty, tx1, ty);

    for (var i = 0; i <= n; i++) {
        var px = tx0 + (tx1 - tx0) * i / n;
        var fixo = (i == nivel_fixo);
        draw_set_color(fixo ? c_yellow : (i <= nivel_expedicao ? c_white : c_gray));
        draw_circle(px, ty, fixo ? 9 : 5, i > nivel_expedicao);
    }

    var mxp = tx0 + (tx1 - tx0) * trilha_vis / n;
    draw_set_color(c_lime);
    draw_triangle(mxp - 8, ty - 26, mxp + 8, ty - 26, mxp, ty - 12, false);
    draw_set_color(c_white);
}

function texto_recompensa(_c) {
    switch (_c.recompensa) {
        case RECOMPENSA.recurso: return "+" + string(_c.recompensa_valor) + " Recursos";
        case RECOMPENSA.cura:    return "+" + string(_c.recompensa_valor) + " de vida para o grupo";
        case RECOMPENSA.stat:    return "+" + string(_c.recompensa_valor) + " " + stat_nomes[_c.recompensa_stat];
        case RECOMPENSA.aliado:  return "Novo aliado: " + _c.aliado_nome;
        case RECOMPENSA.relacao: return "Relação +1 com a Facção " + string(_c.origin);
    }
    return "";
}

function draw_opcao_card(_i) {
    var opt = carta_atual.options[_i];
    var b = box_opcao(_i);
    var meu = stat_total(player, opt.stat);
    var cy = (b[1] + b[3]) / 2;
    var xi = b[2] - 150;

    draw_botao(b, "", c_dkgray, c_white, HV.opcao + _i, true);

    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(b[0] + 12, cy, string(_i + 1) + ". " + opcao_flavor(opt));

    draw_icone_stat(opt.stat, xi, cy - 10, 20);
    draw_set_color(c_yellow);
    draw_text(xi + 26, cy, string(opt.required));
    draw_set_color((meu >= opt.required) ? c_lime : c_ltgray);
    draw_text(xi + 54, cy, "(você: " + string(meu) + ")");
    draw_set_valign(fa_top);
}

function draw_card() {
    if (carta_atual == undefined) return;
    var c = carta_atual;
    var b = box_card();

    draw_set_halign(fa_center);
    draw_set_color(c_yellow);
    draw_text(640, 25, nome_area + " | Nível " + string(nivel_expedicao) + " de " + string(nivel_max_expedicao));
    draw_set_halign(fa_left);

    draw_set_color(c_dkgray);
    draw_rectangle(b[0], b[1], b[2], b[3], false);
    draw_set_color(origem_cores[c.origin]);
    draw_rectangle(b[0], b[1], b[2], b[3], true);

    var tag = "EVENTO";
    switch (c.tipo) {
        case CARD_TIPO.hostil:   tag = "COMBATE"; break;
        case CARD_TIPO.amigavel: tag = "ENCONTRO AMIGÁVEL"; break;
        case CARD_TIPO.posto:    tag = "POSTO"; break;
        case CARD_TIPO.missao:   tag = "MISSÃO"; break;
    }
    draw_set_halign(fa_right);
    draw_text(b[2] - 20, b[1] + 15, tag);
    draw_set_halign(fa_left);

    draw_set_color(c_white);
    draw_text(b[0] + 20, b[1] + 15, c.name);
    draw_set_color(c_ltgray);
    draw_text_ext(b[0] + 20, b[1] + 45, c.description, 20, (b[2] - b[0]) - 40);

    if (c.tipo == CARD_TIPO.hostil) {
        draw_set_color(c_aqua);
        draw_text(b[0] + 20, b[1] + 190, "Vitória: +" + string(c.recompensa_valor) + " Recursos");
    } else if (c.tipo == CARD_TIPO.evento || c.tipo == CARD_TIPO.amigavel) {
        draw_set_color(c_aqua);
        draw_text(b[0] + 20, b[1] + 190, "Sucesso: " + texto_recompensa(c));
        draw_set_color(c_orange);
        draw_text(b[0] + 20, b[1] + 215, "Falha: Avança +" + string(c.fail_tempo) + " min no Relógio");
    }

    if (!carta_resolvida) {
        for (var i = 0; i < 3; i++) {
            draw_opcao_card(i);
        }
        draw_botao(box_opcao(3), "4. Contornar o obstáculo  (Avança +" + string(custo_contornar) + " min no Relógio)", c_maroon, c_white, HV.opcao + 3, true);
    } else {
        draw_set_color(c_yellow);
        draw_text_ext(b[0] + 20, b[1] + 250, card_msg, 22, (b[2] - b[0]) - 40);
        draw_text(b[0] + 20, b[1] + 295, "[ Clique para continuar ]");
    }
    draw_set_color(c_white);
}

function draw_combate() {
    var g = get_grupo();
    var sk = skill_selecionada();
    var alvo_dano = (sk != undefined && skill_hostil(sk));
    var alvo_cura = (sk != undefined && !skill_hostil(sk));

    for (var i = 0; i < array_length(g); i++) {
        draw_slot_personagem(box_slot_party(i), g[i], HV.alvo + 4 + i, alvo_cura && g[i].hp > 0, false);
    }
    for (var e = 0; e < array_length(inimigos); e++) {
        draw_slot_personagem(box_slot_inimigo(e), inimigos[e], HV.alvo + e, alvo_dano && inimigos[e].hp > 0, true);
    }

    draw_set_halign(fa_center);
    draw_set_color(c_yellow);
    draw_text(640, 8, "COMBATE - Rodada " + string(c_rodada));

    var instr = "";
    switch (c_fase) {
        case COMBAT_FASE.skill:    instr = "Escolha a habilidade de " + g[c_ator].nome; break;
        case COMBAT_FASE.alvo:     instr = "Clique no alvo (botão direito cancela)"; break;
        case COMBAT_FASE.resolver: instr = "Resolvendo... (clique para acelerar)"; break;
        case COMBAT_FASE.fim:
            if (c_resultado == COMBAT_RES.vitoria) instr = "VITÓRIA! Clique para continuar";
            else if (c_resultado == COMBAT_RES.derrota) instr = "Você caiu... Clique para continuar";
            else instr = "O sol nasceu! Clique para continuar";
            break;
    }
    draw_set_color(c_white);
    draw_text(640, 32, instr);
    draw_set_halign(fa_left);

    draw_set_color(c_ltgray);
    draw_text(30, 262, "FILA (menor tempo consumido primeiro):");
    for (var q = 0; q < array_length(c_fila); q++) {
        var a = c_fila[q];
        var cor = c_white;
        if (c_fase == COMBAT_FASE.resolver) {
            if (q == c_idx - 1) cor = c_yellow;
            else if (q < c_idx) cor = c_gray;
        }
        draw_set_color(cor);

        var fx = 30;
        var fy = 284 + q * 22;
        var pre = "[+" + string(a.tempo) + "m] " + a.ator.nome + " > ";
        draw_text(fx, fy, pre);
        fx += string_width(pre);
        draw_icone_skill(a.skill, fx, fy - 1, 20);
        fx += 25;
        draw_set_color(cor);
        draw_text(fx, fy, a.skill.nome + " > " + a.alvo.nome);
    }

    draw_set_color(c_ltgray);
    for (var l = 0; l < array_length(c_log); l++) {
        draw_text(680, 284 + l * 22, c_log[l]);
    }
    draw_set_color(c_white);
}

function skill_resumo(_s, _st) {
    var v = _s.base + _st;
    var t = "";
    switch (_s.tipo) {
        case SKILL_TIPO.dano:      t = "Dano " + string(v) + " [" + string(_s.base) + "+" + stat_nomes[_s.stat] + " " + string(_st) + "]"; break;
        case SKILL_TIPO.cura:      t = "Cura " + string(v) + " [" + string(_s.base) + "+" + stat_nomes[_s.stat] + " " + string(_st) + "]"; break;
        case SKILL_TIPO.restaurar: t = "Cura " + string(v) + " e remove status ruins"; break;
        case SKILL_TIPO.buff:      t = "Reforça o aliado"; break;
        case SKILL_TIPO.debuff:    t = "Enfraquece o inimigo"; break;
        case SKILL_TIPO.recarga:   t = "Reduz " + string(_s.base) + " de recarga do grupo"; break;
        case SKILL_TIPO.defesa:    t = "Bloqueia " + string(round(DEFENDER_REDUCAO * 100)) + "% do dano até a próxima rodada"; break;
    }
    switch (_s.alcance) {
        case ALCANCE.adjacente: t += "  |  área (adjacentes: metade)"; break;
        case ALCANCE.global:    t += "  |  todos"; break;
    }
    if (_s.efeito != -1) t += "  |  " + status_nome(_s.efeito) + " (" + string(_s.ef_dur) + ")";
    return t;
}

function draw_skill_info(_ator, _k, _x, _y) {
    var s = _ator.skills[_k];
    var tx = _x + ICONE_SKILL + 10;

    draw_icone_skill(s, _x, _y, ICONE_SKILL);

    draw_set_color(c_white);
    if (s.cat == SKILL_CAT.missao) {
        draw_text(tx, _y, s.nome);
        draw_set_color(c_ltgray);
        draw_text(tx, _y + 24, "Habilidade de missão: não faz nada em combate.");
        return;
    }

    var st = stat_total(_ator, s.stat);
    var cd_txt = (s.cd_max > 0) ? ("  |  Recarga: " + string(s.cd_max)) : "";
    draw_text(tx, _y, s.nome + "  |  " + skill_cat_nome(s.cat) + "  |  Consumo: +" + string(s.tempo) + " min" + cd_txt);
    draw_set_color(c_ltgray);
    draw_text(tx, _y + 24, skill_resumo(s, st));
}

function draw_hud() {
    var top = 550 - 80 * hud_exp;
    var g = get_grupo();
    var ator = player;
    if (estado == GAME_STATE.combat && (c_fase == COMBAT_FASE.skill || c_fase == COMBAT_FASE.alvo)) {
        ator = g[c_ator];
    }

    draw_set_color(c_dkgray);
    draw_rectangle(0, top, 1280, 720, false);
    draw_set_color(c_white);
    draw_line(0, top, 1280, top);

    var ks = -1;
    if (hover >= HV.skill && hover < HV.skill + 3) ks = hover - HV.skill;
    else if (estado == GAME_STATE.combat && c_fase == COMBAT_FASE.alvo) ks = c_skill;

    if (ks >= 0 && ks < array_length(ator.skills)) {
        if (hud_exp > 0.5) {
            draw_set_alpha((hud_exp - 0.5) * 2);
            draw_skill_info(ator, ks, 30, top + 14);
            draw_set_alpha(1);
        } else if (hover >= HV.skill && hover < HV.skill + 3) {
            var tb = box_skill(ks);
            var tx = min(tb[0], 660);
            draw_set_color(c_black);
            draw_rectangle(tx, top - 62, tx + 600, top - 6, false);
            draw_set_color(c_white);
            draw_rectangle(tx, top - 62, tx + 600, top - 6, true);
            draw_skill_info(ator, ks, tx + 6, top - 58);
        }
    }

    draw_set_color(c_white);
    draw_text(30, 570, "Facção Jogável: " + string(faccao_atual + 1) + " / 3");
    draw_text(30, 600, "Vida: " + string(player.hp) + " / " + string(p_hp_max(player)));
    for (var a = 0; a < array_length(aliados); a++) {
        draw_text(30, 620 + a * 20, aliados[a].nome + ": " + string(aliados[a].hp) + " / " + string(p_hp_max(aliados[a])));
    }

    draw_set_color(c_white);
    draw_text(270, 565, "ATRIBUTOS:");
    for (var s = 0; s < STAT.count; s++) {
        var col = s div 3;
        var lin = s mod 3;
        var sx = 270 + col * 140;
        var sy = 592 + lin * 26;
        draw_icone_stat(s, sx, sy, 20);
        draw_set_color(c_white);
        draw_text(sx + 26, sy + 2, stat_nomes[s] + ": " + string(stat_total(player, s)));
    }

    var tit = (ator == player) ? "HABILIDADES / VAGAS:" : ("HABILIDADES: " + ator.nome);
    draw_set_color(c_white);
    draw_text(550, 565, tit);

    var sel = (estado == GAME_STATE.combat && c_fase == COMBAT_FASE.alvo) ? c_skill : -1;
    var ativo = (estado == GAME_STATE.combat && (c_fase == COMBAT_FASE.skill || c_fase == COMBAT_FASE.alvo));

    for (var k = 0; k < ator.max_skills; k++) {
        var b = box_skill(k);

        if (k >= array_length(ator.skills)) {
            draw_set_color(c_gray);
            draw_rectangle(b[0], b[1], b[2], b[3], true);
            draw_text(b[0] + 10, b[1] + 28, "vazio");
            continue;
        }

        var sl = ator.skills[k];
        var up = hover_anim[HV.skill + k] * 8;

        draw_set_color((k == sel) ? c_olive : c_black);
        draw_rectangle(b[0], b[1] - up, b[2], b[3] - up, false);
        draw_set_color(ativo ? c_yellow : c_white);
        draw_rectangle(b[0], b[1] - up, b[2], b[3] - up, true);

        draw_icone_skill(sl, b[0] + 6, b[1] + 6 - up, ICONE_SKILL);
        draw_set_color(cor_categoria_skill(sl.cat));
        draw_text(b[0] + 6, b[1] + 58 - up, sl.nome);
        draw_set_color(c_white);
        if (sl.cat == SKILL_CAT.missao) {
            draw_text(b[0] + 60, b[1] + 10 - up, "Missão");
        } else {
            draw_text(b[0] + 60, b[1] + 10 - up, "+" + string(sl.tempo) + " min");
            if (sl.cd_max > 0) draw_text(b[0] + 60, b[1] + 30 - up, "Rec " + string(sl.cd_max));
        }

        if (sl.cd > 0) {
            draw_set_alpha(0.7);
            draw_set_color(c_black);
            draw_rectangle(b[0], b[1] - up, b[2], b[3] - up, false);
            draw_set_alpha(1);
            draw_set_color(c_orange);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(b[0] + 6 + ICONE_SKILL / 2, b[1] + 6 + ICONE_SKILL / 2 - up, "Rec. " + string(sl.cd));
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }

    var hora_texto = tempo_para_relogio(floor(tempo_vis), tempo_run_max);

    draw_set_color(c_white);
    draw_text(950, 590, "Recursos: " + string(recurso));

    draw_set_color(tempo < 60 ? c_red : c_yellow);
    draw_text(950, 625, "Horário: " + hora_texto + " (Amanhecer: 06:00 AM)");

    var r = clamp(tempo_vis / tempo_run_max, 0, 1);
    draw_set_color(c_black);
    draw_rectangle(950, 655, 1250, 671, false);
    draw_set_color(r > 0.5 ? c_lime : (r > 0.2 ? c_yellow : c_red));
    draw_rectangle(950, 655, 950 + 300 * r, 671, false);
    draw_set_color(c_white);
    draw_rectangle(950, 655, 1250, 671, true);
}

function draw_popups() {
    draw_set_halign(fa_center);
    for (var i = 0; i < array_length(popups); i++) {
        var p = popups[i];
        draw_set_alpha(clamp(p.vida / 20, 0, 1));
        draw_set_color(p.cor);
        draw_text(p.x, p.y, p.txt);
    }
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}

function draw_particulas() {
    for (var i = 0; i < array_length(particulas); i++) {
        var p = particulas[i];
        draw_sprite(p.spr, floor(p.img), p.x, p.y);
    }
}

function draw_fim_run() {
    draw_set_color(c_black);
    draw_rectangle(0, 0, 1280, 720, false);

    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(640, 240, "--- CICLO FINALIZADO ---");
    draw_text_ext(640, 300, msg_fim, 28, 800);

    draw_set_color(c_yellow);
    draw_text(640, 460, "[ Clique para ir à preparação da próxima facção ]");
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}

function draw_painel_lider() {
    draw_set_color(c_dkgray);
    draw_rectangle(950, 20, 1250, 520, false);
    draw_set_color(c_white);
    draw_rectangle(950, 20, 1250, 520, true);

    var l = lideres[faccao_atual];
    draw_set_halign(fa_center);
    draw_text(1100, 40, l.nome);
    draw_personagem(l, 1100, 440, 2, true, true);
    draw_set_halign(fa_left);
}

function draw_prep_menu() {
    draw_botao(box_hub(0), "Melhorias", c_dkgray, c_white, HV.hub, true);
    draw_botao(box_hub(1), "Conversar com o líder", c_dkgray, c_white, HV.hub + 1, true);
    draw_botao(box_hub(2), "Missões", c_dkgray, c_white, HV.hub + 2, true);
    draw_botao(box_hub(3), "Iniciar Expedição", c_lime, c_black, HV.iniciar, true);

    draw_set_color(c_yellow);
    if (missao_sel != undefined) {
        var m = missoes[missao_sel.d][missao_sel.i];
        draw_text(330, 530, "Missão selecionada: " + m.nome + " [" + nome_tipo_missao(m.tipo) + "]");
    } else {
        draw_set_color(c_gray);
        draw_text(330, 530, "Nenhuma missão ativa selecionada.");
    }

    draw_painel_lider();
}

// DESENHO DA ÁRVORE DE UPGRADES
function draw_prep_upgrades() {
    var vis = upgrades_visiveis();
    var comprados = upgrades_comprados[faccao_atual];

    // 1. Desenha as linhas conectoras da árvore
    for (var i = 0; i < array_length(vis); i++) {
        var idx = vis[i];
        var u = upgrades[idx];

        if (u.pai != -1) {
            var b_filho = box_upg(i);
            var idx_pai_vis = -1;
            for (var p = 0; p < array_length(vis); p++) {
                if (vis[p] == u.pai) { idx_pai_vis = p; break; }
            }

            if (idx_pai_vis != -1) {
                var b_pai = box_upg(idx_pai_vis);
                var x_pai = (b_pai[0] + b_pai[2]) / 2;
                var y_pai = (b_pai[1] + b_pai[3]) / 2;
                var x_filho = (b_filho[0] + b_filho[2]) / 2;
                var y_filho = (b_filho[1] + b_filho[3]) / 2;

                var pai_comprado = comprados[u.pai];
                draw_set_color(pai_comprado ? c_yellow : c_dkgray);
                draw_line_width(x_pai, y_pai, x_filho, y_filho, 3);
            }
        }
    }

    // 2. Desenha os nós (caixas) dos upgrades
    for (var j = 0; j < array_length(vis); j++) {
        var idx2 = vis[j];
        var u2 = upgrades[idx2];
        var b = box_upg(j);
        var comprado = comprados[idx2];
        var pode = upgrade_pode_comprar(idx2);

        var cor_fundo = c_dkgray;
        if (comprado) cor_fundo = c_green;
        else if (pode) cor_fundo = c_navy;

        draw_botao(b, "", cor_fundo, c_white, HV.upg + j, pode || comprado);

        draw_set_color(comprado ? c_lime : (pode ? c_white : c_gray));
        draw_text_ext(b[0] + 8, b[1] + 6, u2.nome, 14, 184);

        draw_set_color(c_ltgray);
        draw_text_ext(b[0] + 8, b[1] + 24, u2.desc, 12, 184);

        var info = comprado ? "COMPRADO" : ("Custo: " + string(u2.custo));
        if (!comprado && u2.pai != -1 && !comprados[u2.pai]) info = "Requer Ant.";
        
        draw_set_color(comprado ? c_yellow : (pode ? c_aqua : c_orange));
        draw_text(b[0] + 8, b[1] + 50, info);
    }

    draw_botao(box_voltar(), "Voltar", c_dkgray, c_white, HV.voltar, true);
}

function draw_prep_dialogo() {
    draw_set_color(c_black);
    draw_rectangle(60, 120, 920, 600, false);
    draw_set_color(c_white);
    draw_rectangle(60, 120, 920, 600, true);

    draw_set_color(c_yellow);
    draw_text(80, 135, lideres[faccao_atual].nome + ":");
    draw_set_color(c_white);
    draw_text_ext(80, 170, texto_dialogo_lider(), 24, 820);

    draw_set_color(c_gray);
    draw_text(80, 570, "[ Clique para voltar ]");

    draw_painel_lider();
}

function draw_prep_missoes() {
    draw_set_halign(fa_center);
    for (var c = 0; c < TOTAL_FACCOES; c++) {
        var sufixo = "";
        if (c == faccao_atual) sufixo = "  (você)";
        else if (!faccao_pode_missao(c)) sufixo = "  (sem aliança)";
        else sufixo = "  (aliada)";

        draw_set_color(faccao_pode_missao(c) ? origem_cores[c + 1] : c_gray);
        draw_text(30 + c * 310 + 150, 85, "Facção " + string(c + 1) + sufixo);
    }
    draw_set_halign(fa_left);

    for (var c2 = 0; c2 < TOTAL_FACCOES; c2++) {
        for (var r = 0; r < 5; r++) {
            if (!missao_visivel(c2, r)) continue;

            var m = missoes[c2][r];
            var b = box_missao(c2, r);
            var st = missao_status(c2, r);
            var pode = missao_pode_selecionar(c2, r);

            draw_botao(b, "", c_dkgray, c_white, HV.missao + c2 * 5 + r, pode);
            if (missao_selecionada(c2, r)) {
                draw_set_color(c_yellow);
                draw_rectangle(b[0] + 1, b[1] + 1, b[2] - 1, b[3] - 1, true);
            }

            draw_set_color(m.concluida ? c_gray : c_white);
            draw_text(b[0] + 10, b[1] + 8, m.nome);
            draw_set_color(c_ltgray);
            draw_text(b[0] + 10, b[1] + 30, nome_tipo_missao(m.tipo));
            draw_set_color(st.cor);
            draw_text(b[0] + 10, b[1] + 52, st.txt);
        }
    }

    if (hover >= HV.missao && hover < HV.missao + TOTAL_FACCOES * 5) {
        var hm = hover - HV.missao;
        if (missao_visivel(hm div 5, hm mod 5)) {
            var mm = missoes[hm div 5][hm mod 5];
            draw_set_color(c_white);
            draw_text_ext(40, 545, mm.nome + " [" + nome_tipo_missao(mm.tipo) + "]: " + mm.desc, 22, 1200);
        }
    }

    draw_botao(box_voltar(), "Voltar", c_dkgray, c_white, HV.voltar, true);
}

function draw_preparacao() {
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(640, 25, "PREPARAÇÃO - Facção " + string(faccao_atual + 1) + " / " + string(FACTION.count));
    draw_set_color(c_aqua);
    draw_text(640, 60, "Reserva: " + string(reserva[faccao_atual]) + " recursos");
    draw_set_halign(fa_left);

    switch (prep_tela) {
        case PREP_TELA.menu:     draw_prep_menu(); break;
        case PREP_TELA.upgrades: draw_prep_upgrades(); break;
        case PREP_TELA.dialogo:  draw_prep_dialogo(); break;
        case PREP_TELA.missoes:  draw_prep_missoes(); break;
    }
    draw_set_color(c_white);
}