// botão genérico: a barra clara "desliza" da esquerda no hover
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

function draw_slot_personagem(_b, _p, _hv_id, _valido) {
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
    draw_text((x1 + x2) / 2, y1 + 10, _p.nome);
    draw_text((x1 + x2) / 2, y1 + 80, vivo ? "[ Sprite ]" : "[ Derrotado ]");
    draw_set_halign(fa_left);

    draw_hp_barra(x1 + 20, y2 - 42, x2 - 20, y2 - 24, _p);
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
    draw_text(180, 260, "[ Sprite do Player ]");
    if (party_membro != noone) draw_text(180, 420, "[ Sprite " + party_membro.nome + " ]");

    draw_text(1100, 40, "Ameaça / Interação");
    if (estado == GAME_STATE.card && carta_atual != undefined && carta_atual.sprite_interacao != noone) {
        draw_sprite(carta_atual.sprite_interacao, 0, 1100, 260);
    } else {
        draw_text(1100, 260, "[ Sprite Evento ]");
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

function draw_expedicao() {
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(640, 150, nome_area + " - Nível " + string(nivel_expedicao) + " / " + string(nivel_max_expedicao));
    draw_set_halign(fa_left);

    var fim_trilha = (nivel_expedicao >= nivel_max_expedicao);
    draw_botao(box_avancar(), fim_trilha ? "Concluir a Trilha" : "Avançar na Expedição", c_lime, c_black, HV.avancar, true);
    draw_botao(box_retorno(), "Retornar à Base (Custa " + string(calcular_custo_retorno()) + " Tempo)", c_orange, c_black, HV.retorno, pode_retornar());
    draw_trilha();
}

function texto_recompensa(_c) {
    switch (_c.recompensa) {
        case RECOMPENSA.recurso: return "+" + string(_c.recompensa_valor) + " Recursos";
        case RECOMPENSA.cura:    return "+" + string(_c.recompensa_valor) + " HP para o grupo";
        case RECOMPENSA.stat:    return "+" + string(_c.recompensa_valor) + " " + stat_nomes[_c.recompensa_stat];
        case RECOMPENSA.aliado:  return "Novo aliado: " + _c.aliado_nome;
    }
    return "";
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
    } else if (c.tipo != CARD_TIPO.posto) {
        draw_set_color(c_aqua);
        draw_text(b[0] + 20, b[1] + 190, "Sucesso: " + texto_recompensa(c));
        draw_set_color(c_orange);
        draw_text(b[0] + 20, b[1] + 215, "Falha: -" + string(c.fail_tempo) + " de Tempo");
    }

    if (!carta_resolvida) {
        for (var i = 0; i < 3; i++) {
            var opt = c.options[i];
            var txt = "Opção " + string(i + 1) + ": " + stat_nomes[opt.stat] + " [ Requer: " + string(opt.required) + " ]  (você: " + string(stat_total(player, opt.stat)) + ")";
            draw_botao(box_opcao(i), txt, c_dkgray, c_white, HV.opcao + i, true);
        }
        draw_botao(box_opcao(3), "Opção 4: Contornar (Custa -" + string(custo_contornar) + " de Tempo)", c_maroon, c_white, HV.opcao + 3, true);
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
    var alvo_dano = (sk != undefined && sk.tipo == SKILL_TIPO.dano);
    var alvo_cura = (sk != undefined && sk.tipo == SKILL_TIPO.cura);

    for (var i = 0; i < array_length(g); i++) {
        draw_slot_personagem(box_slot_party(i), g[i], HV.alvo + 2 + i, alvo_cura && g[i].hp > 0);
    }
    for (var e = 0; e < array_length(inimigos); e++) {
        draw_slot_personagem(box_slot_inimigo(e), inimigos[e], HV.alvo + e, alvo_dano && inimigos[e].hp > 0);
    }

    // título e instrução
    draw_set_halign(fa_center);
    draw_set_color(c_yellow);
    draw_text(640, 25, "COMBATE - Rodada " + string(c_rodada));

    var instr = "";
    switch (c_fase) {
        case COMBAT_FASE.skill:    instr = "Escolha a habilidade de " + g[c_ator].nome; break;
        case COMBAT_FASE.alvo:     instr = "Clique no alvo (botão direito cancela)"; break;
        case COMBAT_FASE.resolver: instr = "Resolvendo... (clique para acelerar)"; break;
        case COMBAT_FASE.fim:
            if (c_resultado == COMBAT_RES.vitoria) instr = "VITÓRIA! Clique para continuar";
            else if (c_resultado == COMBAT_RES.derrota) instr = "Você caiu... Clique para continuar";
            else instr = "O tempo acabou! Clique para continuar";
            break;
    }
    draw_set_color(c_white);
    draw_text(640, 55, instr);
    draw_set_halign(fa_left);

    // fila de ações (já ordenada pelo custo de tempo)
    draw_set_color(c_ltgray);
    draw_text(370, 100, "FILA (menor custo de tempo primeiro):");
    for (var q = 0; q < array_length(c_fila); q++) {
        var a = c_fila[q];
        var cor = c_white;
        if (c_fase == COMBAT_FASE.resolver) {
            if (q == c_idx - 1) cor = c_yellow;
            else if (q < c_idx) cor = c_gray;
        }
        draw_set_color(cor);
        draw_text(370, 125 + q * 22, "[t" + string(a.skill.tempo) + "] " + a.ator.nome + " > " + a.skill.nome + " > " + a.alvo.nome);
    }

    // log
    draw_set_color(c_ltgray);
    for (var l = 0; l < array_length(c_log); l++) {
        draw_text(370, 250 + l * 24, c_log[l]);
    }
    draw_set_color(c_white);
}

function draw_skill_info(_ator, _k, _x, _y) {
    var s = _ator.skills[_k];
    var st = stat_total(_ator, s.stat);
    var v = s.base + st;

    draw_set_color(c_white);
    draw_text(_x, _y, s.nome + "  |  Tempo: " + string(s.tempo) + "  |  " + ((s.tipo == SKILL_TIPO.dano) ? "Dano: " : "Cura: ") + string(v));
    draw_set_color(c_ltgray);
    draw_text(_x, _y + 24, "Base " + string(s.base) + " + " + stat_nomes[s.stat] + " " + string(st) + ((s.tipo == SKILL_TIPO.dano) ? "  |  alvo: inimigo" : "  |  alvo: aliado"));
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

    // detalhe da skill: faixa expandida no combate, tooltip fora dele
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
            draw_set_color(c_black);
            draw_rectangle(tb[0], top - 62, tb[0] + 380, top - 6, false);
            draw_set_color(c_white);
            draw_rectangle(tb[0], top - 62, tb[0] + 380, top - 6, true);
            draw_skill_info(ator, ks, tb[0] + 10, top - 56);
        }
    }

    // facção e HP
    draw_set_color(c_white);
    draw_text(30, 570, "Facção Jogável: " + string(faccao_atual + 1) + " / 3");
    draw_text(30, 600, "HP: " + string(player.hp) + " / " + string(p_hp_max(player)));
    if (party_membro != noone) {
        draw_text(30, 625, party_membro.nome + ": " + string(party_membro.hp) + " / " + string(p_hp_max(party_membro)));
    }

    // stats
    draw_text(280, 565, "STATS:");
    for (var s = 0; s < STAT.count; s++) {
        draw_text(280, 590 + s * 18, stat_nomes[s] + ": " + string(stat_total(player, s)));
    }

    // habilidades / slots
    var tit = (ator == player) ? "HABILIDADES / SLOTS:" : ("HABILIDADES: " + ator.nome);
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
        draw_set_color(c_white);
        draw_text(b[0] + 10, b[1] + 10 - up, sl.nome);
        draw_text(b[0] + 10, b[1] + 38 - up, "Tempo: " + string(sl.tempo));
    }

    // recursos e relógio
    draw_set_color(c_white);
    draw_text(950, 590, "Recursos: " + string(recurso));
    draw_text(950, 630, "Relógio (Tempo): " + string(tempo) + " / " + string(tempo_run_max));

    var r = clamp(tempo_vis / tempo_run_max, 0, 1);
    draw_set_color(c_black);
    draw_rectangle(950, 660, 1250, 676, false);
    draw_set_color(r > 0.5 ? c_lime : (r > 0.25 ? c_yellow : c_red));
    draw_rectangle(950, 660, 950 + 300 * r, 676, false);
    draw_set_color(c_white);
    draw_rectangle(950, 660, 1250, 676, true);
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

