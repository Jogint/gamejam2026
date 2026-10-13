
// ================= UTILIDADES =================
function util_box(_mx, _my, _x1, _y1, _x2, _y2) {
    return (_mx >= _x1 && _mx <= _x2 && _my >= _y1 && _my <= _y2);
}

function util_in(_b) {
    return util_box(mx, my, _b[0], _b[1], _b[2], _b[3]);
}

function stat_total(_p, _s) {
    return _p.stats[_s] + _p.stat_mods[_s];
}

function p_hp_max(_p) {
    return 10 + stat_total(_p, STAT.vitalidade) * 3;
}

function p_curar_total(_p) {
    _p.hp = p_hp_max(_p);
    _p.hp_vis = _p.hp;
}

// ================= HITBOXES (clique e desenho usam as mesmas) =================
function box_avancar() { return [450, 240, 830, 310]; }
function box_retorno() { return [450, 330, 830, 400]; }
function box_iniciar() { return [450, 600, 830, 670]; }

function box_card() {
    var off = (1 - card_anim) * 320;
    return [350, 55 - off, 930, 360 - off];
}

function box_opcao(_i) {
    var off = (1 - card_anim) * 200;
    return [360, 380 + _i * 42 + off, 920, 416 + _i * 42 + off];
}

function box_skill(_k) { return [550 + _k * 120, 595, 660 + _k * 120, 670]; }
function box_slot_party(_i) { return [40, 25 + _i * 215, 320, 225 + _i * 215]; }
function box_slot_inimigo(_i) { return [960, 25 + _i * 215, 1240, 225 + _i * 215]; }
function box_upg(_i) { return [200, 110 + _i * 52, 1080, 156 + _i * 52]; }

// ================= DADOS =================
function skill_nova(_id) {
    switch (_id) {
        case SKILL_ID.golpe:      return new Skill("Golpe", 2, 2, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.tiro:       return new Skill("Tiro Preciso", 3, 3, STAT.tecnica, SKILL_TIPO.dano);
        case SKILL_ID.improviso:  return new Skill("Improviso", 5, 6, STAT.imaginacao, SKILL_TIPO.dano);
        case SKILL_ID.remendo:    return new Skill("Remendo", 3, 4, STAT.tecnica, SKILL_TIPO.cura);
        case SKILL_ID.mordida:    return new Skill("Mordida", 2, 1, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.investida:  return new Skill("Investida", 5, 5, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.disparo:    return new Skill("Disparo", 3, 3, STAT.tecnica, SKILL_TIPO.dano);
        case SKILL_ID.sobrecarga: return new Skill("Sobrecarga", 6, 6, STAT.tecnica, SKILL_TIPO.dano);
        case SKILL_ID.rajada:     return new Skill("Rajada", 4, 3, STAT.tecnica, SKILL_TIPO.dano);
    }
    return new Skill("???", 1, 1, STAT.forca, SKILL_TIPO.dano);
}

// ALTERADO: recebe a origem (facção) e define a classe de cada inimigo
function inimigo_novo(_id, _origem) {
    var e = new Personagem("Inimigo");
    var cl = CLASSE.soldado;   // NOVO
    switch (_id) {
        case ENEMY_ID.besta:
            e.nome = "Besta das Ruínas";
            e.stats[STAT.vitalidade] = 2;
            e.stats[STAT.forca] = 2;
            e.skills = [skill_nova(SKILL_ID.mordida), skill_nova(SKILL_ID.investida)];
            cl = CLASSE.mutante;   // NOVO
            break;
        case ENEMY_ID.saqueador:
            e.nome = "Saqueador";
            e.stats[STAT.vitalidade] = 2;
            e.stats[STAT.forca] = 2;
            e.stats[STAT.tecnica] = 2;
            e.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.tiro)];
            cl = CLASSE.soldado;   // NOVO
            break;
        case ENEMY_ID.sentinela:
            e.nome = "Sentinela";
            e.stats[STAT.vitalidade] = 2;
            e.skills = [skill_nova(SKILL_ID.disparo), skill_nova(SKILL_ID.sobrecarga)];
            cl = CLASSE.maquina;   // NOVO
            break;
        case ENEMY_ID.rato:
            e.nome = "Rato Mutante";
            e.stats[STAT.vitalidade] = 0;
            e.stats[STAT.forca] = 1;
            e.skills = [skill_nova(SKILL_ID.mordida)];
            cl = CLASSE.mutante;   // NOVO
            break;
        case ENEMY_ID.guarda:
            e.nome = "Guarda do Posto";
            e.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.rajada)];
            cl = CLASSE.soldado;   // NOVO
            break;
    }
    visual_aleatorio(e, cl, _origem);   // NOVO
    p_curar_total(e);
    return e;
}

