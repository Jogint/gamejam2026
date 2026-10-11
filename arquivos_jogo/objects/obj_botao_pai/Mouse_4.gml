switch (tipo) { // variável de objeto
	case TIPOS_BOTOES.NONE:
        show_message("obj_botao_pai: Este botão não foi configurado. Altere a variável de objeto do botao filho.");
    break;

    case TIPOS_BOTOES.PLAY:
        show_message("obj_botao_pai: Configurar o  room_go_to para a room principal no botao filho.");
    break;

    case TIPOS_BOTOES.CONFIGS:
        show_message("obj_botao_pai: Configurar o  room_go_to para a room de informações no botao filho.");
    break;

    default:
        show_message("obj_botao_pai: não existe um objeto deste tipo. Crie-o primeiro em obj_controle_jogo, no ENUM TIPOS_BOTOES. Recebeu: " + string(tipo));
    break;  
}