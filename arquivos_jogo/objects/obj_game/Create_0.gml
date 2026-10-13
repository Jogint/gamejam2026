////obj_game create
display_set_gui_size(1280, 720);
randomize();

// 1. PRIMEIRO: Inicialize a biblioteca de sprites para que todas as variáveis globais/locais de sprites existam
criar_biblioteca_sprites();  // MOVIDO PARA CÁ

tempo_max = 50;
nivel_max_expedicao = 10;
nivel_fixo = 5;
slots_upg = 1;

stat_nomes = ["VIT", "FOR", "IMA", "TEC", "SOR", "CAR"];
origem_cores = [c_white, c_red, c_aqua, c_orange, c_fuchsia];

estoque_faccoes = array_create(FACTION.count, 0);
reserva = 0;

// 2. AGORA sim, crie o deck, pois os sprites já foram definidos acima
deck_global = criar_deck_jogo(); 

upgrades = criar_upgrades();
upgrades_comprados = array_create(array_length(upgrades), false);

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
figura_evento = undefined;   // NOVO
msg_fim = "";

acao_iniciar_run(FACTION.faction_1);