// NOVO: monta os inimigos da carta (chamada quando a carta hostil aparece)
function montar_inimigos(_c) {
    inimigos = [];
    for (var i = 0; i < array_length(_c.inimigos); i++) {
        var e = inimigo_novo(_c.inimigos[i], _c.origin);
        if (i > 0 && inimigos[i - 1].nome == e.nome) e.nome += " B";
        array_push(inimigos, e);
    }
}

// ALTERADO: recebe a origem para pintar o aliado
function aliado_novo(_nome, _origem) {
    var a = new Personagem(_nome);
    a.stats[STAT.vitalidade] = 2;
    a.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.remendo)];
    visual_aleatorio(a, CLASSE.civil, _origem);   // NOVO (se for NPC importante, use visual_fixo)
    p_curar_total(a);
    return a;
}

function carta_opcoes(_c, _s1, _r1, _s2, _r2, _s3, _r3) {
    _c.options = [
        { stat: _s1, required: _r1 },
        { stat: _s2, required: _r2 },
        { stat: _s3, required: _r3 }
    ];
}

function criar_deck_jogo() {
    var deck = [];
    var c;

    c = new Card();
    c.name = "Besta das Ruínas";
    c.description = "Uma criatura mutante bloqueia a passagem estreita do túnel subterrâneo.";
    c.tipo = CARD_TIPO.hostil;
    c.inimigos = [ENEMY_ID.besta];
    c.recompensa_valor = 3;
    array_push(deck, c);

    c = new Card();
    c.name = "Patrulha Saqueadora";
    c.description = "Um saqueador armado vigia a entrada do depósito e já viu você.";
    c.origin = CARD_ORIGIN.faction_3;
    c.tipo = CARD_TIPO.hostil;
    c.inimigos = [ENEMY_ID.saqueador];
    c.recompensa_valor = 3;
    array_push(deck, c);

    c = new Card();
    c.name = "Sentinela Defeituosa";
    c.description = "Uma máquina de vigilância antiga acorda e mira em você.";
    c.origin = CARD_ORIGIN.faction_2;
    c.tipo = CARD_TIPO.hostil;
    c.inimigos = [ENEMY_ID.sentinela];
    c.recompensa_valor = 4;
    array_push(deck, c);

    c = new Card();
    c.name = "Ninho de Mutantes";
    c.description = "Dois ratos do tamanho de cães saem do escuro, famintos.";
    c.tipo = CARD_TIPO.hostil;
    c.inimigos = [ENEMY_ID.rato, ENEMY_ID.rato];
    c.recompensa_valor = 4;
    array_push(deck, c);

    c = new Card();
    c.name = "Comerciante Errante";
    c.description = "Um sobrevivente oferece dicas sobre a região em troca de uma boa conversa.";
    c.origin = CARD_ORIGIN.faction_1;
    carta_opcoes(c, STAT.carisma, 3, STAT.sorte, 4, STAT.imaginacao, 3);
    c.fail_tempo = 2;
    c.recompensa_valor = 2;
    array_push(deck, c);

    c = new Card();
    c.name = "Terminal Antigo";
    c.description = "Um painel elétrico selado bloqueia o acesso ao depósito principal.";
    c.origin = CARD_ORIGIN.faction_2;
    c.sprite_interacao = spr_cenario_base;   // NOVO
    carta_opcoes(c, STAT.tecnica, 5, STAT.imaginacao, 4, STAT.forca, 6);
    c.fail_tempo = 3;
    c.recompensa_valor = 4;
    array_push(deck, c);

    c = new Card();
    c.name = "Reservatório Intacto";
    c.description = "Uma cisterna lacrada guarda água limpa e suprimentos médicos.";
    c.sprite_interacao = spr_cenario_base;   // NOVO
    carta_opcoes(c, STAT.tecnica, 4, STAT.imaginacao, 3, STAT.sorte, 4);
    c.recompensa = RECOMPENSA.cura;
    c.recompensa_valor = 8;
    c.fail_tempo = 2;
    array_push(deck, c);

    c = new Card();
    c.name = "Treino Improvisado";
    c.description = "Restos de uma arena de treino. Dá para aprender algo antes de seguir.";
    c.sprite_interacao = spr_cenario_base;   // NOVO
    carta_opcoes(c, STAT.vitalidade, 4, STAT.forca, 3, STAT.carisma, 3);
    c.recompensa = RECOMPENSA.stat;
    c.recompensa_stat = STAT.forca;
    c.recompensa_valor = 1;
    c.fail_tempo = 2;
    array_push(deck, c);

    c = new Card();
    c.name = "Viajante Ferido";
    c.description = "Uma sobrevivente machucada pede ajuda. Ela conhece os caminhos e sabe se virar.";
    c.tipo = CARD_TIPO.amigavel;
    c.origin = CARD_ORIGIN.faction_1;
    carta_opcoes(c, STAT.carisma, 3, STAT.imaginacao, 3, STAT.vitalidade, 4);
    c.recompensa = RECOMPENSA.aliado;
    c.aliado_nome = "Mara";
    c.fail_tempo = 2;
    array_push(deck, c);

    return deck;
}

