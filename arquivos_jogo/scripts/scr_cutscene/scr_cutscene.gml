// ================= MOTOR DE CUTSCENES / TUTORIAIS =================
#macro CS_FAIXA 200          // altura da faixa preta inferior
#macro CS_VELOCIDADE 0.7     // letras por frame no efeito de digitação

// ---- destaques de HUD (usados só nos tutoriais) ----
enum DEST {
    nenhum, hub_menu, hub_iniciar, reserva, missoes_quadro,
    trilha, avancar, retorno, hud_relogio, hud_skills, hud_aliados,
    opcoes_evento, opcao_contornar, card, slots_grupo, fila_combate
}

function box_uniao(_a, _b) {
    return [min(_a[0], _b[0]), min(_a[1], _b[1]), max(_a[2], _b[2]), max(_a[3], _b[3])];
}

// resolve o retângulo na hora de desenhar (as posições dependem do estado do jogo)
function cs_dest_rect(_d) {
    switch (_d) {
        case DEST.hub_menu:        return box_uniao(box_hub(0), box_hub(3));
        case DEST.hub_iniciar:     return box_hub(4);
        case DEST.reserva:         return [480, 52, 800, 88];
        case DEST.missoes_quadro:  return [24, 75, 1256, 535];
        case DEST.trilha:          return [380, 440, 900, 495];
        case DEST.avancar:         return box_avancar();
        case DEST.retorno:         return box_retorno();
        case DEST.hud_relogio:     return [940, 580, 1260, 680];
        case DEST.hud_skills:      return box_uniao(box_skill(0), box_skill(player.max_skills - 1));
        case DEST.hud_aliados:     return [20, 590, 300, 715];
        case DEST.opcoes_evento:   return box_uniao(box_opcao(0), box_opcao(2));
        case DEST.opcao_contornar: return box_opcao(3);
        case DEST.card:            return box_card();
        case DEST.slots_grupo:     return box_uniao(box_slot_party(0), box_slot_party(array_length(get_grupo()) - 1));
        case DEST.fila_combate:    return [24, 255, 660, 515];
    }
    return undefined;
}

// 5º parâmetro (destaque) é opcional: sem ele, o slide não destaca nada
function cs_slide(_txt, _legenda, _cor, _spr) {
    return {
        txt: _txt, legenda: _legenda, cor: _cor, spr: _spr,
        dest: (argument_count > 4) ? argument[4] : DEST.nenhum
    };
}

function cutscene_eh_tutorial(_id) {
    return (_id >= CUT.tut_preparacao);
}

function cutscene_eh_final(_id) {
    return (_id >= CUT.final_1 && _id <= CUT.final_4);
}

// quebra o texto em linhas ANTES de digitar (senão as palavras pulam de linha enquanto aparecem)
function texto_quebrar(_txt, _larg) {
    draw_set_font(fnt_main);
    var res = "";
    var linha = "";
    var palavra = "";
    var n = string_length(_txt);

    for (var i = 1; i <= n + 1; i++) {
        var ch = (i <= n) ? string_char_at(_txt, i) : " ";

        if (ch != " " && ch != "\n") {
            palavra += ch;
            continue;
        }

        var cand = (linha == "") ? palavra : (linha + " " + palavra);
        if (linha != "" && string_width(cand) > _larg) {
            res += linha + "\n";
            linha = palavra;
        } else {
            linha = cand;
        }
        palavra = "";

        if (ch == "\n") {
            res += linha + "\n";
            linha = "";
        }
    }
    return res + linha;
}

// ---- controle ----
// tutoriais só tocam na primeira vez; tudo entra numa fila
function cutscene_tocar(_id) {
    if (cutscene_eh_tutorial(_id)) {
        if (tut_visto[_id]) return;
        tut_visto[_id] = true;
    }
    array_push(cs_fila, _id);
    if (!cs_ativa) cutscene_proxima();
}

function cutscene_proxima() {
    if (array_length(cs_fila) == 0) return;
    cs_id = cs_fila[0];
    array_delete(cs_fila, 0, 1);
    cs_slides = cutscene_slides(cs_id);
    cs_idx = 0;
    cs_ativa = true;
    cs_fechando = false;
    cs_anim = (cs_id == CUT.intro) ? 1 : 0;   // a intro já começa sem transição
    cutscene_carregar_slide();
}

