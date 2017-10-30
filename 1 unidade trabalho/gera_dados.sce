// Gera dados de simulacao de sistemas ARX/ARMAX:

// SISTEMA A SER SIMULADO:
// Ordem = 2
// y(k) = 1.5y(k-1) - 0.7y(k-2)
//        +u(k-1-tempo_atraso) + 0.5u(k-2-tempo_atraso)
//        +e(k)
//        +0.8e(k-1) + 0.0e(k-2) -> Esta linha apenas se for ARMAX
th_ARX = [1.5; -0.7; 1.0; 0.5];
th_ARMAX = [th_ARX; 0.8; 0.0];

// Numero de passos de simulacao
npassos = 1500;

// Sinal de entrada: PRBS +1 ou -1
u = 2.0*grand(npassos,1,"uin",0,1)-ones(npassos,1);

// Ruido dinâmico (desvio padrao)
desvio_ruido_dinamico = 0.1;
// Ruido de saida (desvio padrao): apenas para alguns casos
desvio_ruido_saida = 0.01;

// Armazena a pasta atual
OLDDIR=pwd();
// Pasta de salvamento dos arquivos
SAVEDIR='C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\Trabalho_final';
if (~chdir(SAVEDIR)) then
    error('Folder does not exist');
end

// CASO 1:
// Sistema ARX
// Tempo de atraso: 0
// Ruído de saída: não

delay = 0;
y = simulARX(u,th_ARX,delay,desvio_ruido_dinamico);
FILE='EX1_ARX_delay0_noOutNoise.txt';
unix('del '+FILE);
write(FILE,[u y]);

// CASO 2:
// Sistema ARMAX
// Tempo de atraso: 0
// Ruído de saída: não

delay = 0;
y = simulARMAX(u,th_ARMAX,delay,desvio_ruido_dinamico);
FILE='EX2_ARMAX_delay0_noOutNoise.txt';
unix('del '+FILE);
write(FILE,[u y]);

// CASO 3:
// Sistema ARX
// Tempo de atraso: 3
// Ruído de saída: não

delay = 3;
y = simulARX(u,th_ARX,delay,desvio_ruido_dinamico);
FILE='EX3_ARX_delay3_noOutNoise.txt';
unix('del '+FILE);
write(FILE,[u y]);

// CASO 4:
// Sistema ARMAX
// Tempo de atraso: 3
// Ruído de saída: não

delay = 3;
y = simulARMAX(u,th_ARMAX,delay,desvio_ruido_dinamico);
FILE='EX4_ARMAX_delay3_noOutNoise.txt';
unix('del '+FILE);
write(FILE,[u y]);

// CASO 5:
// Sistema ARX
// Tempo de atraso: 0
// Ruído de saída: sim

delay = 0;
y = simulARX(u,th_ARX,delay,desvio_ruido_dinamico);
y = add_noise(y,desvio_ruido_saida);
FILE='EX5_ARX_delay0_yesOutNoise.txt';
unix('del '+FILE);
write(FILE,[u y]);

// CASO 6:
// Sistema ARMAX
// Tempo de atraso: 0
// Ruído de saída: sim

delay = 0;
y = simulARMAX(u,th_ARMAX,delay,desvio_ruido_dinamico);
y = add_noise(y,desvio_ruido_saida);
FILE='EX6_ARMAX_delay0_yesOutNoise.txt';
unix('del '+FILE);
write(FILE,[u y]);

// CASO 7:
// Sistema ARX
// Tempo de atraso: 3
// Ruído de saída: sim

delay = 3;
y = simulARX(u,th_ARX,delay,desvio_ruido_dinamico);
y = add_noise(y,desvio_ruido_saida);
FILE='EX7_ARX_delay3_yesOutNoise.txt';
unix('del '+FILE);
write(FILE,[u y]);

// CASO 8:
// Sistema ARMAX
// Tempo de atraso: 3
// Ruído de saída: sim

delay = 3;
y = simulARMAX(u,th_ARMAX,delay,desvio_ruido_dinamico);
y = add_noise(y,desvio_ruido_saida);
FILE='EX8_ARMAX_delay3_yesOutNoise.txt';
unix('del '+FILE);
write(FILE,[u y]);

// Volta para a pasta anterior
chdir(OLDDIR);
