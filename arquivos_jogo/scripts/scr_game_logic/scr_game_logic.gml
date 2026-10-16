////scr_game_logic
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

// ================= HITBOXES =================
function box_avancar() { return [450, 240, 830, 310]; }
function box_retorno() { return [450, 330, 830, 400]; }
function box_acampar() { return [450, 420, 830, 490]; }

function box_card() {
    var off = (1 - card_anim) * 320;
    return [350, 55 - off, 930, 360 - off];
}

function box_opcao(_i) {
    var off = (1 - card_anim) * 200;
    return [360, 380 + _i * 42 + off, 920, 416 + _i * 42 + off];
}

function box_skill(_k) { return [550 + _k * 120, 595, 660 + _k * 120, 682]; }

function box_slot_party(_i) {
    var x2 = 580 - _i * 140;
    return [x2 - 135, 62, x2, 252];
}
function box_slot_inimigo(_i) {
    var x1 = 700 + _i * 140;
    return [x1, 62, x1 + 135, 252];
}

// Retorna a área retangular do nó da árvore de upgrades
function box_upg(_i) { 
    var vis = upgrades_visiveis();
    if (_i < 0 || _i >= array_length(vis)) return [0, 0, 0, 0];
    var u = upgrades[vis[_i]];
    var x1 = 80 + u.coluna * 230;
    var y1 = 110 + u.linha * 85;
    return [x1, y1, x1 + 200, y1 + 70]; 
}

function box_hub(_k) { return [330, 130 + _k * 75, 760, 190 + _k * 75]; }
function box_voltar() { return [40, 640, 240, 690]; }
function box_missao(_c, _r) {
    var x1 = 30 + _c * 310;
    var y1 = 110 + _r * 85;
    return [x1, y1, x1 + 300, y1 + 78];
}

// ================= DADOS =================
function skill_nova(_id) {
    static spr_ico = asset_get_index("spr_icon_skill");
    static spr_cls = asset_get_index("spr_skills");
    var s = skill_nova_dados(_id);
    if (_id >= SKILL_ID.mine_basico) {
        s.icone = spr_cls;
        s.icone_sub = _id - SKILL_ID.mine_basico;
    } else {
        s.icone = spr_ico;
        s.icone_sub = _id;
    }
    return s;
}