function criar_upgrades() {
    return [
        new Upgrade("Reservas de Água", "+6 de tempo inicial", 4, UPG_EFEITO.tempo, 0, 6),
        new Upgrade("Rota Segura", "Retorno custa 2 a menos", 4, UPG_EFEITO.retorno, 0, 2),
        new Upgrade("Atalho", "Contornar custa 1 a menos", 3, UPG_EFEITO.contornar, 0, 1),
        new Upgrade("Treino de Força", "+1 FOR", 3, UPG_EFEITO.stat, STAT.forca, 1),
        new Upgrade("Sorte de Principiante", "+1 SOR", 3, UPG_EFEITO.stat, STAT.sorte, 1),
        new Upgrade("Constituição", "+1 VIT (mais HP)", 3, UPG_EFEITO.stat, STAT.vitalidade, 1),
        new Upgrade("Kit de Remendo", "Começa com a skill Remendo", 5, UPG_EFEITO.skill, SKILL_ID.remendo, 0),
        new Upgrade("Treino de Improviso", "Começa com a skill Improviso", 5, UPG_EFEITO.skill, SKILL_ID.improviso, 0)
    ];
}

// ================= HERANÇA: PONTO FIXO =================
function faccao_dominante() {
    var d = -1;
    var m = 0;
    for (var f = 0; f < FACTION.count; f++) {
        if (estoque_faccoes[f] > m) {
            m = estoque_faccoes[f];
            d = f;
        }
    }
    return d;
}

function criar_carta_fixa() {
    var d = faccao_dominante();
    var c = new Card();

    if (d == -1) {
        c.name = "Ruínas Vazias";
        c.description = "Ninguém reivindicou este ponto da trilha. Ainda.";
        c.sprite_interacao = spr_cenario_base;   // NOVO
        carta_opcoes(c, STAT.tecnica, 3, STAT.sorte, 3, STAT.imaginacao, 3);
        c.recompensa_valor = 3;
        c.fail_tempo = 2;
    } else if (d == faccao_atual) {
        c.name = "Posto da Sua Facção";
        c.description = "O trabalho das gerações anteriores ergueu este abrigo. Há água, comida e um lugar para descansar.";
        c.origin = d + 1;
        c.tipo = CARD_TIPO.posto;
        c.sprite_interacao = spr_cenario_base;   // NOVO
    } else {
        c.name = "Posto da Facção " + string(d + 1);
        c.description = "Outra facção fincou bandeira aqui, graças aos recursos que ela entregou. Eles não deixam estranhos passarem.";
        c.origin = d + 1;
        c.tipo = CARD_TIPO.hostil;
        c.inimigos = [ENEMY_ID.guarda];
        c.recompensa_valor = 6;
    }
    return c;
}

