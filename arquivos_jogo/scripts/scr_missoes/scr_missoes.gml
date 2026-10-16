// ================= DADOS DAS MISSÕES =================
function missao_nova(_lista, _nome, _desc, _tipo, _nivel) {
    var m = new Missao(_nome, _desc, _tipo, _nivel);
    array_push(_lista, m);
    return m;
}

// missoes[facção (0..3)][0..4] — a missão 4 é a "missão única" da facção
function criar_missoes() {
    var f1 = [];
    var f2 = [];
    var f3 = [];
    var f4 = [];
    var m;

    // ================= FACÇÃO 1 =================
    m = missao_nova(f1, "Reconhecer a Ala Norte", "Você chegou à Ala Norte e mapeou o que restou dela.", MISSAO_TIPO.exploracao, 3);
    m.area = AREA.ini_1;
    m.recompensa = 3;

    m = missao_nova(f1, "Escoltar o Engenheiro", "Leve o Engenheiro até o nível 3 das Ruínas Avançadas 1-2 com vida.", MISSAO_TIPO.escolta, 3);
    m.npc_nome = "Engenheiro";
    m.area = AREA.av_12;
    m.recompensa = 8;

    m = missao_nova(f1, "Peças para o Depósito", "Deixe as peças no depósito da Fronteira 1-2 (nível 3).", MISSAO_TIPO.entrega, 3);
    m.carga_nome = "Peças de Reposição";
    m.area = AREA.ent_12;
    m.recompensa = 6;

    m = missao_nova(f1, "Quebrar a Matilha", "Um domador e sua matilha bloqueiam a Fronteira 3-1 (nível 6).", MISSAO_TIPO.combate, 6);
    m.inimigos = [ENEMY_ID.domador, ENEMY_ID.lobo, ENEMY_ID.lobo];
    m.area = AREA.ent_31;
    m.recompensa = 9;

    m = missao_nova(f1, "Ascensão da Facção 1", "Adquira o upgrade final único (uma alternativa ao recurso).", MISSAO_TIPO.unica, -1);
    m.recompensa = 0;

    // ================= FACÇÃO 2 =================
    m = missao_nova(f2, "Mapear o Perímetro", "Você alcançou o perímetro e marcou os pontos de vigia.", MISSAO_TIPO.exploracao, 2);
    m.area = AREA.ini_2;
    m.recompensa = 3;

    m = missao_nova(f2, "Escoltar o Batedor", "Leve o Batedor até o nível 3 das Ruínas Avançadas 2-3 com vida.", MISSAO_TIPO.escolta, 3);
    m.npc_nome = "Batedor";
    m.area = AREA.av_23;
    m.recompensa = 8;

    m = missao_nova(f2, "Rádio para o Posto Avançado", "Deixe o rádio no posto da Fronteira 2-3 (nível 3).", MISSAO_TIPO.entrega, 3);
    m.carga_nome = "Rádio de Campo";
    m.area = AREA.ent_23;
    m.recompensa = 6;

    m = missao_nova(f2, "Quebrar a Patrulha", "Uma patrulha armada vigia a Fronteira 1-2 (nível 6).", MISSAO_TIPO.combate, 6);
    m.inimigos = [ENEMY_ID.demonio, ENEMY_ID.espadachim];
    m.area = AREA.ent_12;
    m.recompensa = 9;

    m = missao_nova(f2, "Dominar os Pontos Fixos", "Domine 3 pontos fixos hostis de outras facções.", MISSAO_TIPO.unica, -1);
    m.meta = 3;
    m.recompensa = 6;

    // ================= FACÇÃO 3 =================
    m = missao_nova(f3, "Encontro nas Ruínas Neutras", "Você chegou ao ponto de encontro e o local está seguro.", MISSAO_TIPO.exploracao, 4);
    m.area = AREA.ini_3;
    m.recompensa = 3;

    m = missao_nova(f3, "Escoltar o Mediador", "Leve o Mediador até o nível 3 das Ruínas Avançadas 3-1 com vida.", MISSAO_TIPO.escolta, 3);
    m.npc_nome = "Mediador";
    m.area = AREA.av_31;
    m.recompensa = 8;

    m = missao_nova(f3, "Carta de Paz", "Entregue a carta no ponto de troca da Fronteira 3-1 (nível 3).", MISSAO_TIPO.entrega, 3);
    m.carga_nome = "Carta de Paz";
    m.area = AREA.ent_31;
    m.recompensa = 6;

    m = missao_nova(f3, "Dissolver a Emboscada", "Mascarados e seu totem bloqueiam a Fronteira 2-3 (nível 6).", MISSAO_TIPO.combate, 6);
    m.inimigos = [ENEMY_ID.totem, ENEMY_ID.mascara, ENEMY_ID.mascara];
    m.area = AREA.ent_23;
    m.recompensa = 9;

    m = missao_nova(f3, "Paz Entre as Facções", "Leve a relação positiva com todas as outras facções ao máximo.", MISSAO_TIPO.unica, -1);
    m.meta = 3 * RELACAO_MAX;
    m.recompensa = 6;

    // ================= FACÇÃO 4 (missões entregues por NPCs) =================
    m = missao_nova(f4, "Seguir o Rastro do Mensageiro", "O rastro termina nas Ruínas Avançadas 1-2, no nível 4.", MISSAO_TIPO.exploracao, 4);
    m.area = AREA.av_12;
    m.recompensa = 6;

    m = missao_nova(f4, "Guiar o Cartógrafo", "Leve o Cartógrafo até o nível 7 das Ruínas Avançadas 2-3 com vida.", MISSAO_TIPO.escolta, 7);
    m.npc_nome = "Cartógrafo";
    m.area = AREA.av_23;
    m.recompensa = 11;

    m = missao_nova(f4, "Pacote Lacrado", "Deixe o pacote no ponto indicado das Ruínas Avançadas 3-1, no nível 6.", MISSAO_TIPO.entrega, 6);
    m.carga_nome = "Pacote Lacrado";
    m.area = AREA.av_31;
    m.recompensa = 9;

    m = missao_nova(f4, "Eliminar o Enxame Alfa", "O enxame alfa espera no nível 8 do Coração do Setor.", MISSAO_TIPO.combate, 8);
    m.inimigos = [ENEMY_ID.mosquito, ENEMY_ID.mosquito, ENEMY_ID.zumbi];
    m.area = AREA.meio;
    m.recompensa = 12;

    // o chefe vem do último nível do Coração do Setor (criar_carta_chefe)
    m = missao_nova(f4, "Rastrear o Colosso", "No coração do setor, algo enorme espera você.", MISSAO_TIPO.combate, -1);
    m.inimigos = [ENEMY_ID.colosso];
    m.recompensa = 10;

    return [f1, f2, f3, f4];
}

