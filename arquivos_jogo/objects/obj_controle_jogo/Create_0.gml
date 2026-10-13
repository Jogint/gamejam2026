// ==============================
// GLOBAIS
// ==============================

scr_reset_draw();

enum TIPOS_BOTOES {
    NONE,
    PLAY,
    CONFIGS,
}

enum EQUIPES_PLAYER { // deve seguir a ordem dos keyframes de spr_player
    VERDE,
    VERMELHO,
    AZUL,
    AMARELO,
}

global.max_status_selecionado = 5;

// ==============================
// ROOM SET STATUS
// ==============================

qtd_status_selecionado = 0;

function set_qtd_status(valor_a_somar) {
    var _valor_final = valor_a_somar
    
    if (qtd_status_selecionado + valor_a_somar > global.max_status_selecionado) {
        _valor_final = (global.max_status_selecionado - qtd_status_selecionado);
    }
    
    qtd_status_selecionado += _valor_final;
    
    return _valor_final;
}

function reduz_qtd_status(valor_a_remover) {
    qtd_status_selecionado -= valor_a_remover;
}