// ================= RUN =================
function acao_iniciar_run(_fac) {
    faccao_atual = _fac;
    recurso = 0;
    nivel_expedicao = 0;
    nome_area = "Ruínas de Setor 04";

    tempo_run_max = tempo_max;
    mod_retorno = 0;
    custo_contornar = 3;

    player = new Personagem("Sobrevivente F" + string(_fac + 1));
    visual_fixo(player, CLASSE.sobrevivente, origem_da_faccao(_fac), lib_player[_fac], noone);   // NOVO
    player.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.tiro)];
    party_membro = noone;

    for (var i = 0; i < array_length(upgrades); i++) {
        if (!upgrades_comprados[i]) continue;
        var u = upgrades[i];
        switch (u.efeito) {
            case UPG_EFEITO.tempo:     tempo_run_max += u.valor; break;
            case UPG_EFEITO.retorno:   mod_retorno += u.valor; break;
            case UPG_EFEITO.contornar: custo_contornar -= u.valor; break;
            case UPG_EFEITO.stat:      player.stat_mods[u.alvo] += u.valor; break;
            case UPG_EFEITO.skill:     acao_dar_skill(player, u.alvo); break;
        }
    }

    p_curar_total(player);
    tempo = tempo_run_max;
    tempo_vis = tempo;
    trilha_vis = 0;

    inimigos = [];
    popups = [];
    carta_atual = undefined;
    figura_evento = undefined;   // NOVO
    ultima_carta = undefined;
    carta_resolvida = false;
    card_msg = "";

    estado = GAME_STATE.expedition;
}

function acao_dar_skill(_p, _id) {
    var s = skill_nova(_id);
    if (array_length(_p.skills) < _p.max_skills) {
        array_push(_p.skills, s);
    } else {
        _p.skills[_p.max_skills - 1] = s;
    }
}

function mudar_tempo(_v) {
    tempo = clamp(tempo + _v, 0, tempo_run_max);
    criar_popup((_v > 0 ? "+" : "") + string(_v) + " tempo", 1100, 620, (_v > 0) ? c_lime : c_orange);
}

function calcular_custo_retorno() {
    return max(1, nivel_expedicao - mod_retorno);
}

function pode_retornar() {
    return (nivel_expedicao > 0 && tempo >= calcular_custo_retorno());
}

function acao_avancar_expedicao() {
    nivel_expedicao++;

    if (nivel_expedicao > nivel_max_expedicao) {
        acao_finalizar_run(FIM_RUN.trilha);
        return;
    }

    if (nivel_expedicao == nivel_fixo) {
        acao_mostrar_card(criar_carta_fixa());
    } else {
        acao_mostrar_card(sortear_do_deck());
    }
}

function sortear_do_deck() {
    var c = deck_global[irandom(array_length(deck_global) - 1)];
    var tentativas = 0;
    while (c == ultima_carta && tentativas < 10) {
        c = deck_global[irandom(array_length(deck_global) - 1)];
        tentativas++;
    }
    ultima_carta = c;
    return c;
}

function acao_mostrar_card(_c) {
    var ganho = 0;
    carta_atual = _c;
    carta_resolvida = false;
    card_msg = "";
    card_anim = 0;
    estado = GAME_STATE.card;

    // NOVO: define a figura do painel de evento
    figura_evento = undefined;
    if (_c.tipo == CARD_TIPO.hostil) {
        montar_inimigos(_c);
        figura_evento = inimigos[0];
    } else if (_c.tipo == CARD_TIPO.amigavel) {
        figura_evento = aliado_novo(_c.aliado_nome, _c.origin);
    } else if (_c.sprite_interacao == noone) {
        figura_evento = figurante_novo(_c.origin);
    }

    switch (_c.tipo) {
        case CARD_TIPO.hostil:
            carta_resolvida = true;
            card_msg = "Combate forçado! Clique para lutar.";
            break;
        case CARD_TIPO.posto:
            carta_resolvida = true;
            ganho = min(12, tempo_run_max - tempo);
            if (ganho > 0) mudar_tempo(ganho);
            p_curar_total(player);
            if (party_membro != noone) p_curar_total(party_membro);
            card_msg = "Você descansa no posto: tempo e HP recuperados.";
            break;
    }
}

