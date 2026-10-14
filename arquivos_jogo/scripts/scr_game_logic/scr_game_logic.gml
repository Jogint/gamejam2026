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

function box_card() {
    var off = (1 - card_anim) * 320;
    return [350, 55 - off, 930, 360 - off];
}

function box_opcao(_i) {
    var off = (1 - card_anim) * 200;
    return [360, 380 + _i * 42 + off, 920, 416 + _i * 42 + off];
}

function box_skill(_k) { return [550 + _k * 120, 595, 660 + _k * 120, 670]; }

// fila horizontal estilo Darkest Dungeon. O índice 0 fica mais perto do centro.
function box_slot_party(_i) {
    var x2 = 580 - _i * 140;
    return [x2 - 135, 62, x2, 252];
}
function box_slot_inimigo(_i) {
    var x1 = 700 + _i * 140;
    return [x1, 62, x1 + 135, 252];
}

function box_upg(_i) { return [200, 110 + _i * 40, 1080, 146 + _i * 40]; }

// hub da preparação
function box_hub(_k) { return [330, 150 + _k * 90, 760, 220 + _k * 90]; }
function box_voltar() { return [40, 640, 240, 690]; }
function box_missao(_c, _r) {
    var x1 = 30 + _c * 310;
    var y1 = 110 + _r * 85;
    return [x1, y1, x1 + 300, y1 + 78];
}

