display_set_gui_size(1280, 720);
randomize();

// Configs gerais
tempo_max = 20;
custo_passo = 1;
chance_carta = 0.4;
passos_garantidos = 3;
custo_base_volta = 1;
taxa_morte = 0.5;

// Mapa
map_cols = 5;
map_rows = 5;
tile_size = 100;
map_x = 40;
map_y = 40;

btn_voltar = [950, 650, 1240, 700];

// HUD e Layout de Cartas
hud_y = 560;
stats_x = 40; stats_y = 580; stats_gap = 36;
skills_x = 340; skills_y = 580; skills_gap = 190;
info_x = 950;

card_x_off = 1300;
card_x_on = 580;
card_x = card_x_off;
card_dest_x = card_x_off;
card_y = 40; card_w = 600; card_h = 480;
card_spd = 0.2;
opt_margin = 20; opt_top = 260; opt_h = 40; opt_gap = 55;

origem_cores = [c_white, c_red, c_aqua, c_orange, c_fuchsia];
deck_eventos = create_event_deck();

faccao = FACTION.faction_1;
estoque_faccoes = array_create(FACTION.count, 0);

stat_nomes = ["Forca", "Percepcao", "Tecnica"];
stats = array_create(STAT.count, 3);
stat_mods = array_create(STAT.count, 0);
skill_nomes = ["Golpe", "Investida", "Arremesso"];
skill_custos = [1, 2, 3];

carta_atual = undefined;
carta_resolvida = false;
card_msg = "";
estado = GAME_STATE.map;
msg_fim = "";

// Funções de controle
iniciar_run = function(_fac) {
    faccao = _fac;
    tempo = tempo_max;
    recurso = 0;
    passos_sem_carta = 0;
    stat_mods = array_create(STAT.count, 0);
    carta_atual = undefined;
    card_x = card_x_off;
    card_dest_x = card_x_off;

    var cantos = [
        [0, 0],                        
        [map_cols - 1, 0],             
        [map_cols - 1, map_rows - 1],  
        [0, map_rows - 1]              
    ];
    
    base_col = cantos[_fac][0];
    base_lin = cantos[_fac][1];
    player_col = base_col;
    player_lin = base_lin;
    estado = GAME_STATE.map;
};

calc_custo_volta = function() {
    return (abs(player_col - base_col) + abs(player_lin - base_lin)) * custo_base_volta;
};

finalizar_run = function(voltou) {
    var rec_final = voltou ? recurso : floor(recurso * taxa_morte);
    
    msg_fim = voltou 
        ? "Voltou a base com " + string(rec_final) + " de recurso."
        : "O tempo acabou! Roubaram " + string(rec_final) + " de recurso.";

    estoque_faccoes[faccao] += rec_final;
    estado = GAME_STATE.run_end;
};

voltar_base = function() {
    var custo = calc_custo_volta();
    if (tempo >= custo) {
        tempo -= custo;
        finalizar_run(true);
    }
};

mover_para = function(dest_col, dest_lin) {
    player_col = dest_col;
    player_lin = dest_lin;
    tempo = max(0, tempo - custo_passo);

    if (tempo == 0) {
        finalizar_run(false);
        return;
    }

    passos_sem_carta++;
    if (passos_sem_carta >= passos_garantidos || random(1) < chance_carta) {
        passos_sem_carta = 0;
        sortear_carta();
    }
};

get_stat_total = function(idx) {
    return stats[idx] + stat_mods[idx];
};

get_chance_sucesso = function(opt) {
    return min(1, get_stat_total(opt.stat) / opt.required);
};

sortear_carta = function() {
    carta_atual = deck_eventos[irandom(array_length(deck_eventos) - 1)];
    carta_resolvida = false;
    card_msg = "";
    card_dest_x = card_x_on;
    estado = GAME_STATE.card;
};

resolver_escolha = function(escolha) {
    if (escolha == CARD_CHOICE.skip) {
        tempo = max(0, tempo - carta_atual.time);
        card_msg = "Contornou o problema, perdeu " + string(carta_atual.time) + " de tempo.";
    } else {
        var opt = carta_atual.options[escolha];
        if (random(1) < get_chance_sucesso(opt)) {
            recurso += carta_atual.reward;
            card_msg = "Sucesso! Ganhou " + string(carta_atual.reward) + " de recurso.";
            array_foreach(carta_atual.action, function(act) { act(id); });
        } else {
            tempo = max(0, tempo - carta_atual.fail_time);
            card_msg = "Falha... perdeu " + string(carta_atual.fail_time) + " de tempo.";
        }
    }
    carta_resolvida = true;
};

fechar_carta = function() {
    card_dest_x = card_x_off;
    estado = GAME_STATE.map;
    if (tempo <= 0) {
        tempo = 0;
        finalizar_run(false);
    }
};

reencarnar = function() {
    iniciar_run((faccao + 1) % FACTION.count);
};

clicou_box = function(mx, my, x1, y1, x2, y2) {
    return mx >= x1 && mx <= x2 && my >= y1 && my <= y2;
};

iniciar_run(faccao);