function acao_resolver_escolha(_idx) {
    if (_idx == 3) {
        mudar_tempo(-custo_contornar);
        card_msg = "Você contornou o obstáculo e perdeu " + string(custo_contornar) + " de tempo.";
    } else {
        var opt = carta_atual.options[_idx];
        var total = stat_total(player, opt.stat);
        if (party_membro != noone) total += floor(stat_total(party_membro, opt.stat) / 2);

        var sucesso = (total >= opt.required);
        if (!sucesso) {
            var chance = min(stat_total(player, STAT.sorte) * 0.12, 0.6);
            sucesso = (random(1) < chance);
        }

        if (sucesso) {
            card_msg = "SUCESSO! " + acao_aplicar_recompensa(carta_atual);
        } else {
            mudar_tempo(-carta_atual.fail_tempo);
            card_msg = "FALHA... Você perdeu " + string(carta_atual.fail_tempo) + " de tempo.";
        }
    }
    carta_resolvida = true;
}

function acao_aplicar_recompensa(_c) {
    switch (_c.recompensa) {
        case RECOMPENSA.recurso:
            recurso += _c.recompensa_valor;
            criar_popup("+" + string(_c.recompensa_valor) + " recursos", 1050, 585, c_aqua);
            return "Você ganhou +" + string(_c.recompensa_valor) + " de recurso.";
        case RECOMPENSA.cura:
            curar_grupo(_c.recompensa_valor);
            return "O grupo recuperou " + string(_c.recompensa_valor) + " de HP.";
        case RECOMPENSA.stat:
            player.stat_mods[_c.recompensa_stat] += _c.recompensa_valor;
            if (_c.recompensa_stat == STAT.vitalidade) player.hp += _c.recompensa_valor * 3;
            return "+" + string(_c.recompensa_valor) + " " + stat_nomes[_c.recompensa_stat] + " até o fim da expedição.";
        case RECOMPENSA.aliado:
            if (party_membro == noone) {
                // ALTERADO: reaproveita o aliado que apareceu na carta (mesmo visual)
                if (_c.tipo == CARD_TIPO.amigavel) party_membro = figura_evento;
                else party_membro = aliado_novo(_c.aliado_nome, _c.origin);
                return _c.aliado_nome + " se juntou ao seu grupo!";
            }
            recurso += 3;
            return "Você já tem um aliado, então ela deixa 3 recursos de suprimento.";
    }
    return "";
}

function curar_grupo(_v) {
    var g = get_grupo();
    for (var i = 0; i < array_length(g); i++) {
        g[i].hp = min(p_hp_max(g[i]), g[i].hp + _v);
    }
}

function acao_finalizar_run(_fim) {
    var ok = (_fim == FIM_RUN.retorno || _fim == FIM_RUN.trilha);
    var rec_salvo = ok ? recurso : floor(recurso * 0.5);

    if (ok) {
        msg_fim = ((_fim == FIM_RUN.trilha) ? "Você completou a trilha!" : "Retorno à Base Realizado!")
            + "\n\nForam entregues " + string(rec_salvo) + " recursos para a base da Facção " + string(faccao_atual + 1) + ".";
    } else if (_fim == FIM_RUN.tempo) {
        msg_fim = "O Tempo Acabou!\n\nSeu personagem sucumbiu, mas " + string(rec_salvo) + " recursos foram resgatados.";
    } else {
        msg_fim = "Seu personagem caiu em combate.\n\nA equipe de resgate recuperou " + string(rec_salvo) + " recursos.";
    }

    estoque_faccoes[faccao_atual] += rec_salvo;
    reserva += rec_salvo;
    estado = GAME_STATE.run_end;
}

function acao_reencarnar() {
    faccao_atual = (faccao_atual + 1) % FACTION.count;
    estado = GAME_STATE.preparacao;
}

// ================= UPGRADES =================
function contar_upgrades_skill() {
    var n = 0;
    for (var i = 0; i < array_length(upgrades); i++) {
        if (upgrades_comprados[i] && upgrades[i].efeito == UPG_EFEITO.skill) n++;
    }
    return n;
}