function skill_nova_dados(_id) {
    if (_id >= SKILL_ID.mine_basico) return skill_dados_classes(_id);

    switch (_id) {
        case SKILL_ID.golpe:   return new Skill("Golpe", 2, 2, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.pancada: return new Skill("Pancada", 3, 4, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.mordida: return new Skill("Mordida", 2, 1, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.disparo: return new Skill("Disparo", 3, 3, STAT.tecnica, SKILL_TIPO.dano);

        case SKILL_ID.tiro:
            return skill_cd(new Skill("Tiro Preciso", 3, 3, STAT.tecnica, SKILL_TIPO.dano), 2);
        case SKILL_ID.improviso:
            return skill_cd(new Skill("Improviso", 5, 6, STAT.imaginacao, SKILL_TIPO.dano), 3);
        case SKILL_ID.remendo:
            return skill_cd(new Skill("Remendo", 3, 4, STAT.tecnica, SKILL_TIPO.cura), 3);
        case SKILL_ID.investida:
            return skill_cd(new Skill("Investida", 5, 5, STAT.forca, SKILL_TIPO.dano), 2);
        case SKILL_ID.sobrecarga:
            return skill_cd(new Skill("Sobrecarga", 6, 6, STAT.tecnica, SKILL_TIPO.dano), 3);
        case SKILL_ID.rajada:
            return skill_cd(new Skill("Rajada", 4, 3, STAT.tecnica, SKILL_TIPO.dano), 2);

        case SKILL_ID.chama:
            return skill_efeito(skill_cd(new Skill("Chama Viva", 4, 2, STAT.imaginacao, SKILL_TIPO.dano), 3), STATUS.queimadura, 3, 2);
        case SKILL_ID.atordoar:
            return skill_efeito(skill_cd(new Skill("Atordoar", 4, 1, STAT.forca, SKILL_TIPO.dano), 4), STATUS.atordoamento, 1, 0);
        case SKILL_ID.acido:
            return skill_efeito(skill_cd(new Skill("Ácido", 3, 1, STAT.tecnica, SKILL_TIPO.dano), 3), STATUS.corrosao, 3, 1);
        case SKILL_ID.purificar:
            return skill_cd(new Skill("Purificar", 4, 3, STAT.tecnica, SKILL_TIPO.restaurar), 3);
        case SKILL_ID.estilhacos:
            return skill_alcance(skill_cd(new Skill("Estilhaços", 5, 1, STAT.tecnica, SKILL_TIPO.dano), 3), ALCANCE.global);
        case SKILL_ID.explosao:
            return skill_alcance(skill_cd(new Skill("Explosão", 4, 3, STAT.imaginacao, SKILL_TIPO.dano), 3), ALCANCE.adjacente);
        case SKILL_ID.rede:
            return skill_efeito(skill_cd(new Skill("Rede", 3, 0, STAT.tecnica, SKILL_TIPO.debuff), 3), STATUS.lentidao, 3, 2);
        case SKILL_ID.estimulante:
            return skill_efeito(skill_cd(new Skill("Estimulante", 2, 0, STAT.imaginacao, SKILL_TIPO.buff), 4), STATUS.celeridade, 3, 1);
        case SKILL_ID.sincronia:
            return skill_alcance(skill_cd(new Skill("Sincronia", 3, 1, STAT.imaginacao, SKILL_TIPO.recarga), 4), ALCANCE.global);

        case SKILL_ID.defender:
            return skill_cd(new Skill("Defender", 1, 0, STAT.vitalidade, SKILL_TIPO.defesa), 1);
        case SKILL_ID.cura_area:
            return skill_alcance(skill_cd(new Skill("Cura em Área", 4, 2, STAT.tecnica, SKILL_TIPO.cura), 4), ALCANCE.global);
    }
    return new Skill("???", 1, 1, STAT.forca, SKILL_TIPO.dano);
}

// Skills das 5 classes (mineirador, menestrel, acólito, escudeiro, lunático)
function skill_dados_classes(_id) {
    var s;
    switch (_id) {
        // ===== MINEIRADOR =====
        case SKILL_ID.mine_basico:
            return new Skill("Picareta", 2, 2, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.mine_superaquecer:   // buff em si: todo dano causado aplica queimadura
            s = skill_cd(new Skill("Superaquecer", 3, 0, STAT.vitalidade, SKILL_TIPO.buff), 4);
            s.so_si = true;
            return skill_efeito(s, STATUS.superaquecido, 3, 0);
        case SKILL_ID.mine_perfurar:
            return skill_efeito(skill_cd(new Skill("Perfurar os Céus", 5, 6, STAT.forca, SKILL_TIPO.dano), 3), STATUS.atordoamento, 1, 0);
        case SKILL_ID.mine_pedra:
            return skill_alcance(skill_cd(new Skill("Pedra Estranha", 4, 3, STAT.imaginacao, SKILL_TIPO.dano), 3), ALCANCE.adjacente);
        case SKILL_ID.mine_polvora:
            return skill_cd(new Skill("Tiro de Pólvora", 3, 3, STAT.tecnica, SKILL_TIPO.dano), 2);

        // ===== MENESTREL =====
        case SKILL_ID.mene_basico:
            return new Skill("Dedilhada", 2, 2, STAT.tecnica, SKILL_TIPO.dano);
        case SKILL_ID.mene_cura:
            return skill_alcance(skill_cd(new Skill("Canção de Cura", 4, 2, STAT.vitalidade, SKILL_TIPO.cura), 4), ALCANCE.global);
        case SKILL_ID.mene_desespero:
            s = skill_alcance(skill_cd(new Skill("Melodia do Desespero", 5, 2, STAT.imaginacao, SKILL_TIPO.dano), 3), ALCANCE.global);
            s = skill_efeito(s, STATUS.queimadura, 3, 1);
            s.chance = 0.4;
            s.efeito2 = STATUS.corrosao;
            s.ef2_dur = 3;
            s.ef2_chance = 0.2;
            return s;
        case SKILL_ID.mene_detox:
            s = skill_efeito(skill_cd(new Skill("Rima Desintoxicante", 3, 0, STAT.sorte, SKILL_TIPO.buff), 3), STATUS.regeneracao, 3, 2);
            s.def_por_sorte = true;
            return s;
        case SKILL_ID.mene_banshee:
            s = skill_cd(new Skill("Lamento da Banshee", 5, 2, STAT.tecnica, SKILL_TIPO.dano), 4);
            s.instakill = 0.1;
            return s;

        // ===== ACÓLITO =====
        case SKILL_ID.acol_basico:
            return new Skill("Ying", 2, 2, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.acol_yang:
            s = skill_cd(new Skill("Yang", 4, 3, STAT.vitalidade, SKILL_TIPO.dano), 3);
            s.espelho = true;
            return s;
        case SKILL_ID.acol_punho:
            s = skill_efeito(skill_cd(new Skill("Punho de Fogo", 3, 3, STAT.tecnica, SKILL_TIPO.dano), 2), STATUS.queimadura, 3, 1);
            s.chance = 0.5;
            return s;
        case SKILL_ID.acol_perdicao:
            s = skill_efeito(skill_cd(new Skill("Fogo da Perdição", 4, 2, STAT.carisma, SKILL_TIPO.dano), 3), STATUS.corrosao, 3, 1);
            s.chance = 0.5;
            return s;
        case SKILL_ID.acol_raio:
            s = skill_alcance(skill_cd(new Skill("Raio de Luz", 4, 2, STAT.sorte, SKILL_TIPO.dano), 3), ALCANCE.adjacente);
            s.cura_adj = true;
            return s;

        // ===== ESCUDEIRO =====
        case SKILL_ID.escu_basico:
            return new Skill("Escudada", 2, 2, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.escu_tartaruga:
            s = skill_alcance(skill_cd(new Skill("Formação Tartaruga", 3, 0, STAT.vitalidade, SKILL_TIPO.defesa), 4), ALCANCE.global);
            s.exclui_si = true;
            return s;
        case SKILL_ID.escu_refletor:
            return skill_alcance(skill_cd(new Skill("Escudo Refletor", 5, 3, STAT.forca, SKILL_TIPO.dano), 3), ALCANCE.global);
        case SKILL_ID.escu_passo:
            s = skill_cd(new Skill("Passo Rápido", 3, 3, STAT.imaginacao, SKILL_TIPO.dano), 2);
            s.def_chance = 0.4;
            s.def_em_si = true;
            return s;
        case SKILL_ID.escu_grande:
            s = skill_efeito(skill_cd(new Skill("Grande Escudo da Luz Reveladora", 3, 0, STAT.sorte, SKILL_TIPO.buff), 3), STATUS.regeneracao, 3, 2);
            s.def_por_sorte = true;
            return s;

        // ===== LUNÁTICO =====
        case SKILL_ID.luna_basico:
            return new Skill("Cabeçada", 2, 2, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.luna_palacio:
            s = skill_efeito(skill_cd(new Skill("Palácio Mental", 3, 0, STAT.vitalidade, SKILL_TIPO.buff), 4), STATUS.regeneracao, 3, 2);
            s.so_si = true;
            return s;
        case SKILL_ID.luna_empalar:
            return skill_cd(new Skill("Empalar", 5, 7, STAT.forca, SKILL_TIPO.dano), 3);
        case SKILL_ID.luna_arroto:
            return skill_efeito(skill_cd(new Skill("Arroto", 3, 2, STAT.carisma, SKILL_TIPO.dano), 3), STATUS.corrosao, 3, 1);
        case SKILL_ID.luna_respiracao:
            s = skill_cd(new Skill("Respiração Profunda", 4, 0, STAT.imaginacao, SKILL_TIPO.cura), 4);
            s.so_si = true;
            s.cura_total = true;
            s.auto_efeitos = [ { ef: STATUS.lentidao, dur: 2, val: 2 }, { ef: STATUS.atordoamento, dur: 1, val: 0 } ];
            return s;
    }
    return new Skill("???", 1, 1, STAT.forca, SKILL_TIPO.dano);
}

// ids de skills já compradas na árvore (qualquer facção), sem repetir


// dá até _n skills desbloqueadas ao inimigo (máx. 4 no total, sem instakill)
function inimigo_sortear_skills(_e, _n) {
    var pool = skills_desbloqueadas();
    for (var k = 0; k < _n && array_length(pool) > 0; k++) {
        var idx = irandom(array_length(pool) - 1);
        var s = skill_nova(pool[idx]);
        array_delete(pool, idx, 1);
        if (s.instakill > 0) continue;
        if (array_length(_e.skills) < 4) array_push(_e.skills, s);
    }
}

function inimigo_novo(_id, _origem) {
    var e = new Personagem("Inimigo");
    var cl = CLASSE.escudeiro;
    switch (_id) {
        case ENEMY_ID.besta:
            e.nome = "Besta das Ruínas";
            e.stats[STAT.vitalidade] = 2;
            e.stats[STAT.forca] = 2;
            e.skills = [skill_nova(SKILL_ID.mordida), skill_nova(SKILL_ID.investida)];
            cl = CLASSE.lunatico;
            break;
        case ENEMY_ID.saqueador:
            e.nome = "Saqueador";
            e.stats[STAT.vitalidade] = 2;
            e.stats[STAT.forca] = 2;
            e.stats[STAT.tecnica] = 2;
            e.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.tiro)];
            cl = CLASSE.mineirador;
            break;
        case ENEMY_ID.sentinela:
            e.nome = "Sentinela";
            e.stats[STAT.vitalidade] = 2;
            e.skills = [skill_nova(SKILL_ID.disparo), skill_nova(SKILL_ID.sobrecarga)];
            cl = CLASSE.acolito;
            break;
        case ENEMY_ID.rato:
            e.nome = "Rato Mutante";
            e.stats[STAT.vitalidade] = 0;
            e.stats[STAT.forca] = 1;
            e.skills = [skill_nova(SKILL_ID.mordida)];
            cl = CLASSE.lunatico;
            break;
        case ENEMY_ID.guarda:
            e.nome = "Guarda do Posto";
            e.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.rajada)];
            cl = CLASSE.escudeiro;
            break;
        case ENEMY_ID.colosso:
            e.nome = "Colosso das Ruínas";
            e.stats[STAT.vitalidade] = 8;
            e.stats[STAT.forca] = 5;
            e.stats[STAT.tecnica] = 4;
            e.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.investida), skill_nova(SKILL_ID.estilhacos), skill_nova(SKILL_ID.atordoar)];
            cl = CLASSE.lunatico;
            break;
    }
    inimigo_sortear_skills(e, 1);
    visual_aleatorio(e, cl, _origem);
    p_curar_total(e);
    return e;
}

function montar_inimigos(_c) {
    inimigos = [];
    var n_total = min(array_length(_c.inimigos), MAX_INIMIGOS);
    for (var i = 0; i < n_total; i++) {
        var e = inimigo_novo(_c.inimigos[i], _c.origin);
        var n = 0;
        for (var j = 0; j < i; j++) {
            if (string_pos(e.nome, inimigos[j].nome) == 1) n++;
        }
        if (n > 0) e.nome += " " + chr(65 + n);
        array_push(inimigos, e);
    }
}

// ================= ALIADOS POR CLASSE =================
// id da skill básica de cada classe (as 4 seguintes do enum são as outras da classe)
function classe_skill_base(_c) {
    switch (_c) {
        case CLASSE.escudeiro:  return SKILL_ID.escu_basico;
        case CLASSE.mineirador: return SKILL_ID.mine_basico;
        case CLASSE.menestrel:  return SKILL_ID.mene_basico;
        case CLASSE.lunatico:   return SKILL_ID.luna_basico;
        case CLASSE.acolito:    return SKILL_ID.acol_basico;
    }
    return SKILL_ID.golpe;
}

// aliado: nome = nome da classe, visual da facção, skills da classe
function aliado_de_classe(_classe, _faccao) {
    var a = new Personagem(nome_da_classe(_classe));
    visual_aleatorio(a, _classe, _faccao);

    switch (_classe) {
        case CLASSE.escudeiro:
            a.stats[STAT.vitalidade] += 2;
            a.stats[STAT.forca] += 1;
            break;
        case CLASSE.mineirador:
            a.stats[STAT.forca] += 2;
            a.stats[STAT.tecnica] += 1;
            break;
        case CLASSE.menestrel:
            a.stats[STAT.carisma] += 2;
            a.stats[STAT.tecnica] += 1;
            break;
        case CLASSE.lunatico:
            a.stats[STAT.imaginacao] += 2;
            a.stats[STAT.forca] += 1;
            break;
        case CLASSE.acolito:
            a.stats[STAT.tecnica] += 1;
            a.stats[STAT.sorte] += 1;
            a.stats[STAT.carisma] += 1;
            break;
    }

    // básico da classe (se não desbloqueado, Golpe) + até 2 skills da classe já desbloqueadas
	var base = classe_skill_base(_classe);
	a.skills = [skill_nova(skill_desbloqueada(base) ? base : SKILL_ID.golpe)];

	var extras = [];
	for (var k = 1; k <= 4; k++) {
	    if (skill_desbloqueada(base + k)) array_push(extras, base + k);
	}
		for (var n = 0; n < 2 && array_length(extras) > 0; n++) {
	    var i = irandom(array_length(extras) - 1);
	    array_push(a.skills, skill_nova(extras[i]));
	    array_delete(extras, i, 1);
	}

    p_curar_total(a);   // sem isso hp = 1 e hp_vis = 1 (veja abaixo)
    return a;

}


// ================= OPÇÕES DE EVENTO =================
function flavor_padrao(_stat) {
    switch (_stat) {
        case STAT.vitalidade:  return "Aguentar o esforço até o fim";
        case STAT.forca:       return "Resolver na força bruta";
        case STAT.imaginacao:  return "Improvisar uma solução criativa";
        case STAT.tecnica:     return "Aplicar conhecimento técnico";
        case STAT.sorte:       return "Arriscar e confiar na sorte";
        case STAT.carisma:     return "Convencer na conversa";
    }
    return "Agir";
}

function opcao_flavor(_opt) {
    if (variable_struct_exists(_opt, "flavor") && _opt.flavor != "") return _opt.flavor;
    return flavor_padrao(_opt.stat);
}

function carta_opcoes(_c, _s1, _r1, _s2, _r2, _s3, _r3) {
    _c.options = [
        { stat: _s1, required: _r1, flavor: "" },
        { stat: _s2, required: _r2, flavor: "" },
        { stat: _s3, required: _r3, flavor: "" }
    ];
}

function carta_flavors(_c, _f1, _f2, _f3) {
    _c.options[0].flavor = _f1;
    _c.options[1].flavor = _f2;
    _c.options[2].flavor = _f3;
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
    c.name = "Emboscada Saqueadora";
    c.description = "Um bando inteiro estava esperando você sair do corredor.";
    c.origin = CARD_ORIGIN.faction_3;
    c.tipo = CARD_TIPO.hostil;
    c.inimigos = [ENEMY_ID.saqueador, ENEMY_ID.saqueador, ENEMY_ID.rato, ENEMY_ID.rato];
    c.recompensa_valor = 7;
    array_push(deck, c);

    c = new Card();
    c.name = "Comerciante Errante";
    c.description = "Um sobrevivente oferece dicas sobre a região em troca de uma boa conversa.";
    c.origin = CARD_ORIGIN.faction_1;
    carta_opcoes(c, STAT.carisma, 3, STAT.sorte, 4, STAT.imaginacao, 3);
    carta_flavors(c, "Negociar com lábia e simpatia", "Arriscar uma troca no escuro", "Inventar uma história convincente");
    c.custo_tempo = 4;
    c.fail_tempo = 3;
    c.recompensa_valor = 2;
    array_push(deck, c);

    c = new Card();
    c.name = "Terminal Antigo";
    c.description = "Um painel elétrico selado bloqueia o acesso ao depósito principal.";
    c.origin = CARD_ORIGIN.faction_2;
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.tecnica, 5, STAT.imaginacao, 4, STAT.forca, 6);
    carta_flavors(c, "Religar os circuitos com cuidado", "Improvisar um desvio na fiação", "Arrombar o painel na marra");
    c.custo_tempo = 6;
    c.fail_tempo = 4;
    c.recompensa_valor = 4;
    array_push(deck, c);

    c = new Card();
    c.name = "Reservatório Intacto";
    c.description = "Uma cisterna lacrada guarda água limpa e suprimentos médicos.";
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.tecnica, 4, STAT.imaginacao, 3, STAT.sorte, 4);
    carta_flavors(c, "Abrir a lacre sem danificar nada", "Bolar um jeito de forçar a trava", "Tentar a trava e torcer pelo melhor");
    c.recompensa = RECOMPENSA.cura;
    c.recompensa_valor = 8;
    c.custo_tempo = 5;
    c.fail_tempo = 3;
    array_push(deck, c);

    c = new Card();
    c.name = "Treino Improvisado";
    c.description = "Restos de uma arena de treino. Dá para aprender algo antes de seguir.";
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.vitalidade, 4, STAT.forca, 3, STAT.carisma, 3);
    carta_flavors(c, "Aguentar o circuito de treino inteiro", "Erguer os pesos mais pesados", "Chamar outros para treinar junto");
    c.recompensa = RECOMPENSA.stat;
    c.recompensa_stat = STAT.forca;
    c.recompensa_valor = 1;
    c.custo_tempo = 5;
    c.fail_tempo = 3;
    array_push(deck, c);

    c = new Card();
    c.name = "Viajante Ferido";
    c.description = "Uma sobrevivente machucada pede ajuda. Ela conhece os caminhos e sabe se virar.";
    c.tipo = CARD_TIPO.amigavel;
    c.origin = CARD_ORIGIN.faction_1;
    carta_opcoes(c, STAT.carisma, 3, STAT.imaginacao, 3, STAT.vitalidade, 4);
    carta_flavors(c, "Acalmá-la com palavras gentis", "Improvisar uma tala e curativos", "Carregá-la nos ombros até a trilha");
    c.recompensa = RECOMPENSA.aliado;
    c.aliado_classe = CLASSE.menestrel;
    c.custo_tempo = 4;
    c.fail_tempo = 3;
    array_push(deck, c);

    // ---------- ENCONTROS AMIGÁVEIS ----------
    c = new Card();
    c.name = "Escudeiro Perdido";
    c.description = "Um soldado de escudo rachado vaga sozinho e aceita seguir quem o tirar da zona aberta.";
    c.tipo = CARD_TIPO.amigavel;
    c.origin = CARD_ORIGIN.faction_3;
    carta_opcoes(c, STAT.carisma, 3, STAT.vitalidade, 4, STAT.forca, 3);
    carta_flavors(c, "Oferecer um lugar seguro no grupo", "Dividir a sua água com ele", "Mostrar que você aguenta o tranco");
    c.recompensa = RECOMPENSA.aliado;
    c.aliado_classe = CLASSE.escudeiro;
    c.custo_tempo = 4;
    c.fail_tempo = 3;
    array_push(deck, c);

    c = new Card();
    c.name = "Mineirador Soterrado";
    c.description = "Um mineirador preso sob entulho pede ajuda. Ele sabe onde ainda há veios intactos.";
    c.tipo = CARD_TIPO.amigavel;
    c.origin = CARD_ORIGIN.faction_1;
    carta_opcoes(c, STAT.forca, 5, STAT.tecnica, 4, STAT.imaginacao, 3);
    carta_flavors(c, "Levantar o entulho na força", "Escorar a estrutura e puxá-lo", "Inventar uma alavanca com sucata");
    c.recompensa = RECOMPENSA.aliado;
    c.aliado_classe = CLASSE.mineirador;
    c.custo_tempo = 5;
    c.fail_tempo = 3;
    array_push(deck, c);

    c = new Card();
    c.name = "Lunático na Estrada";
    c.description = "Alguém fala sozinho no meio da trilha. Os olhos dele não piscam, mas ele não parece hostil.";
    c.tipo = CARD_TIPO.amigavel;
    c.origin = CARD_ORIGIN.faction_2;
    carta_opcoes(c, STAT.imaginacao, 4, STAT.carisma, 4, STAT.sorte, 3);
    carta_flavors(c, "Entrar no jogo de palavras dele", "Convencê-lo com calma", "Arriscar chegar perto");
    c.recompensa = RECOMPENSA.aliado;
    c.aliado_classe = CLASSE.lunatico;
    c.custo_tempo = 4;
    c.fail_tempo = 3;
    array_push(deck, c);

    c = new Card();
    c.name = "Acólito em Jejum";
    c.description = "Um acólito ajoelhado ao lado de uma fogueira apagada. Ele diz que a luz o abandonou.";
    c.tipo = CARD_TIPO.amigavel;
    c.origin = CARD_ORIGIN.faction_2;
    carta_opcoes(c, STAT.carisma, 4, STAT.tecnica, 3, STAT.sorte, 4);
    carta_flavors(c, "Dizer o que ele precisa ouvir", "Reacender a fogueira para ele", "Apostar que a luz volta");
    c.recompensa = RECOMPENSA.aliado;
    c.aliado_classe = CLASSE.acolito;
    c.custo_tempo = 4;
    c.fail_tempo = 3;
    array_push(deck, c);

    // ---------- EVENTOS DE CENÁRIO ----------
    c = new Card();
    c.name = "Ponte Desabada";
    c.description = "O único caminho seguro sobre a vala foi levado pela última tempestade. Do outro lado há suprimentos largados.";
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.forca, 5, STAT.imaginacao, 4, STAT.tecnica, 4);
    carta_flavors(c, "Arrastar os destroços e refazer a travessia", "Improvisar um jeito de atravessar", "Calcular onde a estrutura ainda aguenta");
    c.recompensa_valor = 3;
    c.custo_tempo = 5;
    c.fail_tempo = 3;
    array_push(deck, c);

    c = new Card();
    c.name = "Horta Abandonada";
    c.description = "Entre as ruínas, uma horta resistiu ao sol. Com sorte, ainda dá para comer algo.";
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.vitalidade, 4, STAT.tecnica, 3, STAT.sorte, 3);
    carta_flavors(c, "Cavar até achar raízes saudáveis", "Separar o que não está contaminado", "Provar o que parece comestível");
    c.recompensa = RECOMPENSA.cura;
    c.recompensa_valor = 6;
    c.custo_tempo = 4;
    c.fail_tempo = 2;
    array_push(deck, c);

    c = new Card();
    c.name = "Oficina Saqueada";
    c.description = "Prateleiras viradas e ferramentas espalhadas. Alguma coisa útil deve ter sobrado.";
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.tecnica, 4, STAT.imaginacao, 4, STAT.forca, 3);
    carta_flavors(c, "Reaproveitar peças com método", "Montar algo novo com os restos", "Remover o que estiver emperrado");
    c.recompensa = RECOMPENSA.stat;
    c.recompensa_stat = STAT.tecnica;
    c.recompensa_valor = 1;
    c.custo_tempo = 5;
    c.fail_tempo = 3;
    array_push(deck, c);

    c = new Card();
    c.name = "Abrigo Soterrado";
    c.description = "A entrada de um antigo abrigo está coberta de pedra. Lá dentro pode haver recursos.";
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.forca, 6, STAT.vitalidade, 5, STAT.tecnica, 4);
    carta_flavors(c, "Quebrar a pedra na marra", "Cavar sem parar até abrir passagem", "Procurar o ponto fraco da entrada");
    c.recompensa_valor = 5;
    c.custo_tempo = 6;
    c.fail_tempo = 4;
    array_push(deck, c);

    c = new Card();
    c.name = "Altar de Sucata";
    c.description = "Alguém montou um altar com peças de máquina. As oferendas ainda estão ali.";
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.sorte, 4, STAT.carisma, 3, STAT.imaginacao, 3);
    carta_flavors(c, "Pegar uma oferenda e torcer", "Fazer uma prece convincente", "Criar um ritual de improviso");
    c.recompensa = RECOMPENSA.stat;
    c.recompensa_stat = STAT.sorte;
    c.recompensa_valor = 1;
    c.custo_tempo = 4;
    c.fail_tempo = 3;
    array_push(deck, c);

    return deck;
}

