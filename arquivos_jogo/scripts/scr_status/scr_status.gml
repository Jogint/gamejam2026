// ================= HELPERS DE SKILL / STATUS / PARTÍCULAS =================

// ---- montar skills (usados em skill_nova) ----
function skill_cd(_s, _cd) {
    _s.cat = SKILL_CAT.skill;
    _s.cd_max = _cd;
    return _s;
}

function skill_efeito(_s, _ef, _dur, _val) {
    _s.efeito = _ef;
    _s.ef_dur = _dur;
    _s.ef_val = _val;
    return _s;
}

function skill_alcance(_s, _a) {
    _s.alcance = _a;
    return _s;
}

// quando tiver a animação: skill_part(skill_cd(new Skill(...), 3), spr_part_fogo)
function skill_part(_s, _spr) {
    _s.particula = _spr;
    return _s;
}

function nome_categoria_skill(_c) {
    switch (_c) {
        case SKILL_CAT.basico: return "Básico";
        case SKILL_CAT.skill:  return "Skill";
        case SKILL_CAT.missao: return "Missão";
    }
    return "";
}

function cor_categoria_skill(_c) {
    switch (_c) {
        case SKILL_CAT.skill:  return c_aqua;
        case SKILL_CAT.missao: return c_orange;
    }
    return c_white;
}

// ---- status ----
function status_nome(_e) {
    switch (_e) {
        case STATUS.queimadura:   return "Queimadura";
        case STATUS.atordoamento: return "Atordoamento";
        case STATUS.corrosao:     return "Corrosão";
        case STATUS.lentidao:     return "Lentidão";
        case STATUS.celeridade:   return "Celeridade";
        case STATUS.regeneracao:  return "Regeneração";
        case STATUS.superaquecido: return "Superaquecido";
    }
    return "";
}

function status_sigla(_e) {
    switch (_e) {
        case STATUS.queimadura:   return "QUE";
        case STATUS.atordoamento: return "ATO";
        case STATUS.corrosao:     return "COR";
        case STATUS.lentidao:     return "LEN";
        case STATUS.celeridade:   return "CEL";
        case STATUS.regeneracao:  return "REG";
        case STATUS.superaquecido: return "SUP";
    }
    return "";
}

function status_cor(_e) {
    switch (_e) {
        case STATUS.queimadura:   return c_orange;
        case STATUS.atordoamento: return c_yellow;
        case STATUS.corrosao:     return c_green;
        case STATUS.lentidao:     return c_aqua;
        case STATUS.celeridade:   return c_fuchsia;
        case STATUS.regeneracao:  return c_lime;
        case STATUS.superaquecido: return c_red;
    }
    return c_white;
}

// celeridade, regeneração e superaquecido são bons; a restauração remove todos os outros
function status_negativo(_e) {
    return (_e != STATUS.celeridade && _e != STATUS.regeneracao && _e != STATUS.superaquecido);
}

function status_tem(_p, _ef) {
    for (var i = 0; i < array_length(_p.status); i++) {
        if (_p.status[i].ef == _ef) return true;
    }
    return false;
}

function status_valor(_p, _ef) {
    for (var i = 0; i < array_length(_p.status); i++) {
        if (_p.status[i].ef == _ef) return _p.status[i].val;
    }
    return 0;
}

// se já existe, só renova a duração (e mantém o maior valor)
function status_aplicar(_p, _ef, _dur, _val) {
    for (var i = 0; i < array_length(_p.status); i++) {
        var s = _p.status[i];
        if (s.ef == _ef) {
            s.dur = max(s.dur, _dur);
            s.val = max(s.val, _val);
            return;
        }
    }
    array_push(_p.status, { ef: _ef, dur: _dur, val: _val, acc: _val });
}

function status_remover_negativos(_p) {
    for (var i = array_length(_p.status) - 1; i >= 0; i--) {
        if (status_negativo(_p.status[i].ef)) array_delete(_p.status, i, 1);
    }
}

// gasta 1 carga/turno do status e remove quando acaba
function status_consumir(_p, _ef) {
    for (var i = 0; i < array_length(_p.status); i++) {
        if (_p.status[i].ef == _ef) {
            _p.status[i].dur--;
            if (_p.status[i].dur <= 0) array_delete(_p.status, i, 1);
            return;
        }
    }
}

function status_limpar(_p) {
    _p.status = [];
    _p.pula = false;
}

// ---- partículas (desenhadas sobre o alvo da skill) ----
function criar_particula(_spr, _x, _y) {
    array_push(particulas, { spr: _spr, x: _x, y: _y, img: 0 });
}

function atualizar_particulas() {
    for (var i = array_length(particulas) - 1; i >= 0; i--) {
        var p = particulas[i];
        p.img += 0.3;   // velocidade da animação
        if (p.img >= sprite_get_number(p.spr)) array_delete(particulas, i, 1);
    }
}