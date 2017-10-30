//
// FUNCOES AUXILIARES
//

// Retorna o valor do indice-esimo elemento do vetor, caso indice esteja dentro
// da dimensao do vetor; caso contrario, retorna 0.0

function [valor]=test_zero(vetor,indice)
    if (~iscolumn(vetor)) then
        error('The vetor parameter must be a column.');
    end
    if (~isscalar(indice)) then
        error('The indice parameter must be a scalar.');
    end
    if (indice < 1 | indice > size(vetor,"r")) then
        valor = 0.0;
    else
        valor = vetor(indice,1);
    end
endfunction

// Testa o parametro u

function test_parameterU(u)
    if (~iscolumn(u)) then
        error('The u parameter must be a column.');
    end
endfunction

// Testa o parametro y

function test_parameterY(y)
    if (~iscolumn(y)) then
        error('The y parameter must be a column.');
    end
endfunction

// Testa o parametro theta
// N=2 (ARX) ou N=3 (ARMAX) -> size(theta) = N*order

function test_parameterT(theta,N)
    if (~iscolumn(theta)) then
        error('The theta parameter must be a column.');
    end
    if (N~=2 & N~=3) then
        error('The N parameter must be 2 (ARX) or 3(ARMAX).');
    end
    if (size(theta,"r") < N) then
        error('The size of the theta parameter must be >= N');
    end
    if (pmodulo(size(theta,"r"),N) ~= 0) then
        error('The size of the theta parameter must be a multiple of N.');
    end
endfunction

// Testa o parametro order

function test_parameterO(order)
    if (~isscalar(order)) then
        error('The order parameter must be a scalar.');
    end
    if (order < 1) then
        error('The order parameter must be >= 1.');
    end
endfunction

// Testa o parametro delay

function test_parameterD(delay)
    if (~isscalar(delay)) then
        error('The delay parameter must be a scalar.');
    end
    if (delay < 0) then
        error('The delay parameter must be >= 0.');
    end
endfunction

// Testa o parametro sdev

function test_parameterS(sdev)
    if (~isscalar(sdev)) then
        error('The std deviation parameter must be a scalar.');
    end
endfunction

// Testa os parametros u e y

function test_parametersUY(u,y)
    test_parameterU(u);
    test_parameterY(y);
    if (size(u,"r") ~= size(y,"r")) then
        error('The u and y parameters must have the same size.');
    end
endfunction

// Adiciona ruido gaussiano de desvio padrao sdev a um vetor

function [y_noise]=add_noise(y,sdev)
    test_parameterY(y);
    test_parameterS(sdev);
    y_noise = y+sdev*rand(size(y,"r"),1,"normal");
endfunction

//
// CALCULO DE RESIDUOS
//

// RESIDUOS ARX
// Calcular o erro de predicao um passo a frente (residuo) entre a saida de
// um sistema e a saida prevista pelo modelo ARX, descrito pelo vetor de
// parametros theta, para uma entrada u determinada

function res=resARX(u,y,theta,delay)
    test_parametersUY(u,y);
    test_parameterT(theta,2);
    test_parameterD(delay);

    order = size(theta,"r")/2;
    num_pontos = size(u,"r");

    // Inicializa com zeros (poderia ser dispensado)
    res = zeros(num_pontos,1);
    // Simulacao
    for (i=1:num_pontos)
        y_sim = 0.0;
        for (j=1:order)
            // Parte AR
            y_sim = y_sim + theta(j,1)*test_zero(y,i-j);
            // Parte X
            y_sim = y_sim + theta(j+order,1)*test_zero(u,i-delay-j);
        end
        res(i,1) = y(i,1)-y_sim;
    end
    // Os primeiros pontos do residuo sao descartados
    res = res(1+order+delay:num_pontos,1);
endfunction

// RESIDUOS  ARMAX
// Calcular o erro de predicao um passo a frente (residuo) entre a saida de
// um sistema e a saida prevista pelo modelo ARMAX, descrito pelo vetor de
// parametros theta, para uma entrada u determinada

function res=resARMAX(u,y,theta,delay)
    test_parametersUY(u,y);
    test_parameterT(theta,3);
    test_parameterD(delay);

    order = size(theta,"r")/3;
    num_pontos = size(u,"r");

    // Inicializa com zeros (poderia ser dispensado)
    res = zeros(num_pontos,1);
    // Simulacao
    for (i=1:num_pontos)
        y_sim = 0.0;
        for (j=1:order)
            // Parte AR
            y_sim = y_sim + theta(j,1)*test_zero(y,i-j);
            // Parte X
            y_sim = y_sim + theta(j+order,1)*test_zero(u,i-delay-j);
            // Parte MA
            y_sim = y_sim + theta(j+2*order,1)*test_zero(res,i-j);
        end
        res(i,1) = y(i,1)-y_sim;
    end
    // Os primeiros pontos do residuo sao descartados
    res = res(1+order+delay:num_pontos,1);