// ================= DADOS =================
// Para ligar uma partícula: skill_part(<a skill>, spr_particula)
function skill_nova(_id) {
    switch (_id) {
        // ---- ataques básicos ----
        case SKILL_ID.golpe:   return new Skill("Golpe", 2, 2, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.pancada: return new Skill("Pancada", 3, 4, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.mordida: return new Skill("Mordida", 2, 1, STAT.forca, SKILL_TIPO.dano);
        case SKILL_ID.disparo: return new Skill("Disparo", 3, 3, STAT.tecnica, SKILL_TIPO.dano);

        // ---- skills ----
        case SKILL_ID.tiro:
            return skill_cd(new Skill("Tiro Preciso", 3, 3, STAT.tecnica, SKILL_TIPO.dano), 2);
        case SKILL_ID.improviso:
            return skill_cd(new Skill("Improviso", 5, 6, STAT.imaginacao, SKILL_TIPO.dano), 3);
        case SKILL_ID.remendo:    // cura básica
            return skill_cd(new Skill("Remendo", 3, 4, STAT.tecnica, SKILL_TIPO.cura), 3);
        case SKILL_ID.investida:
            return skill_cd(new Skill("Investida", 5, 5, STAT.forca, SKILL_TIPO.dano), 2);
        case SKILL_ID.sobrecarga:
            return skill_cd(new Skill("Sobrecarga", 6, 6, STAT.tecnica, SKILL_TIPO.dano), 3);
        case SKILL_ID.rajada:
            return skill_cd(new Skill("Rajada", 4, 3, STAT.tecnica, SKILL_TIPO.dano), 2);

        // ---- skills com status ----
        case SKILL_ID.chama:      // queimadura: dano fixo por turno
            return skill_efeito(skill_cd(new Skill("Chama Viva", 4, 2, STAT.imaginacao, SKILL_TIPO.dano), 3), STATUS.queimadura, 3, 2);
        case SKILL_ID.atordoar:   // atordoamento: alvo perde 1 turno
            return skill_efeito(skill_cd(new Skill("Atordoar", 4, 1, STAT.forca, SKILL_TIPO.dano), 4), STATUS.atordoamento, 1, 0);
        case SKILL_ID.acido:      // corrosão: dano cresce a cada turno (1, 2, 3...)
            return skill_efeito(skill_cd(new Skill("Ácido", 3, 1, STAT.tecnica, SKILL_TIPO.dano), 3), STATUS.corrosao, 3, 1);
        case SKILL_ID.purificar:  // cura + remove status negativos
            return skill_cd(new Skill("Purificar", 4, 3, STAT.tecnica, SKILL_TIPO.restaurar), 3);
        case SKILL_ID.estilhacos: // ataque global
            return skill_alcance(skill_cd(new Skill("Estilhaços", 5, 1, STAT.tecnica, SKILL_TIPO.dano), 3), ALCANCE.global);
        case SKILL_ID.explosao:   // ataque em área (adjacentes levam metade)
            return skill_alcance(skill_cd(new Skill("Explosão", 4, 3, STAT.imaginacao, SKILL_TIPO.dano), 3), ALCANCE.adjacente);
        case SKILL_ID.rede:       // lentidão: +2 de tempo nas skills do alvo
            return skill_efeito(skill_cd(new Skill("Rede", 3, 0, STAT.tecnica, SKILL_TIPO.debuff), 3), STATUS.lentidao, 3, 2);
        case SKILL_ID.estimulante: // celeridade: -1 de tempo nas skills do alvo
            return skill_efeito(skill_cd(new Skill("Estimulante", 2, 0, STAT.imaginacao, SKILL_TIPO.buff), 4), STATUS.celeridade, 3, 1);
        case SKILL_ID.sincronia:  // reduz recarga das skills de todo o grupo
            return skill_alcance(skill_cd(new Skill("Sincronia", 3, 1, STAT.imaginacao, SKILL_TIPO.recarga), 4), ALCANCE.global);
    }
    return new Skill("???", 1, 1, STAT.forca, SKILL_TIPO.dano);
}

function inimigo_novo(_id, _origem) {
    var e = new Personagem("Inimigo");
    var cl = CLASSE.soldado;
    switch (_id) {
        case ENEMY_ID.besta:
            e.nome = "Besta das Ruínas";
            e.stats[STAT.vitalidade] = 2;
            e.stats[STAT.forca] = 2;
            e.skills = [skill_nova(SKILL_ID.mordida), skill_nova(SKILL_ID.investida)];
            cl = CLASSE.mutante;
            break;
        case ENEMY_ID.saqueador:
            e.nome = "Saqueador";
            e.stats[STAT.vitalidade] = 2;
            e.stats[STAT.forca] = 2;
            e.stats[STAT.tecnica] = 2;
            e.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.tiro)];
            cl = CLASSE.soldado;
            break;
        case ENEMY_ID.sentinela:
            e.nome = "Sentinela";
            e.stats[STAT.vitalidade] = 2;
            e.skills = [skill_nova(SKILL_ID.disparo), skill_nova(SKILL_ID.sobrecarga)];
            cl = CLASSE.maquina;
            break;
        case ENEMY_ID.rato:
            e.nome = "Rato Mutante";
            e.stats[STAT.vitalidade] = 0;
            e.stats[STAT.forca] = 1;
            e.skills = [skill_nova(SKILL_ID.mordida)];
            cl = CLASSE.mutante;
            break;
        case ENEMY_ID.guarda:
            e.nome = "Guarda do Posto";
            e.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.rajada)];
            cl = CLASSE.soldado;
            break;
        case ENEMY_ID.colosso:   // boss
            e.nome = "Colosso das Ruínas";
            e.stats[STAT.vitalidade] = 8;
            e.stats[STAT.forca] = 5;
            e.stats[STAT.tecnica] = 4;
            e.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.investida), skill_nova(SKILL_ID.estilhacos), skill_nova(SKILL_ID.atordoar)];
            cl = CLASSE.mutante;
            break;
    }
    visual_aleatorio(e, cl, _origem);
    p_curar_total(e);
    return e;
}

// até MAX_INIMIGOS; nomes repetidos viram "B", "C", "D"
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

