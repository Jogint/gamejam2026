// ================= HABILIDADES DE CLASSE =================
// guarda quais das 25 skills foram desbloqueadas e equipadas, por facção.
// índice i = coluna * 5 + linha  (mesma ordem do spr_skills); linha 0 = ataque básico
// hab_slots[f][0] = ataque básico (obrigatório, começa como Golpe); [1] e [2] = habilidades (-1 = vazio)

function hab_iniciar() {
    hab_desbloq = [];
    hab_slots = [];
    for (var f = 0; f < FACTION.count; f++) {
        hab_desbloq[f] = array_create(HAB_TOTAL, false);
        hab_slots[f] = array_create(HAB_SLOTS, -1);
        hab_slots[f][0] = SKILL_ID.golpe;
    }
    hab_catalogo = [];
    for (var i = 0; i < HAB_TOTAL; i++) {
        hab_catalogo[i] = skill_nova(SKILL_ID.mine_basico + i);
    }
    hab_golpe = skill_nova(SKILL_ID.golpe);
    hab_msg = "";
}

function hab_nome_classe(_c) {
    switch (_c) {
        case 0: return "Mineirador";
        case 1: return "Menestrel";
        case 2: return "Acólito";
        case 3: return "Escudeiro";
        case 4: return "Lunático";
    }
    return "?";
}

function hab_custo(_l) {
    return 2 + _l * 2;
}

function hab_eh_basico(_i) {
    return ((_i mod HAB_LINHAS) == 0);
}

// devolve a skill (para desenhar) de um id equipado: de classe ou o Golpe padrão
function hab_skill_por_id(_sid) {
    if (_sid >= SKILL_ID.mine_basico) return hab_catalogo[_sid - SKILL_ID.mine_basico];
    return hab_golpe;
}

function box_hab(_c, _l) {
    var x1 = 30 + _c * 245;
    var y1 = 100 + _l * 74;
    return [x1, y1, x1 + 235, y1 + 62];
}

function box_hab_remover() { return [260, 640, 500, 690]; }

// posição do id nos slots equipados da facção atual (-1 se não equipada)
function hab_pos_slot(_sid) {
    var s = hab_slots[faccao_atual];
    for (var k = 0; k < array_length(s); k++) {
        if (s[k] == _sid) return k;
    }
    return -1;
}

// primeiro slot de habilidade livre (1 ou 2); -1 se cheios. O slot 0 é só do básico
function hab_slot_livre() {
    var s = hab_slots[faccao_atual];
    for (var k = 1; k < HAB_SLOTS; k++) {
        if (s[k] == -1) return k;
    }
    return -1;
}

function hab_pode_comprar(_i) {
    var l = _i mod HAB_LINHAS;
    if (hab_desbloq[faccao_atual][_i]) return false;
    if (l > 0 && !hab_desbloq[faccao_atual][_i - 1]) return false;
    return (reserva[faccao_atual] >= hab_custo(l));
}

function acao_hab_clicar(_i) {
    var f = faccao_atual;
    var sid = SKILL_ID.mine_basico + _i;
    var l = _i mod HAB_LINHAS;
    hab_msg = "";

    if (hab_desbloq[f][_i]) {
        // ataque básico: único e obrigatório. Clicar de novo volta para o Golpe
        if (hab_eh_basico(_i)) {
            if (hab_slots[f][0] == sid) {
                hab_slots[f][0] = SKILL_ID.golpe;
                hab_msg = "Ataque básico: Golpe (padrão).";
            } else {
                hab_slots[f][0] = sid;
            }
            return;
        }

        var pos = hab_pos_slot(sid);
        if (pos != -1) {
            hab_slots[f][pos] = -1;          // desequipa
            return;
        }
        var livre = hab_slot_livre();
        if (livre == -1) {
            hab_msg = "Slots cheios! Clique numa habilidade equipada para liberar espaço.";
            return;
        }
        hab_slots[f][livre] = sid;           // equipa
        return;
    }

    if (hab_pode_comprar(_i)) {
        reserva[f] -= hab_custo(l);
        hab_desbloq[f][_i] = true;
        if (hab_eh_basico(_i)) {
            hab_slots[f][0] = sid;           // o básico comprado já substitui o atual
        } else {
            var livre2 = hab_slot_livre();
            if (livre2 != -1) hab_slots[f][livre2] = sid;
        }
    } else if (l > 0 && !hab_desbloq[f][_i - 1]) {
        hab_msg = "Desbloqueie a habilidade anterior primeiro.";
    } else {
        hab_msg = "Recursos insuficientes (custo: " + string(hab_custo(l)) + ").";
    }
}

