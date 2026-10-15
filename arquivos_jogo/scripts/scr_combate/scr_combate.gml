// ================= GRUPO E LADOS =================
function get_grupo() {
    var g = [player];
    for (var i = 0; i < array_length(aliados); i++) array_push(g, aliados[i]);
    return g;
}

function combate_todos() {
    var t = get_grupo();
    for (var i = 0; i < array_length(inimigos); i++) array_push(t, inimigos[i]);
    return t;
}

function eh_inimigo(_p) {
    for (var i = 0; i < array_length(inimigos); i++) {
        if (inimigos[i] == _p) return true;
    }
    return false;
}

function lista_lado(_ator, _contra) {
    if (eh_inimigo(_ator) == _contra) return get_grupo();
    return inimigos;
}

function skill_hostil(_s) {
    return (_s.tipo == SKILL_TIPO.dano || _s.tipo == SKILL_TIPO.debuff);
}

function skill_usavel(_s) {
    return (_s.cat != SKILL_CAT.missao && _s.cd <= 0);
}

function skill_tempo(_ator, _s) {
    var t = _s.tempo;
    if (status_tem(_ator, STATUS.lentidao)) t += status_valor(_ator, STATUS.lentidao);
    if (status_tem(_ator, STATUS.celeridade)) t -= status_valor(_ator, STATUS.celeridade);
    return max(1, t);
}

function proximo_ator(_de) {
    var g = get_grupo();
    for (var i = _de; i < array_length(g); i++) {
        if (g[i].hp > 0 && !g[i].pula) return i;
    }
    return -1;
}

function todos_inimigos_mortos() {
    for (var i = 0; i < array_length(inimigos); i++) {
        if (inimigos[i].hp > 0) return false;
    }
    return true;
}

function skill_selecionada() {
    if (c_fase != COMBAT_FASE.alvo) return undefined;
    var g = get_grupo();
    return g[c_ator].skills[c_skill];
}

function combate_log(_txt) {
    array_push(c_log, _txt);
    if (array_length(c_log) > 7) array_delete(c_log, 0, 1);
}

// Soma todo o tempo acumulado pelas ações na rodada
function calcular_tempo_rodada() {
    var t = 0;
    for (var i = 0; i < array_length(c_tempos); i++) {
        t += c_tempos[i];
    }
    return t;
}

function centro_slot(_p) {
    var b = box_slot_party(0);
    var g = get_grupo();
    for (var j = 0; j < array_length(g); j++) {
        if (g[j] == _p) b = box_slot_party(j);
    }
    for (var i = 0; i < array_length(inimigos); i++) {
        if (inimigos[i] == _p) b = box_slot_inimigo(i);
    }
    return [(b[0] + b[2]) / 2, (b[1] + b[3]) / 2];
}

// ================= AUXILIARES DE EFEITOS =================
// sorteia uma chance de 0 a 1
function combate_rola(_chance) {
    return (random(1) < _chance);
}

// chance baseada em SORTE: cada ponto vale 10%, teto de 90%
function combate_chance_sorte(_p) {
    return clamp(stat_total(_p, STAT.sorte) * 0.1, 0, 0.9);
}

// skills que dispensam o clique no alvo
function skill_auto_alvo(_s) {
    return (_s.so_si || _s.alcance == ALCANCE.global);
}

// escolhe um alvo válido automaticamente (undefined se não houver)
function combate_alvo_auto(_ator, _s) {
    if (_s.so_si) return _ator;
    var lado = lista_lado(_ator, skill_hostil(_s));
    for (var i = 0; i < array_length(lado); i++) {
        if (lado[i].hp <= 0) continue;
        if (_s.exclui_si && lado[i] == _ator) continue;
        return lado[i];
    }
    return undefined;
}