// ================= ÁRVORE DE UPGRADES =================
// Construtor: Upgrade(_nome, _desc, _custo, _efeito, _alvo, _valor, _pai, _col, _lin)
// _pai = índice do upgrade pai na lista abaixo (cuidado ao reordenar!)
function criar_upgrades() {
    var lista = [
        // --- TEMPO / SOBREVIVÊNCIA (coluna 0) ---
        new Upgrade("Reservas de Água I", "+100 tempo inicial", 3, UPG_EFEITO.tempo, 0, 100, -1, 0, 0),                    // 0
        new Upgrade("Reservas de Água II", "+200 tempo inicial", 5, UPG_EFEITO.tempo, 0, 200, 0, 0, 1),                    // 1
        new Upgrade("Kit de Acampamento", "Restaura todo o relógio 1x na run", 8, UPG_EFEITO.acampamento, 0, 1, 1, 0, 2), // 2

        // --- PLANEJAMENTO E EFICIÊNCIA (colunas 1 e 2) ---
        new Upgrade("Planos Estratégicos I", "Eventos custam -2 min", 4, UPG_EFEITO.custo_evento, 0, 2, -1, 1, 0),            // 3
        new Upgrade("Planos Estratégicos II", "Eventos custam -2 min", 6, UPG_EFEITO.custo_evento, 0, 2, 3, 1, 1),       // 4
        new Upgrade("Atalho", "Contornar -1 min", 3, UPG_EFEITO.contornar, 0, 1, 3, 2, 1),                             // 5
        new Upgrade("Rota Segura", "Retorno -2 min", 4, UPG_EFEITO.retorno, 0, 2, 4, 1, 2),                            // 6

        // --- PARCEIROS (coluna 3) ---
        new Upgrade("Parceiro I", "Começa com 1 aliado na equipe", 5, UPG_EFEITO.membro_inicial, 0, 1, -1, 3, 0),     // 7
        new Upgrade("Parceiro II", "Começa com +1 aliado (total 2)", 7, UPG_EFEITO.membro_inicial, 0, 1, 7, 3, 1),    // 8

        // --- FORÇA e VITALIDADE (coluna 4) ---
        new Upgrade("Treino de Força I", "+1 FOR", 3, UPG_EFEITO.stat, STAT.forca, 1, -1, 4, 0),                       // 9
        new Upgrade("Treino de Força II", "+1 FOR", 5, UPG_EFEITO.stat, STAT.forca, 1, 9, 4, 1),                       // 10
        new Upgrade("Mestre da Força", "+2 FOR", 9, UPG_EFEITO.stat, STAT.forca, 2, 10, 4, 2),                         // 11
        new Upgrade("Constituição I", "+1 VIT (+3 de vida)", 3, UPG_EFEITO.stat, STAT.vitalidade, 1, -1, 4, 3),        // 12
        new Upgrade("Constituição II", "+1 VIT (+3 de vida)", 5, UPG_EFEITO.stat, STAT.vitalidade, 1, 12, 4, 4),       // 13
        new Upgrade("Corpo de Aço", "+2 VIT (+6 de vida)", 9, UPG_EFEITO.stat, STAT.vitalidade, 2, 13, 4, 5),          // 14

        // --- TÉCNICA e IMAGINAÇÃO (coluna 2) ---
        new Upgrade("Mãos Firmes", "+1 TEC", 4, UPG_EFEITO.stat, STAT.tecnica, 1, -1, 2, 2),                           // 15
        new Upgrade("Precisão Cirúrgica", "+2 TEC", 7, UPG_EFEITO.stat, STAT.tecnica, 2, 15, 2, 3),                    // 16
        new Upgrade("Mente Criativa", "+1 IMA", 4, UPG_EFEITO.stat, STAT.imaginacao, 1, -1, 2, 4),                     // 17
        new Upgrade("Gênio Inventivo", "+2 IMA", 7, UPG_EFEITO.stat, STAT.imaginacao, 2, 17, 2, 5),                    // 18

        // --- SORTE (coluna 3) ---
        new Upgrade("Sorte de Principiante", "+1 SOR", 3, UPG_EFEITO.stat, STAT.sorte, 1, -1, 3, 4),                   // 19
        new Upgrade("Trevo da Sorte", "+2 SOR", 7, UPG_EFEITO.stat, STAT.sorte, 2, 19, 3, 5),                          // 20

        // --- CARISMA (coluna 1) ---
        new Upgrade("Lábia", "+1 CAR", 3, UPG_EFEITO.stat, STAT.carisma, 1, -1, 1, 3),                                 // 21
        new Upgrade("Voz de Líder", "+2 CAR", 7, UPG_EFEITO.stat, STAT.carisma, 2, 21, 1, 4)                           // 22
    ];

    var u = new Upgrade("Ascensão Final", "Conclui o objetivo principal", 12, UPG_EFEITO.unico, 0, 0, -1, 3, 3);       // 23
    u.faccao = FACTION.faction_1;
    array_push(lista, u);

    return lista;
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
        c.sprite_interacao = spr_cenario_base;
        carta_opcoes(c, STAT.tecnica, 3, STAT.sorte, 3, STAT.imaginacao, 3);
        carta_flavors(c, "Vasculhar os destroços com método", "Seguir o instinto e a sorte", "Imaginar onde algo útil estaria");
        c.recompensa_valor = 3;
        c.custo_tempo = 3;
        c.fail_tempo = 2;
    } else if (d == faccao_atual) {
        c.name = "Posto da Sua Facção";
        c.description = "O trabalho das gerações anteriores ergueu este abrigo. Há água, comida e um lugar para descansar.";
        c.origin = d + 1;
        c.tipo = CARD_TIPO.posto;
        c.sprite_interacao = spr_cenario_base;
    } else {
        c.name = "Posto da Facção " + string(d + 1);
        c.description = "Outra facção fincou bandeira aqui, graças aos recursos que ela entregou. Eles não deixam estranhos passarem.";
        c.origin = d + 1;
        c.tipo = CARD_TIPO.hostil;
        c.inimigos = [ENEMY_ID.guarda];
        c.recompensa_valor = 6;
        c.ponto_fixo = true;
    }
    return c;
}

