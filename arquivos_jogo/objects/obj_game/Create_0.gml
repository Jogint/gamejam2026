////obj_game create
display_set_gui_size(1280, 720);
randomize();

tempo_max = 50;
nivel_max_expedicao = 10;
nivel_fixo = 5;
slots_upg = 1;

stat_nomes = ["VIT", "FOR", "IMA", "TEC", "SOR", "CAR"];
origem_cores = [c_white, c_red, c_aqua, c_orange, c_fuchsia];

// por facção
estoque_faccoes = array_create(FACTION.count, 0);
reserva = array_create(FACTION.count, 0);                    // ALTERADO
deck_global = criar_deck_jogo();
upgrades = criar_upgrades();
upgrades_comprados = [];                                     // ALTERADO
for (var f = 0; f < FACTION.count; f++) {
    array_push(upgrades_comprados, array_create(array_length(upgrades), false));
}
alt_recurso = false;                                         // NOVO: final da F1 (efeito a definir)

// NOVO: relação de cada facção jogável com cada origem
relacao = [];
for (var g = 0; g < FACTION.count; g++) {
    array_push(relacao, array_create(CARD_ORIGIN.count, 0));
}

// NOVO: missões
missoes = criar_missoes();
missao_sel = undefined;
run_missao = undefined;
escoltado = undefined;
carga_ativa = false;
skill_deslocada = undefined;
aliados = [];
prep_tela = PREP_TELA.menu;

// mouse e hover
mx = 0;
my = 0;
hover = -1;
hover_anim = array_create(HV.count, 0);

// animações
tempo_vis = tempo_max;
hud_exp = 0;
card_anim = 1;
trilha_vis = 0;
popups = [];

// combate
inimigos = [];
c_fase = COMBAT_FASE.skill;
c_ator = 0;
c_skill = -1;
c_fila = [];
c_idx = 0;
c_timer = 0;
c_log = [];
c_tempos = [];
c_rodada = 1;
c_recompensa = 0;
c_resultado = COMBAT_RES.nenhum;

ultima_carta = undefined;
figura_evento = undefined;
msg_fim = "";

criar_biblioteca_sprites();
lideres = criar_lideres();                                   // NOVO

acao_iniciar_run(FACTION.faction_1);
estado = GAME_STATE.preparacao;                              // NOVO: começa no hub