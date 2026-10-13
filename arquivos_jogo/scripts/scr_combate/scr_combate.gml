function get_grupo() {
    var g = [player];
    if (party_membro != noone) array_push(g, party_membro);
    return g;
}

// índice do próximo membro vivo do grupo a partir de _de (ou -1)
function proximo_ator(_de) {
    var g = get_grupo();
    for (var i = _de; i < array_length(g); i++) {
        if (g[i].hp > 0) return i;
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

// Tempo gasto na rodada = maior custo entre as skills executadas.
// Para somar em vez disso, troque a linha do loop por: t += c_tempos[i];
function calcular_tempo_rodada() {
    var t = 0;
    for (var i = 0; i < array_length(c_tempos); i++) {
        t = max(t, c_tempos[i]);
    }
    return t;
}

function centro_slot(_p) {
    var b = box_slot_party(0);
    if (_p == player) {
        b = box_slot_party(0);
    } else if (_p == party_membro) {
        b = box_slot_party(1);
    } else {
        for (var i = 0; i < array_length(inimigos); i++) {
            if (inimigos[i] == _p) b = box_slot_inimigo(i);
        }
    }
    return [(b[0] + b[2]) / 2, (b[1] + b[3]) / 2];
}

// ================= INÍCIO / RODADAS =================
// ALTERADO: os inimigos já foram montados em montar_inimigos (chamada em acao_mostrar_card)
function acao_iniciar_combate(_c) {
    c_recompensa = _c.recompensa_valor;
    c_rodada = 1;
    c_resultado = COMBAT_RES.nenhum;
    c_log = [];
    combate_log("Combate iniciado!");
    combate_nova_rodada();
    estado = GAME_STATE.combat;
}

function combate_nova_rodada() {
    c_fila = [];
    c_idx = 0;
    c_tempos = [];
    c_skill = -1;
    c_ator = proximo_ator(0);
    c_fase = COMBAT_FASE.skill;
}

// insere a ação já na posição certa (ordem crescente de tempo)
function combate_enfileirar(_ator, _skill, _alvo, _lado_inimigo, _ordem) {
    var a = {
        ator: _ator,
        skill: _skill,
        alvo: _alvo,
        chave: _skill.tempo * 10 + (_lado_inimigo ? 5 : 0) + _ordem   // empate: jogador age primeiro
    };
    var i = array_length(c_fila);
    while (i > 0 && c_fila[i - 1].chave > a.chave) i--;
    array_insert(c_fila, i, a);
}

function combate_proximo_ator() {
    c_skill = -1;
    var prox = proximo_ator(c_ator + 1);
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

function combate_planejar_inimigos() {
    var g = get_grupo();
    for (var i = 0; i < array_length(inimigos); i++) {
        var e = inimigos[i];
        if (e.hp <= 0) continue;

        var s = e.skills[irandom(array_length(e.skills) - 1)];
        var alvo = e;

        if (s.tipo == SKILL_TIPO.dano) {
            var vivos = [];
            for (var j = 0; j < array_length(g); j++) {
                if (g[j].hp > 0) array_push(vivos, g[j]);
            }
            alvo = vivos[irandom(array_length(vivos) - 1)];
        }
        combate_enfileirar(e, s, alvo, true, i);
    }
}

// ================= RESOLUÇÃO =================
function combate_exec_acao(_a) {
    var at = _a.ator;
    var sk = _a.skill;
    var al = _a.alvo;

    if (at.hp <= 0) {
        combate_log(at.nome + " caiu antes de agir.");
        return;
    }
    if (al.hp <= 0) {
        combate_log(at.nome + " perdeu o alvo de " + sk.nome + ".");
        return;
    }

    array_push(c_tempos, sk.tempo);
    var v = sk.base + stat_total(at, sk.stat);
    var c = centro_slot(al);

    if (sk.tipo == SKILL_TIPO.dano) {
        al.hp = max(0, al.hp - v);
        al.flash = 12;
        combate_log(at.nome + " > " + sk.nome + " > " + al.nome + " (-" + string(v) + ")");
        criar_popup("-" + string(v), c[0], c[1], c_red);
        if (al.hp <= 0) combate_log(al.nome + " foi derrotado!");
    } else {
        al.hp = min(p_hp_max(al), al.hp + v);
        combate_log(at.nome + " > " + sk.nome + " > " + al.nome + " (+" + string(v) + ")");
        criar_popup("+" + string(v), c[0], c[1], c_lime);
    }
}

function combate_fim_rodada() {
    var t = calcular_tempo_rodada();
    if (t > 0) mudar_tempo(-t);
    combate_log("A rodada durou " + string(t) + " de tempo.");

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
        combate_log("O tempo acabou!");
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
    var sk = g[c_ator].skills;
    for (var k = 0; k < array_length(sk); k++) {
        if (util_in(box_skill(k))) {
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

    // clicar em outra skill troca a seleção
    for (var k = 0; k < array_length(ator.skills); k++) {
        if (util_in(box_skill(k))) {
            c_skill = k;
            return;
        }
    }

    // clicar num alvo válido confirma a ação
    var skill = ator.skills[c_skill];
    var contra_inimigo = (skill.tipo == SKILL_TIPO.dano);
    var lista = contra_inimigo ? inimigos : g;

    for (var i = 0; i < array_length(lista); i++) {
        var b = contra_inimigo ? box_slot_inimigo(i) : box_slot_party(i);
        if (lista[i].hp > 0 && util_in(b)) {
            combate_enfileirar(ator, skill, lista[i], false, c_ator);
            combate_proximo_ator();
            return;
        }
    }
}

function combate_step_resolver(_clicou) {
    if (_clicou) c_timer = 0;   // clique acelera
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
    switch (c_resultado) {
        case COMBAT_RES.vitoria:
            if (party_membro != noone && party_membro.hp <= 0) party_membro = noone;
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
        if (skill.tipo == SKILL_TIPO.dano) {
            for (var i = 0; i < array_length(inimigos); i++) {
                if (inimigos[i].hp > 0 && util_in(box_slot_inimigo(i))) hover = HV.alvo + i;
            }
        } else {
            for (var j = 0; j < array_length(g); j++) {
                if (g[j].hp > 0 && util_in(box_slot_party(j))) hover = HV.alvo + 2 + j;
            }
        }
    }
}