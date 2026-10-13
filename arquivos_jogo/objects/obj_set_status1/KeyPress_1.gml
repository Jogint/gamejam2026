if (selecionada) {
    selecionada = false;
    
    if (is_real(valor_interno)) obj_controle_jogo.reduz_qtd_status(valor_interno);
    
    for (var i = 0; i <= 5; i++) {
        if (keyboard_check_pressed(ord(string(i)))) {
            valor_interno = obj_controle_jogo.set_qtd_status(i);
            
            break; // Para o loop assim que encontrar a tecla válida 
        } else {
            valor_interno = 0;
        }
    }
    
    valor_a_exibir = valor_interno;
}
