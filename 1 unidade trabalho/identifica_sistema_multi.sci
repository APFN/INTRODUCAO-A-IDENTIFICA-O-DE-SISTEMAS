// Identifica sistema a partir de pontos entrada/saida

// Pasta de leitura dos arquivos
DATADIR='C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\Trabalho_final';

exec('C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\Trabalho_final\identificacao.sci',-1)
exec('C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\Trabalho_final\identificacao_multi.sci',-1)

// Armazena a pasta atual
OLDDIR=pwd();
// Pasta de salvamento dos arquivos
DATADIR='C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\Trabalho_final';
if (~chdir(DATADIR)) then
    error('Folder does not exist');
end

// Arquivo a ser lido

FILE='pHdataP2.dat';

// Leitura dos dados
data = read(FILE, -1, 4);
// 70% dos pontos serao utilizados para identificacao
// Os 30% restantes serao utilizados para validacao
total_points = size(data,"r");
num_points = 7*total_points/10;

// Pontos de identificacao
// Sinal de entrada
u1 = data(1:num_points,2);
u2 = data(1:num_points,3);
// Sinal de saida
y = data(1:num_points,4);

// Pontos de verificacao
// Sinal de entrada
u1_verif = data(num_points+1:total_points,2);
u2_verif = data(num_points+1:total_points,3);
// Sinal de saida
y_verif = data(num_points+1:total_points,4);

P=[u1 u2 y];
plot(P);  
 
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
        [theta,res]=multi_identifyARX(u1,u2,y,order,delay);
        res_verif = multi_resARX(u1_verif,u2_verif,y_verif,theta,delay);
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
[theta,res]=multi_identifyARX(u1,u2,y,order,delay);
disp(theta);

disp('Criterio de AKAIKE:');
disp(best_AIC);
[val,index]=min(best_AIC);
disp('Melhor:');
disp(index);
order = index(1,1);
delay = index(1,2)-1;
[theta,res]=multi_identifyARX(u1,u2,y,order,delay);
disp(theta);


//ARMAX


disp('Modelo ARMAX:');
for (order=1:max_order)
    for (delay=0:max_delay)
        num_equacoes = num_points-order-delay;
        [theta,res]=multi_identifyARMAX(u1,u2,y,order,delay);
        res_verif = multi_resARMAX(u1_verif,u2_verif,y_verif,theta,delay);
        best_res(order,delay+1) = stdev(res_verif)^2;
        best_AIC(order,delay+1) = 2*(4*order) + num_equacoes*log(best_res(order,delay+1));
    end
end

disp('RESIDUOS:');
disp(best_res);
[val,index]=min(best_res);
disp('Melhor:');
disp(index);
order = index(1,1);
delay = index(1,2)-1;
[theta,res]=multi_identifyARMAX(u1,u2,y,order,delay);
disp(theta);

disp('Criterio de AKAIKE:');
disp(best_AIC);
[val,index]=min(best_AIC);
disp('Melhor:');
disp(index);
order = index(1,1);
delay = index(1,2)-1;
[theta,res]=multi_identifyARMAX(u1,u2,y,order,delay);
disp(theta);

// Volta para a pasta anterior
chdir(OLDDIR);