// cura o usuário e os aliados ao lado dele
function combate_cura_adjacentes(_at, _v) {
    var lado = lista_lado(_at, false);
    var ia = combate_indice(lado, _at);
    for (var i = 0; i < array_length(lado); i++) {
        var p = lado[i];
        if (p.hp <= 0 || abs(i - ia) > 1) continue;
        p.hp = min(p_hp_max(p), p.hp + _v);
        var c = centro_slot(p);
        criar_popup("+" + string(_v), c[0], c[1], c_lime);
    }
}

// ================= INÍCIO / RODADAS =================
function combate_resetar_grupo() {
    var g = get_grupo();
    for (var i = 0; i < array_length(g); i++) {
        status_limpar(g[i]);
        g[i].defendendo = false;
        g[i].pose = POSE.idle;
        for (var k = 0; k < array_length(g[i].skills); k++) g[i].skills[k].cd = 0;
    }
}

function acao_iniciar_combate(_c) {
    c_recompensa = _c.recompensa_valor;
    c_rodada = 1;
    c_resultado = COMBAT_RES.nenhum;
    c_log = [];
    particulas = [];
    combate_resetar_grupo();
    combate_log("Combate iniciado!");
    combate_nova_rodada();
    estado = GAME_STATE.combat;
}

function combate_nova_rodada() {
    c_fila = [];
    c_idx = 0;
    c_tempos = [];
    c_skill = -1;

    var todos = combate_todos();
    for (var j = 0; j < array_length(todos); j++) {
        var p = todos[j];
        p.defendendo = false;
        p.pula = false;
        if (p.hp > 0) p.pose = POSE.idle;
        if (p.hp > 0 && status_tem(p, STATUS.atordoamento)) {
            p.pula = true;
            status_consumir(p, STATUS.atordoamento);
            combate_log(p.nome + " está atordoado e perde o turno.");
        }
    }

    combate_avancar_ator(0);
}

function combate_enfileirar(_ator, _skill, _alvo, _lado_inimigo, _ordem) {
    var t = skill_tempo(_ator, _skill);
    var a = {
        ator: _ator,
        skill: _skill,
        alvo: _alvo,
        tempo: t,
        inimigo: _lado_inimigo,
        chave: t * 10 + (_lado_inimigo ? 5 : 0) + _ordem
    };
    var i = array_length(c_fila);
    while (i > 0 && c_fila[i - 1].chave > a.chave) i--;
    array_insert(c_fila, i, a);
}

function combate_avancar_ator(_de) {
    c_skill = -1;
    var prox = proximo_ator(_de);
    if (prox == -1) {
        combate_planejar_inimigos();
        c_idx = 0;
        c_timer = 30;
        c_fase = COMBAT_FASE.resolver;
    } else {
        c_ator = prox;
        c_fase = COMBAT_FASE.skill;
    }
}

function combate_proximo_ator() {
    combate_avancar_ator(c_ator + 1);
}

function combate_planejar_inimigos() {
    for (var i = 0; i < array_length(inimigos); i++) {
        var e = inimigos[i];
        if (e.hp <= 0 || e.pula) continue;

        var disp = [];
        for (var k = 0; k < array_length(e.skills); k++) {
            if (skill_usavel(e.skills[k])) array_push(disp, e.skills[k]);
        }
        if (array_length(disp) == 0) continue;
        var s = disp[irandom(array_length(disp) - 1)];

        // skill só em si: o alvo é o próprio inimigo
        if (s.so_si) {
            combate_enfileirar(e, s, e, true, i);
            continue;
        }

        var lado = lista_lado(e, skill_hostil(s));
        var vivos = [];
        for (var j = 0; j < array_length(lado); j++) {
            if (lado[j].hp <= 0) continue;
            if (s.exclui_si && lado[j] == e) continue;
            array_push(vivos, lado[j]);
        }
        if (array_length(vivos) == 0) continue;

        var alvo = vivos[irandom(array_length(vivos) - 1)];
        combate_enfileirar(e, s, alvo, true, i);
    }
}

