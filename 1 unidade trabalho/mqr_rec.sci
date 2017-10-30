//clear all

cd("C:\Users\Álvaro\Google Drive\0 mestrado mecatronica\2017.2\INTRODUÇÃO À IDENTIFICAÇÃO DE SISTEMAS\Trabalho_final");

data = read('pHdataP2.dat', -1, 4);

total_points = size(data,"r");
num_points = 7*total_points/10;


u1 = data(1:num_points,2);
u2 = data(1:num_points,3);
y = data(1:num_points,4);

/*
u = data(1:num_points,1);
y = data(1:num_points,2);
*/


function [theta]=identifyMQR_REC(u,y,order,delay,lambda)
    
    p = 10000*eye(2*order,2*order);    
    theta = zeros(2*order,1);
    erro(1) = 0;
    fi=zeros(2*order,1);
    hist=zeros(length(y)-delay,2*order);
    
    for t=2*order:length(y)-delay
        
        for i=1:order
            fi(i,1)=y(t+delay-i);
            fi(order+i,1)=u(t-i);
        end                       
        
        
        k = p*fi/(lambda+fi'*p*fi);   //com fator de esquecimento
        //k = p*fi/(1+fi'*p*fi);
    
        //erro = y(t) - theta'*fi;
        erro = y(t+delay) - fi'*theta;        
        theta= theta+k*erro;
        
        p = (1/lambda)*(eye(2*order,2*order)-(k*fi'))*p;
        //p = (1/lambda)*(p-k*fi'*p);
        //p = (p-k*fi'*p);
        
        for i=1:order
            hist(t,i)=theta(i,1);
            hist(t,order+i)=theta(order+i,1);
        end
        
    end
    
    for i=1:2*order
        legenda(i)=string(i)+"O= "+string(theta(i));
    end  
    plot(hist);
    legend([legenda],[-1])
    title("Ordem:"+ string(order)+ "; Lambda:" +string(lambda));
          
    disp(theta);
    
endfunction
/*
order=3;
delay=6;
lambda=1;
*/

function [theta]=identifyMQR_RECM(u1,u2,y,order,delay,lambda)
    
    p = 10000*eye(3*order,3*order);    
    theta = zeros(3*order,1);
    erro(1) = 0;
    fi=zeros(3*order,1);
    hist=zeros(length(y)-delay,2*order);
    
    for t=2*order:length(y)-delay
        
        for i=1:order
            fi(i,1)=y(t+delay-i);
            fi(order+i,1)=u1(t-i);
            fi(2*order+i,1)=u2(t-i);
        end                       
        
        
        k = p*fi/(lambda+fi'*p*fi);   //com fator de esquecimento
        //k = p*fi/(1+fi'*p*fi);
    
        //erro = y(t) - theta'*fi;
        erro = y(t+delay) - fi'*theta;        
        theta= theta+k*erro;
        
        p = (1/lambda)*(eye(3*order,3*order)-(k*fi'))*p;
        //p = (1/lambda)*(p-k*fi'*p);
        //p = (p-k*fi'*p);
        
        for i=1:order
            hist(t,i)=theta(i,1);
            hist(t,order+i)=theta(order+i,1);
            hist(t,2*order+i)=theta(2*order+i,1);
        end
        
    end
    
    for i=1:3*order
        legenda(i)=string(i)+"O= "+string(theta(i));
    end   
    plot(hist);
    legend([legenda],[-1])
    title("Ordem:"+ string(order)+ "; Lambda:" +string(lambda));
        
    plot(hist);    
    disp(theta);
    
endfunction

//identifyMQR_REC(u,y,3,6,1) 

identifyMQR_RECM(u1,u2,y,1,6,0.995) 