function draw_preparacao() {
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(640, 25, "PREPARAÇÃO - Facção " + string(faccao_atual + 1) + " / " + string(FACTION.count));
    draw_set_color(c_aqua);
    draw_text(640, 60, "Reserva: " + string(reserva) + " recursos");
    draw_set_halign(fa_left);

    for (var i = 0; i < array_length(upgrades); i++) {
        var u = upgrades[i];
        var b = box_upg(i);
        var comprado = upgrades_comprados[i];
        var pode = upgrade_pode_comprar(i);

        if (comprado) draw_botao(b, "", c_green, c_white, -1, true);
        else draw_botao(b, "", c_dkgray, c_white, HV.upg + i, pode);

        draw_set_color((comprado || pode) ? c_white : c_gray);
        draw_text(b[0] + 15, b[1] + 14, u.nome);
        draw_text(b[0] + 300, b[1] + 14, u.desc);

        var info = comprado ? "COMPRADO" : ("Custo: " + string(u.custo));
        if (!comprado && u.efeito == UPG_EFEITO.skill && contar_upgrades_skill() >= slots_upg) info = "Sem slot";
        draw_text(b[0] + 740, b[1] + 14, info);
    }

    draw_botao(box_iniciar(), "Iniciar Expedição", c_lime, c_black, HV.iniciar, true);
    draw_set_color(c_white);
}