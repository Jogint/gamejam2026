// ================= MOTOR DE CUTSCENES / TUTORIAIS =================
#macro CS_FAIXA 200          // altura da faixa preta inferior
#macro CS_VELOCIDADE 0.7     // letras por frame no efeito de digitação

function cs_slide(_txt, _legenda, _cor, _spr) {
    return { txt: _txt, legenda: _legenda, cor: _cor, spr: _spr };
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
    draw_text(50, y_faixa + CS_FAIXA - 30, string(cs_idx + 1) + " / " + string(array_length(cs_slides)) + (cutscene_eh_tutorial(cs_id) ? "   TUTORIAL" : ""));
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
// para ligar a arte, troque o último parâmetro (noone) pelo sprite
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
                cs_slide("O mundo acabou há gerações. O que sobrou é uma terra ferida e, debaixo dela, um único recurso natural que ainda se renova. Devagar demais.", "ruínas ao amanhecer", terra, noone),
                cs_slide("Em torno dele nasceram três facções. Cada uma acredita saber o que fazer com o recurso: transformá-lo, tomá-lo ou dividi-lo.", "as três bandeiras", azul, noone),
                cs_slide("O setor só é habitável por algumas horas. Depois disso, o ar vira veneno. Quem sai para explorar corre contra o relógio, e o tempo vale mais do que qualquer coisa que se possa carregar.", "um relógio sobre as ruínas", terra, noone),
                cs_slide("Ninguém volta duas vezes. Cada explorador cumpre sua jornada, entrega o que conseguiu e passa o cargo ao próximo, da facção seguinte.", "exploradores em fila", azul, noone),
                cs_slide("Mas o que um deixa para trás o próximo herda: postos, alianças, cicatrizes. Tudo está conectado, e pequenas ações, somadas, transformam o mundo.", "fios ligando as três facções", verde, noone)
            ];
            break;

        case CUT.morte:
            s = [
                cs_slide(msg_fim, "o explorador deixado para trás", terra, noone),
                cs_slide("Outro explorador assume o posto: Facção " + string(((faccao_atual + 1) mod FACTION.count) + 1) + ". O que foi feito aqui continua no mundo.", "passagem de cargo", azul, noone)
            ];
            break;

        case CUT.final_1:
            s = [
                cs_slide("A Facção 1 conseguiu o que prometia: o recurso agora trabalha por ela, e não mais o contrário.", "máquinas em funcionamento", azul, noone),
                cs_slide("Nos laboratórios, tudo gira sozinho. Pela primeira vez em gerações, ninguém precisa descer às ruínas.", "laboratório silencioso", verde, noone),
                cs_slide("Resta saber o que acontece com um mundo que deixou de precisar uns dos outros.", "cidade acesa à noite", azul, noone)
            ];
            break;

        case CUT.final_2:
            s = [
                cs_slide("Cada posto tomado era um aviso. Agora o aviso virou lei.", "bandeira sobre um posto", terra, noone),
                cs_slide("A Facção 2 domina as rotas, o recurso e quem passa por elas. Ninguém discute. Ninguém arrisca.", "rotas controladas", terra, noone),
                cs_slide("A ordem chegou. Só ainda não se sabe a que preço.", "sentinelas na fronteira", azul, noone)
            ];
            break;

        case CUT.final_3:
            s = [
                cs_slide("Uma mesa, três facções e uma quarta cadeira vazia. Pela primeira vez, todas sentaram juntas.", "mesa de negociação nas ruínas", verde, noone),
                cs_slide("O recurso será dividido. Não de forma justa, mas de forma possível. E isso, aqui, já é quase um milagre.", "mãos se apertando", verde, noone),
                cs_slide("A guerra gastava mais do que qualquer expedição. A paz também vai custar, mas custa de outro jeito.", "amanhecer sobre o acordo", azul, noone)
            ];
            break;

        case CUT.final_4:
            s = [
                cs_slide("O Colosso cai. Do que restou dele brota algo que ninguém esperava: o recurso, em abundância.", "o Colosso desabando", roxo, noone),
                cs_slide("Nenhuma facção pode reivindicá-lo sozinha. Todas veem a mesma coisa e, pela primeira vez, olham umas para as outras.", "as facções observando de longe", roxo, noone),
                cs_slide("Do centro do setor, algo novo começa a crescer.", "broto no meio das ruínas", verde, noone)
            ];
            break;

        // ---------- tutoriais ----------
        case CUT.tut_preparacao:
            s = [
                cs_slide("Esta é a Preparação. Entre uma expedição e outra, você gasta a reserva da facção atual em upgrades, escolhe uma missão e conversa com o líder.", "o hub da facção", tut, noone),
                cs_slide("Cada facção tem sua própria reserva e seus próprios upgrades. O que uma compra não passa para as outras, mas o mundo lembra de tudo.", "reservas separadas por facção", tut, noone),
                cs_slide("Quando estiver pronto, clique em Iniciar Expedição.", "botão de iniciar", tut, noone)
            ];
            break;

        case CUT.tut_upgrades:
            s = [
                cs_slide("Upgrades custam recursos da reserva e valem para toda expedição desta facção: mais tempo, atributos, retorno mais barato e novas habilidades.", "tela de upgrades", tut, noone),
                cs_slide("Só dá para levar uma skill extra por vez. Já os ataques básicos apenas trocam o ataque do primeiro slot, sem recarga.", "slots de habilidade", tut, noone)
            ];
            break;

        case CUT.tut_missoes:
            s = [
                cs_slide("Missões de Escolta e Entrega precisam ser selecionadas antes da expedição. As outras acontecem sozinhas quando você passa pelo local.", "quadro de missões", tut, noone),
                cs_slide("Só aparecem as missões que você já pode fazer. As de outras facções se revelam com aliança, e a missão final, depois de cumprir as quatro primeiras.", "missões reveladas aos poucos", tut, noone)
            ];
            break;

        case CUT.tut_expedicao:
            s = [
                cs_slide("A expedição é uma trilha de níveis. Avançar revela um novo evento, e quase tudo nela custa tempo.", "a trilha", tut, noone),
                cs_slide("O relógio é tudo. Se ele zerar, o personagem sucumbe e a equipe de resgate recupera só metade dos recursos.", "o relógio", tut, noone),
                cs_slide("Retornar à Base entrega tudo o que você juntou, mas o custo em tempo cresce quanto mais longe você vai. Pense antes de se aprofundar.", "o caminho de volta", tut, noone)
            ];
            break;

        case CUT.tut_evento:
            s = [
                cs_slide("Eventos oferecem três opções que testam um atributo. Aliados ajudam com metade do atributo deles. Se você atinge o valor pedido, tem sucesso garantido.", "um evento", tut, noone),
                cs_slide("Se não atinge, ainda existe uma chance baseada em SORTE. A quarta opção contorna o problema, mas custa tempo.", "opções do evento", tut, noone)
            ];
            break;

        case CUT.tut_diplomacia:
            s = [
                cs_slide("Emissários oferecem acordos entre facções. Com relação alta, a facção vira aliada e você pode cumprir as missões dela.", "um emissário", tut, noone),
                cs_slide("Cuidado: derrotar inimigos de uma facção piora a relação com ela.", "relações entre facções", tut, noone)
            ];
            break;

        case CUT.tut_combate:
            s = [
                cs_slide("No combate, cada personagem escolhe uma habilidade e um alvo. Depois todas são executadas da menor para a maior custo de tempo. Botão direito cancela a seleção.", "o campo de batalha", tut, noone),
                cs_slide("Ataques básicos não têm recarga. Skills têm recarga em turnos. A skill de missão não faz nada em combate. O tempo gasto na rodada é o maior custo entre as ações.", "slots de habilidade", tut, noone),
                cs_slide("Status: queimadura e corrosão ferem a cada rodada, atordoamento faz perder uma ação, lentidão e celeridade mudam o custo de tempo das skills.", "ícones de status", tut, noone)
            ];
            break;

        case CUT.tut_escolta:
            s = [
                cs_slide("Um aliado de escolta se juntou a você. Leve-o vivo até o ponto da missão, no nível indicado, para concluí-la.", "o escoltado", tut, noone)
            ];
            break;

        case CUT.tut_entrega:
            s = [
                cs_slide("A carga ocupa um slot de habilidade, deslocando a última. Ela não faz nada em combate. Entregue no ponto da missão para recuperar a skill.", "a carga", tut, noone)
            ];
            break;

        case CUT.tut_passagem:
            s = [
                cs_slide("Você chegou ao fim desta área. Resolva o que houver aqui e escolha para onde seguir. Cada área nova zera o contador de níveis, mas o custo de retorno continua acumulando.", "bifurcação no caminho", tut, noone),
                cs_slide("Mais adiante, as áreas avançadas levam ao Coração do Setor. É lá que o caminho termina.", "o centro do mapa", tut, noone)
            ];
            break;
    }
    return s;
}