function nome_tipo_missao(_t) {
    switch (_t) {
        case MISSAO_TIPO.exploracao: return "Exploração";
        case MISSAO_TIPO.escolta:    return "Escolta";
        case MISSAO_TIPO.entrega:    return "Entrega";
        case MISSAO_TIPO.combate:    return "Combate";
        case MISSAO_TIPO.unica:      return "Missão Única";
    }
    return "";
}

// ================= REGRAS DAS MISSÕES =================
// escolta e entrega exigem seleção; as demais são automáticas
function missao_ativa_tipo(_m) {
    return (_m.tipo == MISSAO_TIPO.escolta || _m.tipo == MISSAO_TIPO.entrega);
}

// a missão 5 só abre depois das 4 primeiras
function missao_bloqueada(_d, _i) {
    if (_i != 4) return false;
    for (var k = 0; k < 4; k++) {
        if (!missoes[_d][k].concluida) return true;
    }
    return false;
}

// a facção encarnada é a dona da missão, ou é aliada dela
function faccao_pode_missao(_d) {
    if (_d == faccao_atual) return true;
    return (relacao[faccao_atual][origem_da_faccao(_d)] >= RELACAO_ALIADA);
}

// missão desbloqueada = aparece na tela de missões
function missao_visivel(_d, _i) {
    return (faccao_pode_missao(_d) && !missao_bloqueada(_d, _i));
}

function missao_selecionada(_d, _i) {
    return (missao_sel != undefined && missao_sel.d == _d && missao_sel.i == _i);
}

function missao_pode_selecionar(_d, _i) {
    var m = missoes[_d][_i];
    return (missao_ativa_tipo(m) && !m.concluida && !missao_bloqueada(_d, _i) && faccao_pode_missao(_d));
}

function missao_progresso_texto(_d) {
    var m = missoes[_d][4];
    if (m.concluida) return "CONCLUÍDA";
    if (missao_bloqueada(_d, 4)) return "Bloqueada: conclua as 4 missões anteriores";
    switch (_d) {
        case FACTION.faction_1: return "Upgrade final ainda não adquirido";
        case FACTION.faction_2: return string(m.progresso) + " / " + string(m.meta) + " pontos dominados";
        case FACTION.faction_3: return string(m.progresso) + " / " + string(m.meta) + " de relação positiva";
    }
    return "O Colosso ainda vive";
}