// ================= RESOLUÇÃO =================
function combate_indice(_lista, _p) {
    for (var i = 0; i < array_length(_lista); i++) {
        if (_lista[i] == _p) return i;
    }
    return -1;
}

function combate_alvos(_a) {
    var sk = _a.skill;
    var lista = lista_lado(_a.ator, skill_hostil(sk));
    var res = [];

    if (sk.so_si) {
        if (_a.ator.hp > 0) array_push(res, _a.ator);
        return res;
    }

    if (sk.alcance != ALCANCE.global && _a.alvo.hp <= 0) return res;

    var ia = combate_indice(lista, _a.alvo);
    for (var i = 0; i < array_length(lista); i++) {
        var p = lista[i];
        if (p.hp <= 0) continue;
        if (sk.exclui_si && p == _a.ator) continue;
        switch (sk.alcance) {
            case ALCANCE.unico:
                if (p == _a.alvo) array_push(res, p);
                break;
            case ALCANCE.adjacente:
                if (abs(i - ia) <= 1) array_push(res, p);
                break;
            case ALCANCE.global:
                array_push(res, p);
                break;
        }
    }
    return res;
}

function combate_exec_acao(_a) {
    var at = _a.ator;
    var sk = _a.skill;

    var todos = combate_todos();
    for (var j = 0; j < array_length(todos); j++) {
        if (todos[j].hp > 0) todos[j].pose = POSE.idle;
    }

    if (at.hp <= 0) {
        combate_log(at.nome + " caiu antes de agir.");
        return;
    }
    if (status_tem(at, STATUS.atordoamento)) {
        status_consumir(at, STATUS.atordoamento);
        combate_log(at.nome + " está atordoado e perde a ação.");
        return;
    }

    // REGISTRO DE TEMPO: Toda ação executada adiciona seu tempo ao total do turno
    array_push(c_tempos, _a.tempo);

    var alvos = combate_alvos(_a);
    if (array_length(alvos) == 0) {
        combate_log(at.nome + " perdeu o alvo de " + sk.nome + ".");
        return;
    }

    if (sk.cat == SKILL_CAT.basico) {
        at.pose = POSE.atq_basico;
    } else {
        at.pose = POSE.habilidade;
    }

    var txt_log = "";
    var aplicou = false;   // algum status entrou de fato (para o log)

    for (var i = 0; i < array_length(alvos); i++) {
        var al = alvos[i];
        var c = centro_slot(al);
        var v = sk.base + stat_total(at, sk.stat);
        var txt = "";
        var morte = false;

        if (sk.alcance == ALCANCE.adjacente && al != _a.alvo) v = max(1, floor(v / 2));
        var v_cru = v;   // valor antes de defesa (usado por espelho e cura_adj)

        switch (sk.tipo) {
            case SKILL_TIPO.dano:
                al.pose = POSE.dano;

                // morte instantânea
                if (sk.instakill > 0) {
                    var ch_k = min(sk.instakill + stat_total(at, sk.stat) * 0.02, 0.5);
                    if (combate_rola(ch_k)) {
                        v = al.hp;
                        morte = true;
                    }
                }

                if (al.defendendo && !morte) {
                    v = round(v * (1 - DEFENDER_REDUCAO));
                    txt = "-" + string(v) + " (Defendido!)";
                    combate_log(al.nome + " bloqueou o ataque!");
                } else {
                    txt = morte ? "MORTE INSTANTÂNEA!" : "-" + string(v);
                }

                al.hp = max(0, al.hp - v);
                al.flash = 12;
                criar_popup(txt, c[0], c[1], (al.defendendo && !morte) ? c_aqua : c_red);
                if (al.hp <= 0) combate_log(al.nome + " foi derrotado!");

                // Superaquecido: todo dano causado queima o alvo
                if (status_tem(at, STATUS.superaquecido) && al.hp > 0) {
                    status_aplicar(al, STATUS.queimadura, 3, 1);
                    criar_popup(status_nome(STATUS.queimadura), c[0], c[1] - 24, status_cor(STATUS.queimadura));
                }

                // espelho: o usuário sofre o mesmo dano (ignora Defender)
                if (sk.espelho && i == 0) {
                    var ca = centro_slot(at);
                    at.hp = max(0, at.hp - v_cru);
                    at.flash = 12;
                    at.pose = POSE.dano;
                    criar_popup("-" + string(v_cru), ca[0], ca[1], c_purple);
                    combate_log(at.nome + " sofre " + string(v_cru) + " de dano próprio.");
                    if (at.hp <= 0) combate_log(at.nome + " foi derrotado!");
                }

                // cura o usuário e aliados adjacentes (ex: Raio de Luz)
                if (sk.cura_adj && i == 0) combate_cura_adjacentes(at, v_cru);
                break;

            case SKILL_TIPO.cura:
            case SKILL_TIPO.restaurar:
                if (sk.cura_total) v = p_hp_max(al) - al.hp;
                al.hp = min(p_hp_max(al), al.hp + v);
                txt = "+" + string(v);
                criar_popup("+" + string(v), c[0], c[1], c_lime);
                if (sk.tipo == SKILL_TIPO.restaurar) status_remover_negativos(al);
                break;

            case SKILL_TIPO.defesa:
                al.defendendo = true;
                al.pose = POSE.dano;
                txt = "Defendendo";
                criar_popup("Defendendo!", c[0], c[1], c_aqua);
                break;

            case SKILL_TIPO.recarga:
                for (var k = 0; k < array_length(al.skills); k++) {
                    al.skills[k].cd = max(0, al.skills[k].cd - sk.base);
                }
                txt = "recarga -" + string(sk.base);
                criar_popup("Recarga -" + string(sk.base), c[0], c[1], c_aqua);
                break;
        }

        // efeito principal (com chance)
        if (sk.efeito != -1 && al.hp > 0 && combate_rola(sk.chance)) {
            status_aplicar(al, sk.efeito, sk.ef_dur, sk.ef_val);
            criar_popup(status_nome(sk.efeito), c[0], c[1] - 24, status_cor(sk.efeito));
            aplicou = true;
        }

        // segundo efeito (com chance própria)
        if (sk.efeito2 != -1 && al.hp > 0 && combate_rola(sk.ef2_chance)) {
            status_aplicar(al, sk.efeito2, sk.ef2_dur, 1);
            criar_popup(status_nome(sk.efeito2), c[0], c[1] - 44, status_cor(sk.efeito2));
        }

        // chance de dar Defender (no alvo ou em si)
        var ch_def = sk.def_por_sorte ? combate_chance_sorte(at) : sk.def_chance;
        if (ch_def > 0 && combate_rola(ch_def)) {
            var dest = sk.def_em_si ? at : al;
            if (dest.hp > 0) {
                var cd_ = centro_slot(dest);
                dest.defendendo = true;
                criar_popup("Defendendo!", cd_[0], cd_[1] - 64, c_aqua);
            }
        }

        if (sk.particula != noone) criar_particula(sk.particula, c[0], c[1]);

        if (i == 0) txt_log = txt;
    }

    // status que a skill aplica no próprio usuário (ex: Respiração Profunda)
    if (at.hp > 0) {
        var cs = centro_slot(at);
        for (var m = 0; m < array_length(sk.auto_efeitos); m++) {
            var ae = sk.auto_efeitos[m];
            status_aplicar(at, ae.ef, ae.dur, ae.val);
            criar_popup(status_nome(ae.ef), cs[0], cs[1] - 24 - m * 20, status_cor(ae.ef));
        }
    }

    sk.cd = (sk.cd_max > 0) ? sk.cd_max + 1 : 0;

    var nome_alvo = (array_length(alvos) > 1) ? "todos" : alvos[0].nome;
    var detalhe = txt_log;
    if (sk.efeito != -1 && aplicou) detalhe += ((detalhe == "") ? "" : " ") + status_nome(sk.efeito);
    combate_log(at.nome + " > " + sk.nome + " > " + nome_alvo + " (" + detalhe + ")");
}