function cutscene_carregar_slide() {
    var s = cs_slides[cs_idx];
    cs_texto = texto_quebrar(s.txt, 1180);
    cs_chars = 0;
}

function cutscene_concluir() {
    cs_ativa = false;
    if (cs_id == CUT.morte) acao_reencarnar();
    cutscene_proxima();
}

function step_cutscene(_clicou) {
    if (cs_fechando) {
        cs_anim = lerp(cs_anim, 0, 0.15);
        if (cs_anim < 0.02) {
            cs_anim = 0;
            cutscene_concluir();
        }
        return;
    }

    cs_anim = lerp(cs_anim, 1, 0.12);
    if (cs_anim < 0.9) return;   // espera a transição de entrada

    var total = string_length(cs_texto);
    if (cs_chars < total) cs_chars += CS_VELOCIDADE;
    if (!_clicou) return;

    // clique 1: completa o texto; clique 2: próximo slide
    if (cs_chars < total) {
        cs_chars = total;
        return;
    }

    cs_idx++;
    if (cs_idx < array_length(cs_slides)) {
        cutscene_carregar_slide();
        return;
    }

    // acabou a cutscene
    if (cutscene_eh_final(cs_id)) {
        fim_tipo = cs_id - CUT.final_1;
        fim_jogo = true;
        cs_ativa = false;
        cs_fila = [];
    } else {
        cs_fechando = true;
    }
}

// ---- desenho ----
function draw_cutscene() {
    if (cs_idx >= array_length(cs_slides)) return;
    if (cutscene_eh_tutorial(cs_id)) {
        draw_cutscene_tutorial();
        return;
    }

    var a = cs_anim;
    var s = cs_slides[cs_idx];
    var h_vis = 720 - CS_FAIXA;
    var y_vis = -(1 - a) * h_vis;                 // área visual desce do topo
    var y_faixa = h_vis + (1 - a) * CS_FAIXA;     // faixa preta sobe de baixo

    // área visual (sprite do slide, ou placeholder com a legenda)
    draw_set_color(s.cor);
    draw_rectangle(0, y_vis, 1280, y_vis + h_vis, false);
    if (s.spr != noone) {
        draw_sprite(s.spr, 0, 640, y_vis + h_vis / 2);
    } else {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_gray);
        draw_text_ext(640, y_vis + h_vis / 2, "[ ARTE: " + s.legenda + " ]", 24, 900);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }

    // faixa preta com o texto digitando
    draw_set_color(c_black);
    draw_rectangle(0, y_faixa, 1280, y_faixa + CS_FAIXA, false);
    draw_set_color(c_white);
    draw_line(0, y_faixa, 1280, y_faixa);
    draw_text(50, y_faixa + 22, string_copy(cs_texto, 1, floor(cs_chars)));

    draw_set_color(c_gray);
    draw_text(50, y_faixa + CS_FAIXA - 30, string(cs_idx + 1) + " / " + string(array_length(cs_slides)));
    if (cs_chars >= string_length(cs_texto) && ((current_time div 400) mod 2 == 0)) {
        draw_set_halign(fa_right);
        draw_text(1230, y_faixa + CS_FAIXA - 30, "[ clique ]");
        draw_set_halign(fa_left);
    }
    draw_set_color(c_white);
}

