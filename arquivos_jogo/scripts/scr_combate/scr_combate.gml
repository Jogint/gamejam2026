// ================= GRUPO E LADOS =================
function get_grupo() {
    var g = [player];
    for (var i = 0; i < array_length(aliados); i++) array_push(g, aliados[i]);
    return g;
}

// NOVO: grupo + inimigos
function combate_todos() {
    var t = get_grupo();
    for (var i = 0; i < array_length(inimigos); i++) array_push(t, inimigos[i]);
    return t;
}

// NOVO
function eh_inimigo(_p) {
    for (var i = 0; i < array_length(inimigos); i++) {
        if (inimigos[i] == _p) return true;
    }
    return false;
}

// NOVO: lista do lado oposto ao ator (_contra = true) ou do mesmo lado dele (false)
function lista_lado(_ator, _contra) {
    if (eh_inimigo(_ator) == _contra) return get_grupo();
    return inimigos;
}

// NOVO: dano e debuff vão contra o lado oposto; o resto é no próprio lado
function skill_hostil(_s) {
    return (_s.tipo == SKILL_TIPO.dano || _s.tipo == SKILL_TIPO.debuff);
}

// NOVO: skill de missão nunca é usável; as demais só fora de recarga
function skill_usavel(_s) {
    return (_s.cat != SKILL_CAT.missao && _s.cd <= 0);
}

// NOVO: custo de tempo com lentidão (+) e celeridade (-)
function skill_tempo(_ator, _s) {
    var t = _s.tempo;
    if (status_tem(_ator, STATUS.lentidao)) t += status_valor(_ator, STATUS.lentidao);
    if (status_tem(_ator, STATUS.celeridade)) t -= status_valor(_ator, STATUS.celeridade);
    return max(1, t);
}