endfunction

//
// SIMULACAO
//

// SIMULACAO ARX
// Simula a saida de um sistema ARX, descrito pelo vetor de parametros theta,
// para uma entrada u determinada
// O vetor de erros eh gerado aleatoriamente (normal, media 0.0, desvio padrao sdev)

function y=simulARX(u,theta,delay,sdev)
    test_parameterU(u);
    test_parameterT(theta,2);
    test_parameterD(delay);
    test_parameterS(sdev);

    order = size(theta,"r")/2;
    num_pontos = size(u,"r");
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
            y(i,1) = y(i,1) + theta(j+order,1)*test_zero(u,i-delay-j);
        end
    end
endfunction

// SIMULACAO ARMAX
// Simula a saida de um sistema ARMAX, descrito pelo vetor de parametros theta,
// para uma entrada u determinada
// O vetor de erros eh gerado aleatoriamente (normal, media 0.0, desvio padrao sdev)

function y=simulARMAX(u,theta,delay,sdev)
    test_parameterU(u);
    test_parameterT(theta,3);
    test_parameterD(delay);
    test_parameterS(sdev);
    
    order = size(theta,"r")/3;
    num_pontos = size(u,"r");
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
            y(i,1) = y(i,1) + theta(j+order,1)*test_zero(u,i-delay-j);
            // Parte MA
            y(i,1) = y(i,1) + theta(j+2*order,1)*test_zero(e,i-j);
        end
    end
endfunction

//
// IDENTIFICACAO
//

// IDENTIFICACAO ARX
// Para um conjunto de pontos <u,y>, identifica o melhor sistema ARX com ordem e
// tempo de atraso (delay) dados que se adequa aos pontos. Retorna o vetor de parametros
// theta e os residuos (erro de predicao um passo a frente)

function [theta,res]=identifyARX(u,y,order,delay)
    test_parametersUY(u,y);
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
    A = zeros(num_equacoes,2*order);
    // Preenche os valores corretos dos elementos de A e B
    for (i=1:num_equacoes)
        for (j=1:order)
            A(i,j) = y(i+order+delay-j,1);
            A(i,j+order) = u(i+order-j,1);
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

// Funcao interna (nao deve ser utilizada para identificar)
// Identifica os coeficientes supondo que o vetor de erro eh conhecido
// Similar aa identificacao de modelos ARX
// Nao pode ser utilizada diretamente porque o vetor de erro e nunca eh conhecido

function [theta,res]=identifyARMAX_int(u,e,y,order,delay)
    test_parametersUY(u,y);
    test_parameterO(order);
    test_parameterD(delay);
    if ~iscolumn(e) then
        error('The e parameter must be a column.');
    end
    if (size(e,"r") ~= size(y,"r")) then
        error('The e and y parameters must have the same size.');
    end

    num_pontos = size(y,"r");
    num_minimo_pontos = 4*order + delay;
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
    A = zeros(num_equacoes,3*order);
    // Preenche os valores corretos dos elementos de A e B
    for (i=1:num_equacoes)
        for (j=1:order)
            A(i,j) = y(i+order+delay-j,1);
            A(i,j+order) = u(i+order-j,1);
            A(i,j+2*order) = e(i+order+delay-j,1);
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
// Essa e a funcao que deve ser utilizada para identificacao ARMAX
// 
// Para um conjunto de pontos <u,y>, identifica o melhor sistema ARMAX com ordem e
// tempo de atraso (delay) dados que se adequa aos pontos. Retorna o vetor de parametros
// theta e os residuos (erro de predicao um passo a frente)
// Para o calculo dos parametros, usa o vetor de residuos do passo anterior como se
// fosse o vetor de erros. Com os pontos <u,e,y>, calcula os coeficientes ARMAX e o
// novo vetor de residuos, o que permite nova iteracao ate que o erro quadratico medio
// (media quadratica dos residuos) nao se reduza mais de maneira significativa.
// Ao final, retorna o vetor de parametros theta e os residuos (erro de predicao
// um passo a frente) da última iteracao.

function [theta,res]=identifyARMAX(u,y,order,delay)
  // Os testes dos parametros serao feitos ao chamar a funcao identifyARX
  [theta,res] = identifyARX(u,y,order,delay);
  residuo = stdev(res);
  residuo_ant = 2.0*residuo; // Para garantir que execute o laco ao menos uma vez
  N = 0;
  while (abs(residuo_ant-residuo)/residuo > 0.01 & N < 30)
    e_estim = [zeros(order+delay,1) ; res];
    // Os testes dos parametros serao feitos ao chamar a funcao identifyARMAX_int
    [theta,res] = identifyARMAX_int(u,e_estim,y,order,delay);
    residuo_ant = residuo;
    residuo = stdev(res);
    N = N+1;
  end
endfunction