// ================= RUN =================
function acao_iniciar_run(_fac) {
    faccao_atual = _fac;
    recurso = 0;
    nivel_total = 0;
    nivel_expedicao = 0;
    area_atual = _fac;
    area_anterior = -1;
    area_aplicar();

    tempo_run_max = tempo_max;
    mod_retorno = 0;
    custo_contornar = 3;
    mod_custo_evento = 0;
    pode_acampar_run = false;
    ja_acampou_run = false;
    var aliados_iniciais = 0;

    // player: corpo fixo da facção + primeira cabeça da cor dela
    var o = origem_da_faccao(_fac);
    var cls_player = [CLASSE.escudeiro, CLASSE.acolito, CLASSE.menestrel];   // mesma ordem do lib_player
    player = new Personagem("Sobrevivente F" + string(_fac + 1));
    visual_fixo(player, cls_player[_fac], o, lib_player[_fac], lib_cabecas[o][0]);

	// player usa sprite completo, sem cabeça separada
	player.spr_body = spr_player;
	player.spr_head = noone;
	player.spr_overworld = spr_player;
    player.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.tiro)];
    aliados = [];

    var comprados = upgrades_comprados[_fac];
    for (var i = 0; i < array_length(upgrades); i++) {
        if (!comprados[i]) continue;
        var u = upgrades[i];
        switch (u.efeito) {
            case UPG_EFEITO.tempo:          tempo_run_max += u.valor; break;
            case UPG_EFEITO.retorno:        mod_retorno += u.valor; break;
            case UPG_EFEITO.contornar:      custo_contornar -= u.valor; break;
            case UPG_EFEITO.custo_evento:   mod_custo_evento += u.valor; break;
            case UPG_EFEITO.acampamento:    pode_acampar_run = true; break;
            case UPG_EFEITO.membro_inicial: aliados_iniciais += u.valor; break;
            case UPG_EFEITO.stat:           player.stat_mods[u.alvo] += u.valor; break;
            case UPG_EFEITO.skill:          acao_dar_skill(player, u.alvo); break;
            case UPG_EFEITO.basico:         acao_dar_skill(player, u.alvo); break;
        }
    }
	hab_aplicar_equipadas(player, _fac);
    // Adiciona aliados iniciais comprados na árvore de upgrades (classe sorteada)
    for (var k = 0; k < min(aliados_iniciais, 2); k++) {
        array_push(aliados, aliado_de_classe(irandom(CLASSE.count - 1), origem_da_faccao(_fac)));
    }

    run_missao = missao_sel;
    missao_sel = undefined;
    escoltado = undefined;
    carga_ativa = false;
    skill_deslocada = undefined;
    if (run_missao != undefined) {
        var m = missoes[run_missao.d][run_missao.i];
        if (m.tipo == MISSAO_TIPO.escolta) {
            escoltado = aliado_de_classe(irandom(CLASSE.count - 1), origem_da_faccao(run_missao.d));
            array_push(aliados, escoltado);
            cutscene_tocar(CUT.tut_escolta);
        } else if (m.tipo == MISSAO_TIPO.entrega) {
            acao_dar_carga(m);
            cutscene_tocar(CUT.tut_entrega);
        }
    }

    p_curar_total(player);
    tempo = tempo_run_max;
    tempo_vis = tempo;
    trilha_vis = 0;

    inimigos = [];
    popups = [];
    particulas = [];
    carta_atual = undefined;
    figura_evento = undefined;
    ultima_carta = undefined;
    carta_resolvida = false;
    card_msg = "";

    estado = GAME_STATE.expedition;
}