function combate_tick_status() {
    var todos = combate_todos();
    for (var j = 0; j < array_length(todos); j++) {
        var p = todos[j];
        if (p.hp <= 0) continue;
        var c = centro_slot(p);

        for (var k = array_length(p.status) - 1; k >= 0; k--) {
            var s = p.status[k];
            var dano = 0;
            if (s.ef == STATUS.queimadura) dano = s.val;
            if (s.ef == STATUS.corrosao) {
                dano = s.acc;
                s.acc += s.val;
            }

            // regeneração: cura s.val por turno
            if (s.ef == STATUS.regeneracao) {
                var cura = min(s.val, p_hp_max(p) - p.hp);
                if (cura > 0) {
                    p.hp += cura;
                    criar_popup("+" + string(cura), c[0], c[1], c_lime);
                    combate_log(p.nome + " regenera " + string(cura) + ".");
                }
            }

            if (dano > 0) {
                p.hp = max(0, p.hp - dano);
                p.flash = 12;
                p.pose = POSE.dano;
                criar_popup("-" + string(dano), c[0], c[1], status_cor(s.ef));
                combate_log(p.nome + " sofre " + string(dano) + " de " + status_nome(s.ef) + ".");
                if (p.hp <= 0) combate_log(p.nome + " foi derrotado!");
            }

            if (s.ef != STATUS.atordoamento) {
                s.dur--;
                if (s.dur <= 0) array_delete(p.status, k, 1);
            }
            if (p.hp <= 0) break;
        }
    }
}

