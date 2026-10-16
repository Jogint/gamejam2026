// ================= ÁREAS / MAPA DA TRILHA =================
function Area(_nome, _niveis, _vizinhos) constructor {
    nome = _nome;
    niveis = _niveis;
    vizinhos = _vizinhos;   // AREA que dá para alcançar a partir daqui
    nivel_fixo = 5;         // nível do ponto fixo de herança (-1 = nenhum)
	bg = noone;          // sprite de fundo
    bg_cor = c_white;    // image_blend
    bg_inverter = false; // inverte as cores
	hp_mult = 1;         // multiplicador de vida dos inimigos nesta área
}

// AREA.ini_1..ini_3 têm o mesmo índice de FACTION (0..2)
function criar_areas() {
    var a = array_create(AREA.count);

    a[AREA.ini_1] = new Area("Território da Facção 1", 10, [AREA.ent_12, AREA.ent_31]);
    a[AREA.ini_2] = new Area("Território da Facção 2", 10, [AREA.ent_23, AREA.ent_12]);
    a[AREA.ini_3] = new Area("Território da Facção 3", 10, [AREA.ent_31, AREA.ent_23]);

    a[AREA.ent_12] = new Area("Fronteira 1-2", 8, [AREA.ini_1, AREA.ini_2, AREA.av_12]);
    a[AREA.ent_23] = new Area("Fronteira 2-3", 8, [AREA.ini_2, AREA.ini_3, AREA.av_23]);
    a[AREA.ent_31] = new Area("Fronteira 3-1", 8, [AREA.ini_3, AREA.ini_1, AREA.av_31]);

    a[AREA.av_12] = new Area("Ruínas Avançadas 1-2", 8, [AREA.ent_12, AREA.meio]);
    a[AREA.av_23] = new Area("Ruínas Avançadas 2-3", 8, [AREA.ent_23, AREA.meio]);
    a[AREA.av_31] = new Area("Ruínas Avançadas 3-1", 8, [AREA.ent_31, AREA.meio]);

    a[AREA.meio] = new Area("Coração do Setor", 10, []);
    a[AREA.meio].nivel_fixo = -1;   // o último nível é o chefe final
	
	    // ----- backgrounds -----
    a[AREA.ini_1].bg = spr_forestnight;
    a[AREA.ini_2].bg = spr_bog;
    a[AREA.ini_3].bg = spr_mystic;

    a[AREA.ent_12].bg = spr_forestnight;  a[AREA.ent_12].bg_cor = c_red;
    a[AREA.ent_23].bg = spr_bog;          a[AREA.ent_23].bg_cor = c_lime;
    a[AREA.ent_31].bg = spr_mystic;       a[AREA.ent_31].bg_cor = c_blue;

    a[AREA.av_12].bg = spr_cave;
    a[AREA.av_23].bg = spr_cave;
    a[AREA.av_31].bg = spr_cave;

    a[AREA.meio].bg = spr_cave;
    a[AREA.meio].bg_inverter = true;
	
	    // ----- vida dos inimigos -----
    a[AREA.av_12].hp_mult = 1.15;
    a[AREA.av_23].hp_mult = 1.15;
    a[AREA.av_31].hp_mult = 1.15;
    a[AREA.meio].hp_mult  = 1.30;
	
    return a;
}

// copia os dados da área atual para as variáveis que o resto do código já usa
function area_aplicar() {
    var a = areas[area_atual];
    nome_area = a.nome;
    nivel_max_expedicao = a.niveis;
    nivel_fixo = a.nivel_fixo;
    bg_atual = a.bg;
    bg_cor = a.bg_cor;
    bg_inverter = a.bg_inverter;
}

function acao_entrar_area(_a) {
    area_anterior = area_atual;
    area_atual = _a;
    nivel_expedicao = 0;
    trilha_vis = 0;
    area_aplicar();
}

// destinos possíveis no fim da área: vizinhos, menos a área de onde você veio
function area_destinos() {
    var res = [];
    var v = areas[area_atual].vizinhos;
    for (var i = 0; i < array_length(v); i++) {
        if (v[i] != area_anterior) array_push(res, v[i]);
    }
    return res;
}

function box_destino(_i) { return [450, 190 + _i * 46, 830, 230 + _i * 46]; }

// chefe final (final da Facção 4). missao_f = 3 (índice da F4), missao_i = 4 (missão única)
function criar_carta_chefe() {
    var c = new Card();
    c.name = "O Colosso das Ruínas";
    c.description = "No coração do setor, algo enorme acorda. É aqui que tudo se decide.";
    c.origin = CARD_ORIGIN.faction_4;
    c.tipo = CARD_TIPO.hostil;
    c.inimigos = [ENEMY_ID.colosso];
    c.recompensa_valor = 10;
    c.missao_f = 3;
    c.missao_i = 4;
    return c;
}

// SUBSTITUI a draw_expedicao do scr_draw (apague a antiga)
function draw_expedicao() {
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(640, 150, nome_area + " - Nível " + string(nivel_expedicao) + " / " + string(nivel_max_expedicao));
    draw_set_halign(fa_left);

    if (nivel_expedicao >= nivel_max_expedicao) {
        // fim da área: escolher o caminho
        var dest = area_destinos();
        for (var i = 0; i < array_length(dest); i++) {
            draw_botao(box_destino(i), "Seguir para: " + areas[dest[i]].nome, c_lime, c_black, HV.opcao + i, true);
        }
    } else {
        draw_botao(box_avancar(), "Avançar na Expedição", c_lime, c_black, HV.avancar, true);
    }

    var h_chegada = tempo_para_relogio(tempo - calcular_custo_retorno(), tempo_run_max);
    draw_botao(box_retorno(), "Retornar à Base (Chegada às " + h_chegada + ")", c_orange, c_black, HV.retorno, pode_retornar());
    draw_trilha();
}