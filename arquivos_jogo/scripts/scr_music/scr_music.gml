
// Script/função
function musica_tocar(_snd) {
    // Mesma música e ainda tocando: não faz nada, o loop continua
    if (_snd == global.musica_atual && audio_is_playing(global.musica_inst)) return;

    // Música diferente: para a anterior
    if (global.musica_inst != -1) audio_stop_sound(global.musica_inst);

    global.musica_atual = _snd;
    global.musica_inst  = (_snd == -1) ? -1 : audio_play_sound(_snd, 1, true);
}