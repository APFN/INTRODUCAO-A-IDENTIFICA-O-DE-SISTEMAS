// RESIDUOS ARX
// Calcular o erro de predicao um passo a frente (residuo) entre a saida de
// um sistema e a saida prevista pelo modelo ARX, descrito pelo vetor de
// parametros theta, para uma entrada u determinada

function res=multi_resARX(u1,u2,y,theta,delay)
    test_parametersUY(u1,y);
    test_parametersUY(u2,y);
    test_parameterT(theta,3);
    test_parameterD(delay);

    order = size(theta,"r")/3;
    num_pontos = size(u1,"r");

    // Inicializa com zeros (poderia ser dispensado)
    res = zeros(num_pontos,1);
    // Simulacao
    for (i=1:num_pontos)
        y_sim = 0.0;
        for (j=1:order)
            // Parte AR
            y_sim = y_sim + theta(j,1)*test_zero(y,i-j);
            // Parte X
            y_sim = y_sim + theta(j+order,1)*test_zero(u1,i-delay-j);
            y_sim = y_sim + theta(j+(order*2),1)*test_zero(u2,i-delay-j);
            
        end
        res(i,1) = y(i,1)-y_sim;
    end
    // Os primeiros pontos do residuo sao descartados
    res = res(1+order+delay:num_pontos,1);
endfunction

// SIMULACAO
//

// SIMULACAO ARX
// Simula a saida de um sistema ARX, descrito pelo vetor de parametros theta,
// para uma entrada u determinada
// O vetor de erros eh gerado aleatoriamente (normal, media 0.0, desvio padrao sdev)

function y=multi_simulARX(u1,u2,theta,delay,sdev)
    test_parameterU(u1);
    test_parameterT(theta,3);
    test_parameterD(delay);
    test_parameterS(sdev);

    order = size(theta,"r")/3;
    num_pontos = size(u1,"r");
    // Gera uma semente aleatoria para o gerador de numeros aleatorios
    semente=getdate("s");
    rand("seed",semente);
    // Gera o vetor de sinais de erro
    e = sdev*rand(num_pontos,1,"normal");
    // Inicializa com zeros (poderia ser dispensado)
    y = zeros(num_pontos,1);
    // Simulacao
    for (i=1:num_pontos)
        // Ruido dinamico
        y(i,1) = e(i,1);
        for (j=1:order)
            // Parte AR
            y(i,1) = y(i,1) + theta(j,1)*test_zero(y,i-j);
            // Parte X
            y(i,1) = y(i,1) + theta(j+order,1)*test_zero(u1,i-delay-j);
            y(i,1) = y(i,1) + theta(j+(order*2),1)*test_zero(u2,i-delay-j);
        end
    end
endfunction


// IDENTIFICACAO
//

// IDENTIFICACAO ARX
// Para um conjunto de pontos <u,y>, identifica o melhor sistema ARX com ordem e
// tempo de atraso (delay) dados que se adequa aos pontos. Retorna o vetor de parametros
// theta e os residuos (erro de predicao um passo a frente)

function [theta,res]=multi_identifyARX(u1,u2,y,order,delay)
    test_parametersUY(u1,y);
    test_parametersUY(u2,y);
    test_parameterO(order);
    test_parameterD(delay);

    num_pontos = size(y,"r");
    num_minimo_pontos = 3*order + delay;
    if (num_pontos < num_minimo_pontos) then
        error('The u and y parameters must have a minimal of 3*order+delay points.');
    end
    // Montagem das matrizes da equacao matricial A*theta = B
    // A = matriz de regressores
    // theta = vetor de parametros (a ser identificado)
    // B = vetor com sinais de saida
    num_equacoes = num_pontos-order-delay;
    // Inicializa com zeros (poderia ser dispensado)
    B = zeros(num_equacoes,1);
    A = zeros(num_equacoes,3*order);
    // Preenche os valores corretos dos elementos de A e B
    for (i=1:num_equacoes)
        for (j=1:order)
            A(i,j) = y(i+order+delay-j,1);
            A(i,j+order) = u1(i+order-j,1);
            A(i,j+(order*2)) = u2(i+order-j,1);
        end
        B(i,1) = y(i+order+delay,1);
    end
    // Calcula theta pela pseudoinversa: theta = inv(A'*A)*A'*B
    theta = pinv(A)*B;
    // Calcula os residuos (erros de predicao)
    y_pred = A*theta;
    res = B-y_pred;
endfunction




/////////////ARMAX/////////////////////////////

