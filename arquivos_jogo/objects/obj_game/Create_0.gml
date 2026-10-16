hab_iniciar();


display_set_gui_size(1280, 720);
randomize();

tempo_max = 100;
nivel_max_expedicao = 10;   // sobrescrito por area_aplicar() ao iniciar a run
nivel_fixo = 5;             // idem
slots_upg = 1;

stat_nomes = ["VIT", "FOR", "IMA", "TEC", "SOR", "CAR"];
origem_cores = [c_white, c_red, c_aqua, c_orange, c_fuchsia];

// por facção
estoque_faccoes = array_create(FACTION.count, 0);
reserva = array_create(FACTION.count, 0);
for (var f = 0; f < FACTION.count; f++) reserva[f] = 5;
deck_global = criar_deck_jogo();
upgrades = criar_upgrades();
upgrades_comprados = [];
for (var f = 0; f < FACTION.count; f++) {
    array_push(upgrades_comprados, array_create(array_length(upgrades), false));
}
alt_recurso = false;   // final da F1 (efeito a definir)

// relação de cada facção jogável com cada origem
relacao = [];
for (var g = 0; g < FACTION.count; g++) {
    array_push(relacao, array_create(CARD_ORIGIN.count, 0));
}

// missões
missoes = criar_missoes();
missao_sel = undefined;
run_missao = undefined;
escoltado = undefined;
carga_ativa = false;
skill_deslocada = undefined;
aliados = [];
prep_tela = PREP_TELA.menu;

// NOVO: mapa
areas = criar_areas();
area_atual = 0;
area_anterior = -1;
nivel_total = 0;

// NOVO: finais
final_pendente = -1;   // facção cujo final deve tocar (-1 = nenhum)
fim_jogo = false;
fim_tipo = 0;

// NOVO: cutscenes / tutoriais
cs_ativa = false;
cs_id = 0;
cs_slides = [];
cs_idx = 0;
cs_texto = "";
cs_chars = 0;
cs_anim = 0;
cs_fechando = false;
cs_fila = [];
tut_visto = array_create(CUT.count, false);

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
particulas = [];

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
origem_cores = [c_white, make_color_rgb(70, 120, 255), c_red, c_lime, c_fuchsia];

ultima_carta = undefined;
figura_evento = undefined;
msg_fim = "";

criar_biblioteca_sprites();
lideres = criar_lideres();

acao_iniciar_run(FACTION.faction_1);
estado = GAME_STATE.preparacao;   // começa no hub


// menu inicial
menu_ativo = true;
menu_tela = 0;   // 0 = principal, 1 = créditos
menu_anim = array_create(MENU_BTNS + 1, 0);

global.musica_atual = -1;
global.musica_inst  = -1;
musica_tocar(mus_main);

window_set_fullscreen(true);

// Inicialize UMA vez (Create do objeto de controle, antes de qualquer chamada)