function combate_tick_cooldowns() {
    var todos = combate_todos();
    for (var j = 0; j < array_length(todos); j++) {
        var sk = todos[j].skills;
        for (var k = 0; k < array_length(sk); k++) {
            if (sk[k].cd > 0) sk[k].cd--;
        }
    }
}

function combate_fim_rodada() {
    var t = calcular_tempo_rodada();
    if (t > 0) mudar_tempo(-t);
    combate_log("A rodada consumiu +" + string(t) + " min no relógio.");

    combate_tick_status();
    combate_tick_cooldowns();

    var todos = combate_todos();
    for (var i = 0; i < array_length(todos); i++) {
        if (todos[i].hp > 0) todos[i].pose = POSE.idle;
    }

    if (player.hp <= 0) {
        c_resultado = COMBAT_RES.derrota;
        combate_log("Você caiu...");
        c_fase = COMBAT_FASE.fim;
    } else if (todos_inimigos_mortos()) {
        recurso += c_recompensa;
        c_resultado = COMBAT_RES.vitoria;
        combate_log("Vitória! +" + string(c_recompensa) + " recursos.");
        criar_popup("+" + string(c_recompensa) + " recursos", 1050, 585, c_aqua);
        c_fase = COMBAT_FASE.fim;
    } else if (tempo <= 0) {
        c_resultado = COMBAT_RES.tempo;
        combate_log("O Sol Nasceu! (06:00 AM)");
        c_fase = COMBAT_FASE.fim;
    } else {
        c_rodada++;
        combate_nova_rodada();
    }
}

// ================= STEP DO COMBATE =================
function step_combate(_clicou, _clicou_dir) {
    switch (c_fase) {
        case COMBAT_FASE.skill:    combate_step_skill(_clicou); break;
        case COMBAT_FASE.alvo:     combate_step_alvo(_clicou, _clicou_dir); break;
        case COMBAT_FASE.resolver: combate_step_resolver(_clicou); break;
        case COMBAT_FASE.fim:      if (_clicou) combate_step_fim(); break;
    }
}