function acao_dar_skill(_p, _id) {
    var s = skill_nova(_id);

    if (s.cat == SKILL_CAT.basico) {
        if (array_length(_p.skills) == 0) array_push(_p.skills, s);
        else _p.skills[0] = s;
        return;
    }

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
    return max(1, nivel_total - mod_retorno);
}

function pode_retornar() {
    return (nivel_total > 0 && tempo >= calcular_custo_retorno());
}

function pode_acampar() {
    return (pode_acampar_run && !ja_acampou_run && tempo < tempo_run_max);
}

function acao_acampar() {
    if (!pode_acampar()) return;
    ja_acampou_run = true;
    mudar_tempo(tempo_run_max - tempo);
    curar_grupo_total();
    criar_popup("Acampamento Realizado!", 640, 360, c_lime);
}

function acao_avancar_expedicao() {
    nivel_expedicao++;
    nivel_total++;

    if (nivel_expedicao == nivel_max_expedicao && area_atual != AREA.meio) cutscene_tocar(CUT.tut_passagem);

    if (area_atual == AREA.meio && nivel_expedicao == nivel_max_expedicao) {
        acao_mostrar_card(criar_carta_chefe());
        return;
    }

    var mi = missao_no_nivel(nivel_expedicao);
    if (mi != undefined) {
        acao_mostrar_card(criar_carta_missao(mi.d, mi.i));
    } else if (nivel_expedicao == nivel_fixo) {
        acao_mostrar_card(criar_carta_fixa());
    } else {
        acao_mostrar_card(sortear_do_deck());
    }
}