// índice do próximo membro do grupo que pode agir a partir de _de (ou -1)
function proximo_ator(_de) {
    var g = get_grupo();
    for (var i = _de; i < array_length(g); i++) {
        if (g[i].hp > 0 && !g[i].pula) return i;   // ALTERADO: atordoado pula
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
    var g = get_grupo();
    for (var j = 0; j < array_length(g); j++) {
        if (g[j] == _p) b = box_slot_party(j);
    }
    for (var i = 0; i < array_length(inimigos); i++) {
        if (inimigos[i] == _p) b = box_slot_inimigo(i);
    }
    return [(b[0] + b[2]) / 2, (b[1] + b[3]) / 2];
}

// ================= INÍCIO / RODADAS =================
// NOVO: zera status e recargas do grupo
function combate_resetar_grupo() {
    var g = get_grupo();
    for (var i = 0; i < array_length(g); i++) {
        status_limpar(g[i]);
        for (var k = 0; k < array_length(g[i].skills); k++) g[i].skills[k].cd = 0;
    }
}

// os inimigos já foram montados em montar_inimigos (chamada em acao_mostrar_card)
function acao_iniciar_combate(_c) {
    c_recompensa = _c.recompensa_valor;
    c_rodada = 1;
    c_resultado = COMBAT_RES.nenhum;
    c_log = [];
    particulas = [];            // NOVO
    combate_resetar_grupo();    // NOVO
    combate_log("Combate iniciado!");
    combate_nova_rodada();
    estado = GAME_STATE.combat;
}

function combate_nova_rodada() {
    c_fila = [];
    c_idx = 0;
    c_tempos = [];
    c_skill = -1;

    // NOVO: atordoados perdem este turno (gasta 1 carga do atordoamento)
    var todos = combate_todos();
    for (var j = 0; j < array_length(todos); j++) {
        var p = todos[j];
        p.pula = false;
        if (p.hp > 0 && status_tem(p, STATUS.atordoamento)) {
            p.pula = true;
            status_consumir(p, STATUS.atordoamento);
            combate_log(p.nome + " está atordoado e perde o turno.");
        }
    }

    combate_avancar_ator(0);
}

// insere a ação já na posição certa (ordem crescente de tempo)
function combate_enfileirar(_ator, _skill, _alvo, _lado_inimigo, _ordem) {
    var t = skill_tempo(_ator, _skill);   // NOVO: já considera lentidão/celeridade
    var a = {
        ator: _ator,
        skill: _skill,
        alvo: _alvo,
        tempo: t,
        inimigo: _lado_inimigo,
        chave: t * 10 + (_lado_inimigo ? 5 : 0) + _ordem   // empate: jogador age primeiro
    };
    var i = array_length(c_fila);
    while (i > 0 && c_fila[i - 1].chave > a.chave) i--;
    array_insert(c_fila, i, a);
}

// ALTERADO: vai para o próximo ator que pode agir; se não houver, resolve a rodada
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

// ALTERADO: só usa skills fora de recarga; alvo depende do tipo da skill
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

        var lado = lista_lado(e, skill_hostil(s));
        var vivos = [];
        for (var j = 0; j < array_length(lado); j++) {
            if (lado[j].hp > 0) array_push(vivos, lado[j]);
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

// NOVO: quem de fato é atingido (único, adjacentes ou todos), só os vivos
function combate_alvos(_a) {
    var sk = _a.skill;
    var lista = lista_lado(_a.ator, skill_hostil(sk));
    var res = [];

    if (sk.alcance != ALCANCE.global && _a.alvo.hp <= 0) return res;   // perdeu o alvo

    var ia = combate_indice(lista, _a.alvo);
    for (var i = 0; i < array_length(lista); i++) {
        var p = lista[i];
        if (p.hp <= 0) continue;
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

// ALTERADO: status, alcance, recarga, partículas
function combate_exec_acao(_a) {
    var at = _a.ator;
    var sk = _a.skill;

    if (at.hp <= 0) {
        combate_log(at.nome + " caiu antes de agir.");
        return;
    }
    if (status_tem(at, STATUS.atordoamento)) {
        status_consumir(at, STATUS.atordoamento);
        combate_log(at.nome + " está atordoado e perde a ação.");
        return;
    }

    var alvos = combate_alvos(_a);
    if (array_length(alvos) == 0) {
        combate_log(at.nome + " perdeu o alvo de " + sk.nome + ".");
        return;
    }

    if (!_a.inimigo || TEMPO_CONTA_INIMIGO) array_push(c_tempos, _a.tempo);

    var txt_log = "";
    for (var i = 0; i < array_length(alvos); i++) {
        var al = alvos[i];
        var c = centro_slot(al);
        var v = sk.base + stat_total(at, sk.stat);
        var txt = "";

        // adjacentes (que não são o alvo clicado) levam metade
        if (sk.alcance == ALCANCE.adjacente && al != _a.alvo) v = max(1, floor(v / 2));

        switch (sk.tipo) {
            case SKILL_TIPO.dano:
                al.hp = max(0, al.hp - v);
                al.flash = 12;
                txt = "-" + string(v);
                criar_popup("-" + string(v), c[0], c[1], c_red);
                if (al.hp <= 0) combate_log(al.nome + " foi derrotado!");
                break;
            case SKILL_TIPO.cura:
            case SKILL_TIPO.restaurar:
                al.hp = min(p_hp_max(al), al.hp + v);
                txt = "+" + string(v);
                criar_popup("+" + string(v), c[0], c[1], c_lime);
                if (sk.tipo == SKILL_TIPO.restaurar) status_remover_negativos(al);
                break;
            case SKILL_TIPO.recarga:
                for (var k = 0; k < array_length(al.skills); k++) {
                    al.skills[k].cd = max(0, al.skills[k].cd - sk.base);
                }
                txt = "recarga -" + string(sk.base);
                criar_popup("Recarga -" + string(sk.base), c[0], c[1], c_aqua);
                break;
        }

        if (sk.efeito != -1 && al.hp > 0) {
            status_aplicar(al, sk.efeito, sk.ef_dur, sk.ef_val);
            criar_popup(status_nome(sk.efeito), c[0], c[1] - 24, status_cor(sk.efeito));
        }

        if (sk.particula != noone) criar_particula(sk.particula, c[0], c[1]);

        if (i == 0) txt_log = txt;
    }

    // a recarga começa depois do efeito (senão a Sincronia reduziria a própria recarga)
    // +1 porque o fim desta mesma rodada já desconta 1
    sk.cd = (sk.cd_max > 0) ? sk.cd_max + 1 : 0;

    var nome_alvo = (array_length(alvos) > 1) ? "todos" : alvos[0].nome;
    var detalhe = txt_log;
    if (sk.efeito != -1) detalhe += ((detalhe == "") ? "" : " ") + status_nome(sk.efeito);
    combate_log(at.nome + " > " + sk.nome + " > " + nome_alvo + " (" + detalhe + ")");
}

// NOVO: queimadura (fixo) e corrosão (cresce a cada tick) no fim da rodada
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

            if (dano > 0) {
                p.hp = max(0, p.hp - dano);
                p.flash = 12;
                criar_popup("-" + string(dano), c[0], c[1], status_cor(s.ef));
                combate_log(p.nome + " sofre " + string(dano) + " de " + status_nome(s.ef) + ".");
                if (p.hp <= 0) combate_log(p.nome + " foi derrotado!");
            }

            // atordoamento não expira por tempo: acaba quando faz perder a ação
            if (s.ef != STATUS.atordoamento) {
                s.dur--;
                if (s.dur <= 0) array_delete(p.status, k, 1);
            }
            if (p.hp <= 0) break;
        }
    }
}

// NOVO
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
    combate_log("A rodada durou " + string(t) + " de tempo.");

    combate_tick_status();      // NOVO
    combate_tick_cooldowns();   // NOVO

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
            if (!skill_usavel(sk[k])) return;   // ALTERADO: missão ou em recarga
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
            if (skill_usavel(ator.skills[k])) c_skill = k;   // ALTERADO
            return;
        }
    }

    // clicar num alvo válido confirma a ação (em skill global, qualquer alvo válido serve)
    var skill = ator.skills[c_skill];
    var lista = skill_hostil(skill) ? inimigos : g;   // ALTERADO

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
    combate_resetar_grupo();   // NOVO: status e recargas não passam para fora do combate
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
        if (skill_hostil(skill)) {   // ALTERADO
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