function aliado_novo(_nome, _origem) {
    var a = new Personagem(_nome);
    a.stats[STAT.vitalidade] = 2;
    a.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.remendo)];
    visual_aleatorio(a, CLASSE.civil, _origem);   // se for NPC importante, use visual_fixo
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

    // teste de 4 inimigos
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
    c.fail_tempo = 2;
    c.recompensa_valor = 2;
    array_push(deck, c);

    c = new Card();
    c.name = "Terminal Antigo";
    c.description = "Um painel elétrico selado bloqueia o acesso ao depósito principal.";
    c.origin = CARD_ORIGIN.faction_2;
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.tecnica, 5, STAT.imaginacao, 4, STAT.forca, 6);
    c.fail_tempo = 3;
    c.recompensa_valor = 4;
    array_push(deck, c);

    c = new Card();
    c.name = "Reservatório Intacto";
    c.description = "Uma cisterna lacrada guarda água limpa e suprimentos médicos.";
    c.sprite_interacao = spr_cenario_base;
    carta_opcoes(c, STAT.tecnica, 4, STAT.imaginacao, 3, STAT.sorte, 4);
    c.recompensa = RECOMPENSA.cura;
    c.recompensa_valor = 8;
    c.fail_tempo = 2;
    array_push(deck, c);

    c = new Card();
    c.name = "Treino Improvisado";
    c.description = "Restos de uma arena de treino. Dá para aprender algo antes de seguir.";
    c.sprite_interacao = spr_cenario_base;
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
    var lista = [
        new Upgrade("Reservas de Água", "+6 de tempo inicial", 4, UPG_EFEITO.tempo, 0, 6),
        new Upgrade("Rota Segura", "Retorno custa 2 a menos", 4, UPG_EFEITO.retorno, 0, 2),
        new Upgrade("Atalho", "Contornar custa 1 a menos", 3, UPG_EFEITO.contornar, 0, 1),
        new Upgrade("Treino de Força", "+1 FOR", 3, UPG_EFEITO.stat, STAT.forca, 1),
        new Upgrade("Sorte de Principiante", "+1 SOR", 3, UPG_EFEITO.stat, STAT.sorte, 1),
        new Upgrade("Constituição", "+1 VIT (mais HP)", 3, UPG_EFEITO.stat, STAT.vitalidade, 1),
        new Upgrade("Treino de Pancada", "Básico: Pancada (mais forte, mais lenta)", 3, UPG_EFEITO.basico, SKILL_ID.pancada, 0),
        new Upgrade("Kit de Remendo", "Começa com a skill Remendo", 5, UPG_EFEITO.skill, SKILL_ID.remendo, 0),
        new Upgrade("Treino de Improviso", "Começa com a skill Improviso", 5, UPG_EFEITO.skill, SKILL_ID.improviso, 0),
        new Upgrade("Chama Viva", "Começa com a skill Chama Viva (queima)", 5, UPG_EFEITO.skill, SKILL_ID.chama, 0),
        new Upgrade("Explosão", "Começa com a skill Explosão (área)", 5, UPG_EFEITO.skill, SKILL_ID.explosao, 0),
        new Upgrade("Estimulante", "Começa com a skill Estimulante", 5, UPG_EFEITO.skill, SKILL_ID.estimulante, 0)
    ];

    // upgrade final único da Facção 1 (conclui a missão única dela)
    var u = new Upgrade("Ascensão Final", "Alternativa ao recurso (efeito a definir)", 12, UPG_EFEITO.unico, 0, 0);
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
        c.recompensa_valor = 3;
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
        c.ponto_fixo = true;   // conta para a dominação
    }
    return c;
}