// tutorial: a HUD continua visível, escurecida, com um "buraco" no elemento destacado
function draw_cutscene_tutorial() {
    var a = cs_anim;
    var s = cs_slides[cs_idx];
    var r = cs_dest_rect(s.dest);
    if (r != undefined) {
        var pad = 6;
        r = [r[0] - pad, r[1] - pad, r[2] + pad, r[3] + pad];
    }

    // o painel de texto vai para o lado com menos sobreposição com o destaque
    var topo = false;
    if (r != undefined) {
        var ov_baixo = max(0, r[3] - (720 - CS_FAIXA));
        var ov_topo  = max(0, CS_FAIXA - r[1]);
        topo = (ov_baixo > ov_topo);
    }
    var y_faixa = topo ? -(1 - a) * CS_FAIXA : (720 - CS_FAIXA) + (1 - a) * CS_FAIXA;

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // escurece tudo, deixando um buraco no destaque
    draw_set_color(c_black);
    draw_set_alpha(0.7 * a);
    if (r == undefined) {
        draw_rectangle(0, 0, 1280, 720, false);
    } else {
        draw_rectangle(0, 0, 1280, r[1], false);
        draw_rectangle(0, r[3], 1280, 720, false);
        draw_rectangle(0, r[1], r[0], r[3], false);
        draw_rectangle(r[2], r[1], 1280, r[3], false);
    }

    // borda pulsando
    if (r != undefined) {
        draw_set_alpha(a * (0.65 + 0.35 * sin(current_time / 150)));
        draw_set_color(c_yellow);
        draw_rectangle(r[0], r[1], r[2], r[3], true);
        draw_rectangle(r[0] - 1, r[1] - 1, r[2] + 1, r[3] + 1, true);
    }
    draw_set_alpha(1);

    // painel de texto
    draw_set_color(c_black);
    draw_rectangle(0, y_faixa, 1280, y_faixa + CS_FAIXA, false);
    draw_set_color(c_white);
    draw_rectangle(0, y_faixa, 1280, y_faixa + CS_FAIXA, true);
    draw_text(50, y_faixa + 22, string_copy(cs_texto, 1, floor(cs_chars)));

    draw_set_color(c_gray);
    draw_text(50, y_faixa + CS_FAIXA - 30, string(cs_idx + 1) + " / " + string(array_length(cs_slides)) + "   TUTORIAL");
    if (cs_chars >= string_length(cs_texto) && ((current_time div 400) mod 2 == 0)) {
        draw_set_halign(fa_right);
        draw_text(1230, y_faixa + CS_FAIXA - 30, "[ clique ]");
        draw_set_halign(fa_left);
    }
    draw_set_color(c_white);
}

function draw_fim_jogo() {
    draw_set_color(c_black);
    draw_rectangle(0, 0, 1280, 720, false);
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(640, 280, "--- FIM ---");
    draw_text(640, 320, "Final da Facção " + string(fim_tipo + 1));
    draw_set_color(c_yellow);
    draw_text(640, 420, "[ Clique para recomeçar ]");
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}