function sortear_do_deck() {
    if (random(1) < 0.2) return criar_carta_emissario();

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

    figura_evento = undefined;
    if (_c.tipo == CARD_TIPO.hostil) {
        montar_inimigos(_c);
        figura_evento = inimigos[0];
    } else if (_c.tipo == CARD_TIPO.amigavel) {
        figura_evento = aliado_de_classe(_c.aliado_classe, _c.origin);
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
            var g = get_grupo();
            for (var i = 0; i < array_length(g); i++) p_curar_total(g[i]);
            card_msg = "Você descansa no posto: tempo e vida recuperados.";
            break;
        case CARD_TIPO.missao:
            carta_resolvida = true;
            card_msg = missao_chegada(_c);
            break;
    }

    // o tutorial de combate agora toca em step_card, quando o combate já começou
    if (_c.tipo == CARD_TIPO.evento || _c.tipo == CARD_TIPO.amigavel) {
        cutscene_tocar(CUT.tut_evento);
        if (_c.recompensa == RECOMPENSA.relacao) cutscene_tocar(CUT.tut_diplomacia);
    }
}

function acao_resolver_escolha(_idx) {
    if (_idx == 3) {
        mudar_tempo(-custo_contornar);
        card_msg = "Você contornou o obstáculo e perdeu " + string(custo_contornar) + " de tempo.";
    } else {
        var base_tempo = variable_struct_exists(carta_atual, "custo_tempo") ? carta_atual.custo_tempo : 4;
        var c_tempo = max(1, base_tempo - mod_custo_evento);
        
        var opt = carta_atual.options[_idx];
        var total = stat_total(player, opt.stat);
        for (var a = 0; a < array_length(aliados); a++) {
            total += floor(stat_total(aliados[a], opt.stat) / 2);
        }

        var sucesso = (total >= opt.required);
        if (!sucesso) {
            var chance = min(stat_total(player, STAT.sorte) * 0.12, 0.6);
            sucesso = (random(1) < chance);
        }

        if (sucesso) {
            mudar_tempo(-c_tempo);
            card_msg = "SUCESSO! (-" + string(c_tempo) + " tempo) " + acao_aplicar_recompensa(carta_atual);
        } else {
            var penalidade_total = c_tempo + carta_atual.fail_tempo;
            mudar_tempo(-penalidade_total);
            card_msg = "FALHA... Você perdeu " + string(penalidade_total) + " de tempo.";
        }
    }
    
    curar_grupo_total();
    carta_resolvida = true;
}