// ================= RUN =================
function acao_iniciar_run(_fac) {
    faccao_atual = _fac;
    recurso = 0;
    nivel_total = 0;             // NOVO: níveis percorridos na run toda (custo de retorno)
    nivel_expedicao = 0;
    area_atual = _fac;           // NOVO: AREA.ini_1..3 têm o mesmo índice das FACTION
    area_anterior = -1;
    area_aplicar();              // NOVO: nome, nº de níveis e ponto fixo da área

    tempo_run_max = tempo_max;
    mod_retorno = 0;
    custo_contornar = 3;

    player = new Personagem("Sobrevivente F" + string(_fac + 1));
    visual_fixo(player, CLASSE.sobrevivente, origem_da_faccao(_fac), lib_player[_fac], noone);
    player.skills = [skill_nova(SKILL_ID.golpe), skill_nova(SKILL_ID.tiro)];   // slot 0 = básico
    aliados = [];

    // upgrades da facção atual
    var comprados = upgrades_comprados[_fac];
    for (var i = 0; i < array_length(upgrades); i++) {
        if (!comprados[i]) continue;
        var u = upgrades[i];
        switch (u.efeito) {
            case UPG_EFEITO.tempo:     tempo_run_max += u.valor; break;
            case UPG_EFEITO.retorno:   mod_retorno += u.valor; break;
            case UPG_EFEITO.contornar: custo_contornar -= u.valor; break;
            case UPG_EFEITO.stat:      player.stat_mods[u.alvo] += u.valor; break;
            case UPG_EFEITO.skill:     acao_dar_skill(player, u.alvo); break;
            case UPG_EFEITO.basico:    acao_dar_skill(player, u.alvo); break;
        }
    }

    // missão selecionada vale só para esta run
    run_missao = missao_sel;
    missao_sel = undefined;
    escoltado = undefined;
    carga_ativa = false;
    skill_deslocada = undefined;
    if (run_missao != undefined) {
        var m = missoes[run_missao.d][run_missao.i];
        if (m.tipo == MISSAO_TIPO.escolta) {
            escoltado = aliado_novo(m.npc_nome, origem_da_faccao(run_missao.d));
            array_push(aliados, escoltado);
            cutscene_tocar(CUT.tut_escolta);   // NOVO
        } else if (m.tipo == MISSAO_TIPO.entrega) {
            acao_dar_carga(m);
            cutscene_tocar(CUT.tut_entrega);   // NOVO
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

// ataque básico só troca com ataque básico (sempre no slot 0)
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

// ALTERADO: conta os níveis da run inteira, não só da área atual
// (alternativa mais barata: nivel_expedicao + 3 * areas cruzadas)
function calcular_custo_retorno() {
    return max(1, nivel_total - mod_retorno);
}

function pode_retornar() {
    return (nivel_total > 0 && tempo >= calcular_custo_retorno());
}

// ALTERADO: o fim da área vira escolha de caminho (ver step_expedicao); o Coração do Setor termina no chefe
function acao_avancar_expedicao() {
    nivel_expedicao++;
    nivel_total++;

    // última casa de uma área comum: apresenta a escolha de caminho (1ª vez)
    if (nivel_expedicao == nivel_max_expedicao && area_atual != AREA.meio) cutscene_tocar(CUT.tut_passagem);

    // fim do Coração do Setor: chefe final (final da Facção 4)
    if (area_atual == AREA.meio && nivel_expedicao == nivel_max_expedicao) {
        acao_mostrar_card(criar_carta_chefe());
        return;
    }

    // missões têm prioridade sobre o ponto fixo de herança
    var mi = missao_no_nivel(nivel_expedicao);
    if (mi != undefined) {
        acao_mostrar_card(criar_carta_missao(mi.d, mi.i));
    } else if (nivel_expedicao == nivel_fixo) {
        acao_mostrar_card(criar_carta_fixa());
    } else {
        acao_mostrar_card(sortear_do_deck());
    }
}

// 20% de chance de um emissário de outra facção
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

    // figura mostrada no painel da direita
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
            var g = get_grupo();   // cura o grupo todo
            for (var i = 0; i < array_length(g); i++) p_curar_total(g[i]);
            card_msg = "Você descansa no posto: tempo e HP recuperados.";
            break;
        case CARD_TIPO.missao:
            carta_resolvida = true;
            card_msg = missao_chegada(_c);
            break;
    }

    // NOVO: tutoriais da primeira vez
    if (_c.tipo == CARD_TIPO.hostil) {
        cutscene_tocar(CUT.tut_combate);
    } else if (_c.tipo == CARD_TIPO.evento || _c.tipo == CARD_TIPO.amigavel) {
        cutscene_tocar(CUT.tut_evento);
        if (_c.recompensa == RECOMPENSA.relacao) cutscene_tocar(CUT.tut_diplomacia);
    }
}

function acao_resolver_escolha(_idx) {
    if (_idx == 3) {
        mudar_tempo(-custo_contornar);
        card_msg = "Você contornou o obstáculo e perdeu " + string(custo_contornar) + " de tempo.";
    } else {
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
            card_msg = "SUCESSO! " + acao_aplicar_recompensa(carta_atual);
        } else {
            mudar_tempo(-carta_atual.fail_tempo);
            card_msg = "FALHA... Você perdeu " + string(carta_atual.fail_tempo) + " de tempo.";
        }
    }
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
            return "O grupo recuperou " + string(_c.recompensa_valor) + " de HP.";
        case RECOMPENSA.stat:
            player.stat_mods[_c.recompensa_stat] += _c.recompensa_valor;
            if (_c.recompensa_stat == STAT.vitalidade) player.hp += _c.recompensa_valor * 3;
            return "+" + string(_c.recompensa_valor) + " " + stat_nomes[_c.recompensa_stat] + " até o fim da expedição.";
        case RECOMPENSA.aliado:
            if (array_length(aliados) < MAX_GRUPO - 1) {
                // reaproveita o aliado que apareceu na carta (mesmo visual)
                novo = (_c.tipo == CARD_TIPO.amigavel) ? figura_evento : aliado_novo(_c.aliado_nome, _c.origin);
                array_push(aliados, novo);
                return _c.aliado_nome + " se juntou ao seu grupo!";
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

function remover_aliados_mortos() {
    for (var i = array_length(aliados) - 1; i >= 0; i--) {
        if (aliados[i].hp <= 0) array_delete(aliados, i, 1);
    }
}

// ALTERADO: a cutscene de fim de ciclo substitui a tela "CICLO FINALIZADO"
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

    // se um final está pendente, ele toca no lugar da cutscene de fim de ciclo
    if (final_pendente == -1) cutscene_tocar(CUT.morte);
}

function acao_reencarnar() {
    faccao_atual = (faccao_atual + 1) % FACTION.count;
    missao_sel = undefined;               // seleção não atravessa facções
    prep_tela = PREP_TELA.menu;
    estado = GAME_STATE.preparacao;
}

// ================= UPGRADES =================
// índices dos upgrades que a facção atual enxerga
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
    if (u.efeito == UPG_EFEITO.skill && contar_upgrades_skill() >= slots_upg) return false;
    if (u.efeito == UPG_EFEITO.unico && missao_bloqueada(FACTION.faction_1, 4)) return false;
    return true;
}