function upgrade_pode_comprar(_i) {
    var u = upgrades[_i];
    if (upgrades_comprados[_i]) return false;
    if (reserva < u.custo) return false;
    if (u.efeito == UPG_EFEITO.skill && contar_upgrades_skill() >= slots_upg) return false;
    return true;
}

function acao_comprar_upgrade(_i) {
    if (!upgrade_pode_comprar(_i)) return;
    reserva -= upgrades[_i].custo;
    upgrades_comprados[_i] = true;
}

// ================= STEP: CLIQUES POR ESTADO =================
function step_expedicao() {
    if (util_in(box_avancar())) {
        acao_avancar_expedicao();
    } else if (util_in(box_retorno()) && pode_retornar()) {
        mudar_tempo(-calcular_custo_retorno());
        acao_finalizar_run(FIM_RUN.retorno);
    }
}

function step_card() {
    if (card_anim < 0.9) return;

    if (!carta_resolvida) {
        for (var i = 0; i < 4; i++) {
            if (util_in(box_opcao(i))) {
                acao_resolver_escolha(i);
                return;
            }
        }
    } else {
        if (carta_atual.tipo == CARD_TIPO.hostil) {
            acao_iniciar_combate(carta_atual);
        } else if (tempo <= 0) {
            acao_finalizar_run(FIM_RUN.tempo);
        } else {
            estado = GAME_STATE.expedition;
        }
    }
}

function step_preparacao() {
    for (var i = 0; i < array_length(upgrades); i++) {
        if (util_in(box_upg(i))) {
            acao_comprar_upgrade(i);
            return;
        }
    }
    if (util_in(box_iniciar())) acao_iniciar_run(faccao_atual);
}

// ================= ANIMAÇÃO E HOVER =================
function criar_popup(_txt, _x, _y, _cor) {
    array_push(popups, { txt: _txt, x: _x, y: _y, vida: 50, cor: _cor });
}

function tick_personagem(_p) {
    _p.hp_vis = lerp(_p.hp_vis, _p.hp, 0.15);
    if (_p.flash > 0) _p.flash--;
}

function atualizar_animacoes() {
    tempo_vis = lerp(tempo_vis, tempo, 0.1);
    hud_exp = lerp(hud_exp, (estado == GAME_STATE.combat) ? 1 : 0, 0.15);
    card_anim = lerp(card_anim, 1, 0.15);
    trilha_vis = lerp(trilha_vis, nivel_expedicao, 0.15);

    for (var i = 0; i < HV.count; i++) {
        hover_anim[i] = lerp(hover_anim[i], (hover == i) ? 1 : 0, 0.25);
    }

    tick_personagem(player);
    if (party_membro != noone) tick_personagem(party_membro);
    for (var e = 0; e < array_length(inimigos); e++) tick_personagem(inimigos[e]);

    for (var p = array_length(popups) - 1; p >= 0; p--) {
        popups[p].y -= 0.6;
        popups[p].vida -= 1;
        if (popups[p].vida <= 0) array_delete(popups, p, 1);
    }
}

function calcular_hover() {
    hover = -1;

    switch (estado) {
        case GAME_STATE.expedition:
            if (util_in(box_avancar())) hover = HV.avancar;
            else if (util_in(box_retorno()) && pode_retornar()) hover = HV.retorno;
            break;

        case GAME_STATE.card:
            if (!carta_resolvida && card_anim > 0.9) {
                for (var i = 0; i < 4; i++) {
                    if (util_in(box_opcao(i))) hover = HV.opcao + i;
                }
            }
            break;

        case GAME_STATE.combat:
            combate_hover();
            break;

        case GAME_STATE.preparacao:
            for (var j = 0; j < array_length(upgrades); j++) {
                if (util_in(box_upg(j)) && upgrade_pode_comprar(j)) hover = HV.upg + j;
            }
            if (util_in(box_iniciar())) hover = HV.iniciar;
            break;
    }

    // hover nos slots de skill fora do combate (mostra o tooltip)
    if (hover == -1 && (estado == GAME_STATE.expedition || estado == GAME_STATE.card)) {
        for (var k = 0; k < array_length(player.skills); k++) {
            if (util_in(box_skill(k))) hover = HV.skill + k;
        }
    }
}