function acao_aplicar_recompensa(_c) {
    var novo;
    switch (_c.recompensa) {
        case RECOMPENSA.recurso:
            recurso += _c.recompensa_valor;
            criar_popup("+" + string(_c.recompensa_valor) + " recursos", 1050, 585, c_aqua);
            return "Você ganhou +" + string(_c.recompensa_valor) + " de recurso.";
        case RECOMPENSA.cura:
            curar_grupo(_c.recompensa_valor);
            return "O grupo recuperou " + string(_c.recompensa_valor) + " de vida.";
        case RECOMPENSA.stat:
            player.stat_mods[_c.recompensa_stat] += _c.recompensa_valor;
            if (_c.recompensa_stat == STAT.vitalidade) player.hp += _c.recompensa_valor * 3;
            return "+" + string(_c.recompensa_valor) + " " + stat_nomes[_c.recompensa_stat] + " até o fim da expedição.";
        case RECOMPENSA.aliado:
		    if (array_length(aliados) < MAX_GRUPO - 1) {
		        // usa o personagem mostrado no card; se ele não existir mais, cria um novo da classe
		        if (_c.tipo == CARD_TIPO.amigavel && is_struct(figura_evento)) novo = figura_evento;
		        else novo = aliado_de_classe(_c.aliado_classe, _c.origin);
		        array_push(aliados, novo);
		        return nome_da_classe(_c.aliado_classe) + " se juntou ao seu grupo!";
		    }
		    recurso += 3;
		    return "Seu grupo já está cheio, então ela deixa 3 recursos de suprimento.";
        case RECOMPENSA.relacao:
            relacao_mudar(_c.origin, 1);
            return "Acordo firmado! Relação com a Facção " + string(_c.origin) + ": " + string(relacao[faccao_atual][_c.origin]) + " / " + string(RELACAO_MAX) + ".";
    }
    return "";
}

function curar_grupo(_v) {
    var g = get_grupo();
    for (var i = 0; i < array_length(g); i++) {
        g[i].hp = min(p_hp_max(g[i]), g[i].hp + _v);
    }
}

function curar_grupo_total() {
    var g = get_grupo();
    for (var i = 0; i < array_length(g); i++) {
        if (g[i].hp > 0) {
            p_curar_total(g[i]);
        }
    }
}

function remover_aliados_mortos() {
    for (var i = array_length(aliados) - 1; i >= 0; i--) {
        if (aliados[i].hp <= 0) array_delete(aliados, i, 1);
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
    reserva[faccao_atual] += rec_salvo;

    if (final_pendente == -1) cutscene_tocar(CUT.morte);
}

function acao_reencarnar() {
    faccao_atual = (faccao_atual + 1) % FACTION.count;
    missao_sel = undefined;
    prep_tela = PREP_TELA.menu;
    estado = GAME_STATE.preparacao;
}

// ================= MELHORIAS =================
function upgrades_visiveis() {
    var v = [];
    for (var i = 0; i < array_length(upgrades); i++) {
        var u = upgrades[i];
        if (u.faccao == -1 || u.faccao == faccao_atual) array_push(v, i);
    }
    return v;
}

function contar_upgrades_skill() {
    var n = 0;
    var comprados = upgrades_comprados[faccao_atual];
    for (var i = 0; i < array_length(upgrades); i++) {
        if (comprados[i] && upgrades[i].efeito == UPG_EFEITO.skill) n++;
    }
    return n;
}

function upgrade_pode_comprar(_i) {
    var u = upgrades[_i];
    if (upgrades_comprados[faccao_atual][_i]) return false;
    if (reserva[faccao_atual] < u.custo) return false;
    
    // Validação da Árvore: O pai precisa ter sido comprado
    if (u.pai != -1 && !upgrades_comprados[faccao_atual][u.pai]) return false;

    if (u.efeito == UPG_EFEITO.skill && contar_upgrades_skill() >= slots_upg) return false;
    if (u.efeito == UPG_EFEITO.unico && missao_bloqueada(FACTION.faction_1, 4)) return false;
    return true;
}

function acao_comprar_upgrade(_i) {
    if (!upgrade_pode_comprar(_i)) return;
    reserva[faccao_atual] -= upgrades[_i].custo;
    upgrades_comprados[faccao_atual][_i] = true;

    if (upgrades[_i].efeito == UPG_EFEITO.unico) {
        alt_recurso = true;
        missao_concluir(FACTION.faction_1, 4, false);
    }
}

// ================= STEP: CLIQUES POR ESTADO =================
function step_expedicao() {
    if (nivel_expedicao >= nivel_max_expedicao) {
        var dest = area_destinos();
        for (var i = 0; i < array_length(dest); i++) {
            if (util_in(box_destino(i))) {
                acao_entrar_area(dest[i]);
                return;
            }
        }
    } else if (util_in(box_avancar())) {
        acao_avancar_expedicao();
        return;
    }

    if (util_in(box_retorno()) && pode_retornar()) {
        mudar_tempo(-calcular_custo_retorno());
        acao_finalizar_run(FIM_RUN.retorno);
        return;
    }

    if (util_in(box_acampar()) && pode_acampar()) {
        acao_acampar();
        return;
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
            cutscene_tocar(CUT.tut_combate);
        } else if (tempo <= 0) {
            acao_finalizar_run(FIM_RUN.tempo);
        } else {
            curar_grupo_total();
            estado = GAME_STATE.expedition;
        }
    }
}