function acao_comprar_upgrade(_i) {
    if (!upgrade_pode_comprar(_i)) return;
    reserva[faccao_atual] -= upgrades[_i].custo;
    upgrades_comprados[faccao_atual][_i] = true;

    if (upgrades[_i].efeito == UPG_EFEITO.unico) {
        alt_recurso = true;                              // efeito ainda a definir
        missao_concluir(FACTION.faction_1, 4, false);    // conclui a missão única da F1 (dispara o final)
    }
}

// ================= STEP: CLIQUES POR ESTADO =================
// ALTERADO: no fim da área os botões são os destinos
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

// hub com sub-telas
function step_preparacao() {
    var vis = [];
    var c = 0;
    var r = 0;

    switch (prep_tela) {
        case PREP_TELA.menu:
            if (util_in(box_hub(0))) {
                prep_tela = PREP_TELA.upgrades;
                cutscene_tocar(CUT.tut_upgrades);   // NOVO
            } else if (util_in(box_hub(1))) {
                prep_tela = PREP_TELA.dialogo;
            } else if (util_in(box_hub(2))) {
                prep_tela = PREP_TELA.missoes;
                cutscene_tocar(CUT.tut_missoes);    // NOVO
            } else if (util_in(box_hub(3))) {
                cutscene_tocar(CUT.tut_expedicao);  // NOVO (antes, para vir primeiro na fila)
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

        case PREP_TELA.dialogo:
            prep_tela = PREP_TELA.menu;   // qualquer clique fecha
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
            else if (util_in(box_hub(1))) hover = HV.hub + 1;
            else if (util_in(box_hub(2))) hover = HV.hub + 2;
            else if (util_in(box_hub(3))) hover = HV.iniciar;
            break;

        case PREP_TELA.upgrades:
            vis = upgrades_visiveis();
            for (var i = 0; i < array_length(vis); i++) {
                if (util_in(box_upg(i)) && upgrade_pode_comprar(vis[i])) hover = HV.upg + i;
            }
            if (util_in(box_voltar())) hover = HV.voltar;
            break;

        case PREP_TELA.missoes:
            for (var c = 0; c < TOTAL_FACCOES; c++) {
                for (var r = 0; r < 5; r++) {
                    if (util_in(box_missao(c, r))) hover = HV.missao + c * 5 + r;
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
            // ALTERADO: no fim da área o hover é dos botões de destino
            if (nivel_expedicao >= nivel_max_expedicao) {
                var dest = area_destinos();
                for (var d = 0; d < array_length(dest); d++) {
                    if (util_in(box_destino(d))) hover = HV.opcao + d;
                }
            } else if (util_in(box_avancar())) {
                hover = HV.avancar;
            }
            if (util_in(box_retorno()) && pode_retornar()) hover = HV.retorno;
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

    // hover nos slots de skill fora do combate (mostra o tooltip)
    if (hover == -1 && (estado == GAME_STATE.expedition || estado == GAME_STATE.card)) {
        for (var k = 0; k < array_length(player.skills); k++) {
            if (util_in(box_skill(k))) hover = HV.skill + k;
        }
    }
}