// tira todas as habilidades equipadas e volta o ataque básico para o Golpe
function acao_hab_remover_todas() {
    var f = faccao_atual;
    hab_slots[f][0] = SKILL_ID.golpe;
    for (var k = 1; k < HAB_SLOTS; k++) hab_slots[f][k] = -1;
    hab_msg = "Habilidades removidas. Ataque básico: Golpe.";
}

// aplica o equipado ao personagem no início da run:
// 1) o ataque básico escolhido (sempre) 2) as habilidades equipadas 3) o que sobrar de vaga
//    é preenchido com as skills que ele já tinha (nunca outro ataque básico)
function hab_aplicar_equipadas(_p, _fac) {
    var antigas = _p.skills;
    var nova = [];

    var basico = hab_slots[_fac][0];
    if (basico < 0) basico = SKILL_ID.golpe;
    array_push(nova, skill_nova(basico));

    for (var k = 1; k < HAB_SLOTS; k++) {
        var sid = hab_slots[_fac][k];
        if (sid != -1) array_push(nova, skill_nova(sid));
    }

    for (var a = 0; a < array_length(antigas); a++) {
        if (array_length(nova) >= _p.max_skills) break;
        if (antigas[a].cat == SKILL_CAT.basico) continue;
        var repetida = false;
        for (var n = 0; n < array_length(nova); n++) {
            if (nova[n].nome == antigas[a].nome) repetida = true;
        }
        if (!repetida) array_push(nova, antigas[a]);
    }
    _p.skills = nova;
}

// ================= POOL PARA INIMIGOS =================
function lista_tem(_arr, _v) {
    for (var i = 0; i < array_length(_arr); i++) {
        if (_arr[i] == _v) return true;
    }
    return false;
}

// todas as skills já desbloqueadas (árvore de melhorias + habilidades de classe), de qualquer facção
function skills_desbloqueadas() {
    var lista = [];
    for (var f = 0; f < FACTION.count; f++) {
        for (var i = 0; i < array_length(upgrades); i++) {
            if (!upgrades_comprados[f][i]) continue;
            var u = upgrades[i];
            if (u.efeito != UPG_EFEITO.skill && u.efeito != UPG_EFEITO.basico) continue;
            if (!lista_tem(lista, u.alvo)) array_push(lista, u.alvo);
        }
        for (var h = 0; h < HAB_TOTAL; h++) {
            if (!hab_desbloq[f][h]) continue;
            var sid = SKILL_ID.mine_basico + h;
            if (!lista_tem(lista, sid)) array_push(lista, sid);
        }
    }
    return lista;
}

// ================= SKILLS ALEATÓRIAS PARA ALIADOS =================
// dá ao aliado Golpe + até _n skills desbloqueadas (sem básicos de classe, sem repetir).
// se sobrar vaga, completa com Remendo para ele continuar útil
function aliado_sortear_skills(_a, _n) {
    var pool = [];
    var todas = skills_desbloqueadas();
    for (var i = 0; i < array_length(todas); i++) {
        if (skill_nova(todas[i]).cat != SKILL_CAT.basico) array_push(pool, todas[i]);
    }

    _a.skills = [skill_nova(SKILL_ID.golpe)];
    for (var k = 0; k < _n && array_length(pool) > 0; k++) {
        var idx = irandom(array_length(pool) - 1);
        array_push(_a.skills, skill_nova(pool[idx]));
        array_delete(pool, idx, 1);
    }

    if (array_length(_a.skills) < _a.max_skills) {
        array_push(_a.skills, skill_nova(SKILL_ID.remendo));
    }
}