// ---- CONTEÚDO (textos são rascunho: reescreva à vontade) ----
// para ligar a arte, troque o 4º parâmetro (noone) pelo sprite
// nos tutoriais, o 5º parâmetro é o destaque de HUD (DEST.*)
function cutscene_slides(_id) {
    var azul = make_color_rgb(18, 26, 44);
    var terra = make_color_rgb(44, 32, 24);
    var verde = make_color_rgb(20, 40, 32);
    var roxo = make_color_rgb(36, 24, 44);
    var tut = make_color_rgb(24, 24, 24);
    var s = [];

    switch (_id) {
        case CUT.intro:
            s = [
                cs_slide("O mundo acabou há gerações. Tudo o que o sustentou veio de um único recurso natural, arrancado da terra sem medida até o ambiente não aguentar mais. O que sobrou é uma terra ferida e um recurso que ainda se renova. Devagar demais.", "ruínas e terra devastada", terra, spr_cut),
                cs_slide("Em torno dele nasceram três facções. Cada uma acredita saber o que fazer com o que restou: transformá-lo, tomá-lo ou dividi-lo.", "as três bandeiras", azul, spr_cut_1),
                cs_slide("O estrago tem hora marcada. Quando o sol nasce, uma onda de radiação mata tudo o que estiver do lado de fora. Quem sai para explorar corre contra o relógio, e o tempo vale mais do que qualquer coisa que se possa carregar.", "o sol nascendo sobre as ruínas", terra, spr_cut_2),
                cs_slide("Ninguém volta duas vezes. Cada explorador cumpre sua jornada, entrega o que conseguiu e passa o cargo ao próximo, da facção seguinte.", "exploradores em fila", azul, spr_cut_3),
                cs_slide("Mas o que um deixa para trás o próximo herda: postos, melhorias, alianças, cicatrizes. Tudo está conectado, e pequenas ações, somadas, transformam o mundo.", "fios ligando as três facções", verde, spr_cut_4)
            ];
            break;

        case CUT.morte:
            s = [
                cs_slide(msg_fim, "o explorador deixado para trás", terra, spr_cut_5),
                cs_slide("Outro explorador assume o posto: Facção " + string(((faccao_atual + 1) mod FACTION.count) + 1) + ". O que foi feito aqui continua no mundo.", "passagem de cargo", azul, spr_cut_6)
            ];
            break;

        case CUT.final_1:
            s = [
                cs_slide("A Facção 1 conseguiu o que prometia: o recurso agora trabalha por ela, e não mais o contrário.", "máquinas em funcionamento", azul, spr_cut_7),
                cs_slide("Nos laboratórios, tudo gira sozinho. Pela primeira vez em gerações, ninguém precisa descer às ruínas.", "laboratório silencioso", verde, spr_cut_7),
                cs_slide("Mas lá fora o sol continua o mesmo. Resta saber o que acontece com uma sociedade que aprendeu a viver do recurso, e esqueceu do mundo que o produziu.", "cidade acesa à noite, sol ao fundo", azul, spr_cut_7)
            ];
            break;

        case CUT.final_2:
            s = [
                cs_slide("Cada posto tomado era um aviso. Agora o aviso virou lei.", "bandeira sobre um posto", terra, spr_cut_8),
                cs_slide("A Facção 2 domina as rotas, o recurso e quem passa por elas. Ninguém discute. Ninguém arrisca.", "rotas controladas", terra, spr_cut_8),
                cs_slide("A ordem chegou, e o recurso continua sendo arrancado, agora por quem manda. Só ainda não se sabe até quando a terra aguenta.", "sentinelas na fronteira", azul, spr_cut_8)
            ];
            break;

        case CUT.final_3:
            s = [
                cs_slide("Uma mesa, três facções e uma quarta cadeira vazia. Pela primeira vez, todas sentaram juntas.", "mesa de negociação nas ruínas", verde, spr_cut_9),
                cs_slide("O recurso será dividido. Não de forma justa, mas de forma possível. E isso, aqui, já é quase um milagre.", "mãos se apertando", verde, spr_cut_9),
                cs_slide("A guerra gastava mais do que qualquer expedição. A paz também vai custar, mas de outro jeito: pela primeira vez, alguém vai medir quanto a terra ainda pode dar.", "amanhecer sobre o acordo", azul, spr_cut_9)
            ];
            break;

        case CUT.final_4:
            s = [
                cs_slide("O Colosso cai. Do que restou dele brota algo que ninguém esperava: o recurso, em abundância.", "o Colosso desabando", roxo, spr_cut_10),
                cs_slide("Nenhuma facção pode reivindicá-lo sozinha. Todas veem a mesma coisa e, pela primeira vez, olham umas para as outras.", "as facções observando de longe", roxo, spr_cut_10),
                cs_slide("Do centro do setor, algo novo começa a crescer. Talvez, desta vez, ninguém precise tomar mais do que a terra pode dar.", "broto no meio das ruínas", verde, spr_cut_10)
            ];
            break;

        // ---------- tutoriais ----------
        case CUT.tut_preparacao:
            s = [
                cs_slide("Esta é a Preparação. Entre uma expedição e outra, você gasta a reserva da facção atual em melhorias e habilidades, escolhe uma missão e conversa com o líder.", "o hub da facção", tut, noone, DEST.hub_menu),
                cs_slide("Cada facção tem sua própria reserva e suas próprias melhorias. O que uma compra não passa para as outras, mas o mundo lembra de tudo.", "reservas separadas por facção", tut, noone, DEST.reserva),
                cs_slide("Quando estiver pronto, clique em Iniciar Expedição.", "botão de iniciar", tut, noone, DEST.hub_iniciar)
            ];
            break;

        case CUT.tut_upgrades:
            s = [
                cs_slide("Melhorias custam recursos da reserva e valem para toda expedição desta facção: mais tempo, atributos, aliados iniciais e retornos mais baratos.", "tela de melhorias", tut, noone, DEST.reserva),
                cs_slide("Atenção: todos os personagens da facção aproveitam essas melhorias, inclusive os inimigos que você vai encontrar, hoje e nas próximas vidas. O poder que você constrói também volta para você.", "melhorias passando de mão em mão", tut, noone, DEST.nenhum),
                cs_slide("Cada melhoria libera a próxima da mesma linha. As linhas amarelas mostram o que você já comprou.", "árvore de melhorias", tut, noone, DEST.nenhum)
            ];
            break;

        case CUT.tut_missoes:
            s = [
                cs_slide("Missões de Escolta e Entrega precisam ser selecionadas antes da expedição. As outras acontecem sozinhas quando você passa pelo local.", "quadro de missões", tut, noone, DEST.missoes_quadro),
                cs_slide("Só aparecem as missões que você já pode fazer. As de outras facções se revelam com aliança, e a missão final, depois de cumprir as quatro primeiras.", "missões reveladas aos poucos", tut, noone, DEST.missoes_quadro)
            ];
            break;

        case CUT.tut_expedicao:
            s = [
                cs_slide("A expedição é uma trilha de níveis. Avançar revela um novo evento, e quase tudo nela custa tempo.", "a trilha", tut, noone, DEST.trilha),
                cs_slide("O relógio é tudo. Quando ele zera, o sol nasce e a radiação mata tudo lá fora: o personagem sucumbe e a equipe de resgate recupera só metade dos recursos.", "o relógio", tut, noone, DEST.hud_relogio),
                cs_slide("Retornar à Base entrega tudo o que você juntou, mas o custo em tempo cresce quanto mais longe você vai. Pense antes de se aprofundar.", "o caminho de volta", tut, noone, DEST.retorno)
            ];
            break;

        case CUT.tut_evento:
            s = [
                cs_slide("Eventos oferecem três opções que testam um atributo. Aliados ajudam com metade do atributo deles. Se você atinge o valor pedido, tem sucesso garantido.", "um evento", tut, noone, DEST.opcoes_evento),
                cs_slide("Se não atinge, ainda existe uma chance baseada em SORTE. A quarta opção contorna o problema, mas custa tempo.", "opções do evento", tut, noone, DEST.opcao_contornar)
            ];
            break;

        case CUT.tut_diplomacia:
            s = [
                cs_slide("Emissários oferecem acordos entre facções. Com relação alta, a facção vira aliada e você pode cumprir as missões dela.", "um emissário", tut, noone, DEST.card),
                cs_slide("Cuidado: derrotar inimigos de uma facção piora a relação com ela.", "relações entre facções", tut, noone, DEST.card)
            ];
            break;

        case CUT.tut_combate:
            s = [
                cs_slide("No combate, cada personagem escolhe uma habilidade e um alvo. Depois todas são executadas da menor para a maior custo de tempo. Botão direito cancela a seleção.", "o campo de batalha", tut, noone, DEST.fila_combate),
                cs_slide("Ataques básicos não têm recarga. Skills têm recarga em turnos. A skill de missão não faz nada em combate. O tempo gasto na rodada é o maior custo entre as ações.", "slots de habilidade", tut, noone, DEST.hud_skills),
                cs_slide("Status: queimadura e corrosão ferem a cada rodada, atordoamento faz perder uma ação, lentidão e celeridade mudam o custo de tempo das skills.", "ícones de status", tut, noone, DEST.slots_grupo)
            ];
            break;

        case CUT.tut_escolta:
            s = [
                cs_slide("Um aliado de escolta se juntou a você. Leve-o vivo até o ponto da missão, no nível indicado, para concluí-la.", "o escoltado", tut, noone, DEST.hud_aliados)
            ];
            break;

        case CUT.tut_entrega:
            s = [
                cs_slide("A carga ocupa um slot de habilidade, deslocando a última. Ela não faz nada em combate. Entregue no ponto da missão para recuperar a skill.", "a carga", tut, noone, DEST.hud_skills)
            ];
            break;

        case CUT.tut_passagem:
            s = [
                cs_slide("Você chegou ao fim desta área. Resolva o que houver aqui e escolha para onde seguir. Cada área nova zera o contador de níveis, mas o custo de retorno continua acumulando.", "bifurcação no caminho", tut, noone, DEST.card),
                cs_slide("Mais adiante, as áreas avançadas levam ao Coração do Setor. É lá que o caminho termina.", "o centro do mapa", tut, noone, DEST.nenhum)
            ];
            break;
    }
    return s;
}