function combate_step_skill(_clicou) {
    if (!_clicou) return;
    var g = get_grupo();
    var ator = g[c_ator];
    var sk = ator.skills;
    for (var k = 0; k < array_length(sk); k++) {
        if (util_in(box_skill(k))) {
            if (!skill_usavel(sk[k])) return;

            // skills globais ou só em si entram direto na fila
            if (skill_auto_alvo(sk[k])) {
                var al = combate_alvo_auto(ator, sk[k]);
                if (al == undefined) {
                    combate_log("Sem alvos válidos para " + sk[k].nome + ".");
                    return;
                }
                combate_enfileirar(ator, sk[k], al, false, c_ator);
                combate_proximo_ator();
                return;
            }

            c_skill = k;
            c_fase = COMBAT_FASE.alvo;
            return;
        }
    }
}

function combate_step_alvo(_clicou, _clicou_dir) {
    if (_clicou_dir) {
        c_skill = -1;
        c_fase = COMBAT_FASE.skill;
        return;
    }
    if (!_clicou) return;

    var g = get_grupo();
    var ator = g[c_ator];

    // clicou em outra skill: troca (ou já enfileira, se for automática)
    for (var k = 0; k < array_length(ator.skills); k++) {
        if (util_in(box_skill(k))) {
            if (skill_usavel(ator.skills[k])) {
                if (skill_auto_alvo(ator.skills[k])) {
                    c_skill = -1;
                    c_fase = COMBAT_FASE.skill;
                    combate_step_skill(true);
                } else {
                    c_skill = k;
                }
            }
            return;
        }
    }

    var skill = ator.skills[c_skill];
    var lista = skill_hostil(skill) ? inimigos : g;

    for (var i = 0; i < array_length(lista); i++) {
        var b = skill_hostil(skill) ? box_slot_inimigo(i) : box_slot_party(i);
        if (lista[i].hp > 0 && util_in(b)) {
            combate_enfileirar(ator, skill, lista[i], false, c_ator);
            combate_proximo_ator();
            return;
        }
    }
}

function combate_step_resolver(_clicou) {
    if (_clicou) c_timer = 0;
    c_timer--;
    if (c_timer > 0) return;

    if (c_idx < array_length(c_fila)) {
        combate_exec_acao(c_fila[c_idx]);
        c_idx++;
        c_timer = 45;
    } else {
        combate_fim_rodada();
    }
}

function combate_step_fim() {
    combate_resetar_grupo();
    switch (c_resultado) {
        case COMBAT_RES.vitoria:
            remover_aliados_mortos();
            pos_vitoria_carta();
            if (tempo <= 0) acao_finalizar_run(FIM_RUN.tempo);
            else estado = GAME_STATE.expedition;
            break;
        case COMBAT_RES.derrota:
            acao_finalizar_run(FIM_RUN.derrota);
            break;
        case COMBAT_RES.tempo:
            acao_finalizar_run(FIM_RUN.tempo);
            break;
    }
}

function combate_hover() {
    var g = get_grupo();

    if (c_fase == COMBAT_FASE.skill || c_fase == COMBAT_FASE.alvo) {
        var sk = g[c_ator].skills;
        for (var k = 0; k < array_length(sk); k++) {
            if (util_in(box_skill(k))) hover = HV.skill + k;
        }
    }

    if (c_fase == COMBAT_FASE.alvo) {
        var skill = g[c_ator].skills[c_skill];
        if (skill_hostil(skill)) {
            for (var i = 0; i < array_length(inimigos); i++) {
                if (inimigos[i].hp > 0 && util_in(box_slot_inimigo(i))) hover = HV.alvo + i;
            }
        } else {
            for (var j = 0; j < array_length(g); j++) {
                if (g[j].hp > 0 && util_in(box_slot_party(j))) hover = HV.alvo + 4 + j;
            }
        }
    }
}