function step_preparacao() {
    var vis = [];
    var c = 0;
    var r = 0;

    switch (prep_tela) {
        case PREP_TELA.menu:
            if (util_in(box_hub(0))) {
                prep_tela = PREP_TELA.upgrades;
                cutscene_tocar(CUT.tut_upgrades);
            } else if (util_in(box_hub(1))) {
                prep_tela = PREP_TELA.habilidades;
                hab_msg = "";
            } else if (util_in(box_hub(2))) {
                prep_tela = PREP_TELA.dialogo;
            } else if (util_in(box_hub(3))) {
                prep_tela = PREP_TELA.missoes;
                cutscene_tocar(CUT.tut_missoes);
            } else if (util_in(box_hub(4))) {
                cutscene_tocar(CUT.tut_expedicao);
                acao_iniciar_run(faccao_atual);
            }
            break;

        case PREP_TELA.upgrades:
            if (util_in(box_voltar())) {
                prep_tela = PREP_TELA.menu;
                return;
            }
            vis = upgrades_visiveis();
            for (var i = 0; i < array_length(vis); i++) {
                if (util_in(box_upg(i))) {
                    acao_comprar_upgrade(vis[i]);
                    return;
                }
            }
            break;

        case PREP_TELA.habilidades:
            if (util_in(box_voltar())) {
                prep_tela = PREP_TELA.menu;
                return;
            }
            if (util_in(box_hab_remover())) {          // <-- NOVA
                acao_hab_remover_todas();
                return;
            }
			
            for (c = 0; c < HAB_COLUNAS; c++) {
                for (r = 0; r < HAB_LINHAS; r++) {
                    if (util_in(box_hab(c, r))) {
                        acao_hab_clicar(c * HAB_LINHAS + r);
                        return;
                    }
                }
            }
            break;

        case PREP_TELA.dialogo:
            prep_tela = PREP_TELA.menu;
            break;

        case PREP_TELA.missoes:
            if (util_in(box_voltar())) {
                prep_tela = PREP_TELA.menu;
                return;
            }
            for (c = 0; c < TOTAL_FACCOES; c++) {
                for (r = 0; r < 5; r++) {
                    if (util_in(box_missao(c, r)) && missao_pode_selecionar(c, r)) {
                        if (missao_selecionada(c, r)) missao_sel = undefined;
                        else missao_sel = { d: c, i: r };
                        return;
                    }
                }
            }
            break;
    }
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
    for (var a = 0; a < array_length(aliados); a++) tick_personagem(aliados[a]);
    for (var e = 0; e < array_length(inimigos); e++) tick_personagem(inimigos[e]);

    for (var p = array_length(popups) - 1; p >= 0; p--) {
        popups[p].y -= 0.6;
        popups[p].vida -= 1;
        if (popups[p].vida <= 0) array_delete(popups, p, 1);
    }

    atualizar_particulas();
}

function hover_preparacao() {
    var vis = [];
    switch (prep_tela) {
        case PREP_TELA.menu:
            if (util_in(box_hub(0))) hover = HV.hub;
            else if (util_in(box_hub(1))) hover = HV.habmenu;
            else if (util_in(box_hub(2))) hover = HV.hub + 1;
            else if (util_in(box_hub(3))) hover = HV.hub + 2;
            else if (util_in(box_hub(4))) hover = HV.iniciar;
            break;

        case PREP_TELA.upgrades:
            vis = upgrades_visiveis();
            for (var i = 0; i < array_length(vis); i++) {
                if (util_in(box_upg(i)) && upgrade_pode_comprar(vis[i])) hover = HV.upg + i;
            }
            if (util_in(box_voltar())) hover = HV.voltar;
            break;

        case PREP_TELA.habilidades:
            for (var c = 0; c < HAB_COLUNAS; c++) {
                for (var r = 0; r < HAB_LINHAS; r++) {
                    if (util_in(box_hab(c, r))) hover = HV.hab + c * HAB_LINHAS + r;
                }
            }
            if (util_in(box_voltar())) hover = HV.voltar;
			if (util_in(box_hab_remover())) hover = HV.habclear;
            break;

        case PREP_TELA.missoes:
            for (var c2 = 0; c2 < TOTAL_FACCOES; c2++) {
                for (var r2 = 0; r2 < 5; r2++) {
                    if (util_in(box_missao(c2, r2))) hover = HV.missao + c2 * 5 + r2;
                }
            }
            if (util_in(box_voltar())) hover = HV.voltar;
            break;
    }
}

function calcular_hover() {
    hover = -1;

    switch (estado) {
        case GAME_STATE.expedition:
            if (nivel_expedicao >= nivel_max_expedicao) {
                var dest = area_destinos();
                for (var d = 0; d < array_length(dest); d++) {
                    if (util_in(box_destino(d))) hover = HV.opcao + d;
                }
            } else if (util_in(box_avancar())) {
                hover = HV.avancar;
            }
            if (util_in(box_retorno()) && pode_retornar()) hover = HV.retorno;
            if (util_in(box_acampar()) && pode_acampar()) hover = HV.acampar;
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
            hover_preparacao();
            break;
    }

    if (hover == -1 && (estado == GAME_STATE.expedition || estado == GAME_STATE.card)) {
        for (var k = 0; k < array_length(player.skills); k++) {
            if (util_in(box_skill(k))) hover = HV.skill + k;
        }
    }
}

// true se o jogador já desbloqueou essa habilidade
function skill_desbloqueada(_id) {
    var pool = skills_desbloqueadas();
    for (var i = 0; i < array_length(pool); i++) {
        if (pool[i] == _id) return true;
    }
    return false;
}