function res=multi_resARMAX(u1,u2,y,theta,delay)
    test_parametersUY(u1,y);
    test_parametersUY(u2,y);
    //test_parameterT(theta,4);
    test_parameterD(delay);

    order = size(theta,"r")/4;
    num_pontos = size(u1,"r");

    // Inicializa com zeros (poderia ser dispensado)
    res = zeros(num_pontos,1);
    // Simulacao
    for (i=1:num_pontos)
        y_sim = 0.0;
        for (j=1:order)
            // Parte AR
            y_sim = y_sim + theta(j,1)*test_zero(y,i-j);
            // Parte X
            y_sim = y_sim + theta(j+order,1)*test_zero(u1,i-delay-j);
            
            //segunda aprte X
            y_sim = y_sim + theta(j+2*order,1)*test_zero(u2,i-delay-j);
            // Parte MA
            y_sim = y_sim + theta(j+3*order,1)*test_zero(res,i-j);
                           
        end
        res(i,1) = y(i,1)-y_sim;
    end
    // Os primeiros pontos do residuo sao descartados
    res = res(1+order+delay:num_pontos,1);
endfunction




function y=multi_simulARMAX(u1,u2,theta,delay,sdev)
    test_parameterU(u1);
    //test_parameterT(theta,4);
    test_parameterD(delay);
    test_parameterS(sdev);
    
    order = size(theta,"r")/4;
    num_pontos = size(u1,"r");
    // Gera uma semente aleatoria para o gerador de numeros aleatorios
    semente=getdate("s");
    rand("seed",semente);
    // Gera o vetor de sinais de erro
    e = sdev*rand(num_pontos,1,"normal");
    // Inicializa com zeros (poderia ser dispensado)
    y = zeros(num_pontos,1);
    // Simulacao
    for (i=1:num_pontos)
        // Ruido dinamico
        y(i,1) = e(i,1);
        for (j=1:order)
            // Parte AR
            y(i,1) = y(i,1) + theta(j,1)*test_zero(y,i-j);
            // Parte X
            y(i,1) = y(i,1) + theta(j+order,1)*test_zero(u1,i-delay-j);
            y(i,1) = y(i,1) + theta(j+2*order,1)*test_zero(u2,i-delay-j);
            // Parte MA
            y(i,1) = y(i,1) + theta(j+3*order,1)*test_zero(e,i-j);
        end
    end
endfunction




function [theta,res]= multi_identifyARMAX_int(u1,u2,e,y,order,delay)
    test_parametersUY(u1,y);
    test_parameterO(order);
    test_parameterD(delay);
    if ~iscolumn(e) then
        error('The e parameter must be a column.');
    end
    if (size(e,"r") ~= size(y,"r")) then
        error('The e and y parameters must have the same size.');
    end

    num_pontos = size(y,"r");
    num_minimo_pontos = 5*order + delay;
    if (num_pontos < num_minimo_pontos) then
        error('The u, e and y parameters must have a minimal of 4*order+delay points.');
    end
    // Montagem das matrizes da equacao matricial A*theta = B
    // A = matriz de regressores
    // theta = vetor de parametros (a ser identificado)
    // B = vetor com sinais de saida
    num_equacoes = num_pontos-order-delay;
    // Inicializa com zeros (poderia ser dispensado)
    B = zeros(num_equacoes,1);
    A = zeros(num_equacoes,4*order);
    // Preenche os valores corretos dos elementos de A e B
    for (i=1:num_equacoes)
        for (j=1:order)
            A(i,j) = y(i+order+delay-j,1);
            A(i,j+order) = u1(i+order-j,1);
            A(i,j+2*order) = u2(i+order-j,1);
            A(i,j+3*order) = e(i+order+delay-j,1);
        end
        B(i,1) = y(i+order+delay,1);
    end
    // Calcula theta pela pseudoinversa: theta = inv(A'*A)*A'*B
    theta = pinv(A)*B;
    // Calcula os residuos (erros de predicao)
    y_pred = A*theta;
    res = B-y_pred;
endfunction

// IDENTIFICACAO ARMAX

function [theta,res]=multi_identifyARMAX(u1,u2,y,order,delay)
  // Os testes dos parametros serao feitos ao chamar a funcao identifyARX
  [theta,res] = multi_identifyARX(u1,u2,y,order,delay);
  residuo = stdev(res);
  residuo_ant = 2.0*residuo; // Para garantir que execute o laco ao menos uma vez
  N = 0;
  while (abs(residuo_ant-residuo)/residuo > 0.01 & N < 30)
    e_estim = [zeros(order+delay,1) ; res];
    // Os testes dos parametros serao feitos ao chamar a funcao identifyARMAX_int
    [theta,res] = multi_identifyARMAX_int(u1,u2,e_estim,y,order,delay);
    residuo_ant = residuo;
    residuo = stdev(res);
    N = N+1;
  end
endfunction

