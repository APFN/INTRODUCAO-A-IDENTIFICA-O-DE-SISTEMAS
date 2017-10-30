clear
clc
// Identifica sistema a partir de pontos entrada/saida

// Pasta de leitura dos arquivos
DATADIR='C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\Trabalho_final';

exec('C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\Trabalho_final\identificacao.sci', -1)


// Armazena a pasta atual
OLDDIR=pwd();
// Pasta de salvamento dos arquivos
DATADIR='C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\Trabalho_final';
if (~chdir(DATADIR)) then
    error('Folder does not exist');
end


// Arquivo a ser lido
FILE='dryer.dat';
// Leitura dos dados
data = read(FILE, -1, 2);
// 70% dos pontos serao utilizados para identificacao
// Os 30% restantes serao utilizados para validacao
total_points = size(data,"r");
num_points = 7*total_points/10;  //50 ou 100

// Pontos de identificacao
// Sinal de entrada
u = data(1:num_points,1);//angulo
// Sinal de saida
y = data(1:num_points,2);//bola

plot(u,'b');
plot(y,'r');

// Pontos de verificacao
// Sinal de entrada
u_verif = data(num_points+1:total_points,1);
// Sinal de saida
y_verif = data(num_points+1:total_points,2);

// Maxima ordem a ser pesquisada
max_order = 5;
// Maximo tempo de atraso a ser pesquisado
max_delay = 5;

// Cria e inicializa com zeros as matrizes de
// best_resuo e best_AIC para cada modelo ordem/delay
// Poderia ser dispensado, mas agiliza
best_res = zeros(max_order,max_delay+1);
best_AIC = zeros(max_order,max_delay+1);

// Identifica o sistema
disp(FILE);
disp('LINHAS: ordem de 1 a max_order');
disp('COLUNAS: delay de 0 a max_delay');

// Identificacao ARX
disp('Modelo ARX:');
for (order=1:max_order)
    for (delay=0:max_delay)
        num_equacoes = num_points-order-delay;
        [theta,res]=identifyARX(u,y,order,delay);
        res_verif = resARX(u_verif,y_verif,theta,delay);
        best_res(order,delay+1) = stdev(res_verif)^2;
        best_AIC(order,delay+1) = 2*(2*order) + num_equacoes*log(best_res(order,delay+1));
    end
end

disp('RESIDUOS:');
disp(best_res);
[val,index]=min(best_res);
disp('Melhor:');
disp(index);
order = index(1,1);
delay = index(1,2)-1;
[theta,res]=identifyARX(u,y,order,delay);
disp(theta);

disp('Criterio de AKAIKE:');
disp(best_AIC);
[val,index]=min(best_AIC);
disp('Melhor:');
disp(index);
order = index(1,1);
delay = index(1,2)-1;
[theta,res]=identifyARX(u,y,order,delay);
disp(theta);

// Identificacao ARMAX
disp('Modelo ARMAX:');
for (order=1:max_order)
    for (delay=0:max_delay)
        num_equacoes = num_points-order-delay;
        [theta,res]=identifyARMAX(u,y,order,delay);
        res_verif = resARMAX(u_verif,y_verif,theta,delay);
        best_res(order,delay+1) = stdev(res_verif)^2;
        best_AIC(order,delay+1) = 2*(3*order) + num_equacoes*log(best_res(order,delay+1));
    end
end

disp('RESIDUOS:');
disp(best_res);
[val,index]=min(best_res);
disp('Melhor:');
disp(index);
order = index(1,1);
delay = index(1,2)-1;
[theta,res]=identifyARMAX(u,y,order,delay);
disp(theta);

disp('Criterio de AKAIKE:');
disp(best_AIC);
[val,index]=min(best_AIC);
disp('Melhor:');
disp(index);
order = index(1,1);
delay = index(1,2)-1;
[theta,res]=identifyARMAX(u,y,order,delay);
disp(theta);

// Volta para a pasta anterior
chdir(OLDDIR);
