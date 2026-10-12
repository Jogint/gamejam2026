function Card() constructor {
    name = "SEM NOME";
    description = "SEM DESCRICAO";
    type = CARD_TYPE.event;
    origin = CARD_ORIGIN.neutral;

    time = 0; 
    action = []; 
    artwork = noone; 

    options = []; 
    reward = 0; 
    fail_time = 2; 
}

function create_option(stat, required) {
    return { stat: stat, required: required };
}

function create_event_card(name, description, origin, options, reward, time, action) {
    var c = new Card();
    c.type = CARD_TYPE.event;
    c.name = name;
    c.description = description;
    c.origin = origin;
    c.options = options;
    c.reward = reward;
    c.time = time;
    c.action = action;
    return c;
}

function create_event_deck() {
    var deck = [];

    array_push(deck, create_event_card(
        "Porta enferrujada",
        "Uma porta de ferro bloqueia a entrada de um deposito...",
        CARD_ORIGIN.neutral,
        [create_option(STAT.strength, 5), create_option(STAT.technique, 3), create_option(STAT.perception, 4)],
        2, 3, []
    ));

    array_push(deck, create_event_card(
        "Fonte contaminada",
        "Uma fonte de agua suja. Beber?",
        CARD_ORIGIN.faction_1,
        [create_option(STAT.technique, 4), create_option(STAT.perception, 2), create_option(STAT.strength, 6)],
        1, 2,
        [function(game) { game.stat_mods[STAT.perception] += 1; }]
    ));

    array_push(deck, create_event_card(
        "Viajante ferido",
        "Um viajante caido pede ajuda.",
        CARD_ORIGIN.faction_2,
        [create_option(STAT.perception, 3), create_option(STAT.technique, 2), create_option(STAT.strength, 3)],
        3, 2,
        [function(game) { game.stat_mods[STAT.strength] += 1; }]
    ));

    return deck;
}