// texto + cor do status de uma missão na tela de missões
function missao_status(_d, _i) {
    var m = missoes[_d][_i];

    if (m.concluida) return { txt: "CONCLUÍDA", cor: c_lime };
    if (missao_bloqueada(_d, _i)) return { txt: "Bloqueada (conclua as 4 anteriores)", cor: c_gray };
    if (!faccao_pode_missao(_d)) {
        var req = (_d < FACTION.count) ? ("Requer a Facção " + string(_d + 1) + " ou aliada") : "Requer aliança com a Facção 4";
        return { txt: req, cor: c_orange };
    }
    if (missao_selecionada(_d, _i)) return { txt: "SELECIONADA para a próxima run", cor: c_yellow };
    if (missao_ativa_tipo(m)) return { txt: "Clique para selecionar", cor: c_aqua };
    if (m.tipo == MISSAO_TIPO.unica) return { txt: missao_progresso_texto(_d), cor: c_ltgray };
    if (m.nivel_alvo < 0) return { txt: "Automática (no fim do mapa)", cor: c_ltgray };
    return { txt: "Automática (nível " + string(m.nivel_alvo) + ")", cor: c_ltgray };
}

// ALTERADO: qual missão tem evento fixo neste nível DA ÁREA ATUAL? (undefined se nenhuma)
function missao_no_nivel(_n) {
    for (var d = 0; d < TOTAL_FACCOES; d++) {
        if (!faccao_pode_missao(d)) continue;
        for (var i = 0; i < 5; i++) {
            var m = missoes[d][i];
            if (m.concluida || m.nivel_alvo != _n) continue;
            if (m.area != area_atual) continue;   // NOVO
            if (missao_bloqueada(d, i)) continue;
            if (missao_ativa_tipo(m)) {
                if (run_missao == undefined || run_missao.d != d || run_missao.i != i) continue;
            }
            return { d: d, i: i };
        }
    }
    return undefined;
}

function criar_carta_missao(_d, _i) {
    var m = missoes[_d][_i];
    var c = new Card();
    c.name = m.nome;
    c.description = m.desc;
    c.origin = origem_da_faccao(_d);
    c.missao_f = _d;
    c.missao_i = _i;

    if (m.tipo == MISSAO_TIPO.combate) {
        c.tipo = CARD_TIPO.hostil;
        c.inimigos = m.inimigos;
        c.recompensa_valor = m.recompensa;
    } else {
        c.tipo = CARD_TIPO.missao;
        c.sprite_interacao = spr_cenario_base;
    }
    return c;
}

function grupo_tem(_p) {
    if (_p == undefined) return false;
    for (var i = 0; i < array_length(aliados); i++) {
        if (aliados[i] == _p) return true;
    }
    return false;
}

// chegada ao ponto da missão (exploração, escolta, entrega). Devolve a mensagem do card.
function missao_chegada(_c) {
    var d = _c.missao_f;
    var i = _c.missao_i;
    var m = missoes[d][i];

    switch (m.tipo) {
        case MISSAO_TIPO.exploracao:
            missao_concluir(d, i, true);
            return m.desc + "\n\nMissão concluída!";

        case MISSAO_TIPO.escolta:
            if (grupo_tem(escoltado)) {
                var nome = escoltado.nome;
                for (var k = array_length(aliados) - 1; k >= 0; k--) {
                    if (aliados[k] == escoltado) array_delete(aliados, k, 1);
                }
                escoltado = undefined;
                missao_concluir(d, i, true);
                return nome + " chegou ao destino em segurança. Missão concluída!";
            }
            return "O escoltado não sobreviveu. A missão não foi concluída.";

        case MISSAO_TIPO.entrega:
            if (carga_ativa) {
                acao_remover_carga();
                missao_concluir(d, i, true);
                return "Carga entregue. Missão concluída!";
            }
            return "Você não está com a carga. A missão não foi concluída.";
    }
    return "";
}

function missao_concluir(_d, _i, _premiar) {
    var m = missoes[_d][_i];
    if (m.concluida) return;
    m.concluida = true;

    if (_premiar && m.recompensa > 0) {
        recurso += m.recompensa;
        criar_popup("Missão concluída! +" + string(m.recompensa) + " recursos", 640, 300, c_yellow);
    }

    // NOVO: concluir a missão única = final da facção (a cutscene toca no Step do obj_game)
    if (_i == 4) final_pendente = _d;

    missao_checar_finais();
}

// reavalia as missões únicas de F2 e F3 (podem ter ficado prontas antes de desbloquear)
function missao_checar_finais() {
    // F3: soma da relação da Facção 3 com as outras
    var m3 = missoes[FACTION.faction_3][4];
    var soma = 0;
    for (var o = 1; o <= TOTAL_FACCOES; o++) {
        if (o == origem_da_faccao(FACTION.faction_3)) continue;
        soma += relacao[FACTION.faction_3][o];
    }
    m3.progresso = soma;
    if (!m3.concluida && !missao_bloqueada(FACTION.faction_3, 4) && soma >= m3.meta) {
        missao_concluir(FACTION.faction_3, 4, true);
    }

    // F2: pontos dominados
    var m2 = missoes[FACTION.faction_2][4];
    if (!m2.concluida && !missao_bloqueada(FACTION.faction_2, 4) && m2.progresso >= m2.meta) {
        missao_concluir(FACTION.faction_2, 4, true);
    }
}

// ================= ENTREGA (SKILL DE MISSÃO) =================
function acao_dar_carga(_m) {
    var s = new Skill("Carga: " + _m.carga_nome, 0, 0, STAT.forca, SKILL_TIPO.dano);
    s.cat = SKILL_CAT.missao;
	    // frames 2/3/4 = entrega da facção azul/vermelha/verde (dona da missão)
    s.icone = spr_extra_skills;
    s.icone_sub = 2 + ((run_missao.d < FACTION.count) ? run_missao.d : faccao_atual);
    if (array_length(player.skills) < player.max_skills) {
        array_push(player.skills, s);
    } else {
        skill_deslocada = player.skills[player.max_skills - 1];
        player.skills[player.max_skills - 1] = s;
    }
    carga_ativa = true;
}

function acao_remover_carga() {
    for (var i = 0; i < array_length(player.skills); i++) {
        if (player.skills[i].cat == SKILL_CAT.missao) {
            if (skill_deslocada != undefined) {
                player.skills[i] = skill_deslocada;
                skill_deslocada = undefined;
            } else {
                array_delete(player.skills, i, 1);
            }
            break;
        }
    }
    carga_ativa = false;
}

// ================= RELAÇÕES =================
// muda a relação da facção encarnada com a facção de origem _origem
function relacao_mudar(_origem, _v) {
    relacao[faccao_atual][_origem] = clamp(relacao[faccao_atual][_origem] + _v, 0, RELACAO_MAX);
    missao_checar_finais();
}

// evento de diplomacia com uma facção que não seja a sua
function criar_carta_emissario() {
    var o;
    do {
        o = irandom_range(1, TOTAL_FACCOES);
    } until (o != origem_da_faccao(faccao_atual));

    var c = new Card();
    c.name = "Emissário da Facção " + string(o);
    c.description = "Um enviado oferece conversar sobre um acordo entre as facções.";
    c.origin = o;
    carta_opcoes(c, STAT.carisma, 3, STAT.imaginacao, 3, STAT.sorte, 4);
    c.recompensa = RECOMPENSA.relacao;
    c.fail_tempo = 2;
    return c;
}

// ================= PÓS-VITÓRIA =================
function pos_vitoria_carta() {
    var c = carta_atual;
    if (c == undefined) return;

    // missão de combate (inclui o chefe final)
    if (c.missao_f >= 0) missao_concluir(c.missao_f, c.missao_i, true);

    // ponto fixo hostil: conta para a dominação da Facção 2
    if (c.ponto_fixo && faccao_pode_missao(FACTION.faction_2)) {
        var m = missoes[FACTION.faction_2][4];
        if (!m.concluida) {
            m.progresso++;
            missao_checar_finais();
        }
    }

    // vencer inimigos de outra facção piora a relação com ela
    if (c.origin != CARD_ORIGIN.neutral && c.origin != origem_da_faccao(faccao_atual)) {
        relacao_mudar(c.origin, -1);
    }
}

// ================= LÍDER =================
function texto_lider_flavor(_f) {
    switch (_f) {
        case FACTION.faction_1: return "Nossos engenheiros acreditam que dá para fazer o recurso trabalhar por nós, e não o contrário. Falta só o último passo.";
        case FACTION.faction_2: return "Saqueadores só entendem uma língua. Cada posto tomado é um aviso para o resto.";
        case FACTION.faction_3: return "Guerra gasta mais que qualquer expedição. Se sentarmos todas as facções à mesma mesa, ninguém mais precisa lutar.";
    }
    return "...";
}

function texto_dialogo_lider() {
    var f = faccao_atual;
    var m = missoes[f][4];
    var feitas = 0;
    for (var i = 0; i < 5; i++) {
        if (missoes[f][i].concluida) feitas++;
    }

    var t = texto_lider_flavor(f) + "\n\n";
    t += "Missão única: " + (missao_bloqueada(f, 4) ? "???" : m.nome) + "\n" + missao_progresso_texto(f) + "\n";
    t += "Missões concluídas: " + string(feitas) + " / 5\n\nRelações:\n";
    for (var o = 1; o <= TOTAL_FACCOES; o++) {
        if (o == origem_da_faccao(f)) continue;
        t += "Facção " + string(o) + ": " + string(relacao[f][o]) + " / " + string(RELACAO_MAX);
        if (relacao[f][o] >= RELACAO_ALIADA) t += "  (aliada)";
        t += "\n";
    }
    return t;
}