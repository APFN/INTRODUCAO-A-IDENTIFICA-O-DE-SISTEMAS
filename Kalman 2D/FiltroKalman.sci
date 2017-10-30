clc 
clear
cd='C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\2 unidade trabalho\Kalman 2D';
FILE='dados_sensor_GPS.txt';
data = read(FILE, -1, 3);
total_points = size(data,"r");
t = data(1:total_points,1);
x = data(1:total_points,2);
y = data(1:total_points,3);

tempo = 1
dt= t(tempo)-0; //  variacao tempo

//erro esperado de sinal do satelite
Uk= 6; 
Ek= 36;

/////////MATRIZES DE COVARIANCIA//////////
Rk = [0.1 0; 0 0.1];    //covariancia 
Qk = [0.003 0;0 0.003];     //covariancia
PesoR=1;
PesoQ=1000;


Hk = [cos(32) 0;  sin(32) 0];  // modelo de obrservacao
Xkant = [0 ; 0];    //X anterior
Pkant = [0.1 0;0 0.1];  //P anterior

/////////PREDICAO//////////
Phi = [1 dt; 0 1]; // modelo de transicao de estados
Xk = Phi*Xkant;   // X predicao
Pk = Phi*Pkant*Phi' + Qk; //  predicao covariancia

/////////ATUALIZACAO DE DADOS//////////
yk = [(([x(tempo),y(tempo)]))']; //coleta dados
ykest=[(Hk*Xk)]; // dados estimados
erro_estimacao(:,tempo)=yk(:,tempo)-ykest(:,tempo);

/////////CORRECAO//////////
Kk = Pk*Hk'*inv(Hk*Pk*Hk' + Rk); //ganho de kalman
Xkest = Xk + Kk*erro_estimacao; // X correcao
Pkest = (eye(2,2) - Kk*Hk)*Pk; // P correcao

/////////CALCULO DA VELOCIDADE ESTIMADA////////// 
Vkest=[Xkest(1,tempo)/dt;Xkest(2,tempo)/dt] // velocidade                
Vreal=[(yk(1,tempo))/dt;(yk(2,tempo))/dt]; 
vel=[sqrt(((Vkest(1,tempo)))^2 +(Vkest(2,tempo))^2)]; 

/////////Atualizacao Vars. Auxs.//////////
Pkant=Pkest;
Xkant = Xkest(:,tempo);

for tempo = 2:total_points    
    dt= t(tempo)- t(tempo-1); //  variacao tempo
        
    /////////PREDICAO//////////
    Phi = [1 dt; 0 1]; //  atualizacao modelo  
    Xk = Phi*Xkant; // predicao X  
    Pk = Phi*Pkant*Phi' + Qk; //  predicao  variancia
    
    /////////ATUALIZACAO DE DADOS//////////
    yk = [yk, ([x(tempo),y(tempo)])'];//coleta dados
    ykest=[ykest, (Hk*Xk)];
    erro_estimacao=[erro_estimacao,yk(:,tempo)-ykest(:,tempo)];     
               
    /////////CORRECAO//////////        
    Kk = Pk*Hk'*inv(Hk*Pk*Hk' + Rk); // ganho de kalman     
    Xkest = [Xkest ,Xk + Kk*erro_estimacao(:,tempo)]; // correcao X
    Pkest= (eye(2,2) - Kk*Hk)*Pk; //(eye(2,2) - Kk*Hk)*Pk;
   
   /////////Atualizacao Vars. Auxs.//////////
    Pkant=Pkest;
    Xkant = Xkest(:,tempo);
    
    /////////CALCULO DA VELOCIDADE ESTIMADA//////////             
    Vkest=[Vkest, [(Xkest(1,tempo)-Xkest(1,tempo-1))/dt;(Xkest(2,tempo)-Xkest(2,tempo-1))/dt]]; 
    Vreal=[Vreal, [(yk(1,tempo)-yk(1,tempo-1))/dt;(yk(2,tempo)-yk(2,tempo-1))/dt]]; 
    vel=[vel, sqrt(((Vkest(1,tempo)))^2 +(Vkest(2,tempo))^2)]; 
 
    /////////MATRIZES DE COVARIANCIA//////////
    Qk = [(variance(Vkest(1,:)-Vreal(1,:))) 0; 0 (variance(Vkest(2,:)-Vreal(2,:)))]/PesoQ;
    Rk = [(variance(erro_estimacao(1,:))) 0; 0 (variance(erro_estimacao(2,:)))]/PesoR; 
end


////Primeira janela////
figure(1)
f=get("current_figure") ;
f.figure_size=[1000,800];

subplot(311)
title('Longitude X');
plot(x,'r');
set(gca(),"auto_clear","off")
plot(ykest(1,:),'g');
set(gca(),"auto_clear","on")
hl=legend(['Longitude';'Longitude Calculada'],[-4]);

subplot(312)
title('Latitude Y');
plot(y,'r');
set(gca(),"auto_clear","off")
plot(ykest(2,:),'g');
set(gca(),"auto_clear","on")
h2=legend(['Latitude';'Latitude Calculada'],[-4]);

subplot(313)
title('Erro de estimação');
plot(erro_estimacao(1,:),'g')
set(gca(),"auto_clear","off")
plot(erro_estimacao(2,:),'r')
set(gca(),"auto_clear","on")
h3=legend(['Erro Longitude';'Erro Latitude'],[-4]);


////Segunda janela////
figure(2)
f2=get("current_figure") ;
f2.figure_size=[1000,800];

subplot(211)
title('Latitude x Longitude');
plot(ykest(1,:),ykest(2,:), 'b');
plot(x,y, 'r');
h1=legend(['Kalman';'Real'],[-4]);


subplot(212)
title('Velocidade estimada');
plot(vel, 'g');
h2=legend(